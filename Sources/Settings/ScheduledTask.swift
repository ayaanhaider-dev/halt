import Foundation

struct TaskRun: Codable, Equatable, Identifiable {
    var id = UUID()
    let date: Date, name: String
}

struct ScheduledTask: Codable, Identifiable, Equatable {
    var id = UUID()
    var action = TaskAction.topUp
    var limit = 80
    var weekdays: Set<Int> = [2]
    var time = 9 * 60
    var enabled = true
    var lastRun = Date()
    /// A single run at this moment instead of weekly.
    var once: Date?

    var name: String { action == .limit ? "Set limit to \(limit)%" : action.rawValue }

    func next(_ now: Date, _ calendar: Calendar = .current) -> Date? {
        guard enabled else { return nil }
        if let once { return once > now ? once : nil }
        return weekdays.compactMap {
            calendar.nextDate(
                after: now,
                matching: DateComponents(hour: time / 60, minute: time % 60, second: 0, weekday: $0),
                matchingPolicy: .nextTime)
        }.min()
    }

    /// The most recent moment this task should have run.
    func lastDue(_ now: Date, _ calendar: Calendar = .current) -> Date? {
        if let once { return once <= now ? once : nil }
        return weekdays.compactMap {
            // `before` excludes the exact match, so look from one second later.
            calendar.nextDate(
                after: now.addingTimeInterval(1),
                matching: DateComponents(hour: time / 60, minute: time % 60, second: 0, weekday: $0),
                matchingPolicy: .nextTime, direction: .backward)
        }.max()
    }

    func shouldRun(_ now: Date, catchUp: Bool, _ calendar: Calendar = .current) -> Bool {
        guard enabled, let due = lastDue(now, calendar), due > lastRun else { return false }
        return catchUp || now.timeIntervalSince(due) < 120
    }
}
