import Foundation

extension Settings {
    mutating func update(
        percent: Int, temperature: Double, plugged: Bool, wasPlugged: Bool, charging: Bool = false,
        settled: Bool = false, now: Date = .now
    ) {
        if percent >= 100 && plugged { lastFull = now }
        // Charging well past a limit that has long been in force is macOS calibrating, which can't be stopped.
        let busy = topUp || calibration != nil || dischargeTarget != nil
        if settled, charging, plugged, !busy, limit < 95, percent >= limit + 4 { macCalibrating = true }
        if macCalibrating == true {
            if busy || !plugged {
                macCalibrating = nil
            } else if percent >= 100 {
                macCalibrating = nil
                if calibrateAfterMac == true { calibration = 1 }
            }
        }
        // Ends on unplugging, not at 100%: macOS would drain straight back to the limit.
        if wasPlugged && !plugged {
            topUp = false
            dischargeTarget = nil
        }
        switch calibration {
        case 0 where percent >= 100: calibration = 1
        case 1 where percent <= 12: calibration = 2
        case 2 where percent >= 100:
            calibration = nil
            lastCalibration = .now
        default: break
        }
        if !heatProtection || temperature < heatLimit - 2 {
            heatHold = nil
        } else if temperature >= heatLimit && heatHold == nil {
            heatHold = percent
        }
    }
}
