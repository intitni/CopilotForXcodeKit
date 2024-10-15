import Foundation

public struct ExtensionChatTabInfo: Codable, Equatable {
    /// The kind of a chat tab.
    public enum Kind: Codable {
        /// The web content can be either a HTML string, a URL or a file URL.
        public enum WebContent: Codable, Equatable {
            /// A web URL or a file URL.
            case url(URL)
            /// A HTML string.
            case html(String)
        }

        /// A `ExtensionKit` scene.
        ///
        /// - warning: Consider using another kind because `ExtensionKit` scene is
        /// not designed to run indefinitely. In order to workaround all the issues of the scenes,
        /// such custom chat tab will cut the connection when it's no longer active and reload it
        /// whenever it's back active again. The state will not be persisted across connections.
        ///
        /// - warning: It will also slow down the host window and heavily bring up the CPU usage.
        case extensionKit(id: String)
        /// A web view base chat tab. You can access the APIs through Javascript. The web content
        /// can be either a HTML string, a URL or a file URL.
        case webView(WebContent)
        /// Unknown.
        case unknown
    }

    /// The unique identifier of the chat tab. You will need it to determine the kind of a chat tab.
    public let kindId: String
    /// The title of the chat tab.
    public let title: String
    /// Setting it to `true` will allow the user to choose it as the open chat command handler.
    public var canHandleOpenChatCommand: Bool

    /// Initialize a new chat panel scene info.
    /// - Parameters:
    ///  - id: The unique identifier of the chat
    ///  - title: The title of the chat tab.
    ///  - canHandleOpenChatCommand: Setting it to `true` will allow the user to choose it as the
    /// open chat command handler.
    public init(
        kindId: String,
        title: String,
        canHandleOpenChatCommand: Bool = false
    ) {
        self.kindId = kindId
        self.title = title
        self.canHandleOpenChatCommand = canHandleOpenChatCommand
    }
}


