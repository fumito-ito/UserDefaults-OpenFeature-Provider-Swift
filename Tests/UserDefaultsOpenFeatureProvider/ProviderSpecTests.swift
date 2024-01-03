//
//  ProviderSpecTests.swift
//
//
//  Created by Fumito Ito on 2023/12/27.
//

import XCTest
import OpenFeature
@testable import UserDefaultsOpenFeatureProvider

final class ProviderSpecTests: XCTestCase {
    
    let provider: FeatureProvider = {
        UserDefaultsOpenFeatureProvider()
    }()

    static let defaultRegisterData: [String: Any] = [
        ProviderSpecTestCase.trueKey.rawValue: true,
        ProviderSpecTestCase.stringKey.rawValue: "string",
        ProviderSpecTestCase.integer100Key.rawValue: 100,
        ProviderSpecTestCase.piDoubleKey.rawValue: 3.1415,
        ProviderSpecTestCase.objectKey.rawValue: [
            ProviderSpecTestCase.trueKey.rawValue: true,
            ProviderSpecTestCase.stringKey.rawValue: "string",
            ProviderSpecTestCase.integer100Key.rawValue: 100,
            ProviderSpecTestCase.piDoubleKey.rawValue: 3.1415,
            ProviderSpecTestCase.objectKey.rawValue: [
                ProviderSpecTestCase.falseKey.rawValue: false
            ]
        ]
    ]

    enum ProviderSpecTestCase: String {
        case trueKey
        case falseKey
        case stringKey
        case integer100Key
        case piDoubleKey
        case objectKey
    }

    override class func setUp() {
        UserDefaults.standard.register(defaults: defaultRegisterData)
    }

    // MARK: - Feature Provider Interface

    /// Test for the provider metadata
    ///
    /// - Requirement 2.1.1: The provider interface MUST define a metadata member or accessor, containing a name field or accessor of type string, which identifies the provider implementation.
    ///     - https://openfeature.dev/specification/sections/providers#requirement-211
    func testGetNameOfProviderFromMetadata() {
        XCTAssertEqual("UserDefaultsOpenFeatureProvider", provider.metadata.name)
    }

    // MARK: - Flag Value Resolution

    /// Test for the provider resolution result
    ///
    /// - Conditional Requirement 2.2.2.1: The feature provider interface MUST define methods for typed flag resolution, including boolean, numeric, string, and structure.
    /// https://openfeature.dev/specification/sections/providers#conditional-requirement-2221
    /// - Requirement 2.2.3: In cases of normal execution, the provider MUST populate the resolution details structure's value field with the resolved flag value.
    /// https://openfeature.dev/specification/sections/providers#requirement-223
    func testEachInterfacesOfResolutionHaveResolvedValue() throws {
        let boolResult = try provider.getBooleanEvaluation(key: ProviderSpecTestCase.trueKey.rawValue, defaultValue: false, context: MutableContext())
        XCTAssertEqual(true, boolResult.value)

        let stringResult = try provider.getStringEvaluation(key: ProviderSpecTestCase.stringKey.rawValue, defaultValue: "", context: MutableContext())
        XCTAssertEqual("string", stringResult.value)

        let intResult = try provider.getIntegerEvaluation(key: ProviderSpecTestCase.integer100Key.rawValue, defaultValue: 0, context: MutableContext())
        XCTAssertEqual(100, intResult.value)

        let doubleResult = try provider.getDoubleEvaluation(key: ProviderSpecTestCase.piDoubleKey.rawValue, defaultValue: 0.1, context: MutableContext())
        XCTAssertEqual(3.1415, doubleResult.value)

        let objectResult = try provider.getObjectEvaluation(key: ProviderSpecTestCase.objectKey.rawValue, defaultValue: .null, context: MutableContext())
        XCTAssertNotNil(objectResult.value)
    }

    /// Test for the provider resolution variant
    ///
    /// - Requirement 2.2.4: In cases of normal execution, the provider SHOULD populate the resolution details structure's variant field with a string identifier corresponding to the returned flag value.
    /// https://openfeature.dev/specification/sections/providers#requirement-224
    func testEvaluationContainsVariant() throws {
        let boolResult = try provider.getBooleanEvaluation(key: ProviderSpecTestCase.trueKey.rawValue, defaultValue: false, context: MutableContext())
        XCTAssertEqual(Value.boolean(true).description, boolResult.variant)

        let stringResult = try provider.getStringEvaluation(key: ProviderSpecTestCase.stringKey.rawValue, defaultValue: "", context: MutableContext())
        XCTAssertEqual(Value.string("string").description, stringResult.variant)

        let intResult = try provider.getIntegerEvaluation(key: ProviderSpecTestCase.integer100Key.rawValue, defaultValue: 0, context: MutableContext())
        XCTAssertEqual(Value.integer(100).description, intResult.variant)

        let doubleResult = try provider.getDoubleEvaluation(key: ProviderSpecTestCase.piDoubleKey.rawValue, defaultValue: 0.1, context: MutableContext())
        XCTAssertEqual(Value.double(3.1415).description, doubleResult.variant)

        let objectResult = try provider.getObjectEvaluation(key: ProviderSpecTestCase.objectKey.rawValue, defaultValue: .structure(["foo": Value.string("bar")]), context: MutableContext())
        let expects = Self.defaultRegisterData[ProviderSpecTestCase.objectKey.rawValue] as! [String: Any]
        let variant = try XCTUnwrap(objectResult.variant)
        expects.keys.forEach { key in
            XCTAssertTrue(variant.contains(key))
        }
    }

