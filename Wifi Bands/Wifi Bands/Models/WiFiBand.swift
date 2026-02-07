//
//  WiFiBand.swift
//  Wifi Bands
//
//  Created by Claude Code
//

import Foundation

/// Represents the frequency band of a WiFi network
enum WiFiBand: String, Codable, CaseIterable {
    case twoPointFour = "2.4 GHz"
    case five = "5 GHz"
    case six = "6 GHz"
    case unknown = "Unknown"

    /// Determines the WiFi band based on channel number
    /// - Parameter channel: The channel number
    /// - Returns: The corresponding WiFiBand
    nonisolated static func from(channel: Int) -> WiFiBand {
        switch channel {
        case 1...14:
            return .twoPointFour
        case 36...165:
            return .five
        case 1...233 where channel > 165:
            return .six
        default:
            return .unknown
        }
    }

    /// Display order for UI presentation
    var sortOrder: Int {
        switch self {
        case .twoPointFour: return 0
        case .five: return 1
        case .six: return 2
        case .unknown: return 3
        }
    }
}
