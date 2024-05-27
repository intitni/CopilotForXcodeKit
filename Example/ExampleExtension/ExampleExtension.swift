import CopilotForXcodeKit
import Foundation

/// Typically, you must implement a sub class of ``CopilotForXcodeExtension`` and
/// mark it as the main entry point.
@main
class Extension: CopilotForXcodeExtension {
    var suggestionService: SuggestionService?
    var sceneConfiguration = SceneConfiguration()

    required init() {
        let service = SuggestionService()
        suggestionService = service
        super.init()
        /// If you need to access the global ``HostServer`` from the services.
        service.ext = self
    }

    /// When this method is called, the ``host`` property will be set automatically.
    func connectionDidActivate(connectedTo host: HostServer) {
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

/// Everything has a default implementation.
class EmptyExtension: CopilotForXcodeExtension {}
