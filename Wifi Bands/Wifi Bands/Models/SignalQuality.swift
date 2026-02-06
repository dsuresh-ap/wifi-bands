//
//  SignalQuality.swift
//  Wifi Bands
//
//  Created by Claude Code
//

import SwiftUI

/// Represents the quality of a WiFi signal based on RSSI value
enum SignalQuality {
    case excellent  // -30 to -67 dBm
    case good       // -68 to -80 dBm
    case fair       // -81 to -95 dBm
    case poor       // -96 or lower

    /// Determines signal quality from RSSI value
    /// - Parameter rssi: The RSSI value in dBm
    /// - Returns: The corresponding SignalQuality
    static func from(rssi: Int) -> SignalQuality {
        switch rssi {
        case -67...0:
            return .excellent
        case -80...(-68):
            return .good
        case -95...(-81):
            return .fair
        default:
            return .poor
        }
    }

    /// Color coding for signal quality
    var color: Color {
        switch self {
        case .excellent:
            return .green
        case .good:
            return .yellow
        case .fair:
            return .orange
        case .poor:
            return .red
        }
    }

    /// Descriptive label for the signal quality
    var label: String {
        switch self {
        case .excellent:
            return "Excellent"
        case .good:
            return "Good"
        case .fair:
            return "Fair"
        case .poor:
            return "Poor"
        }
    }

    /// Progress value for circular meter (0.0 to 1.0)
    var progressValue: Double {
        switch self {
        case .excellent:
            return 1.0
        case .good:
            return 0.7
        case .fair:
            return 0.4
        case .poor:
            return 0.2
        }
    }
}
