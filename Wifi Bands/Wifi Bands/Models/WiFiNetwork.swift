//
//  WiFiNetwork.swift
//  Wifi Bands
//
//  Created by Claude Code
//

import Foundation
import CoreWLAN

/// Represents a WiFi network with all its properties
struct WiFiNetwork: Identifiable, Hashable {
    let id: String
    let ssid: String?
    let bssid: String?
    let rssi: Int
    let channel: Int
    let band: WiFiBand
    let security: String
    let noise: Int
    let lastSeen: Date

    // MARK: - Additional Properties
    let beaconInterval: Int?           // Milliseconds between beacons
    let countryCode: String?            // ISO 3166-1 country code
    let channelWidth: CWChannelWidth?   // Channel bandwidth (not codable, for internal use)
    let supportedRates: [Int]?          // Array of rates in 500 kbps units
    let firstSeen: Date?                // Timestamp of first detection

    /// Initializes a WiFiNetwork with all properties
    init(
        id: String? = nil,
        ssid: String?,
        bssid: String?,
        rssi: Int,
        channel: Int,
        security: String,
        noise: Int = 0,
        lastSeen: Date = Date(),
        beaconInterval: Int? = nil,
        countryCode: String? = nil,
        channelWidth: CWChannelWidth? = nil,
        supportedRates: [Int]? = nil,
        firstSeen: Date? = nil
    ) {
        // Use BSSID + channel as ID to handle APs on multiple channels
        // This prevents duplicate ID errors in SwiftUI ForEach
        if let bssid = bssid, !bssid.isEmpty {
            self.id = "\(bssid)_ch\(channel)"
        } else if let id = id {
            self.id = id
        } else {
            self.id = UUID().uuidString
        }

        self.ssid = ssid
        self.bssid = bssid
        self.rssi = rssi
        self.channel = channel
        self.band = WiFiBand.from(channel: channel)
        self.security = security
        self.noise = noise
        self.lastSeen = lastSeen
        self.beaconInterval = beaconInterval
        self.countryCode = countryCode
        self.channelWidth = channelWidth
        self.supportedRates = supportedRates
        self.firstSeen = firstSeen
    }

    /// Display name for the network (handles hidden networks)
    var displayName: String {
        if let ssid = ssid, !ssid.isEmpty {
            return ssid
        }
        return "Hidden Network"
    }

    /// Display BSSID (handles nil case)
    var displayBSSID: String {
        return bssid ?? "Unknown"
    }

    /// Signal quality based on RSSI
    var signalQuality: SignalQuality {
        return SignalQuality.from(rssi: rssi)
    }

    /// Signal to Noise Ratio
    var snr: Int? {
        guard noise != 0 else { return nil }
        return rssi - noise
    }

    /// Whether the network is secured
    var isSecured: Bool {
        return !security.contains("Open") && !security.isEmpty
    }

    /// Formatted channel string with band
    var channelDescription: String {
        return "Ch \(channel) (\(band.rawValue))"
    }

    // MARK: - Additional Computed Properties

    /// Beacon interval with units
    var beaconIntervalDescription: String? {
        guard let interval = beaconInterval else { return nil }
        return "\(interval) ms"
    }

    /// Channel width formatted
    var channelWidthDescription: String {
        guard let width = channelWidth else { return "Unknown" }
        switch width {
        case .width20MHz: return "20 MHz"
        case .width40MHz: return "40 MHz"
        case .width80MHz: return "80 MHz"
        case .width160MHz: return "160 MHz"
        case .widthUnknown: return "Unknown"
        @unknown default: return "Unknown"
        }
    }

    /// Max supported rate in Mbps
    var maxSupportedRate: Double? {
        guard let rates = supportedRates, !rates.isEmpty else { return nil }
        return Double(rates.max() ?? 0) * 0.5  // Convert from 500 kbps units
    }

    /// Min supported rate in Mbps
    var minSupportedRate: Double? {
        guard let rates = supportedRates, !rates.isEmpty else { return nil }
        return Double(rates.min() ?? 0) * 0.5
    }

    /// Duration network has been visible
    var visibilityDuration: TimeInterval? {
        guard let firstSeen = firstSeen else { return nil }
        return lastSeen.timeIntervalSince(firstSeen)
    }

    /// Vendor from BSSID lookup
    var vendor: String? {
        return VendorLookup.vendor(from: bssid)
    }

    // MARK: - Hashable
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    /// Connection quality based on SNR
    var connectionQuality: ConnectionQuality {
        return ConnectionQuality.from(snr: snr)
    }

    /// Noise impact severity
    var noiseImpact: NoiseImpact {
        return NoiseImpact.from(noise: noise)
    }

    // MARK: - Equatable
    static func == (lhs: WiFiNetwork, rhs: WiFiNetwork) -> Bool {
        return lhs.id == rhs.id
    }
}

// MARK: - Sorting Extensions
extension WiFiNetwork {
    /// Sorts networks by signal strength (strongest first)
    static func sortBySignalStrength(_ networks: [WiFiNetwork]) -> [WiFiNetwork] {
        return networks.sorted { $0.rssi > $1.rssi }
    }

    /// Groups networks by band
    static func groupByBand(_ networks: [WiFiNetwork]) -> [WiFiBand: [WiFiNetwork]] {
        return Dictionary(grouping: networks) { $0.band }
    }
}
