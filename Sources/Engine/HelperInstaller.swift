import Foundation
import ServiceManagement

enum HelperStatus {
    case missing, outdated, enabled

    /// Compares the installed copy with the one in the app.
    static func read() -> HelperStatus {
        func version(_ path: String) -> String? {
            (CFBundleCopyInfoDictionaryForURL(URL(filePath: path) as CFURL) as? [String: Any])?[
                "CFBundleVersion"] as? String
        }
        guard FileManager.default.fileExists(atPath: "/Library/LaunchDaemons/\(helperID).plist"),
            let installed = version("/Library/PrivilegedHelperTools/\(helperID)")
        else { return .missing }
        return installed == version(Bundle.main.bundlePath + "/Contents/Library/LaunchServices/\(helperID)")
            ? .enabled : .outdated
    }

    /// Asks for an administrator password, then has macOS check both signatures and install.
    static func install() -> String? {
        var auth: AuthorizationRef?
        guard AuthorizationCreate(nil, nil, [], &auth) == errAuthorizationSuccess, let auth else {
            return "Couldn't ask for permission."
        }
        defer { AuthorizationFree(auth, [.destroyRights]) }
        let status = kSMRightBlessPrivilegedHelper.withCString { right in
            kAuthorizationEnvironmentPrompt.withCString { key in
                "Halt needs your permission once to control charging.\n\n".withCString { prompt in
                    var item = AuthorizationItem(name: right, valueLength: 0, value: nil, flags: 0)
                    var note = AuthorizationItem(
                        name: key, valueLength: strlen(prompt),
                        value: UnsafeMutableRawPointer(mutating: prompt), flags: 0)
                    return withUnsafeMutablePointer(to: &item) { i in
                        withUnsafeMutablePointer(to: &note) { n in
                            var rights = AuthorizationRights(count: 1, items: i),
                                environment = AuthorizationEnvironment(count: 1, items: n)
                            return AuthorizationCopyRights(
                                auth, &rights, &environment,
                                [.interactionAllowed, .extendRights, .preAuthorize], nil)
                        }
                    }
                }
            }
        }
        if status == errAuthorizationCanceled { return nil }
        guard status == errAuthorizationSuccess else { return "macOS didn't grant permission (\(status))." }
        // Deprecated, but its replacement asks in System Settings instead of for a password.
        var error: Unmanaged<CFError>?
        return SMJobBless(kSMDomainSystemLaunchd, helperID as CFString, auth, &error)
            ? nil : error?.takeRetainedValue().localizedDescription ?? "Couldn't install the helper."
    }
}
