import Foundation

/// An instance of the chat tab. You can use it to communicate with the actual chat tab that is
/// running in the host app.
///
/// If you are using an extension kit base chat tab, you can communicate
/// with the chat tab directly in your extension.
public typealias ExtensionCustomChatTab = ExtensionCustomChatTabBase & ExtensionCustomChatTabType

public protocol ExtensionCustomChatTabType {
    /// Handle method calls from the actual chat tab.
    ///
    /// If you are using a web view chat tab, you may need to implement this method to maintain the
    /// the communication between the chat tab, the host app and your extension.
    ///
    /// - Parameters:
    ///   - name: The name of the method.
    ///   - arguments: The arguments of the method as a `Data` object of JSON.
    /// - Returns: The result of the method call as a `Data` object of JSON.
    ///
    /// - note: The arguments are defined by you. Usually you can use a ``Codable`` type to represent the
    /// arguments. In the Javascript side you can pass it as an object, the object will be
    /// serialized into a JSON object.
    func handleMethodCall(name: String, arguments: Data) async throws -> Data
    /// Called when the chat tab is loaded.
    ///
    /// If you are using a web view chat tab, the web page may not be ready when this method is
    /// called. You can post a notification to the chat tab to notify it that the extension is
    /// ready.
    func chatTabDidLoad()
    /// Called when the chat tab is closed. After this method is called, this instance will be
    /// removed from ``CopilotForXcodeExtensionBase/runningChatTabs``.
    func chatTabDidClose()
    /// Called when user switch to this tab.
    func chatTabDidBecomeActive()
    /// Called when user switch to another tab.
    func chatTabDidResignActive()
}

open class ExtensionCustomChatTabBase {
    /// The chat tab id.
    public let id: String
    /// The kind of the chat tab. The host app will use this to determine how to
    /// handle the chat tab.
    public let kind: ExtensionChatTabInfo.Kind
    /// The information of the chat tab.
    public let chatTabInfo: ExtensionChatTabInfo
    /// The host server.
    public let host: HostServer

    public init(
        id: String,
        chatTabInfo: ExtensionChatTabInfo,
        kind: ExtensionChatTabInfo.Kind,
        host: HostServer
    ) {
        self.id = id
        self.chatTabInfo = chatTabInfo
        self.kind = kind
        self.host = host
    }

    /// Post a notification to the chat tab.
    public func postNotification<T: Codable>(name: String, info: T) async throws {
        let data = try JSONEncoder().encode(info)
        _ = try await host.send(HostRequests.PostNotificationToChatTab(
            chatTabId: id,
            name: name,
            info: data
        ))
    }
}

// MARK: - Default Implementation

public extension ExtensionCustomChatTabType {
    func handleMethodCall<R: Codable>(name: String, arguments: Data) async throws -> R {
        throw CancellationError()
    }

    func chatTabDidLoad() {}
    func chatTabDidClose() {}
    func chatTabDidBecomeActive() {}
    func chatTabDidResignActive() {}
}

