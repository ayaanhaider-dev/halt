import SwiftUI

struct ScheduleView: View {
    @State var engine = Engine.shared
    @State var open: UUID?

    var body: some View {
        SettingsPage(title: "Schedule", note: "Let Halt change charging by itself. It needs to be open.") {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text("Tasks").font(.title3.bold())
                    Spacer()
                    Menu("Add Task", systemImage: "plus") {
                        ForEach(TaskAction.allCases, id: \.self) { action in
                            Button(action.rawValue, systemImage: icon(action)) {
                                add(ScheduledTask(action: action))
                            }
                        }
                        Section("Templates") {
                            Button("Monday morning top up") {
                                add(ScheduledTask(action: .topUp, weekdays: [2], time: 5 * 60))
                            }
                            Button("Weekdays at 80%") {
                                add(
                                    ScheduledTask(
                                        action: .limit, limit: 80, weekdays: [2, 3, 4, 5, 6], time: 8 * 60))
                            }
                            Button("Weekends at 60%") {
                                add(ScheduledTask(action: .limit, limit: 60, weekdays: [7], time: 9 * 60))
                            }
                            Button("Top up tomorrow, once") {
                                var task = ScheduledTask(action: .topUp)
                                task.once = Calendar.current.date(
                                    bySettingHour: 6, minute: 0, second: 0, of: .now.addingTimeInterval(86400)
                                )
                                add(task)
                            }
                        }
                    }
                    .menuStyle(.button).buttonStyle(.glassProminent).fixedSize()
                }
                if engine.settings.tasks.isEmpty {
                    Card {
                        ContentUnavailableView(
                            "No tasks yet", systemImage: "calendar.badge.plus",
                            description: Text("Top up before a trip, or lower the limit on weekends.")
                        )
                        .frame(maxWidth: .infinity).padding(.vertical, 12)
                    }
                }
                ForEach($engine.settings.tasks) { $task in card($task) }
                Card {
                    SettingRow(
                        icon: "clock.arrow.circlepath", title: "Run missed tasks later",
                        note: "If your Mac was asleep or Halt was closed", on: engine.settings.catchUp
                    ) {
                        Toggle("Run missed tasks later", isOn: $engine.settings.catchUp)
                    }
                    .padding(6)
                }
            }
            if let runs = engine.settings.runs, !runs.isEmpty {
                TitledCard("History") {
                    ForEach(runs.prefix(8)) { run in
                        HStack {
                            Text(run.name)
                            Spacer()
                            Text(run.date.formatted(date: .abbreviated, time: .shortened)).foregroundStyle(
                                .secondary
                            ).monospacedDigit()
                        }
                    }
                    Button("Clear") { engine.settings.runs = nil }.buttonStyle(.glass)
                }
            }
            TitledCard("Shortcuts") {
                SettingRow(
                    icon: "square.stack.3d.up.fill", title: "Use Halt in Shortcuts",
                    note: "Search for Halt in the Shortcuts app to find its actions"
                ) {
                    Button("Open Shortcuts") {
                        NSWorkspace.shared.open(URL(filePath: "/System/Applications/Shortcuts.app"))
                    }.buttonStyle(.glass)
                }
                Divider()
                Text("Or copy a command for scripts and Terminal.").foregroundStyle(.secondary)
                ForEach(
                    [
                        ("Set limit to 80%", "limit 80"), ("Top up", "topup"), ("Discharge", "discharge"),
                        ("Calibrate", "calibrate"), ("Stop", "cancel"),
                    ], id: \.1
                ) { name, command in
                    HStack {
                        Text(name)
                        Spacer()
                        Text(command).font(.callout.monospaced()).foregroundStyle(.secondary)
                        Button("Copy", systemImage: "doc.on.doc") {
                            NSPasteboard.general.clearContents()
                            NSPasteboard.general.setString(
                                "\"\(Bundle.main.executablePath ?? "Halt")\" \(command)", forType: .string)
                        }
                        .buttonStyle(.glass).accessibilityLabel("Copy \(name)")
                    }
                }
            }
        }
    }

}
