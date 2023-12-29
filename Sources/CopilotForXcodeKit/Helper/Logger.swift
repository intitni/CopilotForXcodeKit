import Foundation
import OSLog

enum LogLevel: String {
    case debug
    case info
    case error
}

/// You can change the ``osLog`` to something else so you can find the logs more easily.
public enum CopilotForXcodeKitLogger {
    public static var osLog: OSLog = .init(
        subsystem: "com.intii.CopilotForXcodeKit",
        category: "CopilotForXcodeKit"
    )

    static func log(level: LogLevel, message: String) {
        let osLogType: OSLogType
        switch level {
        case .debug:
            osLogType = .debug
        case .info:
            osLogType = .info
        case .error:
            osLogType = .error
        }

        os_log("%{public}@", log: osLog, type: osLogType, message as CVarArg)
    }

    static func debug(_ message: String) {
        log(level: .debug, message: message)
    }

    static func info(_ message: String) {
        log(level: .info, message: message)
    }

    static func error(_ message: String) {
        log(level: .error, message: message)
    }

    static func error(_ error: Error) {
        log(level: .error, message: error.localizedDescription)
    }

    static func signpost(_ type: OSSignpostType, name: StaticString) {
        os_signpost(type, log: osLog, name: name)
    }
}

typealias Logger = CopilotForXcodeKitLogger
