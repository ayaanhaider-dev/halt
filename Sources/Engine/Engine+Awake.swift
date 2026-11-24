import Foundation
import IOKit.pwr_mgt

extension Engine {
    func keepAwake(hours: Double?) {
        settings.awakeUntil = hours.map { Date.now.addingTimeInterval($0 * 3600) } ?? .distantFuture
        updateAwake()
    }

    func stopAwake() {
        settings.awakeUntil = nil
        updateAwake()
    }

    // Plugged in only, so a forgotten switch can't empty the battery.
    func updateAwake() {
        let want = settings.keepAwake && battery.plugged || settings.awake(.now)
        let lid = settings.staysOnWithLidClosed(.now, plugged: battery.plugged)
        // Off is only sent after on, so a setting made elsewhere is left alone.
        if helperStatus == .enabled,
            lid != (sleepDisabled ?? (!lid && UserDefaults.standard.bool(forKey: "sleepDisabled")))
        {
            sleepDisabled = lid
            UserDefaults.standard.set(lid, forKey: "sleepDisabled")
            helper { $0.setSleepDisabled(lid, reply: report) }
        }
        if want, assertion == nil {
            var id = IOPMAssertionID(0)
            if IOPMAssertionCreateWithName(
                kIOPMAssertPreventUserIdleSystemSleep as CFString, IOPMAssertionLevel(kIOPMAssertionLevelOn),
                "Halt keeps this Mac awake" as CFString, &id) == kIOReturnSuccess
            {
                assertion = id
            }
        } else if !want, let id = assertion {
            IOPMAssertionRelease(id)
            assertion = nil
        }
    }
}
