import Foundation

/// The position of the cursor in the code. Line and character are zero-based.
public struct CursorPosition: Codable, Hashable, Sendable {
    /// A position that is the start of the document.
    public static let zero = CursorPosition(line: 0, character: 0)
    
    /// A position that is out of scope.
    public static var outOfScope: CursorPosition { .init(line: -1, character: -1) }

    /// Line index, zero-based.
    public let line: Int
    /// Character index, zero-based.
    public let character: Int

    public init(line: Int, character: Int) {
        self.line = line
        self.character = character
    }

    public init(_ pair: (Int, Int)) {
        line = pair.0
        character = pair.1
    }

    public var readableText: String {
        return "[\(line + 1), \(character)]"
    }
}

extension CursorPosition: CustomStringConvertible {
    public var description: String {
        return "{\(line), \(character)}"
    }
}

extension CursorPosition: Comparable {
    public static func < (lhs: CursorPosition, rhs: CursorPosition) -> Bool {
        if lhs.line == rhs.line {
            return lhs.character < rhs.character
        }

        return lhs.line < rhs.line
    }
}

/// The range of the cursor in the code. Line and character are zero-based.
public struct CursorRange: Codable, Hashable, Sendable, Equatable, CustomStringConvertible {
    /// A range that is empty and at the start of the document.
    public static let zero = CursorRange(start: .zero, end: .zero)

    /// The start position.
    public var start: CursorPosition
    /// The end position.
    public var end: CursorPosition

    public init(start: CursorPosition, end: CursorPosition) {
        self.start = start
        self.end = end
    }

    public init(startPair: (Int, Int), endPair: (Int, Int)) {
        start = CursorPosition(startPair)
        end = CursorPosition(endPair)
    }

    /// Check if the range contains the position.
    public func contains(_ position: CursorPosition) -> Bool {
        return position >= start && position <= end
    }

    /// Check if the range contains the range.
    public func contains(_ range: CursorRange) -> Bool {
        return range.start >= start && range.end <= end
    }

    /// Check if the range contains the range strictly.
    public func strictlyContains(_ range: CursorRange) -> Bool {
        return range.start > start && range.end < end
    }

    /// Check if the range intersects with the range.
    public func intersects(_ other: CursorRange) -> Bool {
        return contains(other.start) || contains(other.end)
    }

    /// If the range is empty.
    public var isEmpty: Bool {
        return start == end
    }

    /// If the range start and end are on the same line.
    public var isOneLine: Bool {
        return start.line == end.line
    }

    public static func == (lhs: CursorRange, rhs: CursorRange) -> Bool {
        return lhs.start == rhs.start && lhs.end == rhs.end
    }

    public var description: String {
        return "\(start.readableText) - \(end.readableText)"
    }
}

public extension CursorRange {
    /// A range that is out of scope.
    static var outOfScope: CursorRange { .init(start: .outOfScope, end: .outOfScope) }
    
    /// A range that represent a text cursor position.
    static func cursor(_ position: CursorPosition) -> CursorRange {
        return .init(start: position, end: position)
    }
}

