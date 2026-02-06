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

/// Manages location permission required for WiFi scanning
@MainActor
@Observable
class PermissionManager: NSObject {
    var authorizationStatus: CLAuthorizationStatus = .notDetermined

    private let locationManager = CLLocationManager()

    override init() {
        super.init()
        locationManager.delegate = self
        authorizationStatus = locationManager.authorizationStatus
    }

    /// Requests location permission if not yet determined
    func requestPermission() {
        switch authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .denied, .restricted:
            // Permission denied or restricted - user needs to go to System Settings
            break
        case .authorizedAlways, .authorizedWhenInUse:
            // Already authorized
            break
        @unknown default:
            break
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
        if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_LocationServices") {
            NSWorkspace.shared.open(url)
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
