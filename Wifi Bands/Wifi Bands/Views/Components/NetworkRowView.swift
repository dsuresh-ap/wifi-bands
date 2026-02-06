//
//  NetworkRowView.swift
//  Wifi Bands
//
//  Created by Claude Code
//

import SwiftUI

struct NetworkRowView: View {
    let network: WiFiNetwork
    @State private var showingDetail = false

    var body: some View {
        HStack(spacing: 16) {
            // Signal Meter
            SignalMeterView(
                rssi: network.rssi,
                quality: network.signalQuality
            )

            // Network Info
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(network.displayName)
                        .font(.headline)

                    if network.isSecured {
                        Image(systemName: "lock.fill")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }

                HStack(spacing: 12) {
                    Text(network.channelDescription)
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Text(network.security)
                        .font(.caption)
                        .foregroundColor(.secondary)

                    if let bssid = network.bssid, !bssid.isEmpty {
                        Text(bssid)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }

            Spacer()

            // RSSI Value
            VStack(alignment: .trailing, spacing: 2) {
                Text("\(network.rssi) dBm")
                    .font(.system(.body, design: .monospaced))
                    .fontWeight(.semibold)

                Text(network.signalQuality.label)
                    .font(.caption)
                    .foregroundColor(network.signalQuality.color)

                // SNR and noise indicator
                if let snr = network.snr {
                    HStack(spacing: 4) {
                        Text("SNR: \(snr) dB")
                            .font(.caption2)
                            .foregroundColor(network.connectionQuality.color)

                        Circle()
                            .fill(network.noiseImpact.color)
                            .frame(width: 6, height: 6)
                    }
                }
            }
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(8)
        .onTapGesture {
            showingDetail = true
        }
        .sheet(isPresented: $showingDetail) {
            NetworkDetailSheet(network: network)
        }
    }
}

#Preview {
    VStack(spacing: 12) {
        NetworkRowView(
            network: WiFiNetwork(
                ssid: "Home Network",
                bssid: "00:11:22:33:44:55",
                rssi: -45,
                channel: 36,
                security: "WPA2 Personal",
                noise: -95
            )
        )

        NetworkRowView(
            network: WiFiNetwork(
                ssid: "Office WiFi",
                bssid: "AA:BB:CC:DD:EE:FF",
                rssi: -72,
                channel: 6,
                security: "WPA3 Personal",
                noise: -90
            )
        )

        NetworkRowView(
            network: WiFiNetwork(
                ssid: nil,
                bssid: "11:22:33:44:55:66",
                rssi: -88,
                channel: 149,
                security: "Open",
                noise: -92
            )
        )
    }
    .padding()
    .frame(width: 600)
}
