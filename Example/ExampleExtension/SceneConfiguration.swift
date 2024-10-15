import CopilotForXcodeKit
import Foundation
import SwiftUI

/// You have to implement a ``CopilotForXcodeExtensionSceneConfiguration`` to offer UI.
///
/// For a in-app configuration scene, provide a ``configurationScene``.
///
/// For custom chat tabs, you have to provide the information of the chat tabs in ``chatTabInfo``
/// and ``createChatTab(id:chatTabInfo:host:)``.
///
/// If you are providing a scene based chat tab, you have to also provide the implementation
/// in ``chatPanelScenes``. But it's not recommended.
///
struct SceneConfiguration: CopilotForXcodeExtensionSceneConfiguration {
    var configurationScene: ConfigurationScene<ConfigurationView>? {
        .init { model in
            /// When the scene is displayed in Copilot for Xcode, this block will be called.
            /// You can then setup a SwiftUI view and return it.
            ///
            /// The ``model`` here is a view model that is an ``ObservableObject``. It holds a
            /// ``HostServer`` that you can use to communicate with the app.
            ///
            /// But the server will be nil until the next block is called.
            ConfigurationView(model: model)
        } onConnection: { connection in
            /// Once the connection is ready, this block will be called. And the ``HostServer``
            /// will be set.
            ///
            /// You can examine the connection here. Return false if you want to
            /// reject the connection.
            let _ = connection
            return true
        }
    }

    /// If you are providing a scene base chat tab, you have to provide the implementation here.
    ///
    /// - important: But it's not recommended! It has many limitations and performance issues.
    var chatPanelScenes: (some CopilotForXcodeAppExtensionScene)? {
        ChatPanelScene(id: "Example ExtensionKit Tab") { model in
            ChatPanelView(model: model)
        } onConnection: { _ in
            true
        }
    }

    /// The information of the available chat tabs.
    var chatTabInfo: [ExtensionChatTabInfo] {
        [
            .init( // It's not recommended to use an `ExtensionKit` scene.
                kindId: "Example ExtensionKit Tab",
                title: "Example ExtensionKit Tab",
                canHandleOpenChatCommand: false
            ),
            .init( // Use a WebView chat tab.
                kindId: "Example WebView Tab",
                title: "Example WebView Tab",
                canHandleOpenChatCommand: true
            ),
        ]
    }

    func createChatTab(
        id: String,
        chatTabInfo: ExtensionChatTabInfo,
        host: CopilotForXcodeKit.HostServer
    ) throws -> any ExtensionCustomChatTab {
        switch chatTabInfo.kindId {
        /// For a extension kit chat tab, set the ``kind`` to ``.extensionKit(id:)``.
        case "Example ExtensionKit Tab":
            return ChatTab(
                id: id,
                chatTabInfo: chatTabInfo,
                kind: .extensionKit(id: "Example ExtensionKit Tab"),
                host: host
            )
        /// For a web view chat tab, set the ``kind`` to ``.webView``.
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
}

/// You have to provide your own implementation of ``ExtensionCustomChatTab``. You can maintain
/// the communication between the chat tab and this extension here.
final class ChatTab: ExtensionCustomChatTab {
    func chatTabDidLoad() {
        Task {
            try await host.toast("Chat Tab Loaded")
        }
    }

    func chatTabDidClose() {
        Task {
            try await host.toast("Chat Tab Closed")
        }
    }

    func chatTabDidBecomeActive() {
        Task {
            try await host.toast("Chat Tab Became Active")
        }
    }

    func chatTabDidResignActive() {
        Task {
            try await host.toast("Chat Tab Resigned Active")
        }
    }

    /// Chat tabs can be running from the host app, so it may need to communicate with this
    /// extension through the host server.
    func handleMethodCall(name: String, arguments: Data) async throws -> Data {
        struct UnhandledMethodError: Swift.Error, LocalizedError {
            let name: String
            var errorDescription: String? { "Unhandled method \(name)" }
        }

        switch name {
        /// Here is an example of a method call from the chat tab.
        ///
        /// The chat tab can call this method to show a toast message. When this extension
        /// receives the call, it will send another request to the host app to show the toast.
        case "toast":
            /// You have to define the arguments of the method and make sure the chat tab is using
            /// the correct arguments.
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

/// The configuration view can be implemented as a SwiftUI view. It also has the issues the
/// extension kit chat tab has. But users don't have to access this view frequently.
struct ConfigurationView: View {
    @ObservedObject var model: CopilotForXcodeSceneModel
    @State var isOn = false
    @State var counter = 0
    @State var errorMessage = ""
    var body: some View {
        Form {
            Toggle("Toggle", isOn: $isOn)
            Button("Button") {
                counter += 1
            }
            Text("Counter: \(counter)")

            Button("Toast") {
                Task { @MainActor in
                    do {
                        try await model.host?.toast("Hello from Configuration")
                    } catch {
                        errorMessage = error.localizedDescription
                    }
                }
            }

            Text(errorMessage)
        }
    }
}

/// Here's an example of an extension kit chat tab. It's not recommended to use.
struct ChatPanelView: View {
    @ObservedObject var model: CopilotForXcodeSceneModel
    @State var counter = 0
    var body: some View {
        Form {
            Text("Chat Panel")
            Text("Counter: \(counter)")
            Button("Button") {
                counter += 1
            }
            Button("Toast") {
                Task { @MainActor in
                    try await model.host?.toast("Hello from ChatTab")
                }
            }
        }
        .task {
            /// ``host`` is probably still nil here!
            ///
            /// If you need to run something upon connection, observe the changes of the
            /// published property ``CopilotForXcodeSceneModel/isConnected``.

            try? await model.host?.toast("Chat Panel Appeared")
        }
    }
}

/// You can provide a web view chat tab by providing the HTML, URL or file URL.
enum WebViewChatTab {
    static let html = """
    <!DOCTYPE html>
    <html>
        <head>
            <title>WebView Chat Tab</title>
        </head>
        <body>
            <h1>WebView Chat Tab</h1>
            <!-- Call the extension's method -->
            <button onclick="theExtension.call('toast', { message: 'Hello', type: 'warning' })">
                Toast
            </button>
            <h2>Latest Event</h2>
            <p id="event">None</p>
        </body>
        <script>
            <!-- Observe notifications posted by the extension -->
            document.addEventListener('Extension.workspaceDidOpenDocument', function(event) {
                document.getElementById('event').innerText = 'Opened ' + event.detail;
            });
        </script>
    </html>    
    """
}

