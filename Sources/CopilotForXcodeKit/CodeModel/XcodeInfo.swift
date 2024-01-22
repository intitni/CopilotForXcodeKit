import Foundation

public struct XcodeInfo: Codable {
    public var isActive: Bool

    public init(isActive: Bool) {
        self.isActive = isActive
    }
}

