//
//  NetworkDetailSheet.swift
//  Wifi Bands
//
//  Created by Claude Code
//

import SwiftUI

/// Detailed sheet view for a specific network
struct NetworkDetailSheet: View {
    @Environment(WiFiScannerViewModel.self) private var viewModel
    let network: WiFiNetwork

    var body: some View {
        VStack(spacing: 24) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(network.displayName)
                        .font(.title)
                        .fontWeight(.bold)

                    if let bssid = network.bssid {
                        Text(bssid)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }

                Spacer()
            }

            // Large signal meter
            SignalMeterView(
                rssi: network.rssi,
                quality: network.signalQuality
            )
            .scaleEffect(1.5)
            .frame(height: 80)

            // Metrics grid
            LazyVGrid(columns: gridColumns, spacing: 16) {
                MetricCard(
                    title: "Signal Strength",
                    value: "\(network.rssi) dBm",
                    icon: "wifi",
                    color: network.signalQuality.color
                )

                if let snr = network.snr {
                    MetricCard(
                        title: "SNR",
                        value: "\(snr) dB",
                        icon: "waveform",
                        color: network.connectionQuality.color
                    )
                }

                MetricCard(
                    title: "Noise",
                    value: "\(network.noise) dBm",
                    icon: "speaker.wave.3",
                    color: network.noiseImpact.color
                )

                MetricCard(
                    title: "Channel",
                    value: "\(network.channel)",
                    icon: "antenna.radiowaves.left.and.right",
                    color: .blue
                )

                MetricCard(
                    title: "Band",
                    value: network.band.rawValue,
                    icon: "waveform.path",
                    color: .purple
                )

                MetricCard(
                    title: "Security",
                    value: network.security,
                    icon: network.isSecured ? "lock.fill" : "lock.open",
                    color: network.isSecured ? .green : .red
                )
            }

            // Connection quality
            VStack(alignment: .leading, spacing: 8) {
                Text("Connection Quality")
                    .font(.headline)

                HStack {
                    Circle()
                        .fill(network.connectionQuality.color)
                        .frame(width: 12, height: 12)

                    Text(network.connectionQuality.rawValue)
                        .font(.body)
                        .fontWeight(.semibold)

                    Spacer()

                    Text(network.connectionQuality.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color(NSColor.controlBackgroundColor))
                .cornerRadius(8)
            }

            // Channel interference
            let networksOnChannel = viewModel.networks.filter {
                $0.channel == network.channel && $0.band == network.band
            }.count

            HStack {
                Image(systemName: "exclamationmark.triangle")
                    .foregroundColor(networksOnChannel > 5 ? .orange : .secondary)

                Text("\(networksOnChannel) network\(networksOnChannel == 1 ? "" : "s") on channel \(network.channel)")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Spacer()
            }
            .padding()
            .background(Color(NSColor.controlBackgroundColor))
            .cornerRadius(8)

            // Recommendations
            let recommendations = viewModel.getRecommendations(for: network)
            if !recommendations.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Recommendations")
                        .font(.headline)

                    VStack(spacing: 8) {
                        ForEach(recommendations) { recommendation in
                            RecommendationCard(recommendation: recommendation)
                        }
                    }
                }
            }

            Spacer()
        }
        .padding(24)
        .frame(width: 600, height: 800)
    }

    private var gridColumns: [GridItem] {
        [
            GridItem(.flexible(), spacing: 16),
            GridItem(.flexible(), spacing: 16),
            GridItem(.flexible(), spacing: 16)
        ]
    }
}

/// Metric card for displaying network properties
struct MetricCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)

            Text(value)
                .font(.title3)
                .fontWeight(.semibold)

            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(8)
    }
}

#Preview {
    NetworkDetailSheet(
        network: WiFiNetwork(
            ssid: "Home Network",
            bssid: "00:11:22:33:44:55",
            rssi: -45,
            channel: 36,
            security: "WPA2 Personal",
            noise: -95
        )
    )
    .environment(WiFiScannerViewModel())
}
