import SwiftUI

/// The charge as a row of cells. Dragging anywhere on them moves the limit line; a click alone does nothing.
struct ChargeLimitSlider: View {
    @State private var engine = Engine.shared
    /// The limit while it is being changed.
    @State private var editing: Int?
    @State private var dragStart: Int?
    @State private var confirm: Int?
    @State private var pending: Task<Void, Never>?
    @State private var width: CGFloat = 1

    private var value: Int { editing ?? confirm ?? engine.settings.shownLimit }

    var body: some View {
        let battery = engine.battery, mode = engine.mode
        VStack(spacing: 10) {
            BatteryCells(filled: Double(battery.percent), bright: Double(value), color: mode.color)
                .frame(height: 34)
                .overlay(alignment: .leading) {
                    Capsule().fill(.white).shadow(color: .black.opacity(0.5), radius: 2)
                        .frame(width: dragStart == nil ? 6 : 8, height: dragStart == nil ? 44 : 50)
                        .frame(width: 8)
                        .offset(x: (width - 8) * CGFloat(value) / 100)
                        .animation(.easeOut(duration: 0.15), value: dragStart == nil)
                }
                .contentShape(.rect.inset(by: -6))
                .gesture(drag)
                .pointerStyle(.columnResize)
                .animation(.easeInOut(duration: 0.3), value: mode)
                .onGeometryChange(for: CGFloat.self, of: \.size.width) { width = $0 }
                .accessibilityElement()
                .accessibilityLabel("Charge limit")
                .accessibilityValue("\(value)%, battery at \(battery.percent)%")
                .accessibilityAdjustableAction { nudge($0 == .increment ? 5 : -5) }
            HStack(spacing: 0) {
                Text("Charge limit").foregroundStyle(.primary.opacity(0.65))
                Spacer()
                HStack(spacing: 0) {
                    step("minus", -1)
                    Text("\(value)%").fontWeight(.semibold).monospacedDigit().frame(width: 46)
                    step("plus", 1)
                }
                .glassEffect(.regular, in: .capsule)
            }
        }
        .animation(dragStart == nil ? .easeInOut(duration: 0.2) : nil, value: value)
        .confirmationDialog(
            "Let the battery drain to \(value)%?",
            isPresented: Binding(get: { confirm != nil }, set: { if !$0 { confirm = nil } }),
            presenting: confirm
        ) { limit in
            Button("Drain to \(limit)%", role: .destructive) { engine.run(.limit, limit: limit) }
            Button("Cancel", role: .cancel) {}
        } message: { _ in
            Text(
                "macOS drains the battery to the limit even while plugged in. Unplugging at a very low level can switch your Mac off."
            )
        }
    }

    private var drag: some Gesture {
        DragGesture(minimumDistance: 2)
            .onChanged {
                pending?.cancel()
                let start = dragStart ?? value
                dragStart = start
                let new = snappedLimit(from: start, moved: $0.translation.width / width * 100)
                if new != editing, new % 5 == 0 {
                    NSHapticFeedbackManager.defaultPerformer.perform(.alignment, performanceTime: .now)
                }
                editing = new
            }
            .onEnded { _ in
                dragStart = nil
                commit()
            }
    }

    private func step(_ icon: String, _ amount: Int) -> some View {
        Button {
            nudge(amount)
        } label: {
            Image(systemName: icon).font(.caption.bold()).frame(width: 30, height: 28).contentShape(.rect)
        }
        .buttonStyle(.plain).buttonRepeatBehavior(.enabled)
        .accessibilityLabel(amount > 0 ? "Raise limit" : "Lower limit")
    }

    // Waits for the last click, so macOS gets one change instead of many.
    private func nudge(_ amount: Int) {
        editing = min(100, max(0, value + amount))
        pending?.cancel()
        pending = Task {
            try? await Task.sleep(for: .seconds(0.6))
            if !Task.isCancelled { commit() }
        }
    }

    private func commit() {
        guard let limit = editing else { return }
        editing = nil
        guard limit != engine.settings.shownLimit else { return }
        if limit < 20 { confirm = limit } else { engine.run(.limit, limit: limit) }
    }
}
