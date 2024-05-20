import CodableWrappers
import ExtensionFoundation
import Foundation
import OSLog
import XPCConcurrency

/// The information of the extension. The struct should be implemented to be backward compatible.
public struct ExtensionInfo: Codable {
    /// The version of the protocol. It should be updated when there is a breaking change.
    public private(set) var version: Int = 1
    /// Whether the extension provides a suggestion service.
    public var providesSuggestionService: Bool
    /// The configuration of the suggestion service.
    public var suggestionServiceConfiguration: SuggestionServiceConfiguration?
    /// Whether the extension provides a chat service.
    public var providesChatService: Bool
    /// Whether the extension provides a prompt to code service.
    public var providesPromptToCodeService: Bool
    /// Whether the extension provides a configuration scene.
    public var hasConfigurationScene: Bool
    /// Chat panel scenes available.
    public var chatPanelSceneInfo: [ChatPanelSceneInfo]
}

/// The protocol of the extension server. You don't have to worry about implementing it yourself.
@_spi(CopilotForXcodeSPI)
@objc(CopilotForXcodeExtensionXPCProtocol)
public protocol ExtensionXPCProtocol: XPCProtocol {}

@_spi(CopilotForXcodeSPI)
public extension ExtensionXPCProtocol {
    func send<M: ExtensionRequestType, T>(
        requestBody: M,
        continuation: XPCServiceConnectionContinuation<T>
    ) throws where T == M.ResponseBody {
        try _send(endpoint: M.endpoint, requestBody: requestBody, continuation: continuation)
    }
}

public protocol ExtensionRequestType: XPCRequestType {}

extension ExtensionRequestType {
    static func handle(
        endpoint: String,
        requestBody data: Data,
        reply: @escaping (Data?, Error?) -> Void,
        handler: @escaping (Self) async throws -> Self.ResponseBody,
        onceResponded: @escaping () -> Void = {}
    ) throws {
        try _handle(
            endpoint: endpoint,
            requestBody: data,
            reply: reply
        ) { (request: Self) async throws -> Self.ResponseBody in
            try await handler(request)
        } onceResponded: {
            onceResponded()
        }
    }
}

/// Contains all request types.
///
/// Please keep all ``Codable`` types backward compatible.
public enum ExtensionRequests {
    public struct GetExtensionInformation: ExtensionRequestType {
        public typealias ResponseBody = ExtensionInfo
        public static let endpoint = "GetExtensionInformation"

        public init() {}
    }

    public struct Terminate: ExtensionRequestType {
        public typealias ResponseBody = NoResponse
        public static let endpoint = "Terminate"

        public init() {}
    }

    public struct NotifyActivateXcode: ExtensionRequestType {
        public typealias ResponseBody = NoResponse
        public static let endpoint = "NotifyActivateXcode"

        public init() {}
    }

    public struct NotifyDeactivateXcode: ExtensionRequestType {
        public typealias ResponseBody = NoResponse
        public static let endpoint = "NotifyDeactivateXcode"

        public init() {}
    }

    public struct NotifySwitchEditor: ExtensionRequestType {
        public typealias ResponseBody = NoResponse
        public static let endpoint = "NotifySwitchEditor"

        public init() {}
    }

    public struct NotifyOpenWorkspace: ExtensionRequestType {
        public var workspaceInfo: WorkspaceInfo
        public typealias ResponseBody = NoResponse
        public static let endpoint = "NotifyOpenWorkspace"

        public init(workspaceInfo: WorkspaceInfo) {
            self.workspaceInfo = workspaceInfo
        }
    }

    public struct NotifyCloseWorkspace: ExtensionRequestType {
        public var workspaceInfo: WorkspaceInfo
        public typealias ResponseBody = NoResponse
        public static let endpoint = "NotifyCloseWorkspace"

        public init(workspaceInfo: WorkspaceInfo) {
            self.workspaceInfo = workspaceInfo
        }
    }

    public struct NotifyOpenFile: ExtensionRequestType {
        public var fileURL: URL
        public var workspace: WorkspaceInfo
        public typealias ResponseBody = NoResponse
        public static let endpoint = "NotifyOpenFile"

        public init(fileURL: URL, workspace: WorkspaceInfo) {
            self.fileURL = fileURL
            self.workspace = workspace
        }
    }

    public struct NotifyCloseFile: ExtensionRequestType {
        public var fileURL: URL
        public var workspace: WorkspaceInfo
        public typealias ResponseBody = NoResponse
        public static let endpoint = "NotifyCloseFile"

