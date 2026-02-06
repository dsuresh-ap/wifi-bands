//
//  PermissionDeniedView.swift
//  Wifi Bands
//
//  Created by Claude Code
//

import SwiftUI

struct PermissionDeniedView: View {
    @Environment(WiFiScannerViewModel.self) private var viewModel

    var body: some View {
        ContentUnavailableView {
            Label("Location Permission Required", systemImage: "location.slash")
        } description: {
            VStack(spacing: 16) {
                Text("WiFi Bands needs location permission to scan for WiFi networks. This is required by macOS for accessing WiFi information.")
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)

                Text("To enable permission:")
                    .fontWeight(.semibold)

                VStack(alignment: .leading, spacing: 8) {
                    HStack(alignment: .top) {
                        Text("1.")
                        Text("Click 'Open System Settings' below")
                    }
                    HStack(alignment: .top) {
                        Text("2.")
                        Text("Navigate to Privacy & Security → Location Services")
                    }
                    HStack(alignment: .top) {
                        Text("3.")
                        Text("Find 'WiFi Bands' and enable location access")
                    }
                    HStack(alignment: .top) {
                        Text("4.")
                        Text("Restart the app")
                    }
                }
                .font(.caption)
                .foregroundColor(.secondary)
                .padding()
                .background(Color(NSColor.controlBackgroundColor))
                .cornerRadius(8)
            }
            .padding()
        } actions: {
            Button {
                viewModel.openSystemSettings()
            } label: {
                Label("Open System Settings", systemImage: "gear")
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
    }
}

#Preview {
    PermissionDeniedView()
        .environment(WiFiScannerViewModel())
        .frame(width: 600, height: 400)
}
