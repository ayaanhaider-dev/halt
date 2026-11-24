import SwiftUI

struct PopoverView: View {
    @State private var engine = Engine.shared
    @Environment(\.openWindow) private var openWindow

    var body: some View {
        let settings = engine.settings
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top) {
                ChargeHeader()
                Spacer()
                AwakeMenu()
                Button {
                    openWindow(id: "main")
                    NSApp.activate()
                } label: {
                    Image(systemName: "gearshape")
                }
                .buttonStyle(.glass).buttonBorderShape(.circle).accessibilityLabel("Open Halt")
            }
            ChargeLimitSlider()
            if settings.hideButtons != true { ChargeButtons() }
            ControlStatus().font(.callout)
            if settings.showDetails { BatterySummary() }
            if settings.pinHealth == true { HealthCard() }
            if settings.pinPower == true { PowerCard() }
            if settings.showFlow { PowerFlowView(flow: engine.battery.flow) }
        }
        .padding().frame(width: 384)
        // While the window resizes, stay put instead of drifting to its middle.
        .frame(maxHeight: .infinity, alignment: .top)
        .background(Color(nsColor: .windowBackgroundColor).opacity(0.5))
    }
}
