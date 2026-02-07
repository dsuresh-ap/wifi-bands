//
//  ChannelInterferenceMap.swift
//  Wifi Bands
//
//  Created by Claude Code
//

import SwiftUI

/// Represents channel congestion data for a specific WiFi band
struct ChannelInterferenceMap {
    let channelCounts: [Int: Int]  // Channel → network count
    let band: WiFiBand

    /// Pre-sorted channels for efficient rendering
    var sortedChannels: [(channel: Int, count: Int)] {
        channelCounts.sorted { $0.key < $1.key }
            .map { (channel: $0.key, count: $0.value) }
    }

    /// The most congested channel in this band
    var mostCongestedChannel: Int? {
        return channelCounts.max(by: { $0.value < $1.value })?.key
    }

    /// The least congested channel in this band
    var leastCongestedChannel: Int? {
        return channelCounts.min(by: { $0.value < $1.value })?.key
    }

    /// Total number of networks in this band
    var totalNetworks: Int {
        return channelCounts.values.reduce(0, +)
    }

    /// Average networks per channel
    var averageNetworksPerChannel: Double {
        guard !channelCounts.isEmpty else { return 0 }
        return Double(totalNetworks) / Double(channelCounts.count)
    }

    /// Determines congestion level for a specific channel
    /// - Parameter channel: The channel number
    /// - Returns: Congestion level (low/moderate/high)
    func congestionLevel(for channel: Int) -> CongestionLevel {
        guard let count = channelCounts[channel] else { return .low }

        switch count {
        case 0...2:
            return .low
        case 3...5:
            return .moderate
        default:
            return .high
        }
    }

    enum CongestionLevel {
        case low
        case moderate
        case high

        var description: String {
            switch self {
            case .low:
                return "Low congestion"
            case .moderate:
                return "Moderate congestion"
            case .high:
                return "High congestion"
            }
        }
    }
}
