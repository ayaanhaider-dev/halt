import AppKit
import Observation

/// Looks for a newer release on GitHub. It never downloads or installs anything itself.
@MainActor @Observable final class UpdateChecker {
    static let shared = UpdateChecker()

    enum State: Equatable {
        case idle, checking, current
        case available(version: String, page: URL)
        case failed(String)
    }

    private(set) var state = State.idle
    private let latest = URL(string: "https://api.github.com/repos/ayaanhaider-dev/halt/releases/latest")!

    private init() {
        Task {
            while true {
                if Engine.shared.settings.skipUpdateCheck != true { await check() }
                try? await Task.sleep(for: .seconds(86_400))
            }
        }
    }

    func check() async {
        state = .checking
        do {
            let (data, response) = try await URLSession.shared.data(from: latest)
            switch (response as? HTTPURLResponse)?.statusCode {
            case 200:
                let release = try JSONDecoder().decode(Release.self, from: data)
                guard release.isTrusted else {
                    return state = .failed("The release has an unexpected address.")
                }
                state =
                    isNewer(release.version, than: Bundle.main.version)
                    ? .available(version: release.version, page: release.page) : .current
            case 404: state = .current
            default: state = .failed("GitHub didn't answer. Try again later.")
            }
        } catch {
            state = .failed(error.localizedDescription)
        }
    }
}

extension Bundle {
    var version: String { object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "0" }
}
