// The Swift Programming Language
// https://docs.swift.org/swift-book

import OpenFeature
import Foundation

// swiftlint:disable:next identifier_name
public let userDefaultsOpenFeatureProviderSuiteNameKey: String = "userDefaultsOpenFeatureProviderSuiteNameKey"
// swiftlint:disable:next identifier_name
public let userDefaultsOpenFeatureProviderOldContextKey: String = "userDefaultsOpenFeatureProviderOldContextKey"
// swiftlint:disable:next identifier_name
public let userDefaultsOpenFeatureProviderNewContextKey: String = "userDefaultsOpenFeatureProviderNewContextKey"

public final class UserDefaultsOpenFeatureProvider: FeatureProvider {
    /// DateFormatter to format date value
    public static let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        // swiftlint:disable:next force_unwrapping
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)!
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")

        return dateFormatter
    }()

    /// Context used for default
    private var defaultDefaults: UserDefaults?

    public private(set) var defaultContext: EvaluationContext?

    /// Current provider status
    public private(set) var status: UserDefaultsOpenFeatureProviderStatus = .notReady {
        didSet {
            switch status {
            case .notReady:
                break
            case .ready:
                emit(event: .ready)
            case .stale:
                emit(event: .stale)
            case .error:
                emit(event: .error)
            }
        }
    }

    /// Hooks for this provider
    public var hooks: [any Hook] = []

    /// Meta data for this provider
    public let metadata: ProviderMetadata = UserDefaultsOpenFeatureProviderMetadata()

    public init() {}

    /// Called by OpenFeatureAPI whenever the new Provider is registered
    ///
    /// - Parameter initialContext: context to initialize provider
    public func initialize(initialContext: EvaluationContext?) {
        self.defaultContext = initialContext

        guard let initialContext else {
            defaultDefaults = .standard
            status = .ready
            return
        }

        guard
            case .string(let suiteName) = initialContext
                .getValue(key: userDefaultsOpenFeatureProviderSuiteNameKey) else {
            status = .error
            return
        }

        defaultDefaults = UserDefaults(suiteName: suiteName)
        status = .ready
    }

    /// Change context for provider
    ///
    /// - Parameters:
    ///   - oldContext: old context
    ///   - newContext: new context to set
    public func onContextSet(oldContext: EvaluationContext?, newContext: EvaluationContext) {
        initialize(initialContext: newContext)

        emit(event: .configurationChanged, details: [
            userDefaultsOpenFeatureProviderOldContextKey: oldContext as Any,
            userDefaultsOpenFeatureProviderNewContextKey: newContext as Any
        ])
    }

    /// Evaluate the flag for key as Boolean value
    ///
    /// - Parameters:
    ///   - key: Key for the flag
    ///   - defaultValue: Default value for the flag
    ///   - context: Context for evaluation. If not set, initialized context is used.
    /// - Returns: Evaluation result for the flag
    public func getBooleanEvaluation(key: String, defaultValue: Bool, context: EvaluationContext?) throws -> ProviderEvaluation<Bool> {
        let defaults = try getCurrentUserDefaults(with: context)
        guard defaults.has(key) else {
            throw OpenFeatureError.flagNotFoundError(key: key)
        }

        let value = defaults.bool(forKey: key)
        return ProviderEvaluation(value: value, variant: .boolean(value), reason: .cached)
    }

    /// Evaluate the flag for key as String value
    ///
    /// - Parameters:
    ///   - key: Key for the flag
    ///   - defaultValue: Default value for the flag
    ///   - context: Context for evaluation. If not set, initialized context is used.
    /// - Returns: Evaluation result for the flag
    public func getStringEvaluation(key: String, defaultValue: String, context: EvaluationContext?) throws -> ProviderEvaluation<String> {
        let defaults = try getCurrentUserDefaults(with: context)
        guard defaults.has(key) else {
            throw OpenFeatureError.flagNotFoundError(key: key)
        }

        let value: String
        let reason: Reason
        if let wrappedValue = defaults.string(forKey: key) {
            value = wrappedValue
            reason = .cached
        } else {
            value = defaultValue
            reason = .defaultReason
        }

        return ProviderEvaluation(value: value, variant: .string(value), reason: reason)
    }

    /// Evaluate the flag for key as Int64 value
    ///
    /// - Parameters:
    ///   - key: Key for the flag
    ///   - defaultValue: Default value for the flag
    ///   - context: Context for evaluation. If not set, initialized context is used.
    /// - Returns: Evaluation result for the flag
    public func getIntegerEvaluation(key: String, defaultValue: Int64, context: EvaluationContext?) throws -> ProviderEvaluation<Int64> {
        let defaults = try getCurrentUserDefaults(with: context)
        guard defaults.has(key) else {
            throw OpenFeatureError.flagNotFoundError(key: key)
        }

        let value = Int64(defaults.integer(forKey: key))
        return ProviderEvaluation(value: value, variant: .integer(value), reason: .cached)
    }

    /// Evaluate the flag for key as Double value
    ///
    /// - Parameters:
    ///   - key: Key for the flag
    ///   - defaultValue: Default value for the flag
    ///   - context: Context for evaluation. If not set, initialized context is used.
    /// - Returns: Evaluation result for the flag
    public func getDoubleEvaluation(key: String, defaultValue: Double, context: EvaluationContext?) throws -> ProviderEvaluation<Double> {
        let defaults = try getCurrentUserDefaults(with: context)
        guard defaults.has(key) else {
            throw OpenFeatureError.flagNotFoundError(key: key)
        }

        let value = defaults.double(forKey: key)
        return ProviderEvaluation(value: value, variant: .double(value), reason: .cached)
    }

    /// Evaluate the flag for key as Date value
    ///
    /// - Parameters:
    ///   - key: Key for the flag
    ///   - defaultValue: Default value for the flag
    ///   - context: Context for evaluation. If not set, initialized context is used.
    /// - Returns: Evaluation result for the flag
    public func getDateEvaluation(key: String, defaultValue: Date, context: EvaluationContext?) throws -> ProviderEvaluation<Date> {
        let defaults = try getCurrentUserDefaults(with: context)
        guard defaults.has(key) else {
            throw OpenFeatureError.flagNotFoundError(key: key)
        }

        guard let value = defaults.object(forKey: key) as? Date else {
            throw OpenFeatureError.parseError(message: "Cannot get datetime string from UserDefaults with key: \(key)")
        }

        return ProviderEvaluation(value: value, variant: .date(value), reason: .cached)
    }

    /// Evaluate the flag for key as List of `Value`
    ///
    /// - Parameters:
    ///   - key: Key for the flag
    ///   - defaultValue: Default value for the flag
    ///   - context: Context for evaluation. If not set, initialized context is used.
    /// - Returns: Evaluation result for the flag
    public func getListEvaluation(key: String, defaultValue: [Value], context: EvaluationContext?) throws -> ProviderEvaluation<[Value]> {
        let defaults = try getCurrentUserDefaults(with: context)
        guard defaults.has(key) else {
            throw OpenFeatureError.flagNotFoundError(key: key)
        }

        guard
            let anys = defaults.object(forKey: key) as? [Any],
            let array = try? anys.wrapInValue() else {
            throw OpenFeatureError.parseError(
                message: "Cannot get collection of Value type from UserDefaults with key: \(key)"
            )
        }

        return ProviderEvaluation(value: array, variant: .list(array), reason: .cached)
    }

    /// Evaluate the flag for key as `Value` dictionary
    ///
    /// - Parameters:
    ///   - key: Key for the flag
    ///   - defaultValue: Default value for the flag
    ///   - context: Context for evaluation. If not set, initialized context is used.
    /// - Returns: Evaluation result for the flag
    public func getStructureEvaluation(key: String, defaultValue: [String: Value], context: EvaluationContext?) throws -> ProviderEvaluation<[String: Value]> {
        let defaults = try getCurrentUserDefaults(with: context)
        guard defaults.has(key) else {
            throw OpenFeatureError.flagNotFoundError(key: key)
        }

        guard let dictionary = defaults.dictionary(forKey: key) else {
            throw OpenFeatureError.parseError(
                message: "Cannot get data as a `Dictionary<String, Any>` object from UserDefaults with key: \(key)"
            )
        }

        let wrappedDictionary = try dictionary.wrapInValue()
        return ProviderEvaluation(value: wrappedDictionary, variant: .structure(wrappedDictionary), reason: .cached)
    }

    // swiftlint:disable function_body_length
    /// Evaluate the flag for key as `Value`
    ///
    /// - Parameters:
    ///   - key: Key for the flag
    ///   - defaultValue: Default value for the flag
    ///   - context: Context for evaluation. If not set, initialized context is used.
    /// - Returns: Evaluation result for the flag
    public func getObjectEvaluation(key: String, defaultValue: Value, context: EvaluationContext?) throws -> ProviderEvaluation<Value> {
        let defaults = try getCurrentUserDefaults(with: context)
        guard let object = defaults.object(forKey: key) else {
            let error = OpenFeatureError.flagNotFoundError(key: key)
            return try returnNullEvaluationIfDefaultValueIsNull(defaultValue: defaultValue, withError: error)
        }

        switch TypeDetector.detectType(from: object) {
        case .boolean:
            let value = defaultValue.asBoolean() ?? false
            guard
                let evaluation = try? getBooleanEvaluation(key: key, defaultValue: value, context: context).asValueEvaluation else {
                let error = OpenFeatureError.typeMismatchError
                return try returnNullEvaluationIfDefaultValueIsNull(defaultValue: defaultValue, withError: error)
            }
            return evaluation

        case .string:
            let value = defaultValue.asString() ?? ""
            guard let evaluation = try? getStringEvaluation(key: key, defaultValue: value, context: context).asValueEvaluation else {
                let error = OpenFeatureError.typeMismatchError
                return try returnNullEvaluationIfDefaultValueIsNull(defaultValue: defaultValue, withError: error)
            }
            return evaluation

        case .integer:
            let value = defaultValue.asInteger() ?? 0
            guard let evaluation = try? getIntegerEvaluation(key: key, defaultValue: value, context: context).asValueEvaluation else {
                let error = OpenFeatureError.typeMismatchError
                return try returnNullEvaluationIfDefaultValueIsNull(defaultValue: defaultValue, withError: error)
            }
            return evaluation

        case .double:
            let value = defaultValue.asDouble() ?? 0.0
            guard let evaluation = try? getDoubleEvaluation(key: key, defaultValue: value, context: context).asValueEvaluation else {
                let error = OpenFeatureError.typeMismatchError
                return try returnNullEvaluationIfDefaultValueIsNull(defaultValue: defaultValue, withError: error)
            }
            return evaluation

        case .date:
            let value = defaultValue.asDate() ?? Date()
            guard let evaluation = try? getDateEvaluation(key: key, defaultValue: value, context: context).asValueEvaluation else {
                let error = OpenFeatureError.typeMismatchError
                return try returnNullEvaluationIfDefaultValueIsNull(defaultValue: defaultValue, withError: error)
            }
            return evaluation

        case .array:
            let value = defaultValue.asList() ?? []
            guard let evaluation = try? getListEvaluation(key: key, defaultValue: value, context: context).asValueEvaluation else {
                let error = OpenFeatureError.typeMismatchError
                return try returnNullEvaluationIfDefaultValueIsNull(defaultValue: defaultValue, withError: error)
            }
            return evaluation

        case .dictionary:
            let value = defaultValue.asStructure() ?? [:]
            guard let evaluation = try? getStructureEvaluation(key: key, defaultValue: value, context: context).asValueEvaluation else {
                let error = OpenFeatureError.typeMismatchError
                return try returnNullEvaluationIfDefaultValueIsNull(defaultValue: defaultValue, withError: error)
            }
            return evaluation

        case .null:
            return ProviderEvaluation(value: .null, variant: .null, reason: .cached)

        case .unknown:
            throw OpenFeatureError.typeMismatchError
        }
    }
    // swiftlint:enable function_body_length

    /// Returns a default value or throws an exception, depending on the arguments specified
    ///
    /// - Parameters:
    ///   - defaultValue: Default value to be inspected
    ///   - error: Error to throw
    /// - Returns: If default value is null, just return `Value.null`. If not, throw error.
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
    func getCurrentUserDefaults(with context: EvaluationContext?) throws -> UserDefaults {
        if let context {
            return try getUserDefaults(with: context)
        } else if let defaultContext {
            return try getUserDefaults(with: defaultContext)
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
            let contextObject = context.asObjectMap()
            throw OpenFeatureError.generalError(
                message: "Cannot initialize UserDefaults with suite name: \(suiteName), in context: \(contextObject)"
            )
        }
    }
}

extension UserDefaultsOpenFeatureProvider {
    func emit(event: ProviderEvent, error: Error? = nil, details: [String: Any]? = nil) {
        OpenFeatureAPI.shared.emitEvent(event, provider: self, error: error, details: details)
    }
}
