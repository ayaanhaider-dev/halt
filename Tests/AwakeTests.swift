import Foundation

func testAwake() {
    var settings = Settings()
    settings.awakeUntil = monday9
    precondition(settings.awake(monday9.addingTimeInterval(-1)) && !settings.awake(monday9))
    settings.expireAwake(monday9.addingTimeInterval(-1), percent: 21, plugged: false)
    precondition(settings.awakeUntil != nil)
    settings.expireAwake(monday9.addingTimeInterval(-1), percent: 20, plugged: true)
    precondition(settings.awakeUntil != nil)
    settings.expireAwake(monday9.addingTimeInterval(-1), percent: 20, plugged: false)
    precondition(settings.awakeUntil == nil)
    settings.dischargeLid = true
    settings.dischargeTarget = 20
    precondition(
        settings.staysOnWithLidClosed(monday9, plugged: true)
            && !settings.staysOnWithLidClosed(monday9, plugged: false))
}
