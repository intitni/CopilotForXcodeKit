import Foundation
import XCTest

@testable import CopilotForXcodeModel

class LineAnnotationParsingTests: XCTestCase {
    func test_parse_line_annotation() {
        let annotation = "Error Line 25: FileName.swift:25 Cannot convert Type"
        let parsed = Editor.parseLineAnnotation(annotation)
        XCTAssertEqual(parsed.type, "Error")
        XCTAssertEqual(parsed.line, 25)
        XCTAssertEqual(parsed.message, "Cannot convert Type")
    }
}
