//
//  InfoView.swift
//  Wifi Bands
//
//  Created by Claude Code
//

import SwiftUI

struct InfoView: View {
    @Environment(WiFiScannerViewModel.self) private var viewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header
                Text("Information")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.horizontal)

                Divider()

                // Current Network
                VStack(alignment: .leading, spacing: 12) {
                    Text("Current Network")
                        .font(.headline)

                    if let currentNetwork = viewModel.currentConnectedNetwork {
                        VStack(alignment: .leading, spacing: 8) {
                            infoRow(label: "SSID", value: currentNetwork.displayName)
                            infoRow(label: "BSSID", value: currentNetwork.displayBSSID)
                            infoRow(label: "Signal Strength", value: "\(currentNetwork.rssi) dBm (\(currentNetwork.signalQuality.label))")
                            infoRow(label: "Channel", value: currentNetwork.channelDescription)
                            infoRow(label: "Security", value: currentNetwork.security)
                            infoRow(label: "Noise", value: "\(currentNetwork.noise) dBm")
                        }
                        .padding()
                        .background(Color(NSColor.controlBackgroundColor))
                        .cornerRadius(8)
                    } else {
                        Text("Not connected to any network")
                            .foregroundColor(.secondary)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color(NSColor.controlBackgroundColor))
                            .cornerRadius(8)
                    }
                }
                .padding(.horizontal)

                Divider()

                // Permission Status
                VStack(alignment: .leading, spacing: 12) {
                    Text("Location Permission")
                        .font(.headline)

                    HStack {
                        Image(systemName: viewModel.isPermissionGranted ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .foregroundColor(viewModel.isPermissionGranted ? .green : .red)

                        Text(viewModel.isPermissionGranted ? "Granted" : "Not Granted")
                            .fontWeight(.medium)

                        Spacer()

                        if !viewModel.isPermissionGranted {
                            Button("Request Permission") {
                                viewModel.requestPermission()
                            }
                            .buttonStyle(.bordered)
                        }
                    }
                    .padding()
                    .background(Color(NSColor.controlBackgroundColor))
                    .cornerRadius(8)

                    if !viewModel.isPermissionGranted {
                        Text("Location permission is required to scan for WiFi networks on macOS.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.horizontal)

                Divider()

                // App Info
                VStack(alignment: .leading, spacing: 12) {
                    Text("About WiFi Bands")
                        .font(.headline)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("WiFi Bands is a free, user-friendly WiFi analyzer for macOS that helps you check, debug, and learn about your home or work WiFi networks.")
                            .font(.body)
                            .foregroundColor(.secondary)

                        Divider()
                            .padding(.vertical, 4)

                        Text("Features:")
                            .fontWeight(.semibold)

                        VStack(alignment: .leading, spacing: 4) {
                            featureRow(icon: "wifi", text: "Scan nearby WiFi networks")
                            featureRow(icon: "chart.xyaxis.line", text: "Live signal strength tracking")
                            featureRow(icon: "antenna.radiowaves.left.and.right", text: "2.4GHz, 5GHz, and 6GHz band detection")
                            featureRow(icon: "lock.shield", text: "Security type information")
                            featureRow(icon: "waveform", text: "Signal quality indicators")
                        }
                        .font(.caption)

                        Divider()
                            .padding(.vertical, 4)

                        Text("Version 1.0")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color(NSColor.controlBackgroundColor))
                    .cornerRadius(8)
                }
                .padding(.horizontal)

                Spacer()
            }
            .padding(.vertical)
        }
    }

    private func infoRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .foregroundColor(.secondary)
                .frame(width: 120, alignment: .leading)

            Text(value)
                .fontWeight(.medium)

            Spacer()
        }
        .font(.body)
    }

    private func featureRow(icon: String, text: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .frame(width: 20)
                .foregroundColor(.accentColor)

            Text(text)
        }
    }
}

#Preview {
    InfoView()
        .environment(WiFiScannerViewModel())
        .frame(width: 800, height: 600)
}
