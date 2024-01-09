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
            true,
            "string",
            100,
            3.1415,
            Date(timeIntervalSince1970: 1_000_000_000.0),
            [
                ExtendedTestCase.falseKey.rawValue: false
            ]
        ],
        ExtendedTestCase.structureKey.rawValue: [
            ExtendedTestCase.trueKey.rawValue: true,
            ExtendedTestCase.stringKey.rawValue: "string",
            ExtendedTestCase.integer100Key.rawValue: 100,
            ExtendedTestCase.piDoubleKey.rawValue: 3.1415,
            ExtendedTestCase.dateKey.rawValue: Date(timeIntervalSince1970: 1_000_000_000.0),
            ExtendedTestCase.mixedArrayKey.rawValue: [
                true,
                "string",
                100,
                3.1415,
                Date(timeIntervalSince1970: 1_000_000_000.0),
                [
                    ExtendedTestCase.falseKey.rawValue: false
                ]
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

    override class func setUp() {
        UserDefaults.standard.register(defaults: defaultRegisterData)
    }

    // MARK: - Flag Value Resolution

    /// Test for the provider resolution result
    ///
    /// - Conditional Requirement 2.2.2.1: The feature provider interface MUST define methods for typed flag resolution, including boolean, numeric, string, and structure.
    /// https://openfeature.dev/specification/sections/providers#conditional-requirement-2221
    /// - Requirement 2.2.3: In cases of normal execution, the provider MUST populate the resolution details structure's value field with the resolved flag value.
    /// https://openfeature.dev/specification/sections/providers#requirement-223
    func testEachInterfacesOfResolutionHaveResolvedValue() throws {
        let dateResult = try provider.getDateEvaluation(key: ExtendedTestCase.dateKey.rawValue, defaultValue: Date(), context: MutableContext())
        XCTAssertNotNil(dateResult)

        let mixedArrayResult = try provider.getListEvaluation(key: ExtendedTestCase.mixedArrayKey.rawValue, defaultValue: [], context: MutableContext())
        XCTAssertNotNil(mixedArrayResult)

        let structureResult = try provider.getStructureEvaluation(key: ExtendedTestCase.structureKey.rawValue, defaultValue: [:], context: MutableContext())
        XCTAssertNotNil(structureResult)
    }

    /// Test for the provider resolution variant
    ///
    /// - Requirement 2.2.4: In cases of normal execution, the provider SHOULD populate the resolution details structure's variant field with a string identifier corresponding to the returned flag value.
    /// https://openfeature.dev/specification/sections/providers#requirement-224
    func testEvaluationContainsVariant() throws {

        let dateResult = try provider.getDateEvaluation(key: ExtendedTestCase.dateKey.rawValue, defaultValue: Date(), context: MutableContext())
        XCTAssertEqual(Value.date(Date(timeIntervalSince1970: 1_000_000_000.0)).description, dateResult.variant)

        let mixedArrayResult = try provider.getListEvaluation(key: ExtendedTestCase.mixedArrayKey.rawValue, defaultValue: [], context: MutableContext())
        XCTAssertEqual(
            Value.list([
                Value.boolean(true),
                Value.string("string"),
                Value.integer(100),
                Value.double(3.1415),
                Value.date(Date(timeIntervalSince1970: 1_000_000_000.0)),
                Value.structure([
                    ExtendedTestCase.falseKey.rawValue: Value.boolean(false)
                ])
            ]).description,
            mixedArrayResult.variant
        )

        let structureResult = try provider.getStructureEvaluation(key: ExtendedTestCase.structureKey.rawValue, defaultValue: [:], context: MutableContext())
        let expects = Self.defaultRegisterData[ExtendedTestCase.structureKey.rawValue] as! [String: Any]
        let variant = try XCTUnwrap(structureResult.variant)
        expects.keys.forEach { key in
            XCTAssertTrue(variant.contains(key))
        }
    }

    /// Test for the provider resolution reason
    ///
    /// - Requirement 2.2.5: The provider SHOULD populate the resolution details structure's reason field with "STATIC", "DEFAULT", "TARGETING_MATCH", "SPLIT", "CACHED", "DISABLED", "UNKNOWN", "STALE", "ERROR" or some other string indicating the semantic reason for the returned flag value.
    /// https://openfeature.dev/specification/sections/providers#requirement-225
    func testEvaluationContainsReason() throws {
        let dateResult = try provider.getDateEvaluation(key: ExtendedTestCase.dateKey.rawValue, defaultValue: Date(), context: MutableContext())
        XCTAssertEqual(dateResult.reason, Reason.cached.rawValue)

        let mixedArrayResult = try provider.getListEvaluation(key: ExtendedTestCase.mixedArrayKey.rawValue, defaultValue: [], context: MutableContext())
        XCTAssertEqual(mixedArrayResult.reason, Reason.cached.rawValue)

        let structureResult = try provider.getStructureEvaluation(key: ExtendedTestCase.structureKey.rawValue, defaultValue: [:], context: MutableContext())
        XCTAssertEqual(structureResult.reason, Reason.cached.rawValue)
    }

    /// Test for the provider resolution has no error code in case of normal
    ///
    /// - Requirement 2.2.6: In cases of normal execution, the provider MUST NOT populate the resolution details structure's error code field, or otherwise must populate it with a null or falsy value.
    /// https://openfeature.dev/specification/sections/providers#requirement-226
    func testNoErrorCodeInCaseOfNormal() throws {
        let dateResult = try provider.getDateEvaluation(key: ExtendedTestCase.dateKey.rawValue, defaultValue: Date(), context: MutableContext())
        XCTAssertNil(dateResult.errorCode)

        let mixedArrayResult = try provider.getListEvaluation(key: ExtendedTestCase.mixedArrayKey.rawValue, defaultValue: [], context: MutableContext())
        XCTAssertNil(mixedArrayResult.errorCode)

        let structureResult = try provider.getStructureEvaluation(key: ExtendedTestCase.structureKey.rawValue, defaultValue: [:], context: MutableContext())
        XCTAssertNil(structureResult.errorCode)
    }

    ///
    ///
    /// - Requirement 2.2.7: In cases of abnormal execution, the provider MUST indicate an error using the idioms of the implementation language, with an associated error code and optional associated error message.
    ///  https://openfeature.dev/specification/sections/providers#requirement-227
    func testErrorCodeAndErrorMessageIfAbnormal() throws {
        let wrongKey = "wrongKey"

        XCTAssertThrowsError(try provider.getDateEvaluation(key: wrongKey, defaultValue: Date(), context: MutableContext()))

        XCTAssertThrowsError(try provider.getListEvaluation(key: wrongKey, defaultValue: [], context: MutableContext()))

        XCTAssertThrowsError(try provider.getStructureEvaluation(key: wrongKey, defaultValue: [:], context: MutableContext()))
    }

    func testSetters() throws {
        let appendedBoolKey = "appendedBoolKey"
        try provider.setBooleanValue(forKey: appendedBoolKey, givenCondition: { _ in true }, with: TestContext())
        XCTAssertEqual(try provider.getBooleanEvaluation(key: appendedBoolKey, defaultValue: false, context: TestContext()).value, true)

        let appendedStringKey = "appendedStringKey"
        try provider.setStringValue(forKey: appendedStringKey, givenCondition: { _ in "appended" }, with: TestContext())
        XCTAssertEqual(try provider.getStringEvaluation(key: appendedStringKey, defaultValue: "", context: TestContext()).value, "appended")

        let appendedIntKey = "appendedIntKey"
        try provider.setIntegerValue(forKey: appendedIntKey, givenCondition: { _ in 1_000 }, with: TestContext())
        XCTAssertEqual(try provider.getIntegerEvaluation(key: appendedIntKey, defaultValue: 0, context: TestContext()).value, 1_000)

        let appendedDoubleKey = "appendedDoubleKey"
        try provider.setDoubleValue(forKey: appendedDoubleKey, givenCondition: { _ in 2.71828 }, with: TestContext())
        XCTAssertEqual(try provider.getDoubleEvaluation(key: appendedDoubleKey, defaultValue: 0.0, context: TestContext()).value, 2.71828)

        let appendedDateKey = "appendedDateKey"
        try provider.setDateValue(forKey: appendedDateKey, givenCondition: { _ in Date(timeIntervalSince1970: 1_000_000) }, with: TestContext())
        XCTAssertEqual(try provider.getDateEvaluation(key: appendedDateKey, defaultValue: Date(), context: TestContext()).value, Date(timeIntervalSince1970: 1_000_000))

        let appendedArrayKey = "appendedArrayKey"
        try provider.setListValue(forKey: appendedArrayKey, givenCondition: { _ in [true, "appended", 1_000, 2.71828, Date(timeIntervalSince1970: 1_000_000)] }, with: TestContext())
        XCTAssertEqual(
            try provider.getListEvaluation(key: appendedArrayKey, defaultValue: [], context: TestContext()).value,
            [
                .boolean(true),
                .string("appended"),
                .integer(1_000),
                .double(2.71828),
                .date(Date(timeIntervalSince1970: 1_000_000))
            ]
        )

        let appendedStructureKey = "appendedStructureKey"
        try provider.setStructureValue(
            forKey: appendedStructureKey,
            givenCondition: { _ in
                [
                    "boolean": true,
                    "string": "appended",
                    "integer": 1_000,
                    "double": 2.71828,
                    "date": Date(timeIntervalSince1970: 1_000_000),
                ]
            },
            with: TestContext())
        XCTAssertEqual(
            try provider.getStructureEvaluation(key: appendedStructureKey, defaultValue: [:], context: TestContext()).value,
            [
                "boolean": .boolean(true),
                "string": .string("appended"),
                "integer": .integer(1_000),
                "double": .double(2.71828),
                "date": .date(Date(timeIntervalSince1970: 1_000_000)),
            ]
        )
    }
}
