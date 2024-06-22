import CodableWrappers
import Foundation

/// A configuration for the host to decide it's behavior when using the service.
public struct SuggestionServiceConfiguration: Codable {
    /// If true, the app will collect relevant code snippets for the code.
    /// Return `false` if you are doing it by yourself.
    @FallbackDecoding<EmptyBool>
    public var acceptsRelevantCodeSnippets: Bool

    /// If true, the app will collect relevant code snippets from the opened files.
    /// Return `false` if you are doing it by yourself.
    @FallbackDecoding<EmptyBool>
    public var acceptsRelevantSnippetsFromOpenedFiles: Bool

    /// If true, the app will put the snippets into the source content.
    /// Useful when you don't have full control to the service.
    @FallbackDecoding<EmptyBool>
    public var mixRelevantCodeSnippetsInSource: Bool

    public init(
        acceptsRelevantCodeSnippets: Bool,
        mixRelevantCodeSnippetsInSource: Bool,
        acceptsRelevantSnippetsFromOpenedFiles: Bool
    ) {
        self.acceptsRelevantCodeSnippets = acceptsRelevantCodeSnippets
        self.mixRelevantCodeSnippetsInSource = mixRelevantCodeSnippetsInSource
        self.acceptsRelevantSnippetsFromOpenedFiles = acceptsRelevantSnippetsFromOpenedFiles
    }
}

/// A suggestion service should implement this protocol.
///
/// If you need to maintain multiple suggestion services for each workspace
/// (for example, using language servers), you have to maintain the lifecycle of each service
/// yourself.
public protocol SuggestionServiceType {
    /// A configuration for the host to decide it's behavior when using the service.
    var configuration: SuggestionServiceConfiguration { get }

    /// Get suggestions for the given request.
    func getSuggestions(
        _ request: SuggestionRequest,
        workspace: WorkspaceInfo
    ) async throws -> [CodeSuggestion]

    /// Notify that the suggestion is accepted.
    func notifyAccepted(_ suggestion: CodeSuggestion, workspace: WorkspaceInfo) async

    /// Notify that the suggestions are rejected.
    func notifyRejected(_ suggestions: [CodeSuggestion], workspace: WorkspaceInfo) async

    /// Cancel requests.
    func cancelRequest(workspace: WorkspaceInfo) async
}

public struct SuggestionServiceNoticeError: Error, LocalizedError {
    public let error: Error
    public init(error: Error) {
        self.error = error
    }
    
    public var errorDescription: String? { error.localizedDescription }
}

public struct NoSuggestionService: SuggestionServiceType {
    public var configuration: SuggestionServiceConfiguration

    public func getSuggestions(
        _ request: SuggestionRequest,
        workspace: WorkspaceInfo
    ) async throws -> [CodeSuggestion] {
        return []
    }

    public func notifyAccepted(_ suggestion: CodeSuggestion, workspace: WorkspaceInfo) async {}

    public func notifyRejected(_ suggestions: [CodeSuggestion], workspace: WorkspaceInfo) async {}

    public func cancelRequest(workspace: WorkspaceInfo) async {}
}

