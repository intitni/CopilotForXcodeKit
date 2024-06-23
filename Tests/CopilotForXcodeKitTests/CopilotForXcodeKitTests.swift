import XCTest
import SwiftUI
@testable import CopilotForXcodeKit

final class CopilotForXcodeKitExtensionTest: XCTestCase {
    func test_extension_info_match_type_definition_has_suggestion_provider() throws {
        class SuggestionService: SuggestionServiceType {
            var configuration: CopilotForXcodeKit.SuggestionServiceConfiguration {
                .init(
                    acceptsRelevantCodeSnippets: true,
                    mixRelevantCodeSnippetsInSource: true,
                    acceptsRelevantSnippetsFromOpenedFiles: true
                )
            }

            func getSuggestions(
                _ request: CopilotForXcodeKit.SuggestionRequest,
                workspace: CopilotForXcodeKit.WorkspaceInfo
            ) async throws -> [CopilotForXcodeKit.CodeSuggestion] {
                []
            }

            func notifyAccepted(
                _ suggestion: CopilotForXcodeKit.CodeSuggestion,
                workspace: CopilotForXcodeKit.WorkspaceInfo
            ) async {}

            func notifyRejected(
                _ suggestions: [CopilotForXcodeKit.CodeSuggestion],
                workspace: CopilotForXcodeKit.WorkspaceInfo
            ) async {}

            func cancelRequest(workspace: CopilotForXcodeKit.WorkspaceInfo) async {}
        }

        class Extension: CopilotForXcodeExtension {
            let suggestionService = SuggestionService()
        }

        let ext = Extension()
        let extInfo = ext.extensionInfo

        XCTAssertTrue(extInfo.providesSuggestionService)
        XCTAssertFalse(extInfo.providesPromptToCodeService)
        XCTAssertFalse(extInfo.providesChatService)
        XCTAssertFalse(extInfo.hasConfigurationScene)
        XCTAssertTrue(extInfo.chatPanelSceneInfo.isEmpty)
        let conf = extInfo.suggestionServiceConfiguration!
        XCTAssertTrue(conf.acceptsRelevantCodeSnippets)
        XCTAssertTrue(conf.acceptsRelevantSnippetsFromOpenedFiles)
        XCTAssertTrue(conf.mixRelevantCodeSnippetsInSource)
    }
    
    func test_extension_info_match_type_definition_has_scenes() throws {
        struct SceneConfiguration: CopilotForXcodeExtensionSceneConfiguration {
            var configurationScene: ConfigurationScene<EmptyView>? {
                .init { model in
                    EmptyView()
                } onConnection: { connection in
                    return true
                }
            }

            var chatPanelScenes: (some CopilotForXcodeAppExtensionScene)? {
                ChatPanelScene(id: "One") { model in
                    EmptyView()
                } onConnection: { _ in
                    true
                }
                
                ChatPanelScene(id: "Two") { model in
                    EmptyView()
                } onConnection: { _ in
                    true
                }
            }

            var chatPanelSceneInfo: [ChatPanelSceneInfo] {
                [.init(id: "One", title: "One")] // Then "Two" will be unavailable.
            }
        }
        
        class Extension: CopilotForXcodeExtension {
            var sceneConfiguration: SceneConfiguration { SceneConfiguration() }
        }

        let ext = Extension()
        let extInfo = ext.extensionInfo

        XCTAssertFalse(extInfo.providesSuggestionService)
        XCTAssertFalse(extInfo.providesPromptToCodeService)
        XCTAssertFalse(extInfo.providesChatService)
        XCTAssertTrue(extInfo.hasConfigurationScene)
        XCTAssertEqual(extInfo.chatPanelSceneInfo.count, 1)
        let conf = extInfo.suggestionServiceConfiguration!
        XCTAssertFalse(conf.acceptsRelevantCodeSnippets)
        XCTAssertFalse(conf.acceptsRelevantSnippetsFromOpenedFiles)
        XCTAssertFalse(conf.mixRelevantCodeSnippetsInSource)
    }
}

