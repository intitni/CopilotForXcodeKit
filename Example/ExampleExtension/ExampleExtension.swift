import CopilotForXcodeKit
import Foundation

/// Typically, you must implement a sub class of ``CopilotForXcodeExtension`` and
/// mark it as the main entry point.
@main
class Extension: CopilotForXcodeExtension {
    
    /// 1. Provide a suggestion service if needed. You can simply give it a default value here.
    var suggestionService: SuggestionService?
    
    /// 2. Provide a scene configuration if needed. You can simply give it a default value here.
    var sceneConfiguration = SceneConfiguration()

    required init() {
        let service = SuggestionService()
        suggestionService = service
        super.init()
        /// If you need to access the global ``HostServer`` from the services.
        service.ext = self
    }
    
    /// 3. Set up the observers to keep track of the events from Xcode.
    //

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
        for tab in runningChatTabs {
            Task {
                /// You can forward the notification to all running chat tabs by posting
                /// a notification.
                try await tab.postNotification(
                    name: "Extension.workspaceDidOpenDocument",
                    info: documentURL
                )
            }
        }
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

