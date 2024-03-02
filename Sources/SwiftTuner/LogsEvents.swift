import Foundation

public protocol LogsEvents {
    static func log(_ eventName: String, additionalContext: [String: Any]?)
}
