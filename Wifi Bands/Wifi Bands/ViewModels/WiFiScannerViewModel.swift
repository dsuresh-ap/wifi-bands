//
//  WiFiScannerViewModel.swift
//  Wifi Bands
//
//  Created by Claude Code
//

import Foundation
import Observation
import CoreLocation

/// Central view model for WiFi scanning state management
@MainActor
@Observable
class WiFiScannerViewModel {
    // MARK: - Published State
    var networks: [WiFiNetwork] = []
    var isScanning: Bool = false
    var errorMessage: String?
    var permissionStatus: CLAuthorizationStatus = .notDetermined

    // MARK: - Services
    private let scannerService = WiFiScannerService()
    private let permissionManager = PermissionManager()

    // MARK: - Signal History
    private let signalHistory = SignalHistory()

    // MARK: - Timer
    private var scanTimer: Timer?
    private var lastCoreScanTime: Date?

    // MARK: - Constants
    private static let uiUpdateInterval: TimeInterval = 1.0  // 1Hz UI updates
    private static let coreScanInterval: TimeInterval = 3.0  // 3s CoreWLAN scans

    init() {
        // Observe permission changes
        setupPermissionObserver()
    }

    // MARK: - Permission Management
    private func setupPermissionObserver() {
        permissionStatus = permissionManager.authorizationStatus

        // Start scanning regardless - CoreWLAN will trigger permission prompt if needed
        // This is the proper way to trigger the macOS permission dialog
        startScanning()
    }

    func requestPermission() {
        permissionManager.requestPermission()

        // Also attempt to start scanning, which will trigger CoreWLAN's permission prompt
        startScanning()

        // Check permission status after a delay
        Task {
            try? await Task.sleep(for: .seconds(1.0))
            permissionStatus = permissionManager.authorizationStatus
        }
    }

    func openSystemSettings() {
        permissionManager.openSystemSettings()
    }

    var isPermissionDenied: Bool {
        return permissionManager.isDenied
    }

    var isPermissionGranted: Bool {
        return permissionManager.isAuthorized
    }

    // MARK: - Scanning Control
    func startScanning() {
        // Check if WiFi interface is available
        guard scannerService.isInterfaceAvailable else {
            errorMessage = "No WiFi interface found. Make sure WiFi is enabled."
            isScanning = false
            return
        }

        // Don't check permission here - attempting to scan will trigger the permission prompt
        // on macOS if permission hasn't been granted yet
        isScanning = true
        errorMessage = nil

        // Start timer for regular updates
        scanTimer = Timer.scheduledTimer(withTimeInterval: Self.uiUpdateInterval, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                await self?.performScan()
            }
        }

        // Perform initial scan immediately
        Task {
            await performScan()
        }
    }

    func stopScanning() {
        isScanning = false
        scanTimer?.invalidate()
        scanTimer = nil
    }

    private func performScan() async {
        // Check if enough time has passed for a CoreWLAN scan
        let shouldPerformCoreScan: Bool
        if let lastScan = lastCoreScanTime {
            shouldPerformCoreScan = Date().timeIntervalSince(lastScan) >= Self.coreScanInterval
        } else {
            shouldPerformCoreScan = true
        }

        // Only perform CoreWLAN scan if enough time has passed
        if shouldPerformCoreScan {
            do {
                let scannedNetworks = try await scannerService.scanNetworks()

                if !scannedNetworks.isEmpty {
                    networks = scannedNetworks

                    // Update signal history for all networks
                    for network in networks {
                        signalHistory.addPoint(for: network.id, rssi: network.rssi)
                    }

                    // Cleanup history for networks that are no longer visible
                    let activeNetworkIds = Set(networks.map { $0.id })
                    signalHistory.cleanup(keepingOnly: activeNetworkIds)

                    lastCoreScanTime = Date()
                    errorMessage = nil
                }
            } catch {
                errorMessage = error.localizedDescription
                // Don't stop scanning on error, just show message
            }
        }
    }

    // MARK: - Network Queries
    func networks(for band: WiFiBand) -> [WiFiNetwork] {
        return networks.filter { $0.band == band }
            .sorted { $0.rssi > $1.rssi }
    }

    func signalHistoryPoints(for networkId: String) -> [SignalHistoryPoint] {
        return signalHistory.points(for: networkId)
    }

    var currentConnectedNetwork: WiFiNetwork? {
        return scannerService.currentNetwork()
    }
}
