//
//  Dictionary+Extensions.swift
//
//
//  Created by Fumito Ito on 2024/01/04.
//

import Foundation
import OpenFeature

extension Dictionary<String, Any> {
    func wrapInValue() throws -> Dictionary<String, OpenFeature.Value> {
        try self.mapValues { value in
            switch TypeDetector.detectType(from: value) {
            case .boolean:
                guard let v = value as? Bool else {
                    throw OpenFeatureError.parseError(message: "Cannot parse \(value) as Bool")
                }
                return .boolean(v)

            case .string:
                guard let v = value as? String else {
                    throw OpenFeatureError.parseError(message: "Cannot parse \(value) as String")
                }
                return .string(v)

            case .integer:
                guard let v = value as? Int64 else {
                    throw OpenFeatureError.parseError(message: "Cannot parse \(value) as Int64")
                }
                return .integer(v)

            case .double:
                guard let v = value as? Double else {
                    throw OpenFeatureError.parseError(message: "Cannot parse \(value) as Double")
                }
                return .double(v)

            case .date:
                guard let v = value as? Date else {
                    throw OpenFeatureError.parseError(message: "Cannot parse \(value) as Date")
                }
                return .date(v)

            case .array:
                guard let v = value as? [Any],
                      let wrappedArray = try? v.wrapInValue() else {
                    throw OpenFeatureError.parseError(message: "Cannot parse \(value) as Array")
                }
                return .list(wrappedArray)

            case .dictionary:
                guard let v = value as? Dictionary<String, Any>,
                      let wrappedDictionary = try? v.wrapInValue() else {
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
