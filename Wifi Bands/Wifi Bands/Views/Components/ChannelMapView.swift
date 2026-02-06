//
//  ChannelMapView.swift
//  Wifi Bands
//
//  Created by Claude Code
//

import SwiftUI

/// Displays channel interference data as horizontal bar charts
struct ChannelMapView: View {
    let interferenceData: [WiFiBand: ChannelInterferenceMap]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Channel Interference")
                .font(.title2)
                .fontWeight(.bold)

            // 2.4 GHz band
            if let twoGHz = interferenceData[.twoPointFour] {
                BandChannelChart(
                    title: "2.4 GHz Band",
                    interferenceMap: twoGHz
                )
            }

            // 5 GHz band
            if let fiveGHz = interferenceData[.five] {
                BandChannelChart(
                    title: "5 GHz Band",
                    interferenceMap: fiveGHz
                )
            }

            // 6 GHz band
            if let sixGHz = interferenceData[.six] {
                BandChannelChart(
                    title: "6 GHz Band",
                    interferenceMap: sixGHz
                )
            }
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(12)
    }
}

/// Chart for a single band's channel data
struct BandChannelChart: View {
    let title: String
    let interferenceMap: ChannelInterferenceMap

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundColor(.secondary)

            if interferenceMap.channelCounts.isEmpty {
                Text("No networks detected")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.vertical, 8)
            } else {
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(sortedChannels, id: \.0) { channel, count in
                        ChannelBar(
                            channel: channel,
                            count: count,
                            maxCount: maxCount,
                            congestionLevel: interferenceMap.congestionLevel(for: channel)
                        )
                    }
                }

                // Summary info
                HStack {
                    if let mostCongested = interferenceMap.mostCongestedChannel {
                        Text("Most congested: Ch \(mostCongested)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    Spacer()

                    Text("\(interferenceMap.totalNetworks) networks total")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 4)
            }
        }
    }

    private var sortedChannels: [(Int, Int)] {
        interferenceMap.channelCounts.sorted { $0.key < $1.key }
    }

    private var maxCount: Int {
        interferenceMap.channelCounts.values.max() ?? 1
    }
}

/// Single channel bar in the chart
struct ChannelBar: View {
    let channel: Int
    let count: Int
    let maxCount: Int
    let congestionLevel: ChannelInterferenceMap.CongestionLevel

    var body: some View {
        HStack(spacing: 8) {
            Text("Ch \(channel)")
                .font(.caption)
                .foregroundColor(.secondary)
                .frame(width: 40, alignment: .trailing)

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 20)
                        .cornerRadius(4)

                    // Filled bar
                    Rectangle()
                        .fill(congestionColor)
                        .frame(width: barWidth(in: geometry.size.width), height: 20)
                        .cornerRadius(4)

                    // Count label
                    Text("\(count)")
                        .font(.caption2)
                        .foregroundColor(.white)
                        .padding(.leading, 4)
                }
            }
            .frame(height: 20)
        }
    }

    private func barWidth(in totalWidth: CGFloat) -> CGFloat {
        let ratio = CGFloat(count) / CGFloat(maxCount)
        return max(totalWidth * ratio, 20) // Minimum 20 points for visibility
    }

    private var congestionColor: Color {
        switch congestionLevel {
        case .low:
            return .green
        case .moderate:
            return .yellow
        case .high:
            return .red
        }
    }
}

#Preview {
    let sampleData: [WiFiBand: ChannelInterferenceMap] = [
        .twoPointFour: ChannelInterferenceMap(
            channelCounts: [1: 3, 6: 7, 11: 4],
            band: .twoPointFour
        ),
        .five: ChannelInterferenceMap(
            channelCounts: [36: 2, 40: 1, 149: 5, 157: 3],
            band: .five
        )
    ]

    ChannelMapView(interferenceData: sampleData)
        .frame(width: 600)
        .padding()
}
