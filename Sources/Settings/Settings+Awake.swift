import Foundation

extension Settings {
    func awake(_ now: Date) -> Bool { awakeUntil.map { $0 > now } ?? false }

    /// Whether the Mac must stay on with its lid closed. Discharging only counts while plugged in, never in a bag.
    func staysOnWithLidClosed(_ now: Date, plugged: Bool) -> Bool {
        (awake(now) && awakeLid == true)
            || (dischargeLid == true && plugged && (dischargeTarget != nil || calibration != nil))
    }

    /// Ends a timed or low-battery keep awake.
    mutating func expireAwake(_ now: Date, percent: Int, plugged: Bool) {
        if awakeUntil != nil, !awake(now) || (!plugged && percent <= awakeCutoff ?? 20) { awakeUntil = nil }
    }
}
