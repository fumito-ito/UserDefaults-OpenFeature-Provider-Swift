# UserDefaults OpenFeature Provider for Swift

This is yet another OpenFeature provider for UserDefaults.

## Installation

### Swift Package Manager

In dependencies section of Package.swift add:

```swift
dependencies: [
    .package(
        url: "git@github.com:fumito-ito/UserDefaults-OpenFeature-Provider-Swift.git",
        .upToNextMajor(from: "0.0.1")
    ),
]
```

and in the target dependencies section add:

```swift
.product(name: "UserDefaultsOpenFeatureProvider", package: "UserDefaultsOpenFeatureProvider"),
```

## Usage

Import the `UserDefaultsOpenFeatureProvider` and `OpenFeature` modules.

```swift
import UserDefaultsOpenFeatureProvider
```

Create and set provider.

```swift
let provider = UserDefaultsOpenFeatureProvider()
let context = MutableContext(targetingKey: "your_targeting_key", structure: MutableStructure())
OpenFeatureAPI.shared.setProvider(provider: provider, initialContext: context)
``` 

If not specified, `UserDefaults.standard` is used.

If you want to use UserDefaults with a specific `suiteName`, pass an EvaluationContext that returns the `suiteName` you want to specify for the `UserDefaultsOpenFeatureProviderSuiteNameKey` key.

```swift
struct CustomContext: EvaluationContext {
    var suiteName: String? = "your_suite_name"

    func getValue(key: String) -> OpenFeature.Value? {
        if let suiteName, key == userDefaultsOpenFeatureProviderSuiteNameKey {
            return .string(suiteName)
        }

        return nil
    }
}

let provider = UserDefaultsOpenFeatureProvider()
let context = CustomContext()
provider.initialize(initialContext: context)
```

### Utilities

The UserDefaultsOpenFeatureProvider implements setter functions to store values in UserDefaults.
By saving the value through this function, the `PROVIDER_CONFIGURATION_CHANGED` event can be fired.

```swift
let provider = UserDefaultsOpenFeatureProvider()
try provider.setBooleanValue(
    forKey: appendedBoolKey,
    givenCondition: { targetingKey in
        // You can determine the value to be set based on the targeting key.
        return targetingKey == "this_user_is_target"
    },
    with: TestContext())
```

## Contributing

Pull requests are welcome. For major changes, please open an issue first
to discuss what you would like to change.

Please make sure to update tests as appropriate.

## License

[Apache License 2.0](https://choosealicense.com/licenses/apache-2.0/)
