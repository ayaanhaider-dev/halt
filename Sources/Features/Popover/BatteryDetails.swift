import SwiftUI

/// Two cards: the battery itself, then the live electrical readings.
struct BatteryDetails: View {
    var body: some View {
        Group {
            HealthCard()
            PowerCard()
        }
    }
}
