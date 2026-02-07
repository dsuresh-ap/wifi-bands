//
//  SignalLineChart.swift
//  Wifi Bands
//
//  Created by Claude Code
//

import SwiftUI
import Charts

struct SignalLineChart: View {
    let selectedNetworks: Set<String>
    let viewModel: WiFiScannerViewModel

    var body: some View {
        // Pre-compute network lookup dictionary for O(1) access
        let networkLookup = Dictionary(
            uniqueKeysWithValues: viewModel.networks.map { ($0.id, $0) }
        )

        VStack(alignment: .leading, spacing: 12) {
            // Chart
            Chart {
                ForEach(Array(selectedNetworks), id: \.self) { networkId in
                    let points = viewModel.signalHistoryPoints(for: networkId)

                    // Use dictionary lookup instead of linear search
                    if let network = networkLookup[networkId] {
                        ForEach(points) { point in
                            LineMark(
                                x: .value("Time", point.timestamp),
                                y: .value("Signal", point.rssi)
                            )
                            .foregroundStyle(by: .value("Network", network.displayName))
                            .interpolationMethod(.catmullRom)
                            .lineStyle(StrokeStyle(lineWidth: 2))
                        }
                    }
                }
            }
            .chartYScale(domain: -100...0)
            .chartYAxis {
                AxisMarks(position: .leading, values: .stride(by: 10)) { value in
                    AxisGridLine()
                    AxisValueLabel {
                        if let rssi = value.as(Int.self) {
                            Text("\(rssi) dBm")
                                .font(.caption)
                        }
                    }
                }
            }
            .chartXAxis {
                AxisMarks(values: .automatic) { value in
                    AxisGridLine()
                    AxisValueLabel(format: .dateTime.hour().minute().second())
                }
            }
            .chartLegend(position: .bottom)
            .frame(height: 400)

            // Legend with current values
            legendView(networkLookup: networkLookup)
        }
    }

    private func legendView(networkLookup: [String: WiFiNetwork]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Current Signal Strength")
                .font(.caption)
                .foregroundColor(.secondary)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(Array(selectedNetworks), id: \.self) { networkId in
                        // Use dictionary lookup instead of linear search
                        if let network = networkLookup[networkId] {
                            HStack(spacing: 8) {
                                Circle()
                                    .fill(network.signalQuality.color)
                                    .frame(width: 8, height: 8)

                                Text(network.displayName)
                                    .font(.caption)
                                    .fontWeight(.medium)

                                Text("\(network.rssi) dBm")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color(NSColor.controlBackgroundColor))
                            .cornerRadius(12)
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    SignalLineChart(
        selectedNetworks: [],
        viewModel: WiFiScannerViewModel()
    )
    .padding()
    .frame(width: 700, height: 500)
}
