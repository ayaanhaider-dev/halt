import AppIntents
import Foundation

// These run inside Halt, which macOS opens in the background when needed.

struct SetLimitIntent: AppIntent {
    static let title: LocalizedStringResource = "Set Charge Limit"
    static let description = IntentDescription("Sets where charging stops.")
    @Parameter(title: "Limit", default: 80, inclusiveRange: (0, 100)) var limit: Int
    static var parameterSummary: some ParameterSummary { Summary("Set charge limit to \(\.$limit)%") }

    @MainActor func perform() async throws -> some IntentResult {
        Engine.shared.run(.limit, limit: limit)
        return .result()
    }
}

struct TopUpIntent: AppIntent {
    static let title: LocalizedStringResource = "Top Up Battery"
    static let description = IntentDescription("Charges to 100% until you unplug.")

    @MainActor func perform() async throws -> some IntentResult {
        Engine.shared.run(.topUp)
        return .result()
    }
}

struct DischargeIntent: AppIntent {
    static let title: LocalizedStringResource = "Discharge Battery"
    static let description = IntentDescription("Uses the battery while plugged in.")

    @MainActor func perform() async throws -> some IntentResult {
        Engine.shared.run(.discharge)
        return .result()
    }
}

struct CalibrateIntent: AppIntent {
    static let title: LocalizedStringResource = "Calibrate Battery"
    static let description = IntentDescription("Starts a full calibration, which takes many hours.")

    @MainActor func perform() async throws -> some IntentResult {
        Engine.shared.run(.calibrate)
        return .result()
    }
}

struct StopIntent: AppIntent {
    static let title: LocalizedStringResource = "Return to Charge Limit"
    static let description = IntentDescription("Stops a top up, discharge or calibration.")

    @MainActor func perform() async throws -> some IntentResult {
        Engine.shared.run(nil)
        return .result()
    }
}

struct KeepAwakeIntent: AppIntent {
    static let title: LocalizedStringResource = "Keep Mac Awake"
    static let description = IntentDescription("Keeps your Mac awake. Zero hours turns it off.")
    @Parameter(title: "Hours", default: 2, inclusiveRange: (0, 24)) var hours: Double
    static var parameterSummary: some ParameterSummary { Summary("Keep Mac awake for \(\.$hours) hours") }

    @MainActor func perform() async throws -> some IntentResult {
        if hours > 0 { Engine.shared.keepAwake(hours: hours) } else { Engine.shared.stopAwake() }
        return .result()
    }
}

struct BatteryIntent: AppIntent {
    static let title: LocalizedStringResource = "Get Battery Level"
    static let description = IntentDescription("Returns the battery percentage.")

    @MainActor func perform() async throws -> some IntentResult & ReturnsValue<Int> {
        .result(value: Engine.shared.battery.percent)
    }
}
