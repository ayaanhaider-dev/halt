import Foundation

func testModeAndSummary() {
    var settings = Settings()
    settings.limit = 50
    let idle = PowerFlow(adapter: 20, system: 20)
    precondition(settings.mode(plugged: true, flow: idle) == .holding && settings.shownLimit == 50)
    precondition(settings.mode(plugged: true, flow: PowerFlow(adapter: 30, system: 20)) == .charging)
    precondition(
        settings.mode(plugged: true, flow: PowerFlow(adapter: 0, system: 20)) == .draining
            && settings.mode(plugged: false, flow: idle) == .draining)
    settings.topUp = true
    precondition(settings.mode(plugged: true, flow: idle) == .charging && settings.shownLimit == 100)
    settings.discharge(from: 40)
    precondition(settings.mode(plugged: true, flow: idle) == .draining && settings.shownLimit == 20)
    var described = Settings()
    described.limit = 80
    func line(_ percent: Int, _ flow: PowerFlow, plugged: Bool = true) -> String {
        described.summary(percent: percent, plugged: plugged, flow: flow, minutes: nil)
    }
    precondition(
        line(80, idle) == "Holding at 80%"
            && line(60, PowerFlow(adapter: 30, system: 20)) == "Charging to 80%")
    precondition(
        line(90, PowerFlow(adapter: 0, system: 20)) == "Draining to 80%"
            && line(70, PowerFlow(adapter: 28, system: 42)) == "Adapter needs help from battery")
    precondition(line(70, PowerFlow(adapter: 0, system: 9), plugged: false) == "On battery")
    precondition(
        described.summary(percent: 60, plugged: true, flow: PowerFlow(adapter: 30, system: 20), minutes: 121)
            == "Charging to 80%")
    described.topUp = true
    precondition(line(90, idle) == "Topping up to 100%" && line(100, idle) == "Full, unplug when ready")
}
