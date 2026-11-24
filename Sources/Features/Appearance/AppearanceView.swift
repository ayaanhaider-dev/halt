import SwiftUI

struct AppearanceView: View {
    @State var engine = Engine.shared
    @State var height: CGFloat = 0
    let scale: CGFloat = 0.68

    var body: some View {
        SettingsPage(title: "Appearance", note: "Choose what you see. The preview is live.") {
            ViewThatFits(in: .horizontal) {
                HStack(alignment: .top, spacing: 28) {
                    controls.frame(minWidth: 330)
                    preview
                }
                VStack(alignment: .leading, spacing: 28) {
                    controls
                    preview
                }
            }
        }
    }

    var controls: some View {
        VStack(alignment: .leading, spacing: 28) {
            TitledCard("Menu bar") {
                Text("Click to show or hide.").foregroundStyle(.secondary)
                LazyVGrid(
                    columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 3), spacing: 10
                ) {
                    ForEach(MenuBarItem.allCases, id: \.self) { choice in
                        item(
                            engine.barValue(choice), choice.rawValue,
                            Binding(
                                get: { engine.settings.barItems.contains(choice) },
                                set: { on in
                                    // Always in the order shown here.
                                    let now = engine.settings.barItems
                                    engine.settings.barItems = MenuBarItem.allCases.filter {
                                        $0 == choice ? on : now.contains($0)
                                    }
                                }))
                    }
                }
                Divider()
                LabeledContent("Icon") {
                    Picker(
                        "Icon",
                        selection: Binding(
                            get: { engine.settings.barIcon ?? .status }, set: { engine.settings.barIcon = $0 }
                        )
                    ) { ForEach(MenuBarIconStyle.allCases, id: \.self) { Text($0.rawValue) } }
                }
                LabeledContent("Right click") {
                    Picker(
                        "Right click",
                        selection: Binding(
                            get: { engine.settings.rightClick ?? .popover },
                            set: { engine.settings.rightClick = $0 })
                    ) { ForEach(RightClick.allCases, id: \.self) { Text($0.rawValue) } }
                }
                LabeledContent("Spacing") {
                    Slider(
                        value: Binding(
                            get: { Double(engine.settings.barSpacing ?? 2) },
                            set: { engine.settings.barSpacing = Int($0) }), in: 1...6, step: 1
                    ) { Text("Spacing") }.frame(width: 140)
                }
                LabeledContent("Updates every") {
                    HStack {
                        Text("\(engine.settings.barInterval ?? 1) s").monospacedDigit()
                        Stepper(
                            "Updates every",
                            value: Binding(
                                get: { engine.settings.barInterval ?? 1 },
                                set: { engine.settings.barInterval = $0 }), in: 1...20
                        ).labelsHidden()
                    }
                }
                LabeledContent("Yellow icon in Low Power Mode") {
                    Toggle(
                        "Yellow icon in Low Power Mode",
                        isOn: Binding(
                            get: { engine.settings.barTint == true }, set: { engine.settings.barTint = $0 }))
                }
            }
            .labeledContentStyle(SpreadLabeledContentStyle())
            TitledCard("Popover") {
                section(
                    "slider.horizontal.3", "Buttons", "Discharge and Top Up",
                    Binding(
                        get: { engine.settings.hideButtons != true },
                        set: { engine.settings.hideButtons = !$0 }))
                section("heart.fill", "Summary", "Health, heat and cycles", $engine.settings.showDetails)
                section(
                    "cross.case.fill", "Health card", "Always open",
                    Binding(
                        get: { engine.settings.pinHealth == true }, set: { engine.settings.pinHealth = $0 }))
                section(
                    "bolt.fill", "Power card", "Always open",
                    Binding(get: { engine.settings.pinPower == true }, set: { engine.settings.pinPower = $0 })
                )
                section(
                    "arrow.trianglehead.branch", "Power flow", "Where your power goes",
                    $engine.settings.showFlow)
            }
        }
    }

    func section(_ icon: String, _ title: String, _ note: String, _ on: Binding<Bool>) -> some View {
        SettingRow(icon: icon, title: title, note: note, on: on.wrappedValue) { Toggle(title, isOn: on) }
    }

    func item(_ value: String, _ name: String, _ shown: Binding<Bool>) -> some View {
        Button {
            shown.wrappedValue.toggle()
        } label: {
            VStack(spacing: 4) {
                Text(value).font(.system(.title3, design: .rounded).weight(.semibold).monospacedDigit())
                Text(name).font(.callout).foregroundStyle(.secondary)
            }
            .lineLimit(1).minimumScaleFactor(0.7)
        }
        .buttonStyle(ChoiceButtonStyle(on: shown.wrappedValue)).accessibilityAddTraits(
            shown.wrappedValue ? .isSelected : [])
    }

}
