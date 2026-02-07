//
//  WiFiScannerService.swift
//  Wifi Bands
//
//  Created by Claude Code
//

import Foundation
import CoreWLAN

/// Errors that can occur during WiFi scanning
enum WiFiScanError: Error, LocalizedError {
    case noInterface
    case scanFailed(String)
    case permissionDenied

    var errorDescription: String? {
        switch self {
        case .noInterface:
            return "No WiFi interface found. Make sure WiFi is enabled."
        case .scanFailed(let reason):
            return "WiFi scan failed: \(reason)"
        case .permissionDenied:
            return "Location permission is required to scan for WiFi networks."
        }
    }
}

/// Service class that wraps CoreWLAN framework for WiFi scanning
/// Runs on background thread to avoid blocking main thread during hardware scans
actor WiFiScannerService {
    /// Minimum interval between scans enforced by CoreWLAN hardware
    private static let minimumScanInterval: TimeInterval = 3.0

    private var lastScanTime: Date?
    private let wifiClient = CWWiFiClient.shared()

    /// Scans for available WiFi networks
    /// - Returns: Array of WiFiNetwork objects
    /// - Throws: WiFiScanError if scan fails
    func scanNetworks() async throws -> [WiFiNetwork] {
        // Enforce minimum scan interval
        if let lastScan = lastScanTime {
            let timeSinceLastScan = Date().timeIntervalSince(lastScan)
            if timeSinceLastScan < Self.minimumScanInterval {
                // Return empty array if too soon, don't throw error
                return []
            }
        }

        // Get the default WiFi interface
        guard let interface = wifiClient.interface() else {
            throw WiFiScanError.noInterface
        }

        // Perform the scan
        let networks: Set<CWNetwork>
        do {
            networks = try interface.scanForNetworks(withSSID: nil)
        } catch {
            throw WiFiScanError.scanFailed(error.localizedDescription)
        }

        // Get noise measurement from interface
        let noise = interface.noiseMeasurement()

        // Update last scan time
        lastScanTime = Date()

        // Transform CWNetwork objects to WiFiNetwork models
        return networks.compactMap { cwNetwork in
            transformNetwork(cwNetwork, noise: noise)
        }
    }

    /// Gets the currently connected network
    /// - Returns: WiFiNetwork if connected, nil otherwise
    func currentNetwork() -> WiFiNetwork? {
        guard let interface = wifiClient.interface(),
              let ssid = interface.ssid(),
              !ssid.isEmpty else {
            return nil
        }

        let noise = interface.noiseMeasurement()

        // Note: beaconInterval, countryCode, and supportedRates are not available
        // from CWInterface, only from CWNetwork objects from scans
        let channelWidth = interface.wlanChannel()?.channelWidth

        return WiFiNetwork(
            ssid: ssid,
            bssid: interface.bssid(),
            rssi: interface.rssiValue(),
            channel: interface.wlanChannel()?.channelNumber ?? 0,
            security: securityString(from: interface.security()),
            noise: noise,
            channelWidth: channelWidth
        )
    }

    /// Transforms a CWNetwork object to WiFiNetwork model
    private func transformNetwork(_ cwNetwork: CWNetwork, noise: Int) -> WiFiNetwork? {
        let ssid = cwNetwork.ssid
        let bssid = cwNetwork.bssid
        let rssi = cwNetwork.rssiValue
        let channel = cwNetwork.wlanChannel?.channelNumber ?? 0
        let security = securityDescription(from: cwNetwork)

        // Extract additional properties
        let beaconInterval = cwNetwork.beaconInterval
        let countryCode = cwNetwork.countryCode
        let channelWidth = cwNetwork.wlanChannel?.channelWidth

        // Note: supportedRates is not directly available via CoreWLAN public API
        // It would require parsing information elements which is out of scope

        // Create WiFiNetwork model
        return WiFiNetwork(
            ssid: ssid,
            bssid: bssid,
            rssi: rssi,
            channel: channel,
            security: security,
            noise: noise,
            beaconInterval: beaconInterval,
            countryCode: countryCode,
            channelWidth: channelWidth,
            supportedRates: nil
        )
    }

    /// Converts CWSecurity to readable string
    private func securityString(from security: CWSecurity) -> String {
        switch security {
        case .none:
            return "Open"
        case .WEP:
            return "WEP"
        case .wpaPersonal:
            return "WPA Personal"
        case .wpaPersonalMixed:
            return "WPA/WPA2 Personal"
        case .wpa2Personal:
            return "WPA2 Personal"
        case .personal:
            return "Personal"
        case .dynamicWEP:
            return "Dynamic WEP"
        case .wpaEnterprise:
            return "WPA Enterprise"
        case .wpaEnterpriseMixed:
            return "WPA/WPA2 Enterprise"
        case .wpa2Enterprise:
            return "WPA2 Enterprise"
        case .enterprise:
            return "Enterprise"
        case .wpa3Personal:
            return "WPA3 Personal"
        case .wpa3Enterprise:
            return "WPA3 Enterprise"
        case .wpa3Transition:
            return "WPA2/WPA3 Transition"
        case .unknown:
            return "Unknown"
        @unknown default:
            return "Unknown"
        }
    }

    /// Converts CWNetwork security information to readable string
    private func securityDescription(from network: CWNetwork) -> String {
        // Use informationElementData to infer security
        // For now, return a simple description based on RSN/WPA IEs
        return "WPA/WPA2"  // Placeholder - CoreWLAN doesn't expose all security details directly
    }

    /// Checks if WiFi interface is available
    /// Must be called with await since this is an actor
    func isInterfaceAvailable() -> Bool {
        return wifiClient.interface() != nil
    }
}
