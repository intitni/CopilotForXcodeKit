import Foundation
import XPCConcurrency

@_spi(CopilotForXcodeSPI)
@objc(CopilotForXcodeXPCProtocol)
public protocol XPCProtocol: NSObjectProtocol {
    /// Use a universal send method to avoid API changes.
    ///
    /// - note: You should not call this method directly. Use the methods in protocols conforming
    /// to ``XPCProtocol`` instead.
    func send(endpoint: String, requestBody: Data, reply: @escaping (Data?, Error?) -> Void)
}

extension XPCProtocol {
    /// A helper method for sending XPC requests with Swift Concurrency.
    func _send<Request: Codable, Response: Codable>(
        endpoint: String,
        requestBody: Request,
        continuation: XPCServiceConnectionContinuation<Response>
    ) throws {
        try Task.checkCancellation()
        let requestBodyData = try JSONEncoder().encode(requestBody)
        send(endpoint: endpoint, requestBody: requestBodyData) { [continuation] data, error in
            if let error {
                continuation.reject(error)
            } else {
                do {
                    guard let data = data else {
                        continuation.reject(NoDataError())
                        return
                    }
                    let responseBody = try JSONDecoder().decode(
                        Response.self,
                        from: data
                    )
                    continuation.resume(responseBody)
                } catch {
                    continuation.reject(error)
                }
            }
        }
    }
}

struct NoDataError: Error {}

public struct NoResponse: Codable {
    public static let none = NoResponse()
}

/// The request was not handled by the XPC server.
@_spi(CopilotForXcodeSPI)
public struct XPCRequestNotHandledError: Error, LocalizedError {
    public var errorDescription: String? {
        "The request was not handled by the XPC server."
    }

    public init() {}
}

/// This is not an actual error, it just indicates a request handler was hit, and no more check is
/// needed.
@_spi(CopilotForXcodeSPI)
public struct XPCRequestHandlerHitError: Error, LocalizedError {
    public var errorDescription: String? {
        "This is not an actual error, it just indicates a request handler was hit, and no more check is needed."
    }

    public init() {}
}

public protocol XPCRequestType: Codable {
    associatedtype ResponseBody: Codable
    static var endpoint: String { get }
}

extension XPCRequestType {
    /// A helper method to handle requests.
    static func _handle<Request: Codable, Response: Codable>(
        endpoint: String,
        requestBody data: Data,
        reply: @escaping (Data?, Error?) -> Void,
        handler: @escaping (Request) async throws -> Response,
        onceResponded: @escaping () -> Void
    ) throws {
        guard endpoint == Self.endpoint else {
            return
        }
        do {
            let requestBody = try JSONDecoder().decode(Request.self, from: data)
            Task {
                do {
                    let responseBody = try await handler(requestBody)
                    let responseBodyData = try JSONEncoder().encode(responseBody)
                    reply(responseBodyData, nil)
                    onceResponded()
                } catch {
                    reply(nil, error)
                    onceResponded()
                }
            }
        } catch {
            reply(nil, error)
            onceResponded()
        }
        throw XPCRequestHandlerHitError()
    }
}

