//
//  PermissionManager.swift
//  Wifi Bands
//
//  Created by Claude Code
//

import Foundation
import CoreLocation
import AppKit
import Observation
import OSLog

/// Manages location permission required for WiFi scanning
@MainActor
@Observable
class PermissionManager: NSObject {
    var authorizationStatus: CLAuthorizationStatus = .notDetermined {
        didSet {
            logger.info("Authorization status changed: \(self.authorizationStatusString(oldValue)) -> \(self.authorizationStatusString(self.authorizationStatus))")
        }
    }

    private let locationManager = CLLocationManager()
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "WifiBands", category: "PermissionManager")

    override init() {
        super.init()
        locationManager.delegate = self
        authorizationStatus = locationManager.authorizationStatus
        logger.info("PermissionManager initialized with status: \(self.authorizationStatusString(self.authorizationStatus))")
    }

    /// Requests location permission if not yet determined
    func requestPermission() {
        logger.info("requestPermission() called with current status: \(self.authorizationStatusString(self.authorizationStatus))")

        switch authorizationStatus {
        case .notDetermined:
            logger.info("Requesting when-in-use authorization...")
            locationManager.requestWhenInUseAuthorization()
        case .denied, .restricted:
            logger.warning("Permission already denied or restricted - user needs to go to System Settings")
        case .authorizedAlways:
            logger.info("Already authorized")
        @unknown default:
            logger.warning("Unknown authorization status")
        }
    }

    /// Returns true if location permission is granted
    var isAuthorized: Bool {
        return authorizationStatus == .authorizedAlways
    }

    /// Returns true if permission has been denied
    var isDenied: Bool {
        return authorizationStatus == .denied || authorizationStatus == .restricted
    }

    /// Returns true if permission has not been determined yet
    var isNotDetermined: Bool {
        return authorizationStatus == .notDetermined
    }

    /// Opens System Settings to the app's privacy settings
    func openSystemSettings() {
        logger.info("Opening System Settings for location permissions")
        if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_LocationServices") {
            NSWorkspace.shared.open(url)
        } else {
            logger.error("Failed to create System Settings URL")
        }
    }

    /// Converts authorization status to a readable string for logging
    private func authorizationStatusString(_ status: CLAuthorizationStatus) -> String {
        switch status {
        case .notDetermined:
            return "notDetermined"
        case .restricted:
            return "restricted"
        case .denied:
            return "denied"
        case .authorizedAlways:
            return "authorizedAlways"
        case .authorizedWhenInUse:
            return "authorizedWhenInUse"
        @unknown default:
            return "unknown(\(status.rawValue))"
        }
    }
}

// MARK: - CLLocationManagerDelegate
extension PermissionManager: CLLocationManagerDelegate {
    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        Task { @MainActor in
            authorizationStatus = manager.authorizationStatus
        }
    }
}
