import AppKit

extension Engine {
    var barIcon: String {
        if !battery.plugged { return "battery.75percent" }
        switch mode {
        case .charging: return "bolt.fill"
        case .draining: return "minus.circle"
        case .holding: return "powerplug.fill"
        }
    }

    func barValue(_ item: MenuBarItem) -> String {
        return switch item {
        case .battery: "\(battery.percent)%"
        case .power: watts(battery.flow.system)
        case .heat: degrees(battery.temperature)
        case .time: battery.minutes.map { "\($0 / 60):" + String(format: "%02d", $0 % 60) } ?? "–:––"
        case .health: "♥ \(Int(battery.health.rounded()))%"
        case .cycles: "\(battery.cycles) cycles"
        case .volts: "\(battery.voltage.formatted(.number.precision(.fractionLength(1)))) V"
        case .amps: "\(battery.liveCurrent.formatted(.number.precision(.fractionLength(2)))) A"
        case .status: statusWord
        }
    }

    private var statusWord: String {
        if settings.calibration != nil { return "Calibrating" }
        if settings.heatHold != nil { return "Hot" }
        if settings.topUp { return "Top up" }
        if settings.dischargeTarget != nil { return "Discharging" }
        if settings.awake(.now) { return "Awake" }
        return "Limit \(settings.limit)%"
    }

    private var batterySymbol: String {
        if battery.charging { return "battery.100percent.bolt" }
        switch battery.percent {
        case 88...: return "battery.100percent"
        case 63...: return "battery.75percent"
        case 38...: return "battery.50percent"
        case 13...: return "battery.25percent"
        default: return "battery.0percent"
        }
    }

    /// The menu bar redraws on every assignment, so it only gets real changes.
    func refreshMenuBar() {
        let content = MenuBarContent(
            icon: barImage, text: barText, isTinted: settings.barTint == true && lowPower)
        if content != menuBar { menuBar = content }
    }

    var barText: String {
        settings.barItems.map(barValue).joined(
            separator: String(repeating: " ", count: settings.barSpacing ?? 2))
    }

    /// nil when hidden; an item with no text always keeps an icon to click.
    var barImage: String? {
        switch settings.barIcon ?? .status {
        case .halt: return BrandMark.menuBar
        case .status: return barIcon
        case .battery: return batterySymbol
        case .bolt: return "bolt.fill"
        case .none: return settings.barItems.isEmpty ? "bolt.fill" : nil
        }
    }

    func applyDock() { NSApp.setActivationPolicy(settings.dock != false ? .regular : .accessory) }

    func rightClicked() -> Bool {
        switch settings.rightClick ?? .popover {
        case .popover: return false
        case .window: openWindow()
        case .topUp: run(settings.topUp ? nil : .topUp)
        case .lowPower: setLowPower(!lowPower)
        case .awake: if settings.awake(.now) { stopAwake() } else { keepAwake(hours: nil) }
        }
        return true
    }
}
