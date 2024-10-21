# Creating Web View Custom Chat Tab

Learn how to create a custom chat tab using a WebView. 

In a web view base chat tab, the web view will be created by the host app, aka Copilot for Xcode. You need to maintain the communication between the web view and the extension through a chat tab instance.

## Prerequisites

Before you start, make sure you have:

1. Created an extension target.
2. Added the CopilotForXcodeKit package to the extension target.

This tutorial will assume that you are building an extension that only provide a web view base custom chat tab.

## Create a ``CopilotForXcodeExtensionSceneConfiguration``

All UIs provided by your extension must be defined in a type conforming to ``CopilotForXcodeExtensionSceneConfiguration``. If you are providing a web view base chat tab, you will need to provide both the ``CopilotForXcodeExtensionSceneConfiguration\chatTabInfo`` and ``CopilotForXcodeExtensionSceneConfiguration\createChatTab``

```swift
struct SceneConfiguration: CopilotForXcodeExtensionSceneConfiguration {
    var chatTabInfo: [ExtensionChatTabInfo] {
        ...
    }

    func createChatTab(
        id: String,
        chatTabInfo: ExtensionChatTabInfo,
        host: CopilotForXcodeKit.HostServer
    ) throws -> any ExtensionCustomChatTab {
        ...
    }
}
```

In ``CopilotForXcodeExtensionConfiguration\chatTabInfo``, you should return a list of supported chat tabs.

```swift
var chatTabInfo: [ExtensionChatTabInfo] {
    [
        .init(
            // for you to determine what to do in `createChatTab`.
            kindId: "Example WebView Tab",
            // To display in the create tab menu.
            title: "Example WebView Tab", 
            // If this tab can handle the open chat command.
            canHandleOpenChatCommand: true 
        ),
    ]
}
```

In ``CopilotForXcodeExtensionConfiguration\createChatTab``, you should return a custom chat tab based on the ``ExtensionChatTabInfo``. This function will be called when the user creates a chat tab. 

You can use the ``ExtensionChatTabInfo\kindId`` to determine which chat tab to create. The chat tab instance will then be added to the ``CopilotForXcodeExtension\runningChatTabs``. You can use the instance to maintain the communication between the chat tab and the extension.

The kind of the chat tab must be `.webView(...)`. The content can be either a raw `.html(htmlString)` or a `.url(url)`.

```swift
func createChatTab(
    id: String,
    chatTabInfo: ExtensionChatTabInfo,
    host: CopilotForXcodeKit.HostServer
) throws -> any ExtensionCustomChatTab {
    switch chatTabInfo.kindId {
    case "Example WebView Tab":
        return ChatTab(
            id: id,
            chatTabInfo: chatTabInfo,
            kind: .webView(.html(WebViewChatTab.html)),
            host: host
        )
    default:
        throw CancellationError()
    }
}
```

## Create a ``ExtensionCustomChatTab``

To return chat tab, you need to create a type conforming to ``ExtensionCustomChatTab``. 

```swift
final class ChatTab: ExtensionCustomChatTab {
    func chatTabDidLoad() { ... }
    func chatTabDidClose() { ... }
    func chatTabDidBecomeActive() { ... }
    func chatTabDidResignActive() { ... }
}
```

### Maintain communication between the extension and the chat tab

When the web view is loaded in the host app, the host app will inject scripts into the web page so that the web page can communicate with the extension. 

You will need this communication if the web view needs to talk to the extension and also the **host app**.

#### From the extension to the web view

You can post notifications from the extension to the web view using the ``ExtensionCustomChatTab\postNotification(name:info:)`` method.

```swift
chatTab.postNotification(name: "Extension.workspaceDidOpenDocument", info: Info(workspace: url, file: url))
```

The info can be any ``Codable`` object. On the JavaScript side, you can listen to the notification using the ``document.addEventListener`` method. The Info will be converted to a JavaScript object.

```javascript
document.addEventListener('Extension.workspaceDidOpenDocument', function(event) {
    document.getElementById('event').innerText = 'Opened ' + event.detail.file;
});
```

#### From the web view to the extension

You can call `theExtension.call(methodName, arguments)` from the JavaScript side to call a method in the extension.

```javascript
theExtension.call('toast', { message: 'Hello', type: 'warning' });
const activeDocumentURL = await theExtension.call('activeDocumentURL', null);
```

When a call is initiated from the web view, the extension will receive the call in the ``ExtensionCustomChatTab\handleMethodCall(name:arguments:)`` method. The arguments will be a ``Data`` object that you can decode to the expected type. You can also make use of the ``ExtensionCustomChatTab\host`` property to communicate with the host app.

```swift
final class ChatTab: ExtensionCustomChatTab {
    func handleMethodCall(name: String, arguments: Data) async throws -> Data {
        struct UnhandledMethodError: Swift.Error, LocalizedError {
            let name: String
            var errorDescription: String? { "Unhandled method \(name)" }
        }

        switch name {
        case "toast":
            struct ToastArguments: Decodable {
                var message: String
                var type: String
            }

            let arguments = try JSONDecoder().decode(ToastArguments.self, from: arguments)
            try await host.toast(
                arguments.message,
                toastType: {
                    switch arguments.type {
                    case "warning":
                        return .warning
                    case "error":
                        return .error
                    default:
                        return .info
                    }
                }()
            )
            return Data()
        default:
            throw UnhandledMethodError(name: name)
        }
    }
}
```

## Returning the scene configuration from the extension

After implementing the configuration, you need to return the configuration from the extension.

```swift
@main
class Extension: CopilotForXcodeExtension {
    var sceneConfiguration = SceneConfiguration()
}
```

You can access the chat tabs by using the ``CopilotForXcodeExtension\runningChatTabs`` property of the extension.

```swift
@main
class Extension: CopilotForXcodeExtension {
    ...

    func workspace(_ workspace: WorkspaceInfo, didOpenDocumentAt documentURL: URL) {
        for tab in runningChatTabs {
            Task {
                try await tab.postNotification(
                    name: "Extension.workspaceDidOpenDocument",
                    info: documentURL
                )
            }
        }
    }
}
