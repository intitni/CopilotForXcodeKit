import ExtensionKit
import Foundation
import SwiftUI

/// A custom parameter attribute that constructs extension scenes from closures.
@available(macOS 13.0, *)
@resultBuilder public enum ChatPanelSceneBuilder {
    /// Passes through a single extension scene unmodified.
    ///
    /// - Returns: The composed scene.
    public static func buildBlock<Content>(
        _ content: ChatPanelScene<Content>
    ) -> some CopilotForXcodeAppExtensionScene where Content: View {
        return content
    }
}

@available(macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0, *)
public extension ChatPanelSceneBuilder {
    /// Builds an extension scene by combining two scenes.
    ///
    /// - Returns: The composed scene.
    static func buildBlock<C0, C1>(
        _ c0: ChatPanelScene<C0>,
        _ c1: ChatPanelScene<C1>
    )
        -> some CopilotForXcodeAppExtensionScene where C0: View, C1: View
    {
        return CopilotForXcodeAppExtensionGroupedScene {
            c0
            c1
        }
    }

    /// Builds an extension scene by combining three scenes.
    ///
    /// - Returns: The composed scene.
    static func buildBlock<C0, C1, C2>(
        _ c0: ChatPanelScene<C0>,
        _ c1: ChatPanelScene<C1>,
        _ c2: ChatPanelScene<C2>
    )
        -> some CopilotForXcodeAppExtensionScene where C0: View, C1: View, C2: View
    {
        return CopilotForXcodeAppExtensionGroupedScene {
            c0
            c1
            c2
        }
    }

    /// Builds an extension scene by combining four scenes.
    ///
    /// - Returns: The composed scene.
    static func buildBlock<C0, C1, C2, C3>(
        _ c0: ChatPanelScene<C0>,
        _ c1: ChatPanelScene<C1>,
        _ c2: ChatPanelScene<C2>,
        _ c3: ChatPanelScene<C3>
    )
        -> some CopilotForXcodeAppExtensionScene where C0: View, C1: View, C2: View, C3: View
    {
        return CopilotForXcodeAppExtensionGroupedScene {
            c0
            c1
            c2
            c3
        }
    }

    /// Builds an extension scene by combining five scenes.
    ///
    /// - Returns: The composed scene.
    static func buildBlock<C0, C1, C2, C3, C4>(
        _ c0: ChatPanelScene<C0>,
        _ c1: ChatPanelScene<C1>,
        _ c2: ChatPanelScene<C2>,
        _ c3: ChatPanelScene<C3>,
        _ c4: ChatPanelScene<C4>
    ) -> some CopilotForXcodeAppExtensionScene where C0: View, C1: View, C2: View, C3: View,
        C4: View
    {
        return CopilotForXcodeAppExtensionGroupedScene {
            c0
            c1
            c2
            c3
            c4
        }
    }

    /// Builds an extension scene by combining six scenes.
    ///
    /// - Returns: The composed scene.
    static func buildBlock<C0, C1, C2, C3, C4, C5>(
        _ c0: ChatPanelScene<C0>,
        _ c1: ChatPanelScene<C1>,
        _ c2: ChatPanelScene<C2>,
        _ c3: ChatPanelScene<C3>,
        _ c4: ChatPanelScene<C4>,
        _ c5: ChatPanelScene<C5>
    )
        -> some CopilotForXcodeAppExtensionScene where C0: View, C1: View, C2: View, C3: View,
        C4: View, C5: View
    {
        return CopilotForXcodeAppExtensionGroupedScene {
            c0
            c1
            c2
            c3
            c4
            c5
        }
    }

