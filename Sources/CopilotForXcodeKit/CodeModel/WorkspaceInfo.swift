import Foundation

/// The information of a workspace.
///
/// - note: If you need to use some of the information as an ID, use ``workspaceURL`` instead of
/// ``projectURL``.
public struct WorkspaceInfo: Codable, Identifiable {
    /// An id.
    public var id: String { workspaceURL.path }
    /// URL to a workspace or project file.
    public let workspaceURL: URL
    /// URL of the project root path.
    public let projectURL: URL

    public init(workspaceURL: URL, projectURL: URL) {
        self.workspaceURL = workspaceURL
        self.projectURL = projectURL
    }
}

