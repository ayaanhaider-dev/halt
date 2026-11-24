import Foundation

// `Halt limit 80` from Shortcuts' Run Shell Script talks to the running app.
let arguments = CommandLine.arguments.dropFirst().filter { !$0.hasPrefix("-") }
if let first = arguments.first, ["limit", "topup", "discharge", "calibrate", "cancel"].contains(first) {
    let command = arguments.joined(separator: " ")
    guard parseCommand(command) != nil else {
        print("Use: limit 0-100, topup, discharge, calibrate or cancel")
        exit(1)
    }
    DistributedNotificationCenter.default().postNotificationName(
        commandNotification, object: command, userInfo: nil, deliverImmediately: true)
    exit(0)
}
HaltApp.main()
