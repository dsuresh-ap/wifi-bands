//
//  BandUtilizationCard.swift
//  Wifi Bands
//
//  Created by Claude Code
//

import SwiftUI

/// Card displaying band utilization statistics
struct BandUtilizationCard: View {
    let report: BandUtilizationReport

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Band name
            Text(report.band.rawValue)
                .font(.headline)

            // Network count
            HStack {
                Image(systemName: "wifi")
                    .foregroundColor(.secondary)
                Text("\(report.networkCount) networks")
                    .font(.body)
            }

            // Average RSSI
            HStack {
                Image(systemName: "antenna.radiowaves.left.and.right")
                    .foregroundColor(.secondary)
                Text("\(report.averageRSSI) dBm avg")
                    .font(.body)
            }

            Divider()

            // Congestion indicator
            HStack {
                Circle()
                    .fill(report.congestionLevel.color)
                    .frame(width: 12, height: 12)

                Text(report.congestionLevel.label)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Text(report.congestionLevel.description)
                .font(.caption2)
                .foregroundColor(.secondary)
                .lineLimit(2)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(report.congestionLevel.color, lineWidth: 2)
        )
    }
}

#Preview {
    HStack(spacing: 16) {
        BandUtilizationCard(
            report: BandUtilizationReport(
                band: .twoPointFour,
                networkCount: 15,
                averageRSSI: -72
            )
        )

        BandUtilizationCard(
            report: BandUtilizationReport(
                band: .five,
                networkCount: 8,
                averageRSSI: -65
            )
        )

        BandUtilizationCard(
            report: BandUtilizationReport(
                band: .six,
                networkCount: 2,
                averageRSSI: -58
            )
        )
    }
    .frame(width: 800)
    .padding()
}