        public init(fileURL: URL, workspace: WorkspaceInfo) {
            self.fileURL = fileURL
            self.workspace = workspace
        }
    }

    public struct NotifySaveFile: ExtensionRequestType {
        public var fileURL: URL
        public var workspace: WorkspaceInfo
        public typealias ResponseBody = NoResponse
        public static let endpoint = "NotifySaveFile"

        public init(fileURL: URL, workspace: WorkspaceInfo) {
            self.fileURL = fileURL
            self.workspace = workspace
        }
    }

    public struct NotifyUpdateFile: ExtensionRequestType {
        public var fileURL: URL
        public var workspace: WorkspaceInfo
        public var content: String?
        public typealias ResponseBody = NoResponse
        public static let endpoint = "NotifyUpdateFile"

        public init(fileURL: URL, workspace: WorkspaceInfo, content: String?) {
            self.fileURL = fileURL
            self.workspace = workspace
            self.content = content
        }
    }

    public struct NotifyExtensionUsageChange: ExtensionRequestType {
        public typealias ResponseBody = NoResponse
        public var usage: ExtensionUsage
        public static let endpoint = "NotifyExtensionUsageChange"

        public init(usage: ExtensionUsage) {
            self.usage = usage
        }
    }

    public enum SuggestionService {
        public struct GetSuggestions: ExtensionRequestType {
            public var request: SuggestionRequest
            public var workspace: WorkspaceInfo
            public struct ResponseBody: Codable {
                public let suggestions: [CodeSuggestion]
            }

            public static let endpoint = "SuggestionService/GetSuggestions"

            public init(request: SuggestionRequest, workspace: WorkspaceInfo) {
                self.request = request
                self.workspace = workspace
            }
        }

        public struct NotifyAccepted: ExtensionRequestType {
            public var suggestion: CodeSuggestion
            public var workspace: WorkspaceInfo
            public typealias ResponseBody = NoResponse
            public static let endpoint = "SuggestionService/NotifyAccepted"

            public init(suggestion: CodeSuggestion, workspace: WorkspaceInfo) {
                self.suggestion = suggestion
                self.workspace = workspace
            }
        }

        public struct NotifyRejected: ExtensionRequestType {
            public var suggestions: [CodeSuggestion]
            public var workspace: WorkspaceInfo
            public typealias ResponseBody = NoResponse
            public static let endpoint = "SuggestionService/NotifyRejected"

            public init(suggestions: [CodeSuggestion], workspace: WorkspaceInfo) {
                self.suggestions = suggestions
                self.workspace = workspace
            }
        }

        public struct CancelRequest: ExtensionRequestType {
            public var workspace: WorkspaceInfo
            public typealias ResponseBody = NoResponse
            public static let endpoint = "SuggestionService/CancelRequest"

            public init(workspace: WorkspaceInfo) {
                self.workspace = workspace
            }
        }
    }
}

// MARK: - XPC Server Implementation

@available(macOS 13.0, *)
@objc(CopilotForXcodeExtensionXPCServer)
final class ExtensionXPCServer: NSObject, ExtensionXPCProtocol {
    let theExtension: any CopilotForXcodeExtension

    init(theExtension: any CopilotForXcodeExtension) {
        self.theExtension = theExtension
    }

