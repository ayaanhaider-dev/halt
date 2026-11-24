import Foundation

private let utc: Calendar = {
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = .gmt
    return calendar
}()
let monday9 = utc.date(from: DateComponents(year: 2026, month: 11, day: 23, hour: 9))!

func testWeeklyTask() {
    var task = ScheduledTask(weekdays: [2], time: 540, lastRun: monday9.addingTimeInterval(-3600))
    precondition(!task.shouldRun(monday9.addingTimeInterval(-60), catchUp: true, utc))
    precondition(task.shouldRun(monday9, catchUp: false, utc))
    precondition(!task.shouldRun(monday9.addingTimeInterval(600), catchUp: false, utc))
    precondition(task.shouldRun(monday9.addingTimeInterval(600), catchUp: true, utc))
    task.lastRun = monday9
    precondition(!task.shouldRun(monday9.addingTimeInterval(30), catchUp: true, utc))
}

func testOneTimeTask() {
    var task = ScheduledTask(lastRun: monday9.addingTimeInterval(-60))
    task.once = monday9
    precondition(task.next(monday9.addingTimeInterval(-1), utc) == monday9 && task.next(monday9, utc) == nil)
    precondition(
        task.shouldRun(monday9, catchUp: false, utc)
            && !task.shouldRun(monday9.addingTimeInterval(-1), catchUp: true, utc))
    precondition(
        ScheduledTask(weekdays: [2], time: 540).next(monday9, utc) == monday9.addingTimeInterval(7 * 86400))
}
