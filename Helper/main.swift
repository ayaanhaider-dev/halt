import Foundation
import Security

// Only an app signed by the same team as this helper may connect.
private func teamID() -> String? {
    var code: SecCode?, staticCode: SecStaticCode?, info: CFDictionary?
    guard SecCodeCopySelf([], &code) == errSecSuccess, let code,
        SecCodeCopyStaticCode(code, [], &staticCode) == errSecSuccess, let staticCode,
        SecCodeCopySigningInformation(staticCode, SecCSFlags(rawValue: kSecCSSigningInformation), &info)
            == errSecSuccess
    else { return nil }
    return (info as? [String: Any])?[kSecCodeInfoTeamIdentifier as String] as? String
}

guard let team = teamID() else { fatalError("The helper must be signed with a developer certificate.") }
private let service = HelperService()
private let listener = NSXPCListener(machServiceName: helperID)
listener.setConnectionCodeSigningRequirement(
    "anchor apple generic and identifier \"com.lveno.halt\" and certificate leaf[subject.OU] = \"\(team)\"")
listener.delegate = service
listener.resume()
RunLoop.main.run()
