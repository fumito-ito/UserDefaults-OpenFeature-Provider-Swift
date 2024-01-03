// The Swift Programming Language
// https://docs.swift.org/swift-book

import OpenFeature
import Foundation

public let userDefaultsOpenFeatureProviderSuiteNameKey: String = "userDefaultsOpenFeatureProviderSuiteNameKey"

public final class UserDefaultsOpenFeatureProvider: FeatureProvider {

    public static let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)!
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")

        return dateFormatter
    }()

    private var defaultDefaults: UserDefaults?

    public private(set) var initialContext: EvaluationContext?

    // TODO: Hooksのハンドリングを書く
    public var hooks: [any Hook] = []

    public let metadata: ProviderMetadata = UserDefaultsOpenFeatureProviderMetadata()

    public func initialize(initialContext: EvaluationContext?) {
        self.initialContext = initialContext

        guard let initialContext, case .string(let suiteName) = initialContext.getValue(key: userDefaultsOpenFeatureProviderSuiteNameKey) else {
            defaultDefaults = .standard
            return
        }

        defaultDefaults = UserDefaults(suiteName: suiteName)

        // TODO: emit `ready`
    }
    
    public func onContextSet(oldContext: EvaluationContext?, newContext: EvaluationContext) {
        initialize(initialContext: newContext)
        // TODO: emit `configurationChanged`
    }
    
    public func getBooleanEvaluation(key: String, defaultValue: Bool, context: EvaluationContext?) throws -> ProviderEvaluation<Bool> {
        let defaults = try getCurrentUserDefaults(with: context)
        guard defaults.has(key) else {
            throw OpenFeatureError.flagNotFoundError(key: key)
        }

        let value = defaults.bool(forKey: key)
        return ProviderEvaluation(value: value, variant: .boolean(value), reason: .cached)
    }
    
    public func getStringEvaluation(key: String, defaultValue: String, context: EvaluationContext?) throws -> ProviderEvaluation<String> {
        let defaults = try getCurrentUserDefaults(with: context)
        guard defaults.has(key) else {
            throw OpenFeatureError.flagNotFoundError(key: key)
        }

        let value: String
        let reason: Reason
        if let v = defaults.string(forKey: key) {
            value = v
            reason = .cached
        } else {
            value = defaultValue
            reason = .defaultReason
        }

        return ProviderEvaluation(value: value, variant: .string(value), reason: reason)
    }
    
    public func getIntegerEvaluation(key: String, defaultValue: Int64, context: EvaluationContext?) throws -> ProviderEvaluation<Int64> {
        let defaults = try getCurrentUserDefaults(with: context)
        guard defaults.has(key) else {
            throw OpenFeatureError.flagNotFoundError(key: key)
        }

        let value = Int64(defaults.integer(forKey: key))
        return ProviderEvaluation(value: value, variant: .integer(value), reason: .cached)
    }
    
    public func getDoubleEvaluation(key: String, defaultValue: Double, context: EvaluationContext?) throws -> ProviderEvaluation<Double> {
        let defaults = try getCurrentUserDefaults(with: context)
        guard defaults.has(key) else {
            throw OpenFeatureError.flagNotFoundError(key: key)
        }

        let value = defaults.double(forKey: key)
        return ProviderEvaluation(value: value, variant: .double(value), reason: .cached)
    }

    public func getDateEvaluation(key: String, defaultValue: Date, context: EvaluationContext?) throws -> ProviderEvaluation<Date> {
        let defaults = try getCurrentUserDefaults(with: context)
        guard defaults.has(key) else {
            throw OpenFeatureError.flagNotFoundError(key: key)
        }

        guard let deteString = defaults.string(forKey: key),
              let value = Self.dateFormatter.date(from: deteString) else {
            throw OpenFeatureError.parseError(message: "Cannot get datetime string from UserDefaults with key: \(key)")
        }

        return ProviderEvaluation(value: value, variant: .date(value), reason: .cached)
    }

    public func getListEvaluation(key: String, defaultValue: [Value], context: EvaluationContext?) throws -> ProviderEvaluation<[Value]> {
        let defaults = try getCurrentUserDefaults(with: context)
        guard defaults.has(key) else {
            throw OpenFeatureError.flagNotFoundError(key: key)
        }

        guard let jsonString = defaults.string(forKey: key),
              let jsonData = jsonString.data(using: .utf8),
              let value = try? JSONDecoder().decode(Value.self, from: jsonData),
              case .list(let array) = value else {
            throw OpenFeatureError.parseError(message: "Cannot get collection of Value type from UserDefaults with key: \(key)")
        }

        return ProviderEvaluation(value: array, variant: .list(array), reason: .cached)
    }

    public func getStructureEvaluation(key: String, defaultValue: [String: Value], context: EvaluationContext?) throws -> ProviderEvaluation<[String: Value]> {
        let defaults = try getCurrentUserDefaults(with: context)
        guard defaults.has(key) else {
            throw OpenFeatureError.flagNotFoundError(key: key)
        }

        guard let dictionary = defaults.dictionary(forKey: key) else {
            throw OpenFeatureError.parseError(message: "Cannot get data as a `Dictionary<String, Any>` object from UserDefaults with key: \(key)")
        }

        let wrappedDictionary = try dictionary.wrapInValue()
        return ProviderEvaluation(value: wrappedDictionary, variant: .structure(wrappedDictionary), reason: .cached)
    }

    public func getObjectEvaluation(key: String, defaultValue: Value, context: EvaluationContext?) throws -> ProviderEvaluation<Value> {
        let defaults = try getCurrentUserDefaults(with: context)
        guard let object = defaults.object(forKey: key) else {
            let error = OpenFeatureError.flagNotFoundError(key: key)
            return try returnNullEvaluationIfDefaultValueIsNull(defaultValue: defaultValue, withError: error)
        }

        switch Self.detectType(from: object) {
        case .boolean:
            guard let value = defaultValue == .null ? false : defaultValue.asBoolean() else {
                let error = OpenFeatureError.typeMismatchError
                return try returnNullEvaluationIfDefaultValueIsNull(defaultValue: defaultValue, withError: error)
            }
            return try getBooleanEvaluation(key: key, defaultValue: value, context: context).asValueEvaluation

        case .string:
            guard let value = defaultValue == .null ? "" : defaultValue.asString() else {
                let error = OpenFeatureError.typeMismatchError
                return try returnNullEvaluationIfDefaultValueIsNull(defaultValue: defaultValue, withError: error)
            }
            return try getStringEvaluation(key: key, defaultValue: value, context: context).asValueEvaluation

        case .integer:
            guard let value = defaultValue == .null ? 0 : defaultValue.asInteger() else {
                let error = OpenFeatureError.typeMismatchError
                return try returnNullEvaluationIfDefaultValueIsNull(defaultValue: defaultValue, withError: error)
            }
            return try getIntegerEvaluation(key: key, defaultValue: value, context: context).asValueEvaluation

        case .double:
            guard let value = defaultValue == .null ? 0.0 : defaultValue.asDouble() else {
                let error = OpenFeatureError.typeMismatchError
                return try returnNullEvaluationIfDefaultValueIsNull(defaultValue: defaultValue, withError: error)
            }
            return try getDoubleEvaluation(key: key, defaultValue: value, context: context).asValueEvaluation

        case .date:
            guard let value = defaultValue == .null ? Date() : defaultValue.asDate() else {
                let error = OpenFeatureError.typeMismatchError
                return try returnNullEvaluationIfDefaultValueIsNull(defaultValue: defaultValue, withError: error)
            }
            return try getDateEvaluation(key: key, defaultValue: value, context: context).asValueEvaluation

        case .array:
            guard let value = defaultValue == .null ? [] : defaultValue.asList() else {
                let error = OpenFeatureError.typeMismatchError
                return try returnNullEvaluationIfDefaultValueIsNull(defaultValue: defaultValue, withError: error)
            }
            return try getListEvaluation(key: key, defaultValue: value, context: context).asValueEvaluation

        case .dictionary:
            guard let value = defaultValue == .null ? [:] : defaultValue.asStructure() else {
                // TODO: このエラーを使うかは一考の余地がある
                let error = OpenFeatureError.typeMismatchError
                return try returnNullEvaluationIfDefaultValueIsNull(defaultValue: defaultValue, withError: error)
            }
            return try getStructureEvaluation(key: key, defaultValue: value, context: context).asValueEvaluation

        case .null:
            return ProviderEvaluation(value: .null, variant: .null, reason: .cached)

        case .unknown:
            throw OpenFeatureError.typeMismatchError
        }
    }

    private func returnNullEvaluationIfDefaultValueIsNull(defaultValue: Value, withError error: OpenFeatureError) throws -> ProviderEvaluation<Value> {
        if defaultValue.isNull() {
            return ProviderEvaluation(
                value: .null,
                variant: defaultValue.description,
                reason: Reason.defaultReason.rawValue
            )
        } else {
            throw error
        }
    }
}

