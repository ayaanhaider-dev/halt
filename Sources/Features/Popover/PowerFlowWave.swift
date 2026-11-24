import SwiftUI

/// A glow with a soft front that keeps travelling in the direction the power goes.
/// Core Animation, because redrawing this in SwiftUI every frame kept the CPU busy.
struct PowerFlowWave: NSViewRepresentable {
    let color: Color
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func makeNSView(context: Context) -> WaveView { WaveView() }
    func updateNSView(_ view: WaveView, context: Context) { view.update(NSColor(color), still: reduceMotion) }
}

final class WaveView: NSView {
    private let gradient = CAGradientLayer()
    private var still = false

    init() {
        super.init(frame: .zero)
        layer = gradient
        wantsLayer = true
        gradient.locations = [0, 0.8, 1]
    }
    required init?(coder: NSCoder) { nil }

    func update(_ color: NSColor, still: Bool) {
        gradient.colors = [
            color.withAlphaComponent(0).cgColor, color.withAlphaComponent(0.75).cgColor,
            color.withAlphaComponent(0).cgColor,
        ]
        self.still = still
        animate()
    }

    // A layer loses its animations when its window closes.
    override func viewDidMoveToWindow() { animate() }

    private func animate() {
        gradient.startPoint = CGPoint(x: 0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1.1, y: 0.5)
        if still || window == nil { gradient.removeAllAnimations() }
        guard !still, window != nil, gradient.animation(forKey: "wave") == nil else { return }
        let start = CABasicAnimation(keyPath: "startPoint"), end = CABasicAnimation(keyPath: "endPoint")
        start.fromValue = CGPoint(x: -0.9, y: 0.5)
        start.toValue = CGPoint(x: 1, y: 0.5)
        end.fromValue = CGPoint(x: 0, y: 0.5)
        end.toValue = CGPoint(x: 1.9, y: 0.5)
        let wave = CAAnimationGroup()
        wave.animations = [start, end]
        wave.duration = 2.5
        wave.repeatCount = .infinity
        wave.preferredFrameRateRange = CAFrameRateRange(minimum: 15, maximum: 30, preferred: 30)
        gradient.add(wave, forKey: "wave")
    }
}
