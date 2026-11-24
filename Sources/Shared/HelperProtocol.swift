import Foundation

let helperID = "com.lveno.halt.helper"

/// Every reply is nil on success, or a message to show.
@objc protocol HelperProtocol {
    func setLimit(_ percent: Int, pauseOptimized: Bool, reply: @escaping (String?) -> Void)
    func setLED(_ state: Int, reply: @escaping (String?) -> Void)
    func setSleepDisabled(_ on: Bool, reply: @escaping (String?) -> Void)
    /// Removes the helper from this Mac.
    func uninstall(reply: @escaping (String?) -> Void)
    func setLowPower(_ on: Bool, reply: @escaping (String?) -> Void)
}