extension UserDefaultsOpenFeatureProvider {
    enum DetectedType {
        case boolean
        case string
        case integer
        case double
        case date
        case array
        case dictionary
        case null
        case unknown
    }

    static func detectType(from object: Any) -> DetectedType {
        switch CFGetTypeID(object as CFTypeRef) {
        case CFBooleanGetTypeID():
            return .boolean

        case CFStringGetTypeID():
            return .string

        case CFNumberGetTypeID():
            let numberType = CFNumberGetType((object as! CFNumber))
            switch numberType {
            case
                    .sInt8Type,
                    .sInt16Type,
                    .sInt32Type,
                    .sInt64Type,
                    .charType,
                    .shortType,
                    .intType,
                    .longType,
                    .longLongType,
                    .cfIndexType,
                    .nsIntegerType:
                return .integer

            case
                    .float32Type,
                    .float64Type,
                    .floatType,
                    .doubleType,
                    .cgFloatType:
                return .double

            @unknown default:
                return .unknown
            }

        case CFDateGetTypeID():
            return .date

        case CFArrayGetTypeID():
            return .array

        case CFDictionaryGetTypeID():
            return .dictionary

        case CFNullGetTypeID():
            return .null

        default:
            return .unknown
        }
    }
}

extension UserDefaultsOpenFeatureProvider {
    public func getCurrentUserDefaults(with context: EvaluationContext?) throws -> UserDefaults {
        if let context {
            return try getUserDefaults(with: context)
        } else if let initialContext {
            return try getUserDefaults(with: initialContext)
        } else if let defaultDefaults {
            return defaultDefaults
        } else {
            throw OpenFeatureError.providerNotReadyError
        }
    }

    private func getUserDefaults(with context: EvaluationContext) throws -> UserDefaults {
        guard case .string(let suiteName) = context.getValue(key: userDefaultsOpenFeatureProviderSuiteNameKey) else {
            return .standard
        }

        if let defaults = UserDefaults(suiteName: suiteName) {
            return defaults
        } else {
            throw OpenFeatureError.generalError(message: "Cannot initialize UserDefaults with suite name: \(suiteName), in context: \(context.asObjectMap())")
        }
    }

    func emit(event: ProviderEvent, error: Error? = nil, details: [String: Any]? = nil) {
        OpenFeatureAPI.shared.emitEvent(event, provider: self, error: error, details: details)
    }
}
