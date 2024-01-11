import Foundation

/// The information of an editor.
///
/// Please keep this type backward compatible.
public struct Editor: Codable {
    public struct LineAnnotation: Codable {
        /// The type of the line annotation.
        public var type: String
        /// The line index (one-based) of the line annotation.
        public var line: Int
        /// The message of the line annotation.
        public var message: String

        public init(type: String, line: Int, message: String) {
            self.type = type
            self.line = line
            self.message = message
        }
    }

    public struct Content: Codable {
        /// The content of the source editor.
        public var content: String
        /// The content of the source editor in lines. Every line should ends with `\n`.
        public var lines: [String]
        /// The selection ranges of the source editor.
        public var selections: [CursorRange]
        /// The cursor position of the source editor.
        public var cursorPosition: CursorPosition
        /// Line annotations of the source editor.
        public var lineAnnotations: [LineAnnotation]
        /// The selected content.
        public var selectedContent: String

        public init(
            content: String,
            lines: [String],
            selections: [CursorRange],
            cursorPosition: CursorPosition,
            lineAnnotations: [LineAnnotation],
            selectedContent: String
        ) {
            self.content = content
            self.lines = lines
            self.selections = selections
            self.cursorPosition = cursorPosition
            self.lineAnnotations = lineAnnotations
            self.selectedContent = selectedContent
        }
    }

    /// The content in the editor.
    public let editorContent: Content?
    /// The document location of the project.
    public let documentURL: URL
    /// The workspace location of the project.
    public let workspaceURL: URL
    /// The root of the project.
    public let projectRootURL: URL
    /// The relative path of the file to the project root.
    public let relativePath: String
    /// The language of the file.
    public let language: CodeLanguage

    public init(
        documentURL: URL,
        workspaceURL: URL,
        projectRootURL: URL,
        language: CodeLanguage,
        editorContent: Content?
    ) {
        self.editorContent = editorContent
        self.documentURL = documentURL
        self.workspaceURL = workspaceURL
        self.projectRootURL = projectRootURL
        relativePath = documentURL.path.replacingOccurrences(of: projectRootURL.path, with: "")
        self.language = language
    }
}

