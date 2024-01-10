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

    public struct RunCommand: HostRequestType {
        public var extensionName: String
        public var command: String
        public typealias ResponseBody = NoResponse
        public static let endpoint = "RunCommand"
    }

    public struct ClickMenuItem: HostRequestType {
        public var path: [String]
        public typealias ResponseBody = NoResponse
        public static let endpoint = "ClickMenuItem"
    }

    public struct GetExistedWorkspaces: HostRequestType {
        public typealias ResponseBody = [WorkspaceInfo]
        public static let endpoint = "getExistedWorkspaces"
    }
    
    public struct GetActiveEditor: HostRequestType {
        public typealias ResponseBody = Editor?
        public static let endpoint = "GetActiveEditor"
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
    public func runCommand(_ extensionName: String, _ command: String) async throws {
        _ = try await send(HostRequests.RunCommand(extensionName: extensionName, command: command))
    }

    /// Click a menu item from a source editor extension.
    /// - Parameters:
    ///  - path: The path of the menu item. e.g. ["Product", "Run"].
    public func clickMenuItem(_ path: [String]) async throws {
        _ = try await send(HostRequests.ClickMenuItem(path: path))
    }
    
    /// Get the active editor.
    public func getActiveEditor() async throws -> Editor? {
        try await send(HostRequests.GetActiveEditor())
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
        }
    }
}