    /// Builds an extension scene by combining seven scenes.
    ///
    /// - Returns: The composed scene.
    static func buildBlock<C0, C1, C2, C3, C4, C5, C6>(
        _ c0: ChatPanelScene<C0>,
        _ c1: ChatPanelScene<C1>,
        _ c2: ChatPanelScene<C2>,
        _ c3: ChatPanelScene<C3>,
        _ c4: ChatPanelScene<C4>,
        _ c5: ChatPanelScene<C5>,
        _ c6: ChatPanelScene<C6>
    )
        -> some CopilotForXcodeAppExtensionScene where C0: View, C1: View, C2: View, C3: View,
        C4: View, C5: View, C6: View
    {
        return CopilotForXcodeAppExtensionGroupedScene {
            c0
            c1
            c2
            c3
            c4
            c5
            c6
        }
    }

    /// Builds an extension scene by combining eight scenes.
    ///
    /// - Returns: The composed scene.
    static func buildBlock<C0, C1, C2, C3, C4, C5, C6, C7>(
        _ c0: ChatPanelScene<C0>,
        _ c1: ChatPanelScene<C1>,
        _ c2: ChatPanelScene<C2>,
        _ c3: ChatPanelScene<C3>,
        _ c4: ChatPanelScene<C4>,
        _ c5: ChatPanelScene<C5>,
        _ c6: ChatPanelScene<C6>,
        _ c7: ChatPanelScene<C7>
    )
        -> some CopilotForXcodeAppExtensionScene where C0: View, C1: View, C2: View, C3: View,
        C4: View, C5: View, C6: View, C7: View
    {
        return CopilotForXcodeAppExtensionGroupedScene {
            c0
            c1
            c2
            c3
            c4
            c5
            c6
            c7
        }
    }

    /// Builds an extension scene by combining nine scenes.
    ///
    /// - Returns: The composed scene.
    static func buildBlock<C0, C1, C2, C3, C4, C5, C6, C7, C8>(
        _ c0: ChatPanelScene<C0>,
        _ c1: ChatPanelScene<C1>,
        _ c2: ChatPanelScene<C2>,
        _ c3: ChatPanelScene<C3>,
        _ c4: ChatPanelScene<C4>,
        _ c5: ChatPanelScene<C5>,
        _ c6: ChatPanelScene<C6>,
        _ c7: ChatPanelScene<C7>,
        _ c8: ChatPanelScene<C8>
    )
        -> some CopilotForXcodeAppExtensionScene where C0: View, C1: View, C2: View, C3: View,
        C4: View, C5: View, C6: View, C7: View,
        C8: View
    {
        return CopilotForXcodeAppExtensionGroupedScene {
            c0
            c1
            c2
            c3
            c4
            c5
            c6
            c7
            c8
        }
    }

    /// Builds an extension scene by combining ten scenes.
    ///
    /// - Returns: The composed scene.
    static func buildBlock<C0, C1, C2, C3, C4, C5, C6, C7, C8, C9>(
        _ c0: ChatPanelScene<C0>,
        _ c1: ChatPanelScene<C1>,
        _ c2: ChatPanelScene<C2>,
        _ c3: ChatPanelScene<C3>,
        _ c4: ChatPanelScene<C4>,
        _ c5: ChatPanelScene<C5>,
        _ c6: ChatPanelScene<C6>,
        _ c7: ChatPanelScene<C7>,
        _ c8: ChatPanelScene<C8>,
        _ c9: ChatPanelScene<C9>
    )
        -> some CopilotForXcodeAppExtensionScene where C0: View, C1: View, C2: View, C3: View,
        C4: View, C5: View, C6: View, C7: View,
        C8: View,
        C9: View
    {
        return CopilotForXcodeAppExtensionGroupedScene {
            c0
            c1
            c2
            c3
            c4
            c5
            c6
            c7
            c8
            c9
        }
    }
}

@available(macOS 13.0, *)
public extension AppExtensionSceneBuilder {
    static func buildOptional<Content>(_ content: Content?) -> some AppExtensionScene
        where Content: AppExtensionScene
    {
        if let content {
            return [content]
        }
        return [Content]()
    }
}

