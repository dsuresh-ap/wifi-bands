//
//  NoiseImpact.swift
//  Wifi Bands
//
//  Created by Claude Code
//

import SwiftUI

/// Represents the impact of noise on WiFi signal quality
enum NoiseImpact: String {
    case low = "Low"
    case moderate = "Moderate"
    case high = "High"

    /// Determines noise impact from noise level
    /// - Parameter noise: The noise level in dBm
    /// - Returns: The corresponding NoiseImpact
    static func from(noise: Int) -> NoiseImpact {
        switch noise {
        case (-85)...:
            return .high      // Poor - noise is close to signal
        case (-90)..<(-85):
            return .moderate  // Fair - some interference
        default:
            return .low       // Good - minimal interference
        }
    }

    /// Color coding for noise impact
    var color: Color {
        switch self {
        case .low:
            return .green
        case .moderate:
            return .yellow
        case .high:
            return .red
        }
    }

    /// Descriptive explanation of the noise impact
    var description: String {
        switch self {
        case .low:
            return "Minimal interference, optimal conditions"
        case .moderate:
            return "Some interference present, may affect performance"
        case .high:
            return "High interference, signal quality degraded"
        }
    }
}
