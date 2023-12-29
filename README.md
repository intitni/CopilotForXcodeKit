# CopilotForXcodeKit

CopilotforXcodeKit is a Swift package that offers API to build extensions for [Copilot for Xcode](https://github.com/intitni/CopilotForXcode).

## Roadmap

- [x] In-app Configuration Screen
- [x] Suggestion Service
- [ ] Custom Chat Tab
- [ ] Chat Service
- [ ] Prompt to Code Service
- [ ] APIs for other Xcode Source Editor Extensions
- [ ] Custom Models

## Building an Extension

### 1. Create an Extension Target

Create a **Generic Extension** target. The extension should target macOS 13+. It can be sandboxed.

In the info.plist of the target, add the following content:

```xml
<key>EXAppExtensionAttributes</key>
<dict>
    <key>EXExtensionPointIdentifier</key>
    <string>com.intii.CopilotForXcode.ExtensionService.Extension</string>
</dict>
```

### 2. Add CopilotForXcodeKit as a Dependency

Add this repo as an dependency in Package.swift or via UI in Xcode.

### 3. Implement the Extension

Create a class that conforms to `CopilotForXcodeExtension`, and mark it with `@main`.

```swift
import CopilotForXcodeKit

@main
class Extension: CopilotForXcodeExtension {
    ...
}
```

#### 3.1 Communicate via Global Connection

When the extension is turned on in Copilot for Xcode, the connection will be established. `connectionDidActivate(connectedTo:)` will be called and `host` will be set.

Once `host` is set, you can use it to communicate with Copilot for Xcode.

```swift
class Extension: CopilotForXcodeExtension {
    var host: HostServer?
    
    func connectionDidActivate(connectedTo host: HostServer) {
        Task {
            try await host.toast("Connected to Example Extension")
        }
    }
    
    ...
}
```

Copilot for Xcode will occasionally communicate with your extension to provide updates about Xcode. You can implement observer methods such as `workspace(_:didOpenFileAt:)` to receive this information.

#### 3.2 Provide Configuration Screen

To provide a configuration screen that users can access from the extension list, you must

- Create a type that conforms to `CopilotForXcodeExtensionSceneConfiguration`. Then, return a scene through the `configurationScene` property.
- Return the configuration from the `sceneConfiguration` property of the extension.

```swift
struct SceneConfiguration: CopilotForXcodeExtensionSceneConfiguration {
    var configurationScene: ConfigurationScene<ConfigurationView>? {
        .init { viewModel in
            ConfigurationView(model: viewModel)
        } onConnection: { _ in
            return true
        }
    }
}
```

The `ConfigurationView` is instantiated when the configuration screen is opened, and the connection is established at this point. 

You can then utilize the `host` property of the view model to communicate with Copilot for Xcode.

```swift
struct ConfigurationView: View {
    @ObservedObject var model: CopilotForXcodeSceneModel
    var body: some View {
        Button("Toast") {
            Task { @MainActor in
                try? await model.host?.toast("Hello")
            }
        }
    }
}
```

#### 3.3 Provide Suggestion Service

To enable the suggestion service within your extension, you must:

- Implement a type that conforms to the `SuggestionServiceType` protocol.
- Provide an instance of this type by returning it from the `suggestionService` property.

```swift
class SuggestionService: SuggestionServiceType {
    var configuration: SuggestionServiceConfiguration {
        .init(acceptsRelevantCodeSnippets: true)
    }

    func getSuggestions(
        _ request: SuggestionRequest,
        workspace: WorkspaceInfo
    ) async throws -> [CodeSuggestion] {
        [
            .init(
                id: UUID().uuidString,
                text: "Hello World",
                position: request.cursorPosition,
                range: .init(start: request.cursorPosition, end: request.cursorPosition)
            ),
        ]
    }
    
    ...
}
```

If you need to maintain multiple suggestion services for different workspaces, such as those utilizing language servers, you will be responsible for managing the lifecycle of each service individually.

### 4. Debugging the Extension

To debug the extension, you have two options: running it directly in Xcode or simply building it. There is no practical difference between the two methods, as Xcode does not automatically attach to the extension's process (may be a bug). Even with manual attachment, you still can not see the logs. Either way, once the extension is built, it will be available in Copilot for Xcode.

To enable the extension, click "Extensions" in Copilot for Xcode.app, and click "Select Extensions" to see all available extensions. Enable the extension you want to debug.

It is recommended to give the debug build a different bundle identifier to prevent conflicts with the release version.

It is recommended to use OSLog. Logs can be viewed in the Console.app.

When running the extension from Xcode, you will be prompted to choose a target application. Please select "Copilot for Xcode.app".
