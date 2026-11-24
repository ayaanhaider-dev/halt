import Foundation

/// Watts moving through the Mac; the numbers always balance.
struct PowerFlow: Equatable {
    var adapter = 0.0, system = 0.0
    var battery: Double { adapter - system }  // positive = charging
    init() {}
    init(adapter: Double, system: Double) {
        self.adapter = max(0, adapter)
        self.system = max(0, system)
    }

    /// `total` runs about a second behind `adapter`, so their difference is not battery power; `battery` is measured.
    init(adapter: Double, total: Double, battery: Double) {
        // A paused adapter reads about 0.6 W: everything comes from the battery.
        if adapter <= 1 {
            self.init(adapter: adapter, system: total)
        }
        // Keeps the battery's sign even if its slower reading is larger than the adapter's.
        else {
            self.init(adapter: adapter, system: adapter - (abs(battery) < 1 ? 0 : min(battery, adapter)))
        }
    }

    /// Moves part of the way each second, unless power came or went.
    func smoothed(from old: PowerFlow) -> PowerFlow {
        guard (adapter > 1) == (old.adapter > 1), (battery > 1) == (old.battery > 1),
            (battery < -1) == (old.battery < -1), old.system > 0
        else { return self }
        return PowerFlow(
            adapter: old.adapter + (adapter - old.adapter) * 0.3,
            system: old.system + (system - old.system) * 0.3)
    }
}
