import Foundation

public struct RelevantCodeSnippet: Codable {
    public var content: String
    public var priority: Int

    public init(content: String, priority: Int) {
        self.content = content
        self.priority = priority
    }
}

/// A request to generate suggestions.
public struct SuggestionRequest: Codable {
    /// The file URL of the file for which suggestions should be generated.
    public var fileURL: URL
    /// The content. Please not that the content may not be exactly the same as the file content.
    public var content: String
    /// The cursor position in the content.
    public var cursorPosition: CursorPosition
    /// Tab size.
    public var tabSize: Int
    /// Indentation size.
    public var indentSize: Int
    /// Whether the file uses tabs for indentation.
    public var usesTabsForIndentation: Bool
    /// Relevant code snippets.
    ///
    /// It will be empty if ``SuggestionServiceConfiguration/acceptsRelevantCodeSnippets`` is false.
    public var relevantCodeSnippets: [RelevantCodeSnippet]

    public init(
        fileURL: URL,
        content: String,
        cursorPosition: CursorPosition,
        tabSize: Int,
        indentSize: Int,
        usesTabsForIndentation: Bool,
        relevantCodeSnippets: [RelevantCodeSnippet]
    ) {
        self.fileURL = fileURL
        self.content = content
        self.cursorPosition = cursorPosition
        self.tabSize = tabSize
        self.indentSize = indentSize
        self.usesTabsForIndentation = usesTabsForIndentation
        self.relevantCodeSnippets = relevantCodeSnippets
    }
}

