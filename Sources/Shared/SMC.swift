import Foundation
import IOKit

final class SMC {
    private var port: io_connect_t = 0
    private var sizes: [String: UInt32] = [:]

    init?() {
        let service = IOServiceGetMatchingService(kIOMainPortDefault, IOServiceMatching("AppleSMC"))
        guard service != 0 else { return nil }
        defer { IOObjectRelease(service) }
        guard IOServiceOpen(service, mach_task_self_, 0, &port) == KERN_SUCCESS else { return nil }
    }

    deinit { IOServiceClose(port) }

    // The kernel's 80-byte request: key @0, size @28, result @40, command @42, data @48.
    private func call(_ key: String, _ command: UInt8, size: UInt32 = 0, data: [UInt8] = []) -> [UInt8]? {
        var input = [UInt8](repeating: 0, count: 80)
        var output = input
        var length = 80
        input.withUnsafeMutableBytes {
            $0.storeBytes(of: key.utf8.reduce(UInt32(0)) { $0 << 8 | UInt32($1) }, as: UInt32.self)
            $0.storeBytes(of: size, toByteOffset: 28, as: UInt32.self)
        }
        input[42] = command
        for (i, byte) in data.enumerated() { input[48 + i] = byte }
        guard IOConnectCallStructMethod(port, 2, input, 80, &output, &length) == KERN_SUCCESS, output[40] == 0
        else { return nil }
        return output
    }

    /// Asked once per key, because it never changes.
    private func size(_ key: String) -> UInt32? {
        if let known = sizes[key] { return known }
        let size = call(key, 9)?.withUnsafeBytes { $0.load(fromByteOffset: 28, as: UInt32.self) }
        sizes[key] = size
        return size
    }

    func float(_ key: String) -> Double? {
        guard size(key) == 4, let out = call(key, 5, size: 4) else { return nil }
        let value = Double(out.withUnsafeBytes { $0.load(fromByteOffset: 48, as: Float.self) })
        return value.isFinite ? value : nil
    }

    func writeByte(_ key: String, _ value: UInt8) -> Bool {
        size(key) == 1 && call(key, 6, size: 1, data: [value]) != nil
    }
}
