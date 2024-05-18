import ExtensionFoundation
import ExtensionKit
import Foundation
import SwiftUI

/// The definition of the extension.
///
/// Conform the entry point of your extension to this protocol.
///
/// ```swift
/// @main
/// class MyExtension: CopilotForXcodeExtension {}
/// ```
///
/// Copilot for Xcode will initiate the extension at launch and when users enable the extension.
/// Once connected, ``connectionDidActivate(connectedTo:)`` is called, and ``host`` is set.
///
/// ``host`` is then available for communication with the host app.
///
/// For scenes, each has a separate connection to the host app. While you can still use ``host``,
/// ``CopilotForXcodeSceneModel/host`` is recommended for easier communication within scenes.
///
/// ## Observing the Workspace
///
/// Use `workspace`-prefixed methods to monitor workspace changes.
///
/// Note that workspaces may be open prior to extension activation.
/// In this case, use ``HostServer/getExistedWorkspaces`` to fetch all ``WorkspaceInfo``.
///
/// ## Providing UI
///
/// If your extension includes UI, provide a ``CopilotForXcodeExtensionSceneConfiguration``
/// implementation via ``sceneConfiguration``.
///
/// ## Providing Suggestion Service
///
/// If your extension offers a suggestion service, return it via ``suggestionService``.
///
/// ## Providing Chat Service
///
/// Currently unimplemented. Return nil from ``chatService``.
///
/// ## Providing Prompt to Code Service
///
/// Currently unimplemented. Return nil from ``promptToCodeService``.
///
@available(macOS 13.0, *)
public protocol CopilotForXcodeExtension:
    AnyObject,
    AppExtension,
    CopilotForXcodeExtensionCapability
{
    associatedtype TheSceneConfiguration: CopilotForXcodeExtensionSceneConfiguration

    /// The host app, aka the extension service of Copilot for Xcode.app. You can use this
    /// object to communicate with the host app.
    ///
    /// You don't have to worry about it's value, it will be set once the connection is ready.
    var host: HostServer? { get set }
    /// Define scenes of the extension. You can use it to provide UI for the extension.
    var sceneConfiguration: TheSceneConfiguration { get }

    // MARK: Optional Methods

    /// Check if the connection should be accepted.
    func shouldAccept(_ connection: NSXPCConnection) -> Bool

    /// Called when connection is activated. You don't have to set the `host` property here.
    func connectionDidActivate(connectedTo host: HostServer)

    /// Called when the host app decides to quit this app. As soon as this function returns
    /// the app will call `exit(0)` to kill itself.
    func extensionWillTerminate()
}

// MARK: - Capability

public protocol CopilotForXcodeExtensionCapability {
    /// The suggestion service.
    ///
    /// Provide a non nil value if the extension provides a suggestion service, even if
    /// the extension is not yet ready to provide suggestions.
    ///
    /// Leave it `nil` if the extension does not provide a suggestion service.
    var suggestionService: SuggestionServiceType? { get }
    /// Not implemented yet.
    var chatService: ChatServiceType? { get }
    /// Not implemented yet.
    var promptToCodeService: PromptToCodeServiceType? { get }

    // MARK: Optional Methods

    /// Called when a workspace is opened.
    ///
    /// A workspace may have already been opened when the extension is activated.
    /// Use ``HostServer/getExistedWorkspaces()`` to get all ``WorkspaceInfo`` instead.
    func workspaceDidOpen(_ workspace: WorkspaceInfo)

    /// Called when a workspace is closed.
    func workspaceDidClose(_ workspace: WorkspaceInfo)

    /// Called when a document is saved.
    func workspace(_ workspace: WorkspaceInfo, didSaveDocumentAt documentURL: URL)

    /// Called when a document is closed.
    ///
    /// - note: Copilot for Xcode doesn't know that a document is closed. It use
    /// some mechanism to detect if the document is closed which is inaccurate and could be delayed.
    func workspace(_ workspace: WorkspaceInfo, didCloseDocumentAt documentURL: URL)

    /// Called when a document is opened.
    ///
    /// - note: Copilot for Xcode doesn't know that a document is opened. It use
    /// some mechanism to detect if the document is opened which is inaccurate and could be delayed.
    func workspace(_ workspace: WorkspaceInfo, didOpenDocumentAt documentURL: URL)

    /// Called when a document is changed.
    func workspace(
        _ workspace: WorkspaceInfo,
        didUpdateDocumentAt documentURL: URL,
        content: String
    )

    /// Called when the application configuration is changed. The configuration contains information
    /// like the current user-picked suggestion service, etc. You can use this to determine if
    /// you would like to startup or dispose some resources.
    ///
    /// For example, if you are running a language server to provide suggestions, you may want to
    /// kill the process when the user switched to another suggestion service.
    func appConfigurationDidChange(_ configuration: AppConfiguration)
}

// MARK: - Default Implementation

@available(macOS 13.0, *)
public extension CopilotForXcodeExtension {
    var configuration: AppExtensionSceneConfiguration {
        return .init(
            // swiftformat:disable:next all
            self.sceneConfiguration.body,
            configuration: CopilotForXcodeExtensionConfiguration(self)
        )
    }

    func shouldAccept(_: NSXPCConnection) -> Bool { true }

    func extensionWillTerminate() {}

    func connectionDidActivate(connectedTo host: HostServer) {}
}

public extension CopilotForXcodeExtensionCapability {
    func xcodeDidBecomeActive() {}

    func xcodeDidBecomeInactive() {}

    func xcodeDidSwitchEditor() {}

    func workspaceDidOpen(_: WorkspaceInfo) {}

    func workspaceDidClose(_: WorkspaceInfo) {}

    func workspace(_: WorkspaceInfo, didSaveDocumentAt _: URL) {}

    func workspace(_: WorkspaceInfo, didCloseDocumentAt _: URL) {}

    func workspace(_: WorkspaceInfo, didOpenDocumentAt _: URL) {}

    func workspace(_: WorkspaceInfo, didUpdateDocumentAt _: URL, content: String) {}
    
    func appConfigurationDidChange(_: AppConfiguration) {}
}

// MARK: - Extension Configuration

@available(macOS 13.0, *)
public struct CopilotForXcodeExtensionConfiguration<
    E: CopilotForXcodeExtension
>: AppExtensionConfiguration {
    let theExtension: E
    let server: ExtensionXPCServer

    public init(_ theExtension: E) {
        self.theExtension = theExtension
        server = .init(theExtension: theExtension)
    }
}

@available(macOS 13.0, *)
public extension CopilotForXcodeExtensionConfiguration {
    /// Accept the XPC connection from the host.
    func accept(connection: NSXPCConnection) -> Bool {
        Logger.info("Extension scene did receive connection.")

        guard theExtension.shouldAccept(connection) else { return false }
        connection.exportedInterface = NSXPCInterface(with: ExtensionXPCProtocol.self)
        connection.exportedObject = server
        connection.remoteObjectInterface = NSXPCInterface(with: HostXPCProtocol.self)

        connection.activate()

        let host = HostServer(connection)
        theExtension.host = host
        theExtension.connectionDidActivate(connectedTo: host)

        return true
    }
}

// MARK: - App Configuration

public struct AppConfiguration: Codable, Equatable {
    /// If the suggestion service in this extension is in use.
    public var suggestionServiceInUse: Bool
    /// If the chat service in this extension is in use.
    public var chatServiceInUse: Bool

    public init(suggestionServiceInUse: Bool, chatServiceInUse: Bool) {
        self.suggestionServiceInUse = suggestionServiceInUse
        self.chatServiceInUse = chatServiceInUse
    }
}

