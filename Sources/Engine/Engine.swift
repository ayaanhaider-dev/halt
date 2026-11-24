import AppKit
import IOKit.pwr_mgt
import Observation
import ServiceManagement

@MainActor @Observable final class Engine {
    static let shared = Engine()

    var settings: Settings {
        didSet {
            guard settings != oldValue else { return }
            save()
            refreshMenuBar()
        }
    }
    var menuBar = MenuBarContent()
    var battery = Battery()
    var samples = BatteryHistory.load()
    var error: String?
    var helperStatus = HelperStatus.missing
    var conflict = false
    var lowPower = ProcessInfo.processInfo.isLowPowerModeEnabled

    /// Shows the setup again for someone who has already finished it.
    var showSetup = CommandLine.arguments.contains("--setup")

    var connection: NSXPCConnection?
    var applied: (limit: Int, pause: Bool, led: Int, at: Date)?
    var assertion: IOPMAssertionID?
    var started = false
    var ticks = 0
    var limitSince = Date.now
    var sleepDisabled: Bool?
    /// Set by the menu bar item, which can open windows.
    var openWindow: () -> Void = {}

    private init() {
        settings =
            UserDefaults.standard.data(forKey: "settings").flatMap {
                try? JSONDecoder().decode(Settings.self, from: $0)
            } ?? Settings()
        battery = Battery.read() ?? Battery()
        tick()
        let timer = Timer(timeInterval: 1, repeats: true) { _ in
            MainActor.assumeIsolated { Engine.shared.tick() }
        }
        RunLoop.main.add(timer, forMode: .common)
        DistributedNotificationCenter.default().addObserver(
            forName: commandNotification, object: nil, queue: .main
        ) { note in
            guard let text = note.object as? String, let (action, limit) = parseCommand(text) else { return }
            MainActor.assumeIsolated { Engine.shared.run(action, limit: limit) }
        }
    }

    func save() {
        if let data = try? JSONEncoder().encode(settings) {
            UserDefaults.standard.set(data, forKey: "settings")
        }
    }

    var mode: ChargeMode { settings.mode(plugged: battery.plugged, flow: battery.flow) }

    func tick() {
        ticks += 1
        lowPower = ProcessInfo.processInfo.isLowPowerModeEnabled
        if ticks % 5 == 1 { checkSurroundings() }
        guard !started || ticks % (settings.barInterval ?? 1) == 0, let new = Battery.read() else { return }
        receive(new)
        refreshMenuBar()
        runDueTasks()
        recordSample()
        updateAwake()
        apply()
    }

    /// Slower questions, asked of other processes and the disk.
    private func checkSurroundings() {
        helperStatus = .read()
        conflict = NSWorkspace.shared.runningApplications.contains {
            $0.bundleIdentifier?.hasPrefix("com.apphousekitchen.") == true
        }
    }

    private func receive(_ reading: Battery) {
        let wasPlugged = started ? battery.plugged : reading.plugged
        started = true
        var smoothed = reading
        smoothed.flow = reading.flow.smoothed(from: battery.flow)
        battery = smoothed
        var updated = settings
        updated.update(
            percent: reading.percent, temperature: reading.temperature, plugged: reading.plugged,
            wasPlugged: wasPlugged, charging: reading.charging,
            settled: Date.now.timeIntervalSince(limitSince) > 900)
        updated.expireAwake(.now, percent: reading.percent, plugged: reading.plugged)
        if updated != settings { settings = updated }
    }

    private func runDueTasks() {
        let now = Date.now
        for i in settings.tasks.indices where settings.tasks[i].shouldRun(now, catchUp: settings.catchUp) {
            let task = settings.tasks[i]
            settings.tasks[i].lastRun = now
            if task.once != nil { settings.tasks[i].enabled = false }
            settings.runs = [TaskRun(date: now, name: task.name)] + (settings.runs ?? []).prefix(19)
            run(task.action, limit: task.limit)
        }
    }

    private func recordSample() {
        let now = Date.now
        guard now.timeIntervalSince(samples.last?.id ?? .distantPast) >= 60 else { return }
        let sample = BatterySample(
            id: now, percent: Double(battery.percent), temperature: battery.temperature,
            watts: battery.flow.system, health: battery.health, cycles: Double(battery.cycles))
        samples.append(sample)
        BatteryHistory.append(sample)
    }
}
