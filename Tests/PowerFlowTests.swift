import Foundation

func testPowerFlow() {
    let charging = PowerFlow(adapter: 30, system: 20)
    precondition(charging.battery == 10 && PowerFlow(adapter: 0, system: 8).battery == -8)

    // Readings from the Mac while macOS reported 0 A: the battery must not appear.
    for (adapter, total) in [(25.7, 21.0), (21.3, 26.9), (25.1, 21.6), (18.8, 28.6)] {
        precondition(PowerFlow(adapter: adapter, total: total, battery: 0).battery == 0)
    }
    precondition(PowerFlow(adapter: 30, total: 99, battery: 12).system == 18)
    precondition(PowerFlow(adapter: 20, total: 99, battery: -5).system == 25)
    precondition(PowerFlow(adapter: 0.6, total: 20, battery: 0).system == 20)
    precondition(
        abs(PowerFlow(adapter: 30, system: 30).smoothed(from: PowerFlow(adapter: 20, system: 20)).system - 23)
            < 0.001)
    precondition(
        PowerFlow(adapter: 30, system: 18).smoothed(from: PowerFlow(adapter: 20, system: 20)).system == 18)
}

func testEstimates() {
    precondition(snappedLimit(from: 84, moved: 0.2) == 85 && snappedLimit(from: 84, moved: -2) == 82)
    precondition(snappedLimit(from: 84, moved: 900) == 100 && snappedLimit(from: 84, moved: -900) == 0)
    precondition(runtime(percent: 50, capacity: 4000, volts: 12, watts: 12) == 120)
    precondition(
        runtime(percent: 80, capacity: 4000, volts: 12, watts: 0) == nil
            && runtime(percent: 80, capacity: 0, volts: 12, watts: 9) == nil)
}
