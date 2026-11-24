import Foundation

struct Settings: Codable, Equatable {
    var limit = 100
    var topUp = false
    /// Set while Discharge is on; optional so settings saved before it still load.
    var dischargeTarget: Int?
    var calibration: Int?
    var lastCalibration: Date?
    var heatProtection = false
    var heatLimit = 35.0
    var heatHold: Int?
    var led = MagSafeLight.system
    var tasks: [ScheduledTask] = []
    var catchUp = false
    var keepAwake = false
    var barPercent = true
    var barPower = false
    var barTemperature = false
    var showFlow = true
    var showDetails = true
    var onboarded = false

    // Optional, so settings saved by earlier versions still load.
    /// Keep awake until then; `distantFuture` means until turned off.
    var awakeUntil: Date?
    var awakeCutoff: Int?
    var awakeLid: Bool?
    var dischargeLid: Bool?
    var calibrateAfterMac: Bool?
    var macCalibrating: Bool?
    var lastFull: Date?
    var bar: [MenuBarItem]?
    var barIcon: MenuBarIconStyle?
    var barSpacing: Int?
    var barInterval: Int?
    var barTint: Bool?
    var rightClick: RightClick?
    var hideButtons: Bool?
    var pinHealth: Bool?
    var pinPower: Bool?
    var dock: Bool?
    var ledNoLimit: Bool?
    var ledNoBlink: Bool?
    var runs: [TaskRun]?

    var barItems: [MenuBarItem] {
        get {
            bar
                ?? [barPercent ? .battery : nil, barPower ? .power : nil, barTemperature ? .heat : nil]
                .compactMap(\.self)
        }
        set { bar = newValue }
    }

    static let calibrationSteps = ["Charge to 100%", "Discharge to 10%", "Charge to 100%", "Return to limit"]

}
