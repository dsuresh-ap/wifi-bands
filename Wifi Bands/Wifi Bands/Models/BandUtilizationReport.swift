//
//  BandUtilizationReport.swift
//  Wifi Bands
//
//  Created by Claude Code
//

import SwiftUI

/// Represents utilization statistics for a WiFi band
struct BandUtilizationReport: Identifiable {
    let id: String
    let band: WiFiBand
    let networkCount: Int
    let averageRSSI: Int
    let congestionLevel: CongestionLevel

    init(band: WiFiBand, networkCount: Int, averageRSSI: Int) {
        self.id = band.rawValue
        self.band = band
        self.networkCount = networkCount
        self.averageRSSI = averageRSSI

        // Determine congestion based on network count
        switch networkCount {
        case 0...5:
            self.congestionLevel = .low
        case 6...10:
            self.congestionLevel = .moderate
        default:
            self.congestionLevel = .high
        }
    }

    /// Congestion level for a band
    enum CongestionLevel {
        case low
        case moderate
        case high

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

        var description: String {
            switch self {
            case .low:
                return "Low usage - good choice"
            case .moderate:
                return "Moderate usage"
            case .high:
                return "High usage - may be congested"
            }
        }

        var label: String {
            switch self {
            case .low:
                return "Low"
            case .moderate:
                return "Moderate"
            case .high:
                return "High"
            }
        }
    }
}
