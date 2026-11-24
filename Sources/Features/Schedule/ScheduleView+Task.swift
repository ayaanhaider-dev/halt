import SwiftUI

extension ScheduleView {
    func card(_ task: Binding<ScheduledTask>) -> some View {
        let item = task.wrappedValue
        return Card {
            VStack(alignment: .leading, spacing: 14) {
                SettingRow(icon: icon(item.action), title: item.name, note: summary(item), on: item.enabled) {
                    HStack(spacing: 10) {
                        Button {
                            open = open == item.id ? nil : item.id
                        } label: {
                            Image(systemName: "chevron.down").rotationEffect(
                                .degrees(open == item.id ? 180 : 0))
                        }
                        .buttonStyle(.glass).buttonBorderShape(.circle).accessibilityLabel(
                            open == item.id ? "Close" : "Edit")
                        Toggle("Enabled", isOn: task.enabled)
                    }
                }
                if open == item.id {
                    Divider()
                    if item.action == .limit {
                        Stepper("Limit \(item.limit)%", value: task.limit, in: 0...100, step: 5)
                    }
                    Picker(
                        "Repeat",
                        selection: Binding(
                            get: { item.once != nil },
                            set: { once in
                                task.wrappedValue.once = once ? Date.now.addingTimeInterval(3600) : nil
                                task.wrappedValue.lastRun = .now
                                task.wrappedValue.enabled = true
                            })
                    ) {
                        Text("Weekly").tag(false)
                        Text("Once").tag(true)
                    }.pickerStyle(.segmented).fixedSize()
                    if item.once != nil {
                        DatePicker(
                            "When",
                            selection: Binding(
                                get: { item.once ?? .now },
                                set: {
                                    task.wrappedValue.once = $0
                                    task.wrappedValue.lastRun = .now
                                    task.wrappedValue.enabled = true
                                }), in: Date.now...)
                    } else {
                        DatePicker(
                            "Time",
                            selection: Binding(
                                get: {
                                    Calendar.current.startOfDay(for: .now).addingTimeInterval(
                                        Double(item.time) * 60)
                                },
                                set: {
                                    let c = Calendar.current.dateComponents([.hour, .minute], from: $0)
                                    task.wrappedValue.time = c.hour! * 60 + c.minute!
                                    task.wrappedValue.lastRun = .now
                                }
                            ), displayedComponents: .hourAndMinute)
                    }
                    HStack {
                        if item.once == nil {
                            ForEach(1...7, id: \.self) { day in
                                let on = item.weekdays.contains(day)
                                Button {
                                    if on {
                                        task.wrappedValue.weekdays.remove(day)
                                    } else {
                                        task.wrappedValue.weekdays.insert(day)
                                    }
                                    task.wrappedValue.lastRun = .now
                                } label: {
                                    Text(Calendar.current.veryShortWeekdaySymbols[day - 1]).fontWeight(
                                        .semibold
                                    ).foregroundStyle(
                                        on ? AnyShapeStyle(.black.opacity(0.8)) : AnyShapeStyle(.secondary)
                                    )
                                    .frame(width: 32, height: 32).background(
                                        on ? AnyShapeStyle(Color.halt) : AnyShapeStyle(.quaternary),
                                        in: .circle)
                                }
                                .buttonStyle(.plain).accessibilityLabel(
                                    Calendar.current.weekdaySymbols[day - 1]
                                ).accessibilityAddTraits(on ? .isSelected : [])
                            }
                        }
                        Spacer()
                        Button("Delete", systemImage: "trash", role: .destructive) {
                            engine.settings.tasks.removeAll { $0.id == item.id }
                        }.buttonStyle(.glass)
                    }
                }
            }
            .padding(6)
        }
    }

    func add(_ task: ScheduledTask) {
        engine.settings.tasks.append(task)
        open = task.id
    }
}
