import AppIntents

/// The ready-made shortcuts people find under Halt without building their own.
struct HaltShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: SetLimitIntent(), phrases: ["Set the \(.applicationName) charge limit"],
            shortTitle: "Set Charge Limit", systemImageName: "gauge.with.needle")
        AppShortcut(
            intent: TopUpIntent(), phrases: ["Top up with \(.applicationName)"],
            shortTitle: "Top Up", systemImageName: "arrow.up")
        AppShortcut(
            intent: DischargeIntent(), phrases: ["Discharge with \(.applicationName)"],
            shortTitle: "Discharge", systemImageName: "arrow.down")
        AppShortcut(
            intent: StopIntent(), phrases: ["Return to the \(.applicationName) limit"],
            shortTitle: "Return to Limit", systemImageName: "stop.fill")
        AppShortcut(
            intent: CalibrateIntent(), phrases: ["Calibrate with \(.applicationName)"],
            shortTitle: "Calibrate", systemImageName: "arrow.triangle.2.circlepath")
        AppShortcut(
            intent: KeepAwakeIntent(), phrases: ["Keep my Mac awake with \(.applicationName)"],
            shortTitle: "Keep Awake", systemImageName: "cup.and.saucer")
        AppShortcut(
            intent: BatteryIntent(), phrases: ["Get the battery level from \(.applicationName)"],
            shortTitle: "Battery Level", systemImageName: "battery.75percent")
    }
}