    /// Test for the provider resolution reason
    ///
    /// - Requirement 2.2.5: The provider SHOULD populate the resolution details structure's reason field with "STATIC", "DEFAULT", "TARGETING_MATCH", "SPLIT", "CACHED", "DISABLED", "UNKNOWN", "STALE", "ERROR" or some other string indicating the semantic reason for the returned flag value.
    /// https://openfeature.dev/specification/sections/providers#requirement-225
    func testEvaluationContainsReason() throws {
        let boolResult = try provider.getBooleanEvaluation(key: ProviderSpecTestCase.trueKey.rawValue, defaultValue: false, context: MutableContext())
        XCTAssertEqual(boolResult.reason, Reason.cached.rawValue)

        let stringResult = try provider.getStringEvaluation(key: ProviderSpecTestCase.stringKey.rawValue, defaultValue: "", context: MutableContext())
        XCTAssertEqual(stringResult.reason, Reason.cached.rawValue)

        let intResult = try provider.getIntegerEvaluation(key: ProviderSpecTestCase.integer100Key.rawValue, defaultValue: 0, context: MutableContext())
        XCTAssertEqual(intResult.reason, Reason.cached.rawValue)

        let doubleResult = try provider.getDoubleEvaluation(key: ProviderSpecTestCase.piDoubleKey.rawValue, defaultValue: 0.1, context: MutableContext())
        XCTAssertEqual(doubleResult.reason, Reason.cached.rawValue)

        let objectResult = try provider.getObjectEvaluation(key: ProviderSpecTestCase.objectKey.rawValue, defaultValue: .null, context: MutableContext())
        XCTAssertEqual(objectResult.reason, Reason.cached.rawValue)
    }

    /// Test for the provider resolution has no error code in case of normal
    ///
    /// - Requirement 2.2.6: In cases of normal execution, the provider MUST NOT populate the resolution details structure's error code field, or otherwise must populate it with a null or falsy value.
    /// https://openfeature.dev/specification/sections/providers#requirement-226
    func testNoErrorCodeInCaseOfNormal() throws {
        let boolResult = try provider.getBooleanEvaluation(key: ProviderSpecTestCase.trueKey.rawValue, defaultValue: false, context: MutableContext())
        XCTAssertNil(boolResult.errorCode)

        let stringResult = try provider.getStringEvaluation(key: ProviderSpecTestCase.stringKey.rawValue, defaultValue: "", context: MutableContext())
        XCTAssertNil(stringResult.errorCode)

        let intResult = try provider.getIntegerEvaluation(key: ProviderSpecTestCase.integer100Key.rawValue, defaultValue: 0, context: MutableContext())
        XCTAssertNil(intResult.errorCode)

        let doubleResult = try provider.getDoubleEvaluation(key: ProviderSpecTestCase.piDoubleKey.rawValue, defaultValue: 0.1, context: MutableContext())
        XCTAssertNil(doubleResult.errorCode)

        let objectResult = try provider.getObjectEvaluation(key: ProviderSpecTestCase.objectKey.rawValue, defaultValue: .null, context: MutableContext())
        XCTAssertNil(objectResult.errorCode)
    }

    ///
    ///
    /// - Requirement 2.2.7: In cases of abnormal execution, the provider MUST indicate an error using the idioms of the implementation language, with an associated error code and optional associated error message.
    ///  https://openfeature.dev/specification/sections/providers#requirement-227
    func testErrorCodeAndErrorMessageIfAbnormal() throws {
        let wrongKey = "wrongKey"

        XCTAssertThrowsError(try provider.getBooleanEvaluation(key: wrongKey, defaultValue: false, context: MutableContext()))

        XCTAssertThrowsError(try provider.getStringEvaluation(key: wrongKey, defaultValue: "", context: MutableContext()))

        XCTAssertThrowsError(try provider.getIntegerEvaluation(key: wrongKey, defaultValue: 0, context: MutableContext()))

        XCTAssertThrowsError(try provider.getDoubleEvaluation(key: wrongKey, defaultValue: 0.1, context: MutableContext()))

        XCTAssertThrowsError(try provider.getObjectEvaluation(key: wrongKey, defaultValue: .structure([wrongKey: .boolean(false)]), context: MutableContext()))
    }

