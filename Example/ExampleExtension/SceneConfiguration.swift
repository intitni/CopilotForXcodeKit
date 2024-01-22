import CopilotForXcodeKit
import Foundation
import SwiftUI

/// You have to implement a ``CopilotForXcodeExtensionSceneConfiguration`` to offer UI.
///
/// For a in-app configuration scene, provide a ``configurationScene``.
///
/// For custom chat tabs (not implemented yet), provide both ``chatPanelScenes``
/// and ``chatPanelSceneInfo``.
//

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
    
    /// Custom chat panel is not implemented yet.
    //

    var chatPanelScenes: (some CopilotForXcodeAppExtensionScene)? {
        ChatPanelScene(id: "One") { model in
            ChatPanelView(model: model)
        } onConnection: { _ in
            true
        }
        
        ChatPanelScene(id: "Two") { model in
            ChatPanelView(model: model)
        } onConnection: { _ in
            true
        }
    }

    var chatPanelSceneInfo: [ChatPanelSceneInfo] {
        [.init(id: "One", title: "One")] // Then "Two" will be unavailable.
    }
}

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

struct ChatPanelView: View {
    @ObservedObject var model: CopilotForXcodeSceneModel
    var body: some View {
        Text("Chat Panel")
            .task {
                /// ``host`` is probably still nil here!
                ///
                /// If you need to run something upon connection, observe the changes of the
                /// published property ``CopilotForXcodeSceneModel/isConnected``.
                
                try? await model.host?.toast("Chat Panel Appeared")
            }
    }
}

