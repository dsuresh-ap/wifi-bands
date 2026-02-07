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
    var hasCompletedInitialScan: Bool = false
    var errorMessage: String?
    var permissionStatus: CLAuthorizationStatus = .notDetermined
    var currentConnectedNetwork: WiFiNetwork?

    // MARK: - Services
    private let scannerService = WiFiScannerService()
    private let permissionManager = PermissionManager()
    private let analyticsService = NetworkAnalyticsService()

    // MARK: - Cache Structures
    private var analyticsCache: (
        hash: Int,
        interference: [WiFiBand: ChannelInterferenceMap],
        utilization: [BandUtilizationReport],
        recommendations: [NetworkRecommendation]
    )?

    private var filteredNetworksCache: (
        hash: Int,
        twoGHz: [WiFiNetwork],
        fiveGHz: [WiFiNetwork],
        sixGHz: [WiFiNetwork]
    )?

    // MARK: - Signal History
    private let signalHistory = SignalHistory()

    // MARK: - Network Tracking
    private var firstSeenTimes: [String: Date] = [:]

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

    // MARK: - Cache Management
    private func computeNetworkHash() -> Int {
        // Hash based on network IDs and channels (ignores minor RSSI changes)
        var hasher = Hasher()
        for network in networks.sorted(by: { $0.id < $1.id }) {
            hasher.combine(network.id)
            hasher.combine(network.channel)
            hasher.combine(network.band)
        }
        return hasher.finalize()
    }

    private func updateAnalyticsCache(
        hash: Int,
        interference: [WiFiBand: ChannelInterferenceMap]? = nil,
        utilization: [BandUtilizationReport]? = nil,
        recommendations: [NetworkRecommendation]? = nil
    ) {
        let current = analyticsCache
        analyticsCache = (
            hash: hash,
            interference: interference ?? current?.interference ?? [:],
            utilization: utilization ?? current?.utilization ?? [],
            recommendations: recommendations ?? current?.recommendations ?? []
        )
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

    var isInitialLoading: Bool {
        return isScanning && !hasCompletedInitialScan
    }

    // MARK: - Scanning Control
    func startScanning() {
        // Check if WiFi interface is available (now async)
        Task {
            let isAvailable = await scannerService.isInterfaceAvailable()
            guard isAvailable else {
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
            await performScan()
        }
    }

    func stopScanning() {
        isScanning = false
        hasCompletedInitialScan = false
        scanTimer?.invalidate()
        scanTimer = nil
    }

    private func performScan() async {
        let now = Date()

        // Check if enough time has passed for a CoreWLAN scan
        let shouldPerformCoreScan = lastCoreScanTime
            .map { now.timeIntervalSince($0) >= Self.coreScanInterval }
            ?? true

        // Only perform CoreWLAN scan if enough time has passed
        if shouldPerformCoreScan {
            lastCoreScanTime = now

            do {
                // This now properly runs on background actor thread
                let scannedNetworks = try await scannerService.scanNetworks()

                if !scannedNetworks.isEmpty {
                    // Track first seen times and create enhanced networks
                    var enhancedNetworks: [WiFiNetwork] = []

                    for network in scannedNetworks {
                        // Record first seen time if new
                        if firstSeenTimes[network.id] == nil {
                            firstSeenTimes[network.id] = Date()
                        }

                        // Create network with firstSeen populated
                        let enhancedNetwork = WiFiNetwork(
                            id: network.id,
                            ssid: network.ssid,
                            bssid: network.bssid,
                            rssi: network.rssi,
                            channel: network.channel,
                            security: network.security,
                            noise: network.noise,
                            lastSeen: network.lastSeen,
                            beaconInterval: network.beaconInterval,
                            countryCode: network.countryCode,
                            channelWidth: network.channelWidth,
                            supportedRates: network.supportedRates,
                            firstSeen: firstSeenTimes[network.id]
                        )
                        enhancedNetworks.append(enhancedNetwork)
                    }

                    // Deduplicate networks by ID, keeping the one with strongest signal
                    var deduplicatedNetworks: [String: WiFiNetwork] = [:]
                    for network in enhancedNetworks {
                        if let existing = deduplicatedNetworks[network.id] {
                            // Keep the network with stronger signal
                            if network.rssi > existing.rssi {
                                deduplicatedNetworks[network.id] = network
                            }
                        } else {
                            deduplicatedNetworks[network.id] = network
                        }
                    }

                    networks = Array(deduplicatedNetworks.values)

                    // Update signal history for all networks
                    for network in networks {
                        signalHistory.addPoint(for: network.id, rssi: network.rssi)
                    }

                    // Cleanup history for networks that are no longer visible
                    let activeNetworkIds = Set(networks.map { $0.id })
                    signalHistory.cleanup(keepingOnly: activeNetworkIds)

                    // Cleanup first seen times for networks not seen in last 5 minutes
                    let fiveMinutesAgo = Date().addingTimeInterval(-300)
                    firstSeenTimes = firstSeenTimes.filter { (key, firstSeenTime) in
                        activeNetworkIds.contains(key) || firstSeenTime > fiveMinutesAgo
                    }

                    // Mark that we've completed at least one scan
                    hasCompletedInitialScan = true
                    errorMessage = nil

                    // Update current connected network
                    currentConnectedNetwork = await scannerService.currentNetwork()
                } else if !hasCompletedInitialScan {
                    // First scan completed but found nothing - still mark as complete
                    hasCompletedInitialScan = true
                }
            } catch {
                errorMessage = error.localizedDescription
                // Don't stop scanning on error, just show message
            }
        }
    }

    // MARK: - Network Queries
    func networks(for band: WiFiBand) -> [WiFiNetwork] {
        let currentHash = computeNetworkHash()

        if let cache = filteredNetworksCache, cache.hash == currentHash {
            switch band {
            case .twoPointFour: return cache.twoGHz
            case .five: return cache.fiveGHz
            case .six: return cache.sixGHz
            case .unknown: return []
            }
        }

        // Compute all bands at once
        let twoGHz = networks.filter { $0.band == .twoPointFour }.sorted { $0.rssi > $1.rssi }
        let fiveGHz = networks.filter { $0.band == .five }.sorted { $0.rssi > $1.rssi }
        let sixGHz = networks.filter { $0.band == .six }.sorted { $0.rssi > $1.rssi }

        filteredNetworksCache = (currentHash, twoGHz, fiveGHz, sixGHz)

        switch band {
        case .twoPointFour: return twoGHz
        case .five: return fiveGHz
        case .six: return sixGHz
        case .unknown: return []
        }
    }

    var networksSortedBySignal: [WiFiNetwork] {
        networks.sorted { $0.rssi > $1.rssi }
    }

    func signalHistoryPoints(for networkId: String) -> [SignalHistoryPoint] {
        return signalHistory.points(for: networkId)
    }


    // MARK: - Analytics

    /// Gets channel interference data grouped by band (cached)
    func getChannelInterference() -> [WiFiBand: ChannelInterferenceMap] {
        let currentHash = computeNetworkHash()

        if let cache = analyticsCache, cache.hash == currentHash {
            return cache.interference
        }

        let interference = analyticsService.analyzeChannelInterference(networks: networks)
        updateAnalyticsCache(hash: currentHash, interference: interference)
        return interference
    }

    /// Gets band utilization statistics (cached)
    func getBandUtilization() -> [BandUtilizationReport] {
        let currentHash = computeNetworkHash()

        if let cache = analyticsCache, cache.hash == currentHash {
            return cache.utilization
        }

        let utilization = analyticsService.analyzeBandUtilization(networks: networks)
        updateAnalyticsCache(hash: currentHash, utilization: utilization)
        return utilization
    }

    /// Gets recommendations for a specific network
    func getRecommendations(for network: WiFiNetwork) -> [NetworkRecommendation] {
        return analyticsService.generateRecommendations(for: network, allNetworks: networks)
    }

    /// Gets top recommendations across all networks (cached)
    func getTopRecommendations() -> [NetworkRecommendation] {
        let currentHash = computeNetworkHash()

        if let cache = analyticsCache, cache.hash == currentHash {
            return cache.recommendations
        }

        let recommendations = analyticsService.getTopRecommendations(for: networks)
        updateAnalyticsCache(hash: currentHash, recommendations: recommendations)
        return recommendations
    }
}
