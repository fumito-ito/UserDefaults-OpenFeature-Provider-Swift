//
//  UserDefaultsOpenFeatureProviderSetterExpansion.swift
//  
//
//  Created by Fumito Ito on 2023/12/27.
//

import Foundation
import OpenFeature

extension UserDefaultsOpenFeatureProvider {
    private static let jsonEncoder = JSONEncoder()
    
    /// Sets the Bool value to the provider's specified key as a flag
    ///
    /// If a value is set through this function, the `PROVIDER_CONFIGURATION_CHANGED` event is sent.
    ///
    /// - Parameters:
    ///   - key: key to set value
    ///   - condition: function to calculate the value to be set based on the targeting key given as an argument.
    ///   - context: context for provider
    public func setBooleanValue(forKey key: String, givenCondition condition: @escaping ((_ targetingKey: String) -> Bool), with context: EvaluationContext? = nil) throws {
        guard let context = [context, defaultContext].compactMap({ $0 }).first else {
            throw OpenFeatureError.generalError(message: "`\(#function)` needs context or initial context to define targeting key")
        }

        let defaults = try getCurrentUserDefaults(with: context)
        let value = condition(context.getTargetingKey())
        defaults.set(value, forKey: key)
        emit(event: .configurationChanged, details: [key: value])
    }

    /// Sets the String value to the provider's specified key as a flag
    ///
    /// If a value is set through this function, the `PROVIDER_CONFIGURATION_CHANGED` event is sent.
    ///
    /// - Parameters:
    ///   - key: key to set value
    ///   - condition: function to calculate the value to be set based on the targeting key given as an argument.
    ///   - context: context for provider
    public func setStringValue(forKey key: String, givenCondition condition: @escaping ((_ targetingKey: String) -> String), with context: EvaluationContext? = nil) throws {
        guard let context = [context, defaultContext].compactMap({ $0 }).first else {
            throw OpenFeatureError.generalError(message: "`\(#function)` needs context or initial context to define targeting key")
        }

        let defaults = try getCurrentUserDefaults(with: context)
        let value = condition(context.getTargetingKey())
        defaults.set(value, forKey: key)
        emit(event: .configurationChanged, details: [key: value])
    }

    /// Sets the Int64 value to the provider's specified key as a flag
    ///
    /// If a value is set through this function, the `PROVIDER_CONFIGURATION_CHANGED` event is sent.
    ///
    /// - Parameters:
    ///   - key: key to set value
    ///   - condition: function to calculate the value to be set based on the targeting key given as an argument.
    ///   - context: context for provider
    public func setIntegerValue(forKey key: String, givenCondition condition: @escaping ((_ targetingKey: String) -> Int64), with context: EvaluationContext? = nil) throws {
        guard let context = [context, defaultContext].compactMap({ $0 }).first else {
            throw OpenFeatureError.generalError(message: "`\(#function)` needs context or initial context to define targeting key")
        }

        let defaults = try getCurrentUserDefaults(with: context)
        let value = condition(context.getTargetingKey())
        defaults.set(value, forKey: key)
        emit(event: .configurationChanged, details: [key: value])
    }

    /// Sets the Double value to the provider's specified key as a flag
    ///
    /// If a value is set through this function, the `PROVIDER_CONFIGURATION_CHANGED` event is sent.
    ///
    /// - Parameters:
    ///   - key: key to set value
    ///   - condition: function to calculate the value to be set based on the targeting key given as an argument.
    ///   - context: context for provider
    public func setDoubleValue(forKey key: String, givenCondition condition: @escaping ((_ targetingKey: String) -> Double), with context: EvaluationContext? = nil) throws {
        guard let context = [context, defaultContext].compactMap({ $0 }).first else {
            throw OpenFeatureError.generalError(message: "`\(#function)` needs context or initial context to define targeting key")
        }

        let defaults = try getCurrentUserDefaults(with: context)
        let value = condition(context.getTargetingKey())
        defaults.set(value, forKey: key)
        emit(event: .configurationChanged, details: [key: value])
    }

    /// Sets the Date value to the provider's specified key as a flag
    ///
    /// If a value is set through this function, the `PROVIDER_CONFIGURATION_CHANGED` event is sent.
    ///
    /// - Parameters:
    ///   - key: key to set value
    ///   - condition: function to calculate the value to be set based on the targeting key given as an argument.
    ///   - context: context for provider
    public func setDateValue(forKey key: String, givenCondition condition: @escaping ((_ targetingKey: String) -> Date), with context: EvaluationContext? = nil) throws {
        guard let context = [context, defaultContext].compactMap({ $0 }).first else {
            throw OpenFeatureError.generalError(message: "`\(#function)` needs context or initial context to define targeting key")
        }

        let defaults = try getCurrentUserDefaults(with: context)
        let value = condition(context.getTargetingKey())
        defaults.set(value, forKey: key)
        emit(event: .configurationChanged, details: [key: value])
    }

    /// Sets the List value to the provider's specified key as a flag
    ///
    /// If a value is set through this function, the `PROVIDER_CONFIGURATION_CHANGED` event is sent.
    /// The values in this array must be values that can be converted to `OpenFeature.Value`.
    ///
    /// - Parameters:
    ///   - key: key to set value
    ///   - condition: function to calculate the value to be set based on the targeting key given as an argument.
    ///   - context: context for provider
    public func setListValue(forKey key: String, givenCondition condition: @escaping ((_ targetingKey: String) -> [Any]), with context: EvaluationContext? = nil) throws {
        guard let context = [context, defaultContext].compactMap({ $0 }).first else {
            throw OpenFeatureError.generalError(message: "`\(#function)` needs context or initial context to define targeting key")
        }

        let defaults = try getCurrentUserDefaults(with: context)
        let value = condition(context.getTargetingKey())
        defaults.set(value, forKey: key)
        emit(event: .configurationChanged, details: [key: value])
    }

    /// Sets the Dictionary value to the provider's specified key as a flag
    ///
    /// If a value is set through this function, the `PROVIDER_CONFIGURATION_CHANGED` event is sent.
    /// The values in this dictionary must be values that can be converted to `OpenFeature.Value`.
    ///
    /// - Parameters:
    ///   - key: key to set value
    ///   - condition: function to calculate the value to be set based on the targeting key given as an argument.
    ///   - context: context for provider
    public func setStructureValue(forKey key: String, givenCondition condition: @escaping ((_ targetingKey: String) -> [String: Any]), with context: EvaluationContext? = nil) throws {
        guard let context = [context, defaultContext].compactMap({ $0 }).first else {
            throw OpenFeatureError.generalError(message: "`\(#function)` needs context or initial context to define targeting key")
        }

        let defaults = try getCurrentUserDefaults(with: context)
        let value = condition(context.getTargetingKey())
        defaults.set(value, forKey: key)
        emit(event: .configurationChanged, details: [key: value])
    }
}
