import CodableWrappers
import Foundation

public struct RelevantCodeSnippet: Codable {
    public var content: String
    public var priority: Int
    @FallbackDecoding<EmptyString>
    public var filePath: String

    public init(content: String, priority: Int, filePath: String) {
        self.content = content
        self.priority = priority
        self.filePath = filePath
    }
}

/// A request to generate suggestions.
public struct SuggestionRequest: Codable {
    /// The file URL of the file for which suggestions should be generated.
    public var fileURL: URL
    /// The relativePath.
    public var relativePath: String?
    /// The language of the file.
    public var language: CodeLanguage?
    /// The content. Please not that the content may not be exactly the same as the file content.
    public var content: String
    /// The unchanged file content.
    @FallbackDecoding<EmptyString>
    public var originalContent: String
    /// The cursor position in the content.
    public var cursorPosition: CursorPosition
    /// Tab size.
    public var tabSize: Int
    /// Indentation size.
    public var indentSize: Int
    /// Whether the file uses tabs for indentation.
    public var usesTabsForIndentation: Bool
    /// Relevant code snippets. Already sorted by priority.
    ///
    /// It will be empty if ``SuggestionServiceConfiguration/acceptsRelevantCodeSnippets`` and
    /// ``SuggestionServiceConfiguration/acceptsRelevantSnippetsFromOpenedFiles`` are false or
    /// ``SuggestionServiceConfiguration/mixRelevantCodeSnippetsInSource`` is true.
    public var relevantCodeSnippets: [RelevantCodeSnippet]

    public init(
        fileURL: URL,
        relativePath: String,
        language: CodeLanguage,
        content: String,
        originalContent: String,
        cursorPosition: CursorPosition,
        tabSize: Int,
        indentSize: Int,
        usesTabsForIndentation: Bool,
        relevantCodeSnippets: [RelevantCodeSnippet]
    ) {
        self.fileURL = fileURL
        self.relativePath = relativePath
        self.language = language
        self.content = content
        self.originalContent = originalContent
        self.cursorPosition = cursorPosition
        self.tabSize = tabSize
        self.indentSize = indentSize
        self.usesTabsForIndentation = usesTabsForIndentation
        self.relevantCodeSnippets = relevantCodeSnippets
    }
}

