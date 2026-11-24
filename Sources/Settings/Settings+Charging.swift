import Foundation

extension Settings {
    /// The limit macOS should enforce right now.
    var effectiveLimit: Int {
        // 8 instead of 10: macOS can show up to 4% more than the firmware compares.
        let wanted = calibration.map { $0 == 1 ? 8 : 100 } ?? shownLimit
        return heatHold.map { min(wanted, max(1, $0)) } ?? wanted
    }

    /// The limit to show; the saved one comes back when Top Up or Discharge ends.
    var shownLimit: Int { topUp ? 100 : dischargeTarget ?? limit }

    /// Follows a pressed button at once; macOS itself can take minutes.
    func mode(plugged: Bool, flow: PowerFlow) -> ChargeMode {
        if !plugged || dischargeTarget != nil { return .draining }
        if topUp { return .charging }
        return flow.battery > 1 ? .charging : flow.battery < -1 ? .draining : .holding
    }

    /// What is happening, and why.
    func summary(percent: Int, plugged: Bool, flow: PowerFlow, minutes: Int?) -> String {
        let left = minutes.map { " · \($0 / 60)h \($0 % 60)m left" } ?? ""
        if !plugged { return "On battery" + left }
        if macCalibrating == true { return "macOS is calibrating the battery" }
        if let calibration { return "Calibrating: " + Settings.calibrationSteps[calibration].lowercased() }
        if heatHold != nil { return "Paused, battery is hot" }
        if let dischargeTarget { return "Discharging to \(dischargeTarget)%" }
        if topUp { return percent >= 100 ? "Full, unplug when ready" : "Topping up to 100%" + left }
        switch mode(plugged: plugged, flow: flow) {
        // macOS only estimates the time to 100%.
        case .charging: return limit < 100 ? "Charging to \(limit)%" : "Charging" + left
        case .holding: return "Holding at \(percent)%"
        case .draining:
            return flow.adapter > 1
                ? "Adapter needs help from battery"
                : percent > limit ? "Draining to \(limit)%" : "Using battery"
        }
    }

    /// Whether the user asked for more than the 80% where Optimized Battery Charging stops. A plain 100% leaves that to macOS.
    var pausesOptimized: Bool { effectiveLimit > 80 && (effectiveLimit < 100 || topUp || calibration != nil) }

    /// Above the limit, drains to it; below, drains to 20% or until stopped.
    mutating func discharge(from percent: Int) {
        topUp = false
        calibration = nil
        dischargeTarget = percent > limit ? limit : percent > 20 ? 20 : nil
    }
}
