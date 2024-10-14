import Foundation

/// Avoid continuation being called multiple times.
public final class XPCServiceConnectionContinuation<T> {
    var continuation: AsyncThrowingStream<T, Error>.Continuation

    public func resume(_ value: T) {
        continuation.yield(value)
        continuation.finish()
    }

    public init(_ continuation: AsyncThrowingStream<T, Error>.Continuation) {
        self.continuation = continuation
    }

    public func reject(_ error: Error) {
        if (error as NSError).code == -100 {
            continuation.finish(throwing: CancellationError())
        } else {
            continuation.finish(throwing: error)
        }
    }
}

public enum XPCConnectionError: Error, LocalizedError {
    case remoteObjectProxyError(Error)
    case incorrectInterface

    public var errorDescription: String? {
        switch self {
        case let .remoteObjectProxyError(error):
            return "Remote object proxy error: \(error.localizedDescription)"
        case .incorrectInterface:
            return "Incorrect interface"
        }
    }
}

/// Connects to the XPC service and calls the given function with the service proxy.
public func withXPCServiceConnected<T, P>(
    connection: NSXPCConnection,
    as _: P.Type = P.self,
    isolation: isolated(any Actor)? = #isolation,
    _ fn: @escaping (P, XPCServiceConnectionContinuation<T>) -> Void
) async throws -> T {
    let stream: AsyncThrowingStream<T, Error> = AsyncThrowingStream { continuation in
        let con = XPCServiceConnectionContinuation<T>(continuation)
        guard let service = connection.remoteObjectProxyWithErrorHandler({
            dump($0)
            con.reject(XPCConnectionError.remoteObjectProxyError($0))
        }) as? P else {
            con.reject(XPCConnectionError.incorrectInterface)
            return
        }
        fn(service, con)
    }
    for try await item in stream {
        return item
    }

    throw CancellationError()
}

