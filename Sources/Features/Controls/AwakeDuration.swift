import SwiftUI

enum AwakeDuration {
    static let all: [(name: String, hours: Double?)] = [
        ("30 min", 0.5), ("1 hour", 1), ("2 hours", 2), ("5 hours", 5), ("Until I stop", nil),
    ]

    @MainActor static func buttons(_ engine: Engine) -> some View {
        ForEach(all, id: \.name) { choice in Button(choice.name) { engine.keepAwake(hours: choice.hours) } }
    }
}
