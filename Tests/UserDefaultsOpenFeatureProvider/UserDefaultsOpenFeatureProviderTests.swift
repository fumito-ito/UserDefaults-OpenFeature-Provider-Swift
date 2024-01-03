//
//  UserDefaultsOpenFeatureProviderTests.swift
//
//
//  Created by Fumito Ito on 2023/12/27.
//

import XCTest
import OpenFeature
@testable import UserDefaultsOpenFeatureProvider

final class UserDefaultsOpenFeatureProviderTests: XCTestCase {
    let provider: UserDefaultsOpenFeatureProvider = {
        UserDefaultsOpenFeatureProvider()
    }()

    static let defaultRegisterData: [String: Any] = [
        ExtendedTestCase.trueKey.rawValue: true,
        ExtendedTestCase.stringKey.rawValue: "string",
        ExtendedTestCase.integer100Key.rawValue: 100,
        ExtendedTestCase.piDoubleKey.rawValue: 3.1415,
        ExtendedTestCase.dateKey.rawValue: Date(timeIntervalSince1970: 1_000_000_000.0),
        ExtendedTestCase.mixedArrayKey.rawValue: [
            Value.boolean(true),
            Value.string("string"),
            Value.integer(100),
            Value.double(3.1415),
            Value.date(Date(timeIntervalSince1970: 1_000_000_000.0)),
            Value.structure([
                ExtendedTestCase.falseKey.rawValue: Value.boolean(false)
            ])
        ],
        ExtendedTestCase.structureKey.rawValue: [
            ExtendedTestCase.trueKey.rawValue: true,
            ExtendedTestCase.stringKey.rawValue: "string",
            ExtendedTestCase.integer100Key.rawValue: 100,
            ExtendedTestCase.piDoubleKey.rawValue: 3.1415,
            ExtendedTestCase.dateKey.rawValue: Date(timeIntervalSince1970: 1_000_000_000.0),
            ExtendedTestCase.mixedArrayKey.rawValue: [
                Value.boolean(true),
                Value.string("string"),
                Value.integer(100),
                Value.double(3.1415),
                Value.date(Date(timeIntervalSince1970: 1_000_000_000.0)),
                Value.structure([
                    ExtendedTestCase.falseKey.rawValue: Value.boolean(false)
                ])
            ],
            ExtendedTestCase.structureKey.rawValue: [
                ExtendedTestCase.falseKey.rawValue: false
            ]
        ]
    ]

    enum ExtendedTestCase: String {
        case trueKey
        case falseKey
        case stringKey
        case integer100Key
        case piDoubleKey
        case dateKey
        case mixedArrayKey
        case structureKey
    }
}