    func send(endpoint: String, requestBody: Data, reply: @escaping (Data?, Error?) -> Void) {
        Logger.info("Extension did receive request \(endpoint).")
        do {
            try ExtensionRequests.GetExtensionInformation.handle(
                endpoint: endpoint,
                requestBody: requestBody,
                reply: reply
            ) { [theExtension] _ in
                ExtensionInfo(
                    providesSuggestionService: theExtension.suggestionService != nil,
                    suggestionServiceConfiguration: theExtension.suggestionService?.configuration,
                    providesChatService: theExtension.chatService != nil,
                    providesPromptToCodeService: theExtension.promptToCodeService != nil,
                    hasConfigurationScene: theExtension.sceneConfiguration.hasConfigurationScene,
                    chatPanelSceneInfo: theExtension.sceneConfiguration.chatPanelSceneInfo
                )
            }

            try ExtensionRequests.Terminate.handle(
                endpoint: endpoint,
                requestBody: requestBody,
                reply: reply
            ) { _ in
                .none
            } onceResponded: { [theExtension] in
                theExtension.extensionWillTerminate()
                exit(0)
            }

            try ExtensionRequests.NotifyActivateXcode.handle(
                endpoint: endpoint,
                requestBody: requestBody,
                reply: reply
            ) { [theExtension] _ in
                theExtension.xcodeDidBecomeActive()
                return .none
            }

            try ExtensionRequests.NotifyDeactivateXcode.handle(
                endpoint: endpoint,
                requestBody: requestBody,
                reply: reply
            ) { [theExtension] _ in
                theExtension.xcodeDidBecomeInactive()
                return .none
            }

            try ExtensionRequests.NotifySwitchEditor.handle(
                endpoint: endpoint,
                requestBody: requestBody,
                reply: reply
            ) { [theExtension] _ in
                theExtension.xcodeDidSwitchEditor()
                return .none
            }

            try ExtensionRequests.NotifyOpenWorkspace.handle(
                endpoint: endpoint,
                requestBody: requestBody,
                reply: reply
            ) { [theExtension] request in
                theExtension.workspaceDidOpen(request.workspaceInfo)
                return .none
            }

            try ExtensionRequests.NotifyCloseWorkspace.handle(
                endpoint: endpoint,
                requestBody: requestBody,
                reply: reply
            ) { [theExtension] request in
                theExtension.workspaceDidClose(request.workspaceInfo)
                return .none
            }

            try ExtensionRequests.NotifyOpenFile.handle(
                endpoint: endpoint,
                requestBody: requestBody,
                reply: reply
            ) { [theExtension] request in
                theExtension.workspace(request.workspace, didOpenDocumentAt: request.fileURL)
                return .none
            }

            try ExtensionRequests.NotifyCloseFile.handle(
                endpoint: endpoint,
                requestBody: requestBody,
                reply: reply
            ) { [theExtension] request in
                theExtension.workspace(request.workspace, didCloseDocumentAt: request.fileURL)
                return .none
            }

            try ExtensionRequests.NotifySaveFile.handle(
                endpoint: endpoint,
                requestBody: requestBody,
                reply: reply
            ) { [theExtension] request in
                theExtension.workspace(request.workspace, didSaveDocumentAt: request.fileURL)
                return .none
            }

            try ExtensionRequests.NotifyUpdateFile.handle(
                endpoint: endpoint,
                requestBody: requestBody,
                reply: reply
            ) { [theExtension] request in
                theExtension.workspace(
                    request.workspace,
                    didUpdateDocumentAt: request.fileURL,
                    content: request.content
                )
                return .none
            }

            try ExtensionRequests.NotifyExtensionUsageChange.handle(
                endpoint: endpoint,
                requestBody: requestBody,
                reply: reply
            ) { [theExtension] request in
                if theExtension.extensionUsage != request.usage {
                    theExtension.extensionUsage = request.usage
                    theExtension.extensionUsageDidChange(request.usage)
                }
                return .none
            }

            try ExtensionRequests.SuggestionService.GetSuggestions.handle(
                endpoint: endpoint,
                requestBody: requestBody,
                reply: reply
            ) { [theExtension] request in
                guard let service = theExtension.suggestionService
                else { return .init(suggestions: []) }
                let suggestions = try await service.getSuggestions(
                    request.request,
                    workspace: request.workspace
                )
                return .init(suggestions: suggestions)
            }

            try ExtensionRequests.SuggestionService.NotifyAccepted.handle(
                endpoint: endpoint,
                requestBody: requestBody,
                reply: reply
            ) { [theExtension] request in
                guard let service = theExtension.suggestionService
                else { return .none }
                await service.notifyAccepted(request.suggestion, workspace: request.workspace)
                return .none
            }

            try ExtensionRequests.SuggestionService.NotifyRejected.handle(
                endpoint: endpoint,
                requestBody: requestBody,
                reply: reply
            ) { [theExtension] request in
                guard let service = theExtension.suggestionService
                else { return .none }
                await service.notifyRejected(request.suggestions, workspace: request.workspace)
                return .none
            }

            try ExtensionRequests.SuggestionService.CancelRequest.handle(
                endpoint: endpoint,
                requestBody: requestBody,
                reply: reply
            ) { [theExtension] request in
                guard let service = theExtension.suggestionService
                else { return .none }
                await service.cancelRequest(workspace: request.workspace)
                return .none
            }

        } catch is XPCRequestHandlerHitError {
            return
        } catch {
            reply(nil, error)
            return
        }

        Logger.error("""
        Extension didn't handle request \(endpoint). \
        Please update the package or report to the developer.
        """)
        reply(nil, XPCRequestNotHandledError())
    }
}

