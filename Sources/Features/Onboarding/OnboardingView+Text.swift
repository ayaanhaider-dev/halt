import Foundation

extension OnboardingView {
    var headline: String {
        switch step {
        case .battery:
            battery.design == 0
                ? "Batteries wear out from sitting full."
                : health >= 100
                    ? "Your battery is as good as new."
                    : "Your battery has lost \(100 - health)% of what it could hold."
        case .limit: "Where should charging stop?"
        case .heat: "It's \(degrees(battery.temperature)) in there right now."
        case .permission: installed ? "macOS gave Halt permission." : "macOS has to allow this."
        case .ready:
            !installed
                ? "Almost there."
                : limit == 100
                    ? "Halt will let it charge all the way." : "Halt will stop charging at \(limit)%."
        }
    }

    var detail: String {
        switch step {
        case .battery:
            battery.design == 0
                ? "Halt stops charging before that."
                : "It held \(String(battery.design)) mAh when new and holds \(String(battery.maximum)) mAh after \(battery.cycles) charge cycles. Sitting full and getting hot speed that up. Halt limits both."
        case .limit:
            "Lower is easier on the battery. The times are estimates from how much power your Mac has been using."
        case .heat: "Charging adds heat. Halt can wait until the battery cools down, then carry on."
        case .permission:
            installed
                ? "You can take it back in General whenever you like."
                : "Apps can't change how a Mac charges, so Halt adds a small helper that can. macOS will ask for your password once."
        case .ready:
            installed
                ? "\(heat ? "It also pauses above \(degrees(heatLimit)). " : "")Halt has to be open to watch the heat. macOS keeps the limit itself, except when your Mac is shut down."
                : "Your choices are saved, but charging won't change until you allow the helper. You can do that in General."
        }
    }
}
