//
//  ConnectionQuality.swift
//  Wifi Bands
//
//  Created by Claude Code
//

import SwiftUI

/// Represents connection quality based on SNR (Signal-to-Noise Ratio)
enum ConnectionQuality: String {
    case excellent = "Excellent"
    case good = "Good"
    case fair = "Fair"
    case poor = "Poor"
    case unknown = "Unknown"

    /// Determines connection quality from SNR value
    /// - Parameter snr: The SNR value in dB
    /// - Returns: The corresponding ConnectionQuality
    static func from(snr: Int?) -> ConnectionQuality {
        guard let snr = snr else { return .unknown }

        switch snr {
        case 40...:
            return .excellent
        case 25..<40:
            return .good
        case 15..<25:
            return .fair
        default:
            return .poor
        }
    }

    /// Color coding for connection quality
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
        case .unknown:
            return .gray
        }
    }

    /// Descriptive explanation of the quality level
    var description: String {
        switch self {
        case .excellent:
            return "Ideal for all applications including 4K streaming and gaming"
        case .good:
            return "Suitable for HD streaming and video calls"
        case .fair:
            return "Basic browsing and email work well"
        case .poor:
            return "Connection may be unstable or slow"
        case .unknown:
            return "Quality cannot be determined"
        }
    }
}
