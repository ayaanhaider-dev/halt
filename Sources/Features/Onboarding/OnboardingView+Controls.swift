import SwiftUI

extension OnboardingView {
    @ViewBuilder var picture: some View {
        switch step {
        case .battery:
            BatteryCells(filled: drawn ? Double(health) : 0, bright: 100, color: .white, spacing: 4)
        case .limit: BatteryCells(filled: Double(limit), bright: 100, color: .halt, spacing: 4)
        case .heat:
            BatteryCells(
                filled: heatScale(battery.temperature), bright: heat ? heatScale(heatLimit) : 100,
                color: heat && battery.temperature >= heatLimit ? .orange : .white, spacing: 4)
        case .permission:
            BatteryCells(filled: installed ? Double(limit) : 0, bright: 100, color: .halt, spacing: 4)
        case .ready:
            BatteryCells(filled: Double(battery.percent), bright: Double(limit), color: .halt, spacing: 4)
        }
    }

    @ViewBuilder var controls: some View {
        switch step {
        case .battery: EmptyView()
        case .limit:
            HStack(spacing: 10) {
                stop("Mostly at a desk", 60)
                stop("A bit of both", 80)
                stop("Often out", 90)
                stop("No limit", 100)
            }
        case .heat:
            VStack(alignment: .leading, spacing: 14) {
                Toggle(isOn: $heat) {
                    Text("Pause charging when the battery gets hot").frame(
                        maxWidth: .infinity, alignment: .leading)
                }
                HStack(spacing: 14) {
                    Slider(value: $heatLimit, in: 30...45, step: 1) { Text("Pause above") }.labelsHidden()
                    Text("above \(degrees(heatLimit))").monospacedDigit().frame(
                        width: 104, alignment: .trailing)
                }
                .disabled(!heat)
            }
        case .permission:
            if engine.conflict {
                Text("AlDente is running. Quit it, or the two will fight over your battery.").foregroundStyle(
                    .orange)
            } else if let error = engine.error, !installed {
                Text(error).foregroundStyle(.orange)
            }
        case .ready:
            VStack(alignment: .leading, spacing: 14) {
                Toggle(isOn: $login) {
                    Text("Open Halt when I log in").frame(maxWidth: .infinity, alignment: .leading)
                }
                Toggle(
                    isOn: Binding(
                        get: { engine.settings.barItems.contains(.battery) },
                        set: { on in
                            engine.settings.barItems = MenuBarItem.allCases.filter {
                                $0 == .battery ? on : engine.settings.barItems.contains($0)
                            }
                        })
                ) {
                    Text("Show the battery percentage in the menu bar").frame(
                        maxWidth: .infinity, alignment: .leading)
                }
            }
        }
    }

    func stop(_ name: String, _ percent: Int) -> some View {
        let recent = engine.samples.suffix(120).map(\.watts)
        let usual = recent.isEmpty ? battery.flow.system : recent.reduce(0, +) / Double(recent.count)
        let minutes = runtime(
            percent: percent, capacity: battery.maximum, volts: battery.voltage, watts: usual)
        let on = limit == percent
        return Button {
            withAnimation(reduceMotion ? nil : .easeOut(duration: 0.3)) { limit = percent }
        } label: {
            VStack(alignment: .leading, spacing: 4) {
                Text("\(percent)%").font(.title2.weight(.semibold).monospacedDigit())
                Text(name)
                Text(minutes.map { "about \($0 / 60)h \($0 % 60 / 10 * 10)m unplugged" } ?? " ").font(
                    .caption
                ).foregroundStyle(on ? .black.opacity(0.65) : .secondary)
            }
            .lineLimit(1).minimumScaleFactor(0.8)
            .foregroundStyle(on ? .black : .primary)
            .padding(14).frame(maxWidth: .infinity, alignment: .leading)
            .background(
                on ? AnyShapeStyle(Color.halt) : AnyShapeStyle(.quaternary.opacity(0.6)),
                in: .rect(cornerRadius: 10)
            )
            .contentShape(.rect)
        }
        .buttonStyle(.plain).accessibilityAddTraits(on ? .isSelected : [])
    }
}
