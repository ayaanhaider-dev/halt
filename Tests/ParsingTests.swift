import Foundation

func testCommandsAndProcessList() {
    precondition(
        parseCommand("limit 0")?.1 == 0 && parseCommand("limit 101") == nil && parseCommand("limit x") == nil
            && parseCommand("topup")?.0 == .topUp)
    precondition(
        parseTop("PID POWER COMMAND\n1 99.0 old\n\nPID    POWER COMMAND\n420    100.8 My App  \n5 3.0 idle\n")
            .map(\.name) == ["My App"])

    precondition(parseCommand("discharge")?.0 == .discharge)
}

func testOlderSettingsStillLoad() {
    // Settings saved before this version must load.
    let old =
        #"{"onboarded":true,"showDetails":true,"keepAwake":false,"heatLimit":35,"barPower":true,"topUp":false,"barTemperature":false,"limit":83,"catchUp":false,"barPercent":true,"heatProtection":false,"led":"Charge status","tasks":[{"id":"4F8E2C0A-0C0B-4E2F-9B52-0D6B5B9B7A11","action":"Top up","limit":80,"weekdays":[2],"time":540,"enabled":true,"lastRun":0}],"showFlow":true}"#
    let loaded = try! JSONDecoder().decode(Settings.self, from: Data(old.utf8))
    precondition(loaded.limit == 83 && loaded.barItems == [.battery, .power] && loaded.tasks[0].once == nil)
}
