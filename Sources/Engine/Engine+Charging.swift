import Foundation

extension Engine {
    /// nil stops a running top up or calibration.
    func run(_ action: TaskAction?, limit: Int? = nil) {
        if action == .discharge { return discharge() }
        var s = settings
        s.topUp = action == .topUp
        s.dischargeTarget = nil
        s.calibration = action == .calibrate ? 0 : nil
        if action == .limit, let limit { s.limit = limit }
        settings = s
        apply()
    }

    func discharge() {
        var s = settings
        s.discharge(from: battery.percent)
        settings = s
        apply()
    }

    // Asks again every minute: macOS or another app may have changed the limit or light.
    func apply() {
        // Until setup is finished, whatever limit macOS already has stays.
        guard settings.onboarded else { return }
        guard helperStatus == .enabled, !conflict else { return }
        let led: Int =
            switch settings.led {
            case .system: 0
            case .off: 1
            case .green: 3
            case .orange: 4
            case .status:
                battery.draining && settings.ledNoBlink != true
                    ? 6 : battery.charging || settings.ledNoLimit == true ? 4 : 3
            }
        let limit = settings.effectiveLimit, pause = settings.pausesOptimized
        if let applied, applied.limit == limit, applied.pause == pause, applied.led == led,
            Date.now.timeIntervalSince(applied.at) < 60
        {
            return
        }
        // Leaving the light to macOS needs one write, not one a minute.
        let sendLED = applied.map { $0.led != led || led != 0 } ?? true
        if applied?.limit != limit { limitSince = .now }
        applied = (limit, pause, led, .now)
        error = nil
        helper { $0.setLimit(limit, pauseOptimized: pause, reply: self.report) }
        if sendLED { helper { $0.setLED(led, reply: self.report) } }
    }
}
