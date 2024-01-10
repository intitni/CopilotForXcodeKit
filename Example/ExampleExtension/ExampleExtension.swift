import CopilotForXcodeKit
import Foundation

@main
class Extension: CopilotForXcodeExtension {
    var host: HostServer?
    var suggestionService: SuggestionServiceType?
    var chatService: ChatServiceType? = nil
    var promptToCodeService: PromptToCodeServiceType? = nil
    var sceneConfiguration = SceneConfiguration()

    required init() {
        let service = SuggestionService()
        suggestionService = service
        
        /// If you need to access the global ``HostServer`` from the services.
        service.ext = self
    }

    func connectionDidActivate(connectedTo host: HostServer) {
        /// When this method is called, the ``host`` property will be set automatically.

        Task {
            try await host.toast("Connected to Example Extension")
        }
    }

    /// You can use these optional methods to observe changes in the workspace.
    /// Check the ``CopilotForXcodeExtension`` protocol for details.
    //
    
    func workspace(_ workspace: WorkspaceInfo, didOpenDocumentAt documentURL: URL) {
        Task {
            try await host?.toast("Opened \(documentURL.lastPathComponent)")
        }
    }

    func workspace(_ workspace: WorkspaceInfo, didCloseDocumentAt documentURL: URL) {
        Task {
            try await host?.toast("Closed \(documentURL.lastPathComponent)")
        }
    }
}

