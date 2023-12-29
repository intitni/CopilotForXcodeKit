import ExtensionKit

@available(macOS 13.0, *)
public struct CopilotForXcodeAppExtensionGroupedScene<
    Content: AppExtensionScene
>: CopilotForXcodeAppExtensionScene {
    private let content: () -> Content

    public init(@AppExtensionSceneBuilder content: @escaping () -> Content) {
        self.content = content
    }

    public var body: some AppExtensionScene {
        content()
    }
}

