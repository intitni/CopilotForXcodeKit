import ExtensionFoundation
import ExtensionKit
import Foundation
import SwiftUI

/// The definition of the extension.
///
/// Conform the entry point of your extension to this type.
///
/// ```swift
/// @main
/// class MyExtension: CopilotForXcodeExtension {}
/// ```
///
/// Copilot for Xcode will initiate the extension at launch and when users enable the extension.
/// Once connected, ``connectionDidActivate(connectedTo:)`` is called, and
/// ``CopilotForXcodeExtensionBase/host`` is set.
///
/// ``CopilotForXcodeExtensionBase/host`` is then available for communication with the host app.
///
/// For scenes, each has a separate connection to the host app. While you can still use
/// ``CopilotForXcodeExtensionBase/host``,
/// ``CopilotForXcodeSceneModel/host`` is recommended for easier communication within scenes.
///
/// ## Observing the Workspace
///
/// Use `workspace`-prefixed methods to monitor workspace changes.
///
/// Note that workspaces may be open prior to extension activation.
/// In this case, use ``HostServer/getExistedWorkspaces()`` to fetch all ``WorkspaceInfo``.
///
/// ## Providing UI
///
/// If your extension includes UI, provide a ``CopilotForXcodeExtensionSceneConfiguration``
/// implementation via ``CopilotForXcodeExtensionProtocol/sceneConfiguration``.
///
/// ## Providing Suggestion Service
///
/// If your extension offers a suggestion service, return it via
/// ``CopilotForXcodeExtensionCapability/suggestionService``.
///
/// ## Providing Chat Service
///
/// Currently unimplemented. Return nil from ``CopilotForXcodeExtensionCapability/chatService``.
///
/// ## Providing Prompt to Code Service
///
/// Currently unimplemented. Return nil from
/// ``CopilotForXcodeExtensionCapability/promptToCodeService``.
///
@available(macOS 13.0, *)
public typealias CopilotForXcodeExtension =
    CopilotForXcodeExtensionBase
        & CopilotForXcodeExtensionProtocol

/// The base class of the extension.
@available(macOS 13.0, *)
open class CopilotForXcodeExtensionBase {
    /// The host app, aka the extension service of Copilot for Xcode.app. You can use this
    /// object to communicate with the host app.
    ///
    /// You don't have to worry about it's value, it will be set once the connection is ready.
    public internal(set) var host: HostServer?

    /// The usage of this extension in Copilot for Xcode.
    ///
    /// It will begin with everything unused until Copilot for Xcode reports it's usage.
    public internal(set) var extensionUsage: ExtensionUsage = .init(
        isSuggestionServiceInUse: false,
        isChatServiceInUse: false
    )

    public required init() {}
}

/// The interface of the extension.
@available(macOS 13.0, *)
public protocol CopilotForXcodeExtensionProtocol:
    AnyObject,
    AppExtension,
    CopilotForXcodeExtensionCapability
{
    associatedtype TheSceneConfiguration: CopilotForXcodeExtensionSceneConfiguration

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
    associatedtype TheSuggestionService: SuggestionServiceType
    associatedtype TheChatService: ChatServiceType
    associatedtype ThePromptToCodeService: PromptToCodeServiceType

    /// The suggestion service.
    ///
    /// Provide a non nil value if the extension provides a suggestion service, even if
    /// the extension is not yet ready to provide suggestions.
    ///
    /// If you don't have a suggestion service in this extension, simply ignore this property.
    var suggestionService: TheSuggestionService? { get }
    /// Not implemented yet.
    var chatService: TheChatService? { get }
    /// Not implemented yet.
    var promptToCodeService: ThePromptToCodeService? { get }

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
    ///
    /// - attention: `content` could be nil if \
    ///   • the document is too large \
    ///   • the document is binary \
    ///   • the document is git ignored \
    ///   • the extension is not considered in-use by the host app \
    ///   • the extension has no permission to access the file \
    ///   \
    ///   If you still want to access the file content in these cases,
    ///   you will have to access the file by yourself, or call ``HostServer/getDocument(at:)``.
    func workspace(
        _ workspace: WorkspaceInfo,
        didUpdateDocumentAt documentURL: URL,
        content: String?
    )

    /// Called occasionally to inform the extension how it is used in the app.
    ///
    /// The `usage` contains information like the current user-picked suggestion service, etc.
    /// You can use this to determine if you would like to startup or dispose some resources.
    ///
    /// For example, if you are running a language server to provide suggestions, you may want to
    /// kill the process when the suggestion service is no longer in use.
    func extensionUsageDidChange(_ usage: ExtensionUsage)
}

// MARK: - Default Implementation

@available(macOS 13.0, *)
public extension CopilotForXcodeExtensionProtocol where Self: CopilotForXcodeExtensionBase {
    var configuration: AppExtensionSceneConfiguration {
        return .init(
            // swiftformat:disable:next all
            self.sceneConfiguration.body,
            configuration: CopilotForXcodeExtensionConfiguration(self)
        )
    }
}

@available(macOS 13.0, *)
public extension CopilotForXcodeExtensionProtocol {
    func shouldAccept(_: NSXPCConnection) -> Bool { true }
    
    func extensionWillTerminate() {}
    
    func connectionDidActivate(connectedTo host: HostServer) {}
}

@available(macOS 13.0, *)
extension CopilotForXcodeExtensionProtocol {
    var extensionInfo: ExtensionInfo {
        return ExtensionInfo(
            providesSuggestionService: suggestionService != nil,
            suggestionServiceConfiguration: suggestionService?.configuration,
            providesChatService: chatService != nil,
            providesPromptToCodeService: promptToCodeService != nil,
            hasConfigurationScene: sceneConfiguration.hasConfigurationScene,
            chatPanelSceneInfo: sceneConfiguration.chatPanelSceneInfo
        )
    }
}

@available(macOS 13.0, *)
public extension CopilotForXcodeExtensionProtocol
    where TheSceneConfiguration == NoSceneConfiguration
{
    var sceneConfiguration: NoSceneConfiguration { NoSceneConfiguration() }
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

    func workspace(
        _ workspace: WorkspaceInfo,
        didUpdateDocumentAt documentURL: URL,
        content: String?
    ) {}

    func extensionUsageDidChange(_: ExtensionUsage) {}
}

public extension CopilotForXcodeExtensionCapability
    where TheSuggestionService == NoSuggestionService
{
    var suggestionService: TheSuggestionService? { nil }
}

public extension CopilotForXcodeExtensionCapability
    where ThePromptToCodeService == NoPromptToCodeService
{
    var promptToCodeService: ThePromptToCodeService? { nil }
}

public extension CopilotForXcodeExtensionCapability where TheChatService == NoChatService {
    var chatService: TheChatService? { nil }
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

public struct ExtensionUsage: Codable, Equatable {
    /// If the suggestion service in this extension is in use.
    public var isSuggestionServiceInUse: Bool
    /// If the chat service in this extension is in use.
    public var isChatServiceInUse: Bool

    public init(isSuggestionServiceInUse: Bool, isChatServiceInUse: Bool) {
        self.isSuggestionServiceInUse = isSuggestionServiceInUse
        self.isChatServiceInUse = isChatServiceInUse
    }
}
