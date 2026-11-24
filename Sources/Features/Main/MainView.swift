import SwiftUI

struct MainView: View {
    enum Page: String, CaseIterable {
        case dashboard = "Dashboard"
        case charging = "Charging"
        case energy = "Energy"
        case schedule = "Schedule"
        case appearance = "Appearance"
        case general = "General"
        var icon: String {
            switch self {
            case .dashboard: "gauge.with.dots.needle.50percent"
            case .charging: "bolt.fill"
            case .energy: "leaf.fill"
            case .schedule: "calendar"
            case .appearance: "paintbrush.fill"
            case .general: "gearshape.fill"
            }
        }
    }
    @State var page: Page? = .dashboard
    @State var engine = Engine.shared

    var body: some View {
        // Not a sheet: macOS won't quit an app while one is open.
        if !engine.settings.onboarded || engine.showSetup {
            OnboardingView().frame(maxWidth: .infinity, maxHeight: .infinity).background(Color(white: 0.09))
                .frame(minWidth: 780, minHeight: 600).navigationTitle("Setup - Halt")
        } else {
            pages
        }
    }

    var pages: some View {
        NavigationSplitView {
            List(selection: $page) {
                ForEach([Page.dashboard, .charging, .energy, .schedule], id: \.self, content: label)
                Section("Settings") {
                    label(.appearance)
                    label(.general)
                }
            }
            .navigationSplitViewColumnWidth(min: 210, ideal: 230)
            .safeAreaInset(edge: .top) { status }
            .safeAreaInset(edge: .bottom) {
                HStack {
                    Button("Quit Halt", systemImage: "power") { NSApp.terminate(nil) }.buttonStyle(.plain)
                        .foregroundStyle(.secondary)
                    Spacer()
                    LvenoLink(height: 18).font(.caption)
                }
                .padding(16)
            }
        } detail: {
            switch page ?? .dashboard {
            case .dashboard: DashboardView()
            case .charging: ChargingView()
            case .energy: EnergyView()
            case .schedule: ScheduleView()
            case .appearance: AppearanceView()
            case .general: GeneralView()
            }
        }
        .navigationTitle("\((page ?? .dashboard).rawValue) - Halt")
        .toggleStyle(.switch).tint(.halt)
        .frame(minWidth: 780, minHeight: 520)
    }

}
