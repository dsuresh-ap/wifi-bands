//
//  WiFiNetwork.swift
//  Wifi Bands
//
//  Created by Claude Code
//

import Foundation

/// Represents a WiFi network with all its properties
struct WiFiNetwork: Identifiable, Codable, Hashable {
    let id: String
    let ssid: String?
    let bssid: String?
    let rssi: Int
    let channel: Int
    let band: WiFiBand
    let security: String
    let noise: Int
    let lastSeen: Date

    /// Initializes a WiFiNetwork with all properties
    init(
        id: String? = nil,
        ssid: String?,
        bssid: String?,
        rssi: Int,
        channel: Int,
        security: String,
        noise: Int = 0,
        lastSeen: Date = Date()
    ) {
        // Use BSSID as ID if available, otherwise generate UUID
        if let bssid = bssid, !bssid.isEmpty {
            self.id = bssid
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
