import Foundation
import notify

private let domain = "com.apple.smartcharging.topoffprotection" as CFString

private func preference(_ key: String) -> Int? {
    CFPreferencesCopyValue(key as CFString, domain, kCFPreferencesCurrentUser, kCFPreferencesAnyHost) as? Int
}

private func synchronize() -> Bool {
    CFPreferencesSynchronize(domain, kCFPreferencesCurrentUser, kCFPreferencesAnyHost)
}

/// Apple's own charge limit (PowerUIAgent); the direct charging switches are gone on macOS 27.
enum ChargeLimit {
    static let client: NSObject? = {
        // The settings format has only been checked on macOS 27.
        guard ProcessInfo.processInfo.operatingSystemVersion.majorVersion == 27,
            dlopen("/System/Library/PrivateFrameworks/PowerUI.framework/Versions/A/PowerUI", RTLD_NOW) != nil,
            let cls = NSClassFromString("PowerUISmartChargeClient") as? NSObject.Type
        else { return nil }
        let initializer = NSSelectorFromString("initWithClientName:")
        guard cls.instancesRespond(to: initializer),
            [
                "isMCLCurrentlyEnabled:", "enableMCL:", "disableMCL:", "isSmartChargingCurrentlyEnabled:",
                "temporarilyDisableSmartCharging:",
            ].allSatisfy({ cls.instancesRespond(to: NSSelectorFromString($0)) })
        else { return nil }
        typealias Init = @convention(c) (NSObject, Selector, NSString) -> NSObject?
        let allocated = cls.perform(NSSelectorFromString("alloc"))!.takeUnretainedValue() as! NSObject
        return unsafeBitCast(allocated.method(for: initializer), to: Init.self)(
            allocated, initializer, "halt")
    }()

    static func call<T>(_ name: String, _ client: NSObject, _ result: T.Type) throws -> T {
        typealias Function =
            @convention(c) (NSObject, Selector, AutoreleasingUnsafeMutablePointer<NSError?>) -> UInt64
        typealias BoolFunction =
            @convention(c) (NSObject, Selector, AutoreleasingUnsafeMutablePointer<NSError?>) -> Bool
        let selector = NSSelectorFromString(name)
        var error: NSError?
        let value: Any =
            result == Bool.self
            ? unsafeBitCast(client.method(for: selector), to: BoolFunction.self)(client, selector, &error)
            : unsafeBitCast(client.method(for: selector), to: Function.self)(client, selector, &error)
        if let error { throw error }
        return value as! T
    }

    /// A message when macOS enforces a different limit than the saved one.
    private static func staleLimit(_ target: Int) -> String? {
        let process = Process(), pipe = Pipe()
        process.executableURL = URL(filePath: "/usr/bin/pmset")
        process.arguments = ["-g", "battlimit"]
        process.standardOutput = pipe
        guard (try? process.run()) != nil else { return nil }
        let lines = String(decoding: pipe.fileHandleForReading.readDataToEndOfFile(), as: UTF8.self).split(
            separator: "\n")
        let enforced = zip(lines, lines.dropFirst()).compactMap { reason, value in
            reason.contains("manualChargeLimit") ? Int(value.filter(\.isNumber)) : nil
        }
        return enforced.first { $0 != target }.map {
            "macOS still uses a \($0)% limit; \(target)% is pending."
        }
    }

    static func set(_ percent: Int, pauseOptimized: Bool) -> String? {
        guard (0...100).contains(percent) else { return "The limit must be 0–100%." }
        guard let client else { return "This macOS version doesn't offer the charge control Halt needs." }
        guard synchronize() else { return "Couldn't read the charging settings." }
        do {
            // 1 = on. Optimized Battery Charging holds at 80% by itself; macOS turns it back on later.
            if pauseOptimized, try call("isSmartChargingCurrentlyEnabled:", client, UInt64.self) == 1,
                try !call("temporarilyDisableSmartCharging:", client, Bool.self)
            {
                return "macOS refused to pause Optimized Battery Charging."
            }
            let active = try call("isMCLCurrentlyEnabled:", client, UInt64.self) != 0
            let saved = preference("MCLFeatureState") == 1
            if percent == 100 {
                if !active && !saved { return nil }
                // The agent only clears a leftover limit while it believes the limit is on.
                if !active, try !call("enableMCL:", client, Bool.self) {
                    return "macOS refused to release the limit."
                }
                return try call("disableMCL:", client, Bool.self)
                    ? nil : "macOS refused to release the limit."
            }
            // macOS rejects 0 as a target, so 0% means its lowest value.
            let target = max(1, percent)
            if active && saved && preference("mclLimitValue") == target { return staleLimit(target) }
            // While charging, macOS delays replacing a limit by minutes but clears one at once; a stale low one would drain the battery.
            if active, try !call("disableMCL:", client, Bool.self) {
                return "macOS refused to change the limit."
            }
            if try !call("enableMCL:", client, Bool.self) { return "macOS refused to enable the limit." }
            for (key, value) in [("MCLFeatureState", 1), ("mclLimitValue", target)] {
                CFPreferencesSetValue(
                    key as CFString, value as CFNumber, domain, kCFPreferencesCurrentUser,
                    kCFPreferencesAnyHost)
            }
            guard synchronize(), preference("mclLimitValue") == target,
                notify_post("com.apple.smartcharging.defaultschanged") == 0
            else { return "macOS didn't keep the limit." }
            return nil
        } catch { return error.localizedDescription }
    }
}
