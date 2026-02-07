//
//  SignalHistoryView.swift
//  Wifi Bands
//
//  Created by Claude Code
//

import SwiftUI
import Charts

struct SignalHistoryView: View {
    @Environment(WiFiScannerViewModel.self) private var viewModel
    @State private var selectedNetworks: Set<String> = []

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Signal History")
                    .font(.title)
                    .fontWeight(.bold)

                Spacer()

                if viewModel.isScanning {
                    HStack(spacing: 8) {
                        ProgressView()
                            .controlSize(.small)
                        Text("Live")
                            .font(.caption)
                            .foregroundColor(.green)
                    }
                }
            }
            .padding()

            Divider()

            // Content
            if !viewModel.isPermissionGranted {
                PermissionDeniedView()
            } else if viewModel.isInitialLoading {
                initialLoadingView
            } else if viewModel.networks.isEmpty {
                ContentUnavailableView(
                    "No Networks to Chart",
                    systemImage: "chart.xyaxis.line",
                    description: Text("Start scanning to see signal strength over time")
                )
            } else {
                VStack(spacing: 16) {
                    // Network selector
                    NetworkSelectorView(
                        viewModel: viewModel,
                        selectedNetworks: $selectedNetworks
                    )
                    .padding(.horizontal)

                    // Chart
                    if selectedNetworks.isEmpty {
                        ContentUnavailableView(
                            "Select Networks",
                            systemImage: "hand.tap",
                            description: Text("Choose up to 5 networks to display on the chart")
                        )
                    } else {
                        SignalLineChart(
                            selectedNetworks: selectedNetworks,
                            viewModel: viewModel
                        )
                        .padding()
                    }

                    Spacer()
                }
            }
        }
        .onAppear {
            if viewModel.isPermissionGranted && !viewModel.isScanning {
                viewModel.startScanning()
            }
        }
    }

    private var initialLoadingView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .controlSize(.large)
                .scaleEffect(1.5)

            VStack(spacing: 8) {
                Text("Initializing Signal Monitor")
                    .font(.title2)
                    .fontWeight(.semibold)

                Text("Preparing to track WiFi signal strength...")
                    .font(.body)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    SignalHistoryView()
        .environment(WiFiScannerViewModel())
        .frame(width: 800, height: 600)
}
