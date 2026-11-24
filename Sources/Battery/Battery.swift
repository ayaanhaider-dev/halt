import Foundation

struct Battery {
    var percent = 0, plugged = false, charging = false, minutes: Int?
    var temperature = 0.0, voltage = 0.0, current = 0.0, cycles = 0
    var design = 0, maximum = 0, nominal = 0, charge = 0
    var condition = "–", serial = "–"
    var adapterName = "–", adapterWatts = 0, adapterVolts = 0.0, adapterAmps = 0.0
    var flow = PowerFlow()
    var adapterFirmware = ""

    var health: Double { design > 0 ? Double(maximum) / Double(design) * 100 : 0 }
    /// Live; `current` itself only refreshes every minute or so.
    var liveCurrent: Double { voltage > 0 ? flow.battery / voltage : 0 }
    var draining: Bool { plugged && current < -0.15 }
}
