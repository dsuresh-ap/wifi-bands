//
//  NetworkAnalyticsService.swift
//  Wifi Bands
//
//  Created by Claude Code
//

import Foundation

/// Service for analyzing WiFi network data and generating recommendations
@MainActor
class NetworkAnalyticsService {

    // MARK: - Channel Analysis

    /// Analyzes channel interference for networks
    /// - Parameter networks: Array of WiFi networks to analyze
    /// - Returns: Dictionary mapping bands to their channel interference data
    func analyzeChannelInterference(networks: [WiFiNetwork]) -> [WiFiBand: ChannelInterferenceMap] {
        let networksByBand = WiFiNetwork.groupByBand(networks)

        var result: [WiFiBand: ChannelInterferenceMap] = [:]

        for (band, bandNetworks) in networksByBand {
            // Count networks per channel
            var channelCounts: [Int: Int] = [:]
            for network in bandNetworks {
                channelCounts[network.channel, default: 0] += 1
            }

            result[band] = ChannelInterferenceMap(
                channelCounts: channelCounts,
                band: band
            )
        }

        return result
    }

    // MARK: - Band Utilization

    /// Analyzes band utilization statistics
    /// - Parameter networks: Array of WiFi networks to analyze
    /// - Returns: Array of band utilization reports
    func analyzeBandUtilization(networks: [WiFiNetwork]) -> [BandUtilizationReport] {
        let networksByBand = WiFiNetwork.groupByBand(networks)

        return networksByBand.map { band, bandNetworks in
            let averageRSSI = bandNetworks.isEmpty ? 0 :
                bandNetworks.map { $0.rssi }.reduce(0, +) / bandNetworks.count

            return BandUtilizationReport(
                band: band,
                networkCount: bandNetworks.count,
                averageRSSI: averageRSSI
            )
        }.sorted { $0.band.sortOrder < $1.band.sortOrder }
    }

    // MARK: - Recommendations

    /// Generates actionable recommendations for a specific network
    /// - Parameters:
    ///   - network: The network to analyze
    ///   - allNetworks: All visible networks for context
    /// - Returns: Array of recommendations
    func generateRecommendations(for network: WiFiNetwork, allNetworks: [WiFiNetwork]) -> [NetworkRecommendation] {
        var recommendations: [NetworkRecommendation] = []

        // 1. SNR-based recommendations
        if let snr = network.snr {
            if snr < 15 {
                recommendations.append(NetworkRecommendation(
                    type: .improveSignal,
                    priority: .critical,
                    message: "Signal-to-noise ratio is poor (\(snr) dB). Move closer to the router or remove obstacles."
                ))
            } else if snr < 25 {
                recommendations.append(NetworkRecommendation(
                    type: .improveSignal,
                    priority: .warning,
                    message: "Signal-to-noise ratio is fair (\(snr) dB). Consider moving closer for better performance."
                ))
            }
        }

        // 2. Noise-based recommendations
        if network.noise > -85 {
            recommendations.append(NetworkRecommendation(
                type: .reduceInterference,
                priority: .warning,
                message: "High noise interference detected (\(network.noise) dBm). Other devices may be causing interference."
            ))
        }

        // 3. Channel congestion recommendations
        let networksOnSameChannel = allNetworks.filter {
            $0.channel == network.channel && $0.band == network.band
        }

        if networksOnSameChannel.count > 5 {
            // Find a better channel in the same band
            let channelInterference = analyzeChannelInterference(networks: allNetworks)
            if let bandMap = channelInterference[network.band],
               let leastCongested = bandMap.leastCongestedChannel,
               leastCongested != network.channel {
                let count = bandMap.channelCounts[leastCongested] ?? 0
                recommendations.append(NetworkRecommendation(
                    type: .switchChannel,
                    priority: .warning,
                    message: "Channel \(network.channel) is congested (\(networksOnSameChannel.count) networks). Consider switching to channel \(leastCongested) (\(count) networks)."
                ))
            } else {
                recommendations.append(NetworkRecommendation(
                    type: .reduceCongestion,
                    priority: .info,
                    message: "Channel \(network.channel) has \(networksOnSameChannel.count) networks. This may cause slower speeds during peak usage."
                ))
            }
        }

        // 4. Band switching recommendations
        if network.band == .twoPointFour {
            let fiveGHzNetworks = allNetworks.filter { $0.band == .five }
            let avgFiveGHzCongestion = fiveGHzNetworks.isEmpty ? 0 :
                allNetworks.filter { net in
                    fiveGHzNetworks.contains { $0.channel == net.channel }
                }.count / fiveGHzNetworks.count

            if avgFiveGHzCongestion < networksOnSameChannel.count {
                recommendations.append(NetworkRecommendation(
                    type: .switchBand,
                    priority: .info,
                    message: "5 GHz band has less congestion and offers faster speeds. Check if your router supports dual-band."
                ))
            }
        }

        // 5. Security warning for open networks
        if !network.isSecured {
            recommendations.append(NetworkRecommendation(
                type: .securityWarning,
                priority: .critical,
                message: "This network is not secured. Your data may be visible to others. Avoid accessing sensitive information."
            ))
        }

        // Sort by priority (critical first)
        return recommendations.sorted { lhs, rhs in
            let priorityOrder: [NetworkRecommendation.Priority: Int] = [
                .critical: 0,
                .warning: 1,
                .info: 2
            ]
            return (priorityOrder[lhs.priority] ?? 3) < (priorityOrder[rhs.priority] ?? 3)
        }
    }

    // MARK: - Helper Methods

    /// Gets the top recommendations across all networks
    /// - Parameter networks: All visible networks
    /// - Returns: Array of top recommendations (max 5)
    func getTopRecommendations(for networks: [WiFiNetwork]) -> [NetworkRecommendation] {
        var allRecommendations: [NetworkRecommendation] = []

        // Get recommendations for strongest networks (most likely to be used)
        let topNetworks = networks.sorted { $0.rssi > $1.rssi }.prefix(5)

        for network in topNetworks {
            let networkRecs = generateRecommendations(for: network, allNetworks: networks)
            allRecommendations.append(contentsOf: networkRecs)
        }

        // Deduplicate similar recommendations
        var seen: Set<String> = []
        var unique: [NetworkRecommendation] = []

        for rec in allRecommendations {
            let key = "\(rec.type)-\(rec.message)"
            if !seen.contains(key) {
                seen.insert(key)
                unique.append(rec)
            }
        }

        // Return top 5, prioritized
        return Array(unique.sorted { lhs, rhs in
            let priorityOrder: [NetworkRecommendation.Priority: Int] = [
                .critical: 0,
                .warning: 1,
                .info: 2
            ]
            return (priorityOrder[lhs.priority] ?? 3) < (priorityOrder[rhs.priority] ?? 3)
        }.prefix(5))
    }
}
