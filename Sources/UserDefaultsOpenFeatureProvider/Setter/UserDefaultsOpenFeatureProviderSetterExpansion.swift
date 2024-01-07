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

    func setBooleanValue(forKey key: String, givenCondition condition: @escaping ((_ targetingKey: String) -> Bool), with context: EvaluationContext?) throws {
        guard let context = [context, defaultContext].compactMap({ $0 }).first else {
            throw OpenFeatureError.generalError(message: "`\(#function)` needs context or initial context to define targeting key")
        }

        let defaults = try getCurrentUserDefaults(with: context)
        defaults.set(condition(context.getTargetingKey()), forKey: key)
    }

    func setStringValue(forKey key: String, givenCondition condition: @escaping ((_ targetingKey: String) -> String), with context: EvaluationContext?) throws {
        guard let context = [context, defaultContext].compactMap({ $0 }).first else {
            throw OpenFeatureError.generalError(message: "`\(#function)` needs context or initial context to define targeting key")
        }

        let defaults = try getCurrentUserDefaults(with: context)
        defaults.set(condition(context.getTargetingKey()), forKey: key)
    }

    func setIntegerValue(forKey key: String, givenCondition condition: @escaping ((_ targetingKey: String) -> Int64), with context: EvaluationContext?) throws {
        guard let context = [context, defaultContext].compactMap({ $0 }).first else {
            throw OpenFeatureError.generalError(message: "`\(#function)` needs context or initial context to define targeting key")
        }

        let defaults = try getCurrentUserDefaults(with: context)
        defaults.set(condition(context.getTargetingKey()), forKey: key)
    }

    func setDoubleValue(forKey key: String, givenCondition condition: @escaping ((_ targetingKey: String) -> Double), with context: EvaluationContext?) throws {
        guard let context = [context, defaultContext].compactMap({ $0 }).first else {
            throw OpenFeatureError.generalError(message: "`\(#function)` needs context or initial context to define targeting key")
        }

        let defaults = try getCurrentUserDefaults(with: context)
        defaults.set(condition(context.getTargetingKey()), forKey: key)
    }

    func setDateValue(forKey key: String, givenCondition condition: @escaping ((_ targetingKey: String) -> Date), with context: EvaluationContext?) throws {
        guard let context = [context, defaultContext].compactMap({ $0 }).first else {
            throw OpenFeatureError.generalError(message: "`\(#function)` needs context or initial context to define targeting key")
        }

        let defaults = try getCurrentUserDefaults(with: context)
        let date = condition(context.getTargetingKey())
        defaults.set(date, forKey: key)
    }

    func setListValue(forKey key: String, givenCondition condition: @escaping ((_ targetingKey: String) -> [Any]), with context: EvaluationContext?) throws {
        guard let context = [context, defaultContext].compactMap({ $0 }).first else {
            throw OpenFeatureError.generalError(message: "`\(#function)` needs context or initial context to define targeting key")
        }

        let defaults = try getCurrentUserDefaults(with: context)
        let value = condition(context.getTargetingKey())
        defaults.set(value, forKey: key)
    }

    func setStructureValue(forKey key: String, givenCondition condition: @escaping ((_ targetingKey: String) -> [String: Any]), with context: EvaluationContext?) throws {
        guard let context = [context, defaultContext].compactMap({ $0 }).first else {
            throw OpenFeatureError.generalError(message: "`\(#function)` needs context or initial context to define targeting key")
        }

        let defaults = try getCurrentUserDefaults(with: context)
        let value = condition(context.getTargetingKey())
        defaults.set(value, forKey: key)
    }
}
