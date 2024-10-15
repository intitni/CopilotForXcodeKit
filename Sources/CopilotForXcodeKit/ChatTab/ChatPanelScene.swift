import ExtensionKit
import Foundation
import SwiftUI

/// A scene for chat panel view.
@available(macOS 13.0, *)
public struct ChatPanelScene<
    Content: View
>: CopilotForXcodeAppExtensionScene {
    public let id: String
    public let sceneModel: CopilotForXcodeSceneModel
    public let content: (CopilotForXcodeSceneModel) -> Content
    public let onConnection: (NSXPCConnection) -> Bool

    public init(
        id: String,
        sceneModel: CopilotForXcodeSceneModel = .init(),
        @ViewBuilder content: @escaping (CopilotForXcodeSceneModel) -> Content,
        onConnection: @escaping (NSXPCConnection) -> Bool
    ) {
        self.id = id
        self.sceneModel = sceneModel
        self.content = content
        self.onConnection = onConnection
    }

    public var body: some AppExtensionScene {
        PrimitiveAppExtensionScene(id: id) {
            content(sceneModel)
        } onConnection: { connection in
            Logger.info("Chat panel scene did receive connection.")
            sceneModel.connect(to: connection)
            return onConnection(connection)
        }
    }
}

