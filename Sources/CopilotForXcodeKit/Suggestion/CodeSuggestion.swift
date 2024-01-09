import CopilotForXcodeModel
import Foundation

/// A suggestion for code completion.
public struct CodeSuggestion: Codable, Equatable {
    public init(
        id: String,
        text: String,
        position: CursorPosition,
        range: CursorRange
    ) {
        self.text = text
        self.position = position
        self.id = id
        self.range = range
    }

    /// An id.
    public var id: String
    /// The new code to be inserted and the original code on the first line.
    /// `[original code][new code]`.
    ///
    /// For example,
    /// for original code:
    /// ```
    /// draft(
    ///       ^ text cursor
    /// ```
    /// the `text` should be
    /// ```
    /// draft("hello world")
    /// ```
    ///
    /// You can also only return the `[new code]` here, so long as it matches the `range`.
    /// But it's less recommended.
    public var text: String
    /// The position of the cursor before generating the completion. Most of the time you can reuse
    /// the one from a ``SuggestionRequest``.
    /// `[original code][cursor][new code]`
    ///
    /// For example,
    /// ```
    /// draft(
    ///       ^ text cursor {0, 6}
    /// ```
    public var position: CursorPosition
    /// The range of the original code that should be replaced.
    /// `[start][original code][end][new code]`
    ///
    /// For example,
    /// for original code:
    /// ```
    /// draft(
    ///       ^ text cursor
    /// ```
    /// If the suggestion is:
    /// ```
    /// draft("hello world")
    /// ```
    /// the `range` should be `{0, 0} - {0, 6}`.
    ///
    /// If the suggestion is:
    /// ```
    /// "hello world")
    /// ```
    /// the `range` should be `{0, 6} - {0, 6}`.
    public var range: CursorRange
}