    func testNoErrorIfAbnormalButDefaultIsNull() throws {
        let wrongKey = "wrongKey"
        XCTAssertNoThrow(try provider.getObjectEvaluation(key: wrongKey, defaultValue: .null, context: MutableContext()))
    }

    ///
    ///
    /// - Requirement 2.2.8: The resolution details structure SHOULD accept a generic argument (or use an equivalent language feature) which indicates the type of the wrapped value field.
    /// https://openfeature.dev/specification/sections/providers#condition-2281
    func testGenerics() throws {}

    // MARK: Provider hooks

    ///
    ///
    /// - Requirement 2.3.1: The provider interface MUST define a provider hook mechanism which can be optionally implemented in order to add hook instances to the evaluation life-cycle.
    /// https://openfeature.dev/specification/sections/providers#requirement-231
    func testSupportHooksAlongWithLifecycle() throws {}

    ///
    ///
    /// - Requirement 2.3.2: In cases of normal execution, the provider MUST NOT populate the resolution details structure's error message field, or otherwise must populate it with a null or falsy value.
    /// https://openfeature.dev/specification/sections/providers#requirement-232
    func testHookContainsNoErrorIfNormaly() throws {}

    ///
    ///
    /// - Requirement 2.3.3: In cases of abnormal execution, the resolution details structure's error message field MAY contain a string containing additional detail about the nature of the error.
    /// https://openfeature.dev/specification/sections/providers#requirement-233
    func testHookContainsErrorIfAbnormaly() throws {}

    // MARK: Initialization

    private struct TestContext: EvaluationContext {
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
            if key == userDefaultsOpenFeatureProviderSuiteNameKey {
                return .string("suiteName")
            }

            return nil
        }
        
        func asMap() -> [String : OpenFeature.Value] {
            [:]
        }
        
        func asObjectMap() -> [String : AnyHashable?] {
            [:]
        }
    }

    ///
    ///
    /// - Requirement 2.4.1: The provider MAY define an initialize function which accepts the global evaluation context as an argument and performs initialization logic relevant to the provider.
    /// https://openfeature.dev/specification/sections/providers#requirement-241
    func testInitializationContainsIintializationLogics() throws {
        let userDefaultsProvider = UserDefaultsOpenFeatureProvider()

        // tests before initialization
        XCTAssertNil(userDefaultsProvider.initialContext, "Before initialization, provider has no initial context")

        let boolResult = try provider.getBooleanEvaluation(key: ProviderSpecTestCase.trueKey.rawValue, defaultValue: false, context: MutableContext())
        XCTAssertEqual(true, boolResult.value, "Before initialization, provider uses UserDefaults.standard instance")

        // initialization
        userDefaultsProvider.initialize(initialContext: TestContext())

        // test after initialization
        XCTAssertNotNil(userDefaultsProvider.initialContext, "After initialization, provider has some initial context")

        XCTAssertThrowsError(
            try provider.getBooleanEvaluation(key: ProviderSpecTestCase.trueKey.rawValue, defaultValue: false, context: nil),
            "After initialization, provider uses the UserDefaults suite provided by `userDefaultsOpenFeatureProviderSuiteNameKey` key"
        )

        let afterBoolResult = try provider.getBooleanEvaluation(key: ProviderSpecTestCase.trueKey.rawValue, defaultValue: false, context: MutableContext())
        XCTAssertEqual(
            true,
            afterBoolResult.value,
            "After initialization, provider uses UserDefaults.standard instance if applyed context has no informations about userdefaults suite"
        )
    }

    ///
    ///
    /// - Requirement 2.4.2: The provider MAY define a status field/accessor which indicates the readiness of the provider, with possible values NOT_READY, READY, STALE, or ERROR.
    /// https://openfeature.dev/specification/sections/providers#requirement-242
    /// - Requirement 2.4.3: The provider MUST set its status field/accessor to READY if its initialize function terminates normally.
    /// https://openfeature.dev/specification/sections/providers#requirement-243
    /// - Requirement 2.4.4: The provider MUST set its status field to ERROR if its initialize function terminates abnormally.
    /// https://openfeature.dev/specification/sections/providers#requirement-244
    func testStatus() throws {}


    // MARK: Shutdown

    // no implementation

    // MARK: Provider context reconciliation

    ///
    ///
    /// - Requirement 2.6.1: The provider MAY define an on context changed handler, which takes an argument for the previous context and the newly set context, in order to respond to an evaluation context change.
    /// https://openfeature.dev/specification/sections/providers#requirement-261
    func testContextChange() throws {}
}
