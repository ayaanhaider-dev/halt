import SwiftUI

/// Every step is about this Mac's own battery, drawn with the same cells as the rest of Halt.
struct OnboardingView: View {
    enum Step: Int, CaseIterable { case battery, limit, heat, permission, ready }
    @State var step = Step.battery
    @State var engine = Engine.shared
    @State var limit = Engine.shared.settings.onboarded ? Engine.shared.settings.limit : 80
    @State var heat = !Engine.shared.settings.onboarded || Engine.shared.settings.heatProtection
    @State var heatLimit = Engine.shared.settings.heatLimit
    @State var login = Engine.shared.launchAtLogin
    @State var drawn = false
    @Environment(\.accessibilityReduceMotion) var reduceMotion

    var installed: Bool { engine.helperStatus == .enabled }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 9) {
                AppLogo()
                Text("Halt").font(.title3.bold())
                LvenoLink()
                Spacer()
                Text("\(step.rawValue + 1) of \(Step.allCases.count)").foregroundStyle(.secondary)
                    .monospacedDigit()
            }
            picture.frame(height: step == .battery || step == .permission ? 190 : 120).padding(.top, 34)
            VStack(alignment: .leading, spacing: 10) {
                Text(headline).font(.system(size: 30, weight: .semibold)).fixedSize(
                    horizontal: false, vertical: true)
                Text(detail).font(.title3).foregroundStyle(.secondary).fixedSize(
                    horizontal: false, vertical: true
                ).frame(maxWidth: 560, alignment: .leading)
            }
            .padding(.top, 26)
            controls.padding(.top, 22)
            Spacer(minLength: 0)
            HStack {
                if step != .battery { Button("Back") { go(-1) } }
                if engine.settings.onboarded { Button("Cancel") { engine.showSetup = false } }
                Spacer()
                if step == .permission && !installed { Button("Later") { go(1) } }
                Button(
                    step == .ready
                        ? "Start Using Halt" : step == .permission && !installed ? "Allow…" : "Continue"
                ) {
                    if step == .ready {
                        done()
                    } else if step == .permission && !installed {
                        engine.installHelper()
                    } else {
                        go(1)
                    }
                }
                .buttonStyle(Solid()).keyboardShortcut(.defaultAction)
            }
            .controlSize(.large)
        }
        .padding(36).frame(width: 720, height: 560)
        .background(Color(white: 0.09)).environment(\.colorScheme, .dark)
        .toggleStyle(.switch).tint(.halt)
        .onAppear { withAnimation(reduceMotion ? nil : .easeOut(duration: 0.9)) { drawn = true } }
    }

    // The system's prominent button fades to nothing on dark when the window is inactive.
    private struct Solid: ButtonStyle {
        func makeBody(configuration: Configuration) -> some View {
            configuration.label.fontWeight(.medium).foregroundStyle(.black).padding(.horizontal, 18).frame(
                height: 32
            )
            .background(.white.opacity(configuration.isPressed ? 0.75 : 1), in: .capsule).contentShape(
                [.interaction, .focusEffect], .capsule)
        }
    }

    func go(_ by: Int) {
        guard let new = Step(rawValue: step.rawValue + by) else { return }
        withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.35)) { step = new }
    }

    // Nothing about charging changes before this.
    func done() {
        engine.run(.limit, limit: limit)
        engine.settings.heatProtection = heat
        engine.settings.heatLimit = heatLimit
        if login != engine.launchAtLogin { engine.launchAtLogin = login }
        engine.settings.onboarded = true
        engine.showSetup = false
        engine.tick()
    }

    var battery: Battery { engine.battery }
    var health: Int { min(100, Int(battery.health.rounded())) }
    /// 15–45° across the cells.
    func heatScale(_ degrees: Double) -> Double { min(100, max(0, (degrees - 15) / 30 * 100)) }

}
