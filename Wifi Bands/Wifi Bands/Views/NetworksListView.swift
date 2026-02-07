//
//  NetworksListView.swift
//  Wifi Bands
//
//  Created by Claude Code
//

import SwiftUI

struct NetworksListView: View {
    @Environment(WiFiScannerViewModel.self) private var viewModel

    var body: some View {
        @Bindable var bindableViewModel = viewModel

        VStack(spacing: 0) {
            // Header
            HStack {
                Text("WiFi Networks")
                    .font(.title)
                    .fontWeight(.bold)

                Spacer()

                if viewModel.isScanning {
                    HStack(spacing: 8) {
                        ProgressView()
                            .controlSize(.small)
                        Text("Scanning...")
                            .font(.caption)
                            .foregroundColor(.secondary)
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
            } else if let errorMessage = viewModel.errorMessage {
                ContentUnavailableView(
                    "Unable to Scan",
                    systemImage: "exclamationmark.triangle",
                    description: Text(errorMessage)
                )
            } else if viewModel.networks.isEmpty {
                ContentUnavailableView(
                    "No Networks Found",
                    systemImage: "wifi.slash",
                    description: Text("No WiFi networks are currently visible")
                )
            } else {
                networksList
            }
        }
        .onAppear {
            if viewModel.isPermissionGranted {
                viewModel.startScanning()
            } else {
                viewModel.requestPermission()
            }
        }
    }

    private var networksList: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 16) {
                // Group networks by band
                ForEach(WiFiBand.allCases, id: \.self) { band in
                    let networksForBand = viewModel.networks(for: band)

                    if !networksForBand.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            // Band header
                            Text(band.rawValue)
                                .font(.headline)
                                .foregroundColor(.secondary)
                                .padding(.horizontal)

                            // Networks in this band
                            ForEach(networksForBand) { network in
                                NetworkRowView(network: network)
                                    .padding(.horizontal)
                            }
                        }
                    }
                }
            }
            .padding(.vertical)
        }
    }

    private var initialLoadingView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .controlSize(.large)
                .scaleEffect(1.5)

            VStack(spacing: 8) {
                Text("Scanning for Networks")
                    .font(.title2)
                    .fontWeight(.semibold)

                Text("Searching for available WiFi networks...")
                    .font(.body)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    NetworksListView()
        .environment(WiFiScannerViewModel())
        .frame(width: 800, height: 600)
}
