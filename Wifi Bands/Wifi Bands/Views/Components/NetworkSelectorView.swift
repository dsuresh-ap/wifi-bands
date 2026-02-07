//
//  NetworkSelectorView.swift
//  Wifi Bands
//
//  Created by Claude Code
//

import SwiftUI

struct NetworkSelectorView: View {
    let viewModel: WiFiScannerViewModel
    @Binding var selectedNetworks: Set<String>

    private let maxSelection = 5

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Select Networks to Chart (max \(maxSelection))")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Spacer()

                if !selectedNetworks.isEmpty {
                    Button("Clear All") {
                        selectedNetworks.removeAll()
                    }
                    .font(.caption)
                }
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    // Use cached sorted property instead of sorting on every render
                    ForEach(viewModel.networksSortedBySignal) { network in
                        networkButton(for: network)
                    }
                }
            }
        }
    }

    private func networkButton(for network: WiFiNetwork) -> some View {
        let isSelected = selectedNetworks.contains(network.id)
        let canSelect = selectedNetworks.count < maxSelection || isSelected

        return Button {
            if isSelected {
                selectedNetworks.remove(network.id)
            } else if canSelect {
                selectedNetworks.insert(network.id)
            }
        } label: {
            HStack(spacing: 8) {
                // Signal indicator
                Circle()
                    .fill(network.signalQuality.color)
                    .frame(width: 8, height: 8)

                // Network info
                VStack(alignment: .leading, spacing: 2) {
                    // Network name
                    Text(network.displayName)
                        .font(.caption)
                        .fontWeight(.medium)

                    // BSSID
                    Text(network.displayBSSID)
                        .font(.system(size: 9))
                        .foregroundColor(.secondary)
                }

                // RSSI value
                Text("\(network.rssi) dBm")
                    .font(.caption)
                    .foregroundColor(.secondary)

                // Selection indicator
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.caption)
                        .foregroundColor(.accentColor)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                isSelected
                    ? Color.accentColor.opacity(0.2)
                    : Color(NSColor.controlBackgroundColor)
            )
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(
                        isSelected ? Color.accentColor : Color.clear,
                        lineWidth: 2
                    )
            )
        }
        .buttonStyle(.plain)
        .disabled(!canSelect)
        .opacity(canSelect ? 1.0 : 0.5)
    }
}

#Preview {
    @Previewable @State var selected: Set<String> = []
    let viewModel = WiFiScannerViewModel()

    NetworkSelectorView(
        viewModel: viewModel,
        selectedNetworks: $selected
    )
    .padding()
    .frame(width: 700)
}
