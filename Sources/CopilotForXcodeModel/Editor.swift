import Foundation

/// The information of an editor.
///
/// Please keep this type backward compatible.
public struct Editor: Codable {
    public struct LineAnnotation {
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

        public init(
            content: String,
            lines: [String],
            selections: [CursorRange],
            cursorPosition: CursorPosition,
            lineAnnotations: [LineAnnotation]
        ) {
            self.content = content
            self.lines = lines
            self.selections = selections
            self.cursorPosition = cursorPosition
            self.lineAnnotations = lineAnnotations
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
    /// The selected content.
    public let selectedContent: String
    /// The selected content in lines.
    public let selectedLines: [String]

    init(
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
        relativePath = documentURL.path.replacingOccurrences(of: projectURL.path, with: "")
        self.language = language
        let (selectedContent, selectedLines) = Self.code(
            in: editorContent.lines,
            inside: range
        )
        self.selectedContent = selectedContent
        self.selectedLines = selectedLines
    }
}

public extension Editor {
    /// Get code inside the range.
    func code(in range: CursorRange) -> String {
        return Self.code(in: editorContent?.lines ?? [], inside: range).code
    }

    /// Get lines inside the range.
    static func lines(in code: [String], containing range: CursorRange) -> [String] {
        guard !code.isEmpty else { return [] }
        let startIndex = min(max(0, range.start.line), code.endIndex - 1)
        let endIndex = min(max(startIndex, range.end.line), code.endIndex - 1)
        let selectedLines = code[startIndex...endIndex]
        return Array(selectedLines)
    }

    /// Get code and its lines inside the range.
    static func code(
        in code: [String],
        inside range: CursorRange,
        ignoreColumns: Bool = false
    ) -> (code: String, lines: [String]) {
        let rangeLines = lines(in: code, containing: range)
        if ignoreColumns {
            return (rangeLines.joined(), rangeLines)
        }
        var content = rangeLines
        if !content.isEmpty {
            let dropLastCount = max(0, content[content.endIndex - 1].count - range.end.character)
            content[content.endIndex - 1] = String(
                content[content.endIndex - 1].dropLast(dropLastCount)
            )
            let dropFirstCount = max(0, range.start.character)
            content[0] = String(content[0].dropFirst(dropFirstCount))
        }
        return (content.joined(), rangeLines)
    }
}

extension Editor {
    /// Parse line annotation.
    ///
    /// e.g. Error Line 25: FileName.swift:25 Cannot convert Type
    static func parseLineAnnotation(_ annotation: String) -> LineAnnotation {
        let lineAnnotationParser = Parse(input: Substring.self) {
            PrefixUpTo(":")
            ":"
            PrefixUpTo(":")
            ":"
            Int.parser()
            Prefix(while: { _ in true })
        }.map { (prefix: Substring, _: Substring, line: Int, message: Substring) in
            let type = String(prefix.split(separator: " ").first ?? prefix)
            return LineAnnotation(
                type: type.trimmingCharacters(in: .whitespacesAndNewlines),
                line: line,
                message: message.trimmingCharacters(in: .whitespacesAndNewlines)
            )
        }

        do {
            return try lineAnnotationParser.parse(annotation[...])
        } catch {
            return .init(type: "", line: 0, message: annotation)
        }
    }
}

