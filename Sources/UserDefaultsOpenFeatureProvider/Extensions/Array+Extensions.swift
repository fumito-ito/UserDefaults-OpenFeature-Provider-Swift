//
//  Array+Extensions.swift
//
//
//  Created by Fumito Ito on 2024/01/04.
//

import Foundation
import OpenFeature

extension Array where Element == Any {
    func wrapInValue() throws -> [Value] {
        try self.map { value in
            switch TypeDetector.detectType(from: value) {
            case .boolean:
                guard let typedValue = value as? Bool else {
                    throw OpenFeatureError.parseError(message: "Cannot parse \(value) as Bool")
                }
                return .boolean(typedValue)

            case .string:
                guard let typedValue = value as? String else {
                    throw OpenFeatureError.parseError(message: "Cannot parse \(value) as String")
                }
                return .string(typedValue)

            case .integer:
                guard let typedValue = value as? Int64 else {
                    throw OpenFeatureError.parseError(message: "Cannot parse \(value) as Int64")
                }
                return .integer(typedValue)

            case .double:
                guard let typedValue = value as? Double else {
                    throw OpenFeatureError.parseError(message: "Cannot parse \(value) as Double")
                }
                return .double(typedValue)

            case .date:
                guard let typedValue = value as? Date else {
                    throw OpenFeatureError.parseError(message: "Cannot parse \(value) as Date")
                }
                return .date(typedValue)

            case .array:
                guard
                    let typedValue = value as? [Any],
                    let wrappedArray = try? typedValue.wrapInValue() else {
                    throw OpenFeatureError.parseError(message: "Cannot parse \(value) as Array")
                }
                return .list(wrappedArray)

            case .dictionary:
                guard
                    let typedValue = value as? [String: Any],
                    let wrappedDictionary = try? typedValue.wrapInValue() else {
                    throw OpenFeatureError.parseError(message: "Cannot parse \(value) as Dictionary")
                }
                return .structure(wrappedDictionary)

            case .null:
                return .null

            case .unknown:
                throw OpenFeatureError.parseError(message: "Cannot detect type of \(value) in \(self)")
            }
        }
    }
}
