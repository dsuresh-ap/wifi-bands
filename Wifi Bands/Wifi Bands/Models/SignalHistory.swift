//
//  SignalHistory.swift
//  Wifi Bands
//
//  Created by Claude Code
//

import Foundation

/// Represents a single data point in the signal strength history
struct SignalHistoryPoint: Identifiable, Codable {
    let id: UUID
    let timestamp: Date
    let rssi: Int
    let networkId: String

    init(timestamp: Date, rssi: Int, networkId: String) {
        self.id = UUID()
        self.timestamp = timestamp
        self.rssi = rssi
        self.networkId = networkId
    }
}

/// Manages signal history for all networks with automatic trimming
class SignalHistory {
    /// Maximum number of data points to keep per network (2.5 minutes at 1Hz)
    static let maxPointsPerNetwork = 150

    /// Dictionary of network ID to array of signal history points
    private var history: [String: [SignalHistoryPoint]] = [:]

    /// Adds a new data point for a network
    /// - Parameters:
    ///   - networkId: The network identifier
    ///   - rssi: The signal strength in dBm
    func addPoint(for networkId: String, rssi: Int) {
        let point = SignalHistoryPoint(
            timestamp: Date(),
            rssi: rssi,
            networkId: networkId
        )

        if history[networkId] == nil {
            history[networkId] = []
        }

        history[networkId]?.append(point)

        // Trim to maximum points
        if let count = history[networkId]?.count, count > Self.maxPointsPerNetwork {
            history[networkId]?.removeFirst(count - Self.maxPointsPerNetwork)
        }
    }

    /// Retrieves signal history for a specific network
    /// - Parameter networkId: The network identifier
    /// - Returns: Array of signal history points
    func points(for networkId: String) -> [SignalHistoryPoint] {
        return history[networkId] ?? []
    }

    /// Removes history for networks that are no longer visible
    /// - Parameter activeNetworkIds: Set of currently visible network IDs
    func cleanup(keepingOnly activeNetworkIds: Set<String>) {
        let idsToRemove = Set(history.keys).subtracting(activeNetworkIds)
        for id in idsToRemove {
            history.removeValue(forKey: id)
        }
    }

    /// Clears all history
    func clear() {
        history.removeAll()
    }

    /// Returns all network IDs that have history data
    var trackedNetworkIds: [String] {
        return Array(history.keys)
    }
}
