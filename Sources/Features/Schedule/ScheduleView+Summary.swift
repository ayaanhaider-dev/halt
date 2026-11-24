import Foundation

extension ScheduleView {
    func icon(_ action: TaskAction) -> String {
        switch action {
        case .limit: "gauge.with.needle"
        case .topUp: "arrow.up"
        case .calibrate: "arrow.triangle.2.circlepath"
        case .discharge: "arrow.down"
        }
    }

    func summary(_ task: ScheduledTask) -> String {
        let next =
            task.next(.now).map {
                ". Next: " + $0.formatted(.dateTime.weekday().day().month().hour().minute())
            } ?? ""
        if let once = task.once {
            return task.enabled
                ? "Once, \(once.formatted(date: .abbreviated, time: .shortened))" : "Ran once, now off"
        }
        if task.weekdays.isEmpty { return "Pick a day to run it" }
        let days =
            task.weekdays.count == 7
            ? "Every day"
            : task.weekdays.sorted().map { Calendar.current.shortWeekdaySymbols[$0 - 1] }.joined(
                separator: ", ")
        return
            "\(days) at \(Calendar.current.startOfDay(for: .now).addingTimeInterval(Double(task.time) * 60).formatted(date: .omitted, time: .shortened))\(next)"
    }
}
