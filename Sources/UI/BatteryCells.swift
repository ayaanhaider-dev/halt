import SwiftUI

/// Halt's forty cells: filled up to one point, dimmed past another.
struct BatteryCells: View {
    let filled: Double, bright: Double, color: Color
    var spacing: CGFloat = 2

    var body: some View {
        HStack(spacing: spacing) {
            ForEach(0..<40) { i in
                let level = (Double(i) + 0.5) * 2.5
                Capsule().fill(level <= filled ? AnyShapeStyle(color) : AnyShapeStyle(.quaternary)).opacity(
                    level <= bright ? 1 : 0.4)
            }
        }
    }
}
