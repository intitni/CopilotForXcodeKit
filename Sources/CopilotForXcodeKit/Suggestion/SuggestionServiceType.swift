import CopilotForXcodeModel
import Foundation

/// A configuration for the host to decide it's behavior when using the service.
public struct SuggestionServiceConfiguration: Codable {
    /// Not implemented yet.
    ///
    /// If true, the app will collect relevant code snippets for the code.
    /// Return `false` if you are doing it by yourself.
    public var acceptsRelevantCodeSnippets: Bool

    public init(
        acceptsRelevantCodeSnippets: Bool
    ) {
        self.acceptsRelevantCodeSnippets = acceptsRelevantCodeSnippets
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
    func notifyAccepted( _ suggestion: CodeSuggestion, workspace: WorkspaceInfo ) async
    
    /// Notify that the suggestions are rejected.
    func notifyRejected( _ suggestions: [CodeSuggestion], workspace: WorkspaceInfo ) async

    /// Cancel requests.
    func cancelRequest(workspace: WorkspaceInfo) async
}

