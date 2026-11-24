import Foundation
import IOKit.ps

extension Battery {
    private static let smc = SMC()
    private static var last: (signature: [AnyHashable], battery: Battery, at: Date)?

    /// The live sensors every time, everything else only when macOS has refreshed it.
    static func read() -> Battery? {
        let service = IOServiceGetMatchingService(kIOMainPortDefault, IOServiceMatching("AppleSmartBattery"))
        guard service != 0 else { return nil }
        defer { IOObjectRelease(service) }

        let signature = signature(of: service)
        if let last, last.signature == signature, Date.now.timeIntervalSince(last.at) < 5 {
            return last.battery.withLiveSensors()
        }
        guard let battery = readAll(service) else { return nil }
        last = (signature, battery, .now)
        return battery.withLiveSensors()
    }

    private static func signature(of service: io_service_t) -> [AnyHashable] {
        ["AppleRawExternalConnected", "ExternalConnected", "IsCharging", "Amperage", "UpdateTime"].map {
            IORegistryEntryCreateCFProperty(service, $0 as CFString, kCFAllocatorDefault, 0)?
                .takeRetainedValue() as? NSNumber
        }
    }

    private static func readAll(_ service: io_service_t) -> Battery? {
        var raw: Unmanaged<CFMutableDictionary>?
        guard IORegistryEntryCreateCFProperties(service, &raw, kCFAllocatorDefault, 0) == KERN_SUCCESS,
            let registry = raw?.takeRetainedValue() as? [String: Any], let source = powerSource()
        else { return nil }
        // macOS 27 moved the capacities into BatteryData.
        let data = registry["BatteryData"] as? [String: Any] ?? [:]

        var battery = Battery()
        battery.percent = integer(source, kIOPSCurrentCapacityKey)
        battery.plugged =
            registry["AppleRawExternalConnected"] as? Bool ?? registry["ExternalConnected"] as? Bool ?? false
        battery.charging = registry["IsCharging"] as? Bool ?? false
        let minutes = integer(
            source, battery.charging ? kIOPSTimeToFullChargeKey : kIOPSTimeToEmptyKey)
        battery.minutes = minutes > 0 && (battery.charging || !battery.plugged) ? minutes : nil
        battery.condition = condition
        battery.serial = source[kIOPSHardwareSerialNumberKey] as? String ?? "–"
        battery.voltage = Double(integer(registry, "Voltage")) / 1000
        battery.current = Double(integer(registry, "Amperage")) / 1000
        battery.temperature = Double(integer(registry, "Temperature")) / 100
        battery.cycles = integer(registry, "CycleCount")
        battery.design = integer(data, "DesignCapacity")
        battery.maximum = integer(data, "AppleRawMaxCapacity")
        battery.nominal = integer(data, "NominalChargeCapacity")
        battery.charge = integer(data, "AppleRawCurrentCapacity")
        if battery.plugged, let adapter = registry["AdapterDetails"] as? [String: Any] {
            battery.adapterName = adapter["Name"] as? String ?? "Power adapter"
            battery.adapterWatts = integer(adapter, "Watts")
            battery.adapterFirmware = adapter["FwVersion"] as? String ?? ""
            battery.adapterVolts = Double(integer(adapter, "AdapterVoltage")) / 1000
            battery.adapterAmps = Double(integer(adapter, "Current")) / 1000
        }
        return battery
    }

    private func withLiveSensors() -> Battery {
        var battery = self
        let smc = Self.smc
        battery.temperature = smc?.float("TB0T") ?? temperature
        if plugged, adapterWatts > 0 {
            battery.adapterVolts = smc?.float("VD0R") ?? adapterVolts
            battery.adapterAmps = smc?.float("ID0R") ?? adapterAmps
        }
        battery.flow = PowerFlow(
            adapter: plugged ? smc?.float("PDTR") ?? 0 : 0, total: smc?.float("PSTR") ?? 0,
            battery: current * voltage)
        return battery
    }

    private static func powerSource() -> [String: Any]? {
        guard let info = IOPSCopyPowerSourcesInfo()?.takeRetainedValue(),
            let list = IOPSCopyPowerSourcesList(info)?.takeRetainedValue() as? [CFTypeRef]
        else { return nil }
        return list.lazy
            .compactMap { IOPSGetPowerSourceDescription(info, $0)?.takeUnretainedValue() as? [String: Any] }
            .first { $0[kIOPSTypeKey] as? String == kIOPSInternalBatteryType }
    }

    /// Negative numbers arrive as their unsigned 64-bit form.
    private static func integer(_ values: [String: Any], _ key: String) -> Int {
        Int((values[key] as? NSNumber)?.int64Value ?? 0)
    }

    /// Read once per launch: it takes a separate process and hardly ever changes.
    private static let condition: String = {
        let process = Process()
        let pipe = Pipe()
        process.executableURL = URL(filePath: "/usr/sbin/system_profiler")
        process.arguments = ["SPPowerDataType"]
        process.standardOutput = pipe
        guard (try? process.run()) != nil else { return "–" }
        let text = String(decoding: pipe.fileHandleForReading.readDataToEndOfFile(), as: UTF8.self)
        return text.firstMatch(of: #/Condition: (.+)/#).map { String($0.1) } ?? "–"
    }()
}
