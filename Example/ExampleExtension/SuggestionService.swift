import CopilotForXcodeKit
import Foundation

/// Copilot for Xcode will use one instance of the service for all workspace. If you need to
/// maintain multiple services for each workspace, you will have to manage their life cycle by
/// yourself.
///
/// You can use ``HostServer.getExistedWorkspaces()`` to get all existed workspaces on start, and
/// use observers in the ``Extension`` type to determine if you need to create or destroy a service.
//

final class SuggestionService: SuggestionServiceType {
    /// You can pass the extension instance to the service so you can communicate to the host.
    weak var ext: Extension?

    var configuration: SuggestionServiceConfiguration {
        /// Not implemented yet.
        .init(acceptsRelevantCodeSnippets: true)
    }

    func getSuggestions(
        _ request: SuggestionRequest,
        
        /// If you are maintaining multiple services for each workspace, use this parameter
        /// to identify which workspace the request is for.
        ///
        /// It is also recommended to cancel all the previous requests here. If not, you can
        /// cancel the previous request in the ``cancelRequest(workspace:)`` method.
        ///
        /// Please check the implementation of ``CodeSuggestion`` for the format of a suggestion.
        workspace: WorkspaceInfo
    ) async throws -> [CodeSuggestion] {
        try await ext?.host?.toast("Get Suggestions")
        return [
            .init(
                id: UUID().uuidString,
                text: "Hello World",
                position: request.cursorPosition,
                range: .init(start: request.cursorPosition, end: request.cursorPosition)
            ),
        ]
    }

    func notifyAccepted(
        _ suggestion: CodeSuggestion,
        workspace: WorkspaceInfo
    ) async {
        try? await ext?.host?.toast("Accepted!")
    }

    func notifyRejected(
        _ suggestions: [CodeSuggestion],
        workspace: WorkspaceInfo
    ) async {
        try? await ext?.host?.toast("Rejected!")
    }

    func cancelRequest(workspace: WorkspaceInfo) async {
        try? await ext?.host?.toast("Canceled!")
    }
}
