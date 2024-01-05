//
//  TypeDetector.swift
//
//
//  Created by Fumito Ito on 2024/01/04.
//

import Foundation

struct TypeDetector {
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
