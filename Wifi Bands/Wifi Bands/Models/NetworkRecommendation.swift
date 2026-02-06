//
//  NetworkRecommendation.swift
//  Wifi Bands
//
//  Created by Claude Code
//

import SwiftUI

/// Represents an actionable recommendation for improving WiFi connectivity
struct NetworkRecommendation: Identifiable {
    let id = UUID()
    let type: RecommendationType
    let priority: Priority
    let message: String

    /// Types of recommendations that can be made
    enum RecommendationType {
        case switchChannel
        case moveCloser
        case reduceCongestion
        case switchBand
        case improveSignal
        case reduceInterference
        case securityWarning

        var icon: String {
            switch self {
            case .switchChannel:
                return "antenna.radiowaves.left.and.right"
            case .moveCloser:
                return "location.circle"
            case .reduceCongestion:
                return "exclamationmark.triangle"
            case .switchBand:
                return "waveform.path"
            case .improveSignal:
                return "wifi.exclamationmark"
            case .reduceInterference:
                return "minus.circle"
            case .securityWarning:
                return "lock.open"
            }
        }
    }

    /// Priority levels for recommendations
    enum Priority {
        case critical
        case warning
        case info

        var color: Color {
            switch self {
            case .critical:
                return .red
            case .warning:
                return .orange
            case .info:
                return .blue
            }
        }

        var label: String {
            switch self {
            case .critical:
                return "Critical"
            case .warning:
                return "Warning"
            case .info:
                return "Info"
            }
        }
    }
}
