import ExtensionFoundation
import Foundation
import XPCConcurrency

/// The XPC protocol for the host. You don't have to implement it yourself. Simply use the
/// ``HostServer`` and create the server with a connection.
@_spi(CopilotForXcodeSPI)
@objc(CopilotForXcodeHostXPCProtocol)
public protocol HostXPCProtocol: XPCProtocol {}

extension HostXPCProtocol {
    func send<M: HostRequestType, T>(
        requestBody: M,
        continuation: XPCServiceConnectionContinuation<T>
    ) throws where T == M.ResponseBody {
        try Task.checkCancellation()
        return try _send(endpoint: M.endpoint, requestBody: requestBody, continuation: continuation)
    }
}

@frozen
public enum ToastType: Int, Codable {
    case info
    case warning
    case error
}

@_spi(CopilotForXcodeSPI)
public protocol HostRequestType: XPCRequestType {}

/// Contains all request types.
///
/// Please keep all Codable types backward compatible.
@_spi(CopilotForXcodeSPI)
public enum HostRequests {
    public struct Ping: HostRequestType {
        public typealias ResponseBody = NoResponse
        public static let endpoint = "ping"
    }

    public struct Toast: HostRequestType {
        public var message: String
        public var toastType: ToastType
        public typealias ResponseBody = NoResponse
        public static let endpoint = "toast"
    }

    public struct TriggerExtensionCommand: HostRequestType {
        public var extensionName: String
        public var command: String
        public var activateXcode: Bool
        public typealias ResponseBody = NoResponse
        public static let endpoint = "TriggerExtensionCommand"
    }

    public struct TriggerMenuItem: HostRequestType {
        public var path: [String]
        public var activateXcode: Bool
        public typealias ResponseBody = NoResponse
        public static let endpoint = "TriggerMenuItem"
    }

    public struct GetExistedWorkspaces: HostRequestType {
        public typealias ResponseBody = [WorkspaceInfo]
        public static let endpoint = "getExistedWorkspaces"
    }

    public struct GetActiveEditor: HostRequestType {
        public typealias ResponseBody = Editor?
        public static let endpoint = "GetActiveEditor"
    }
    
    public struct GetXcodeInformation: HostRequestType {
        public typealias ResponseBody = XcodeInfo
        public static let endpoint = "GetXcodeInformation"
    }
}

/// The host server, aka the ExtensionService of Copilot for Xcode.app.
///
/// You can use it to communicate with the host.
public final class HostServer {
    let connection: NSXPCConnection

    init(_ connection: NSXPCConnection) {
        self.connection = connection
    }

    func send<M: HostRequestType>(_ requestBody: M) async throws -> M.ResponseBody {
        try await withXPCServiceConnected(
            connection: connection,
            as: HostXPCProtocol.self
        ) { server, continuation in
            do {
                try server.send(requestBody: requestBody, continuation: continuation)
            } catch {
                continuation.reject(error)
            }
        }
    }

    /// Ping the host.
    public func ping() async throws {
        _ = try await send(HostRequests.Ping())
    }

    /// Send a toast that displays next to the Copilot for Xcode circular widget.
    public func toast(
        _ message: String,
        toastType: ToastType = .info
    ) async throws {
        _ = try await send(HostRequests.Toast(message: message, toastType: toastType))
    }

    /// Get the existed workspaces.
    public func getExistedWorkspaces() async throws -> [WorkspaceInfo] {
        try await send(HostRequests.GetExistedWorkspaces())
    }

    /// Run a command from a source editor extension.
    /// - Parameters:
    ///   - extensionName: The name of the extension. It should be in the editor menu.
    ///                    e.g. "Copilot".
    ///   - command: The command to run. It should be in the extension menu. e.g. "Get Suggestions".
    ///   - activateXcode: Whether to force activate Xcode before running the command.
    ///
    /// - Note: A command won't run when Xcode is not active. If you want to make sure that the
    ///         command will run, you can set `activateXcode` to `true`. But please note that it
    ///         will bring Xcode to the front.
    public func triggerExtensionCommand(
        extensionName: String,
        command: String,
        activateXcode: Bool = false
    ) async throws {
        _ = try await send(HostRequests.TriggerExtensionCommand(
            extensionName: extensionName,
            command: command,
            activateXcode: activateXcode
        ))
    }

    /// Click a menu item from a source editor extension.
    /// - Parameters:
    ///   - path: The path of the menu item. e.g. ["Product", "Run"].
    ///   - activateXcode: Whether to force activate Xcode before triggering the menu item.
    ///
    /// - Note: A menu item won't trigger when Xcode is not active. If you want to make sure
    ///         that the command will run, you can set `activateXcode` to `true`. But please note
    ///         that it will bring Xcode to the front.
    public func triggerMenuItem(
        path: [String],
        activateXcode: Bool = false
    ) async throws {
        _ = try await send(HostRequests.TriggerMenuItem(path: path, activateXcode: activateXcode))
    }

    /// Get the active editor.
    public func getActiveEditor() async throws -> Editor? {
        try await send(HostRequests.GetActiveEditor())
    }
    
    /// Get the xcode information.
    public func getXcodeInformation() async throws -> XcodeInfo {
        try await send(HostRequests.GetXcodeInformation())
    }
}

@_spi(CopilotForXcodeSPI)
public extension HostRequestType {
    static func handle(
        endpoint: String,
        requestBody data: Data,
        reply: @escaping (Data?, Error?) -> Void,
        handler: @escaping (Self) async throws -> Self.ResponseBody
    ) throws {
        try _handle(
            endpoint: endpoint,
            requestBody: data,
            reply: reply
        ) { (request: Self) async throws -> Self.ResponseBody in
            try await handler(request)
        } onceResponded: {}
    }
}

