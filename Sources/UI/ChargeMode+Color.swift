import SwiftUI

extension ChargeMode {
    var color: Color {
        switch self {
        case .charging: .halt
        case .holding: .indigo
        case .draining: Color(red: 1, green: 0.48, blue: 0.36)
        }
    }
}
