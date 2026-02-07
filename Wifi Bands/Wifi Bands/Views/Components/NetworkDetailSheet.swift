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
    @Environment(\.dismiss) private var dismiss
    let network: WiFiNetwork

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(network.displayName)
                        .font(.title)
                        .fontWeight(.bold)

                    HStack(spacing: 8) {
                        if let bssid = network.bssid {
                            Text(bssid)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }

                        if let vendor = network.vendor {
                            Text(vendor)
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.accentColor.opacity(0.1))
                                .cornerRadius(4)
                        }
                    }
                }

                Spacer()

                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundStyle(.secondary)
                        .symbolRenderingMode(.hierarchical)
                }
                .buttonStyle(.plain)
                .keyboardShortcut(.cancelAction)
            }

            // Large signal meter
            SignalMeterView(
                rssi: network.rssi,
                quality: network.signalQuality
            )
            .scaleEffect(1.5)
            .frame(height: 80)

            // SECTION 1: Signal Metrics
            SectionHeader(title: "Signal Metrics", icon: "waveform")
            LazyVGrid(columns: gridColumns, spacing: 12) {
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
            }

            // SECTION 2: Channel Information
            SectionHeader(title: "Channel Information", icon: "antenna.radiowaves.left.and.right")
            LazyVGrid(columns: gridColumns, spacing: 12) {
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
                    title: "Width",
                    value: network.channelWidthDescription,
                    icon: "arrow.left.and.right",
                    color: .cyan
                )

                if let countryCode = network.countryCode {
                    MetricCard(
                        title: "Country",
                        value: countryCode,
                        icon: "globe",
                        color: .indigo
                    )
                }
            }

            // SECTION 3: Network Configuration
            SectionHeader(title: "Configuration", icon: "gearshape")
            LazyVGrid(columns: gridColumns, spacing: 12) {
                MetricCard(
                    title: "Security",
                    value: network.security,
                    icon: network.isSecured ? "lock.fill" : "lock.open",
                    color: network.isSecured ? .green : .red
                )

                if let beaconInterval = network.beaconIntervalDescription {
                    MetricCard(
                        title: "Beacon Interval",
                        value: beaconInterval,
                        icon: "timer",
                        color: .orange
                    )
                }

                if let maxRate = network.maxSupportedRate {
                    MetricCard(
                        title: "Max Rate",
                        value: String(format: "%.1f Mbps", maxRate),
                        icon: "speedometer",
                        color: .green
                    )
                }

                if let minRate = network.minSupportedRate {
                    MetricCard(
                        title: "Min Rate",
                        value: String(format: "%.1f Mbps", minRate),
                        icon: "tortoise",
                        color: .gray
                    )
                }
            }

            // SECTION 4: Tracking Information
            SectionHeader(title: "Tracking", icon: "clock")
            LazyVGrid(columns: gridColumns, spacing: 12) {
                if let firstSeen = network.firstSeen {
                    MetricCard(
                        title: "First Seen",
                        value: formatTimestamp(firstSeen),
                        icon: "eye",
                        color: .teal
                    )
                }

                MetricCard(
                    title: "Last Seen",
                    value: formatTimestamp(network.lastSeen),
                    icon: "clock.arrow.circlepath",
                    color: .teal
                )

                if let duration = network.visibilityDuration {
                    MetricCard(
                        title: "Visible For",
                        value: formatDuration(duration),
                        icon: "hourglass",
                        color: .mint
                    )
                }
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
        }
        .padding(24)
        .frame(width: 700)
        }
        .frame(height: 900)
    }

    private var gridColumns: [GridItem] {
        [
            GridItem(.flexible(), spacing: 16),
            GridItem(.flexible(), spacing: 16),
            GridItem(.flexible(), spacing: 16)
        ]
    }

    private func formatTimestamp(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .medium
        formatter.dateStyle = .none
        return formatter.string(from: date)
    }

    private func formatDuration(_ interval: TimeInterval) -> String {
        let minutes = Int(interval) / 60
        let seconds = Int(interval) % 60
        return minutes > 0 ? "\(minutes)m \(seconds)s" : "\(seconds)s"
    }
}

/// Section header for organizing metrics
struct SectionHeader: View {
    let title: String
    let icon: String

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(.secondary)
            Text(title)
                .font(.headline)
                .fontWeight(.semibold)
        }
        .padding(.top, 8)
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
