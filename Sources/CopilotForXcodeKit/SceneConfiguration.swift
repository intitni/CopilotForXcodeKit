import ExtensionKit
import Foundation
import OSLog
import SwiftUI

public let CopilotForXcodeConfigurationSceneId = "COPILOT_FOR_XCODE_CONFIGURATION_SCENE"

/// If you want to provide UI for the extension, you have to implement this protocol.
///
/// There are 2 types of scenes:
/// - `configurationScene`: The scene that allows users to configure the extension. If you
///   provide the configuration in your own app, you can leave it nil by setting
///   ``ConfigurationBody`` to `Never`.
/// - `chatPanelScenes`: (Not implemented yet)
///   The scene that allows users to open in chat panel. If you don't have
///   a chat panel, you can leave it nil by setting ``ChatPanelSceneGroup`` to `Never`.
///
///   When you provide a chat panel scene, you have to provide a list of `chatPanelSceneInfo`.
@available(macOS 13.0, *)
public protocol CopilotForXcodeExtensionSceneConfiguration {
    associatedtype ConfigurationBody: View
    associatedtype ChatPanelSceneGroup: CopilotForXcodeAppExtensionScene

    /// The configuration scene.
    ///
    /// You can provide this scene if you want to display the configuration UI
    /// inside Copilot for Xcode.
    ///
    /// You can also return nil here and handle the configurations in your own app.
    var configurationScene: ConfigurationScene<ConfigurationBody>? { get }
    /// Not implemented yet.
    ///
    /// The chat panel scenes. Please use ``ChatPanelScene`` to define each scene.
    /// - Note: You have to provide this value if you provide `chatPanelScenes`. The app
    ///   uses this information to show the available chat panel scenes to users.
    @ChatPanelSceneBuilder var chatPanelScenes: ChatPanelSceneGroup? { get }
    /// Not implemented yet.
    ///
    /// The information of the available chat panel scenes.
    /// - Note: You have to provide this value if you provide `chatPanelScenes`. The app
    ///   uses this information to show the available chat panel scenes to users.
    var chatPanelSceneInfo: [ChatPanelSceneInfo] { get }
}

@available(macOS 13.0, *)
public struct NoSceneConfiguration: CopilotForXcodeExtensionSceneConfiguration {
    public struct Group: CopilotForXcodeAppExtensionScene {
        public var body: Never
        public typealias Body = Never
    }

    public var configurationScene: ConfigurationScene<Never>? { nil }

    public var chatPanelScenes: Group? { return nil }

    public var chatPanelSceneInfo: [ChatPanelSceneInfo] { [] }
}

@available(macOS 13.0, *)
extension CopilotForXcodeExtensionSceneConfiguration {
    var body: some CopilotForXcodeAppExtensionScene {
        CopilotForXcodeAppExtensionGroupedScene {
            if let configurationScene {
                configurationScene
            }
            if let chatPanelScenes {
                chatPanelScenes
            }
        }
    }

    var hasConfigurationScene: Bool {
        configurationScene != nil
    }
}

@available(macOS 13.0, *)
public extension CopilotForXcodeExtensionSceneConfiguration where ChatPanelSceneGroup == Never {
    var chatPanelScenes: ChatPanelSceneGroup? {
        return nil
    }

    var chatPanelSceneInfo: [ChatPanelSceneInfo] {
        return []
    }
}

@available(macOS 13.0, *)
public extension CopilotForXcodeExtensionSceneConfiguration where ConfigurationBody == Never {
    var configurationScene: ConfigurationScene<ConfigurationBody>? {
        nil
    }
}

// MARK: - Scene

/// A scene for the extension.
@available(macOS 13.0, *)
public protocol CopilotForXcodeAppExtensionScene: AppExtensionScene {}

@available(macOS 13.0, *)
extension Array: CopilotForXcodeAppExtensionScene where Element: CopilotForXcodeAppExtensionScene {}

@available(macOS 13.0, *)
extension Never: CopilotForXcodeAppExtensionScene {}

@objc(CopilotForXcodeExportedSceneModel)
class ExportedModel: NSObject, XPCProtocol {
    func send(endpoint: String, requestBody: Data, reply: @escaping (Data?, Error?) -> Void) {
        reply(nil, nil)
    }
}

/// A view model for the scene. You can use it to communicate with the host.
open class CopilotForXcodeSceneModel: ObservableObject {
    @Published public var isConnected = false
    public var host: HostServer?

    public init() {}

    public var connection: NSXPCConnection?

    open func connect(to connection: NSXPCConnection) {
        connection.activate()
        self.connection = connection
        connection.exportedObject = ExportedModel()
        connection.exportedInterface = NSXPCInterface(with: XPCProtocol.self)
        connection.remoteObjectInterface = NSXPCInterface(with: HostXPCProtocol.self)
        host = HostServer(connection)
        isConnected = true
    }
}

/// A scene for configuration view.
@available(macOS 13.0, *)
public struct ConfigurationScene<
    Content: View
>: CopilotForXcodeAppExtensionScene {
    public let sceneModel: CopilotForXcodeSceneModel
    public let content: (CopilotForXcodeSceneModel) -> Content
    public let onConnection: (NSXPCConnection) -> Bool

    public init(
        sceneModel: CopilotForXcodeSceneModel = .init(),
        @ViewBuilder content: @escaping (CopilotForXcodeSceneModel) -> Content,
        onConnection: @escaping (NSXPCConnection) -> Bool
    ) {
        self.sceneModel = sceneModel
        self.content = content
        self.onConnection = onConnection
    }

    public var body: some AppExtensionScene {
        return PrimitiveAppExtensionScene(id: CopilotForXcodeConfigurationSceneId) {
            self.content(self.sceneModel)
        } onConnection: { connection in
            Logger.info("Configuration scene did receive connection.")
            self.sceneModel.connect(to: connection)
            return self.onConnection(connection)
        }
    }
}

public struct ChatPanelSceneInfo: Codable {
    public let id: String
    public let title: String

    public init(id: String, title: String) {
        self.id = id
        self.title = title
    }
}

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

