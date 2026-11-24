import Foundation

func testLimitsAndOverrides() {
    var settings = Settings()
    precondition(settings.effectiveLimit == 100)
    precondition(!settings.pausesOptimized)
    settings.limit = 86
    precondition(settings.pausesOptimized)
    settings.limit = 80
    precondition(!settings.pausesOptimized)
    settings.topUp = true
    precondition(settings.pausesOptimized)
    settings.topUp = false
    settings.limit = 0
    precondition(settings.effectiveLimit == 0)
    settings.limit = 80
    settings.topUp = true
    precondition(settings.effectiveLimit == 100)
    settings.update(percent: 100, temperature: 30, plugged: true, wasPlugged: true)
    precondition(settings.topUp)
    settings.update(percent: 100, temperature: 30, plugged: false, wasPlugged: true)
    precondition(!settings.topUp && settings.effectiveLimit == 80)

    settings.discharge(from: 70)
    precondition(settings.effectiveLimit == 20 && !settings.pausesOptimized)
    settings.update(percent: 70, temperature: 25, plugged: false, wasPlugged: true)
    precondition(settings.effectiveLimit == 80)
    settings.topUp = true
    settings.discharge(from: 95)
    precondition(!settings.topUp && settings.dischargeTarget == 80)
    settings.discharge(from: 15)
    precondition(settings.dischargeTarget == nil && settings.effectiveLimit == 80)
    settings.heatProtection = true
    settings.update(percent: 60, temperature: 35, plugged: true, wasPlugged: true)
    precondition(settings.effectiveLimit == 60)
    settings.update(percent: 61, temperature: 34, plugged: true, wasPlugged: true)
    precondition(settings.effectiveLimit == 60)
    settings.update(percent: 60, temperature: 32.9, plugged: true, wasPlugged: true)
    precondition(settings.effectiveLimit == 80)

    settings.calibration = 0
    for (percent, limit) in [(99, 100), (100, 8), (50, 8), (12, 100), (100, 80)] {
        settings.update(percent: percent, temperature: 25, plugged: true, wasPlugged: true)
        precondition(settings.effectiveLimit == limit)
    }
    precondition(settings.calibration == nil && settings.lastCalibration != nil)
}

func testCalibrationByMacOS() {
    var settings = Settings()
    settings.limit = 80
    settings.calibrateAfterMac = true
    settings.update(
        percent: 90, temperature: 25, plugged: true, wasPlugged: true, charging: true, settled: false)
    precondition(settings.macCalibrating == nil)
    settings.update(
        percent: 90, temperature: 25, plugged: true, wasPlugged: true, charging: true, settled: true)
    precondition(settings.macCalibrating == true)
    settings.update(
        percent: 100, temperature: 25, plugged: true, wasPlugged: true, charging: true, settled: true)
    precondition(settings.macCalibrating == nil && settings.calibration == 1 && settings.lastFull != nil)
}
