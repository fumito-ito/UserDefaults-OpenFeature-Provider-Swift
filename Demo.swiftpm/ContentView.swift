import SwiftUI
import OpenFeature
import UserDefaultsOpenFeatureProvider

struct ContentView: View {
    @State var inputText: String = ""
    @State var outputText: String = ""

    let provider = UserDefaultsOpenFeatureProvider()
    let context = MutableContext(targetingKey: "", structure: MutableStructure())
    let client = OpenFeatureAPI.shared.getClient()

    init(inputText: String = "", outputText: String = "") {
        self.inputText = inputText
        self.outputText = outputText

        OpenFeatureAPI.shared.setProvider(provider: self.provider, initialContext: self.context)
    }

    var body: some View {
        VStack {
            TextField("Set this value into UserDefaults", text: $inputText)
                .textFieldStyle(.roundedBorder)
                .padding()
                .onSubmit {
                    try? provider.setStringValue(forKey: "value") { targetingKey in
                        "Hello, " + inputText
                    }
                    outputText = client.getStringValue(key: "value", defaultValue: "")
                }
            Text(outputText)
        }
    }
}
