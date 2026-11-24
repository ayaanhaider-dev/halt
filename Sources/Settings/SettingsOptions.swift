import Foundation

enum MagSafeLight: String, Codable, CaseIterable {
    case system = "macOS"
    case status = "Charge status"
    case off = "Off"
    case green = "Green"
    case orange = "Orange"
}
enum TaskAction: String, Codable, CaseIterable {
    case limit = "Set limit"
    case topUp = "Top up"
    case calibrate = "Calibrate"
    case discharge = "Discharge"
}

enum MenuBarItem: String, Codable, CaseIterable {
    case battery = "Battery"
    case power = "Power"
    case heat = "Heat"
    case time = "Time left"
    case health = "Health"
    case cycles = "Cycles"
    case volts = "Volts"
    case amps = "Amps"
    case status = "Status"
}
enum MenuBarIconStyle: String, Codable, CaseIterable {
    case halt = "Halt"
    case status = "Status"
    case battery = "Battery"
    case bolt = "Bolt"
    case none = "None"
}
enum RightClick: String, Codable, CaseIterable {
    case popover = "Open popover"
    case window = "Open Halt"
    case topUp = "Top up"
    case lowPower = "Low Power Mode"
    case awake = "Keep awake"
}
