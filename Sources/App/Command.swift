import Foundation

/// "limit 80", "topup", "calibrate" or "cancel", from Shortcuts' Run Shell Script.
func parseCommand(_ text: String) -> (TaskAction?, Int?)? {
    let words = text.split(separator: " ")
    switch (words.first, words.count) {
    case ("limit", 2): return Int(words[1]).flatMap { (0...100).contains($0) ? (.limit, $0) : nil }
    case ("topup", 1): return (.topUp, nil)
    case ("discharge", 1): return (.discharge, nil)
    case ("calibrate", 1): return (.calibrate, nil)
    case ("cancel", 1): return (nil, nil)
    default: return nil
    }
}

let commandNotification = Notification.Name("com.lveno.halt.command")
