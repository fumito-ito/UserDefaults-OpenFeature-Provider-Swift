//
//  UserDefaultsOpenFeatureProviderSetterExpansion.swift
//  
//
//  Created by Fumito Ito on 2023/12/27.
//

import Foundation
import OpenFeature
import UserDefaultsOpenFeatureProvider

extension UserDefaultsOpenFeatureProvider {
    private static let jsonEncoder = JSONEncoder()

    func setBooleanValue(forKey key: String, givenCondition condition: @escaping ((_ targetingKey: String) -> Bool), with context: EvaluationContext?) throws {
        guard let context = [context, initialContext].compactMap({ $0 }).first else {
            throw OpenFeatureError.generalError(message: "`\(#function)` needs context or initial context to define targeting key")
        }

        let defaults = try getCurrentUserDefaults(with: context)
        defaults.set(condition(context.getTargetingKey()), forKey: key)
    }

    func setStringValue(forKey key: String, givenCondition condition: @escaping ((_ targetingKey: String) -> String), with context: EvaluationContext?) throws {
        guard let context = [context, initialContext].compactMap({ $0 }).first else {
            throw OpenFeatureError.generalError(message: "`\(#function)` needs context or initial context to define targeting key")
        }

        let defaults = try getCurrentUserDefaults(with: context)
        defaults.set(condition(context.getTargetingKey()), forKey: key)
    }

    func setIntegerValue(forKey key: String, givenCondition condition: @escaping ((_ targetingKey: String) -> Int64), with context: EvaluationContext?) throws {
        guard let context = [context, initialContext].compactMap({ $0 }).first else {
            throw OpenFeatureError.generalError(message: "`\(#function)` needs context or initial context to define targeting key")
        }

        let defaults = try getCurrentUserDefaults(with: context)
        defaults.set(condition(context.getTargetingKey()), forKey: key)
    }

    func setDoubleValue(forKey key: String, givenCondition condition: @escaping ((_ targetingKey: String) -> Double), with context: EvaluationContext?) throws {
        guard let context = [context, initialContext].compactMap({ $0 }).first else {
            throw OpenFeatureError.generalError(message: "`\(#function)` needs context or initial context to define targeting key")
        }

        let defaults = try getCurrentUserDefaults(with: context)
        defaults.set(condition(context.getTargetingKey()), forKey: key)
    }

    // TODO: 日付がどのようなフォーマットで文字列に変換されて保存されるのかドキュメントで補足する
    func setDateValue(forKey key: String, givenCondition condition: @escaping ((_ targetingKey: String) -> Date), with context: EvaluationContext?) throws {
        guard let context = [context, initialContext].compactMap({ $0 }).first else {
            throw OpenFeatureError.generalError(message: "`\(#function)` needs context or initial context to define targeting key")
        }

        let defaults = try getCurrentUserDefaults(with: context)
        let date = condition(context.getTargetingKey())
        let dateString = Self.dateFormatter.string(from: date)
        defaults.set(dateString, forKey: key)
    }

    // TODO: 当然 [Value] でないほうが汎用性が高いので変更を検討する
    // TODO: [Value]がJSONStringに変換されて保存されている旨をドキュメントで補足する
    func setListValue(forKey key: String, givenCondition condition: @escaping ((_ targetingKey: String) -> [Value]), with context: EvaluationContext?) throws {
        guard let context = [context, initialContext].compactMap({ $0 }).first else {
            throw OpenFeatureError.generalError(message: "`\(#function)` needs context or initial context to define targeting key")
        }

        let defaults = try getCurrentUserDefaults(with: context)
        let value = condition(context.getTargetingKey())
        let jsonData = try Self.jsonEncoder.encode(value)
        defaults.set(String(data: jsonData, encoding: .utf8), forKey: key)
    }

    // TODO: 当然 [String: Any] のほうが汎用性が高いので変更を検討する
    // TODO: [String: Value]がJSONStringに変換されて保存されている旨をドキュメントで補足する
    func setStructureValue(forKey key: String, givenCondition condition: @escaping ((_ targetingKey: String) -> [String: Value]), with context: EvaluationContext?) throws {
        guard let context = [context, initialContext].compactMap({ $0 }).first else {
            throw OpenFeatureError.generalError(message: "`\(#function)` needs context or initial context to define targeting key")
        }

        let defaults = try getCurrentUserDefaults(with: context)
        let value = condition(context.getTargetingKey())
        let jsonData = try Self.jsonEncoder.encode(value)
        defaults.set(String(data: jsonData, encoding: .utf8), forKey: key)
    }
}
