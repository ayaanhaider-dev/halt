import SwiftUI

struct CalibrationControls: View {
    @State private var engine = Engine.shared
    @State private var confirm = false

    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            ForEach(Settings.calibrationSteps.indices, id: \.self) { i in
                let now = engine.settings.calibration == i
                VStack(spacing: 6) {
                    Image(systemName: ["bolt.fill", "arrow.down", "bolt.fill", "flag.checkered"][i])
                        .foregroundStyle(now ? .white : .secondary).frame(width: 34, height: 34)
                        .background(
                            now ? AnyShapeStyle(ChargeMode.holding.color) : AnyShapeStyle(.quaternary),
                            in: .circle)
                    Text(Settings.calibrationSteps[i]).font(.caption).foregroundStyle(
                        now ? .primary : .secondary
                    ).multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity).accessibilityElement(children: .combine)
            }
        }
        .padding(.vertical, 6)
        HStack {
            Text(
                "Last: \(engine.settings.lastCalibration?.formatted(date: .abbreviated, time: .omitted) ?? "never")"
            ).foregroundStyle(.secondary)
            Spacer()
            if engine.settings.calibration != nil {
                Button("Stop Calibration") { engine.run(nil) }.buttonStyle(.glass)
            } else {
                Button("Start Calibration…") { confirm = true }.buttonStyle(.glass)
            }
        }
        .confirmationDialog("Start calibration?", isPresented: $confirm) {
            Button("Start") { engine.run(.calibrate) }
        } message: {
            Text(
                "Keep your Mac plugged in and Halt open. It takes many hours and uses about one battery cycle."
            )
        }
    }
}
