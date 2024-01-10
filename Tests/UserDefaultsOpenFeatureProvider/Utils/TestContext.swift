//
//  TestContext.swift
//
//
//  Created by Fumito Ito on 2024/01/06.
//

import Foundation
import OpenFeature
import UserDefaultsOpenFeatureProvider

struct TestContext: EvaluationContext {
    var suiteName: String? = "suiteName"

    func getTargetingKey() -> String {
        ""
    }

    func setTargetingKey(targetingKey: String) {
        // no implementation
    }

    func keySet() -> Set<String> {
        Set()
    }

    func getValue(key: String) -> OpenFeature.Value? {
        if let suiteName, key == userDefaultsOpenFeatureProviderSuiteNameKey {
            return .string(suiteName)
        }

        return nil
    }

    func asMap() -> [String: OpenFeature.Value] {
        [:]
    }

    func asObjectMap() -> [String: AnyHashable?] {
        [:]
    }
}
