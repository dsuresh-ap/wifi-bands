//
//  SignalMeterView.swift
//  Wifi Bands
//
//  Created by Claude Code
//

import SwiftUI

struct SignalMeterView: View {
    let rssi: Int
    let quality: SignalQuality

    var body: some View {
        ZStack {
            // Background circle
            Circle()
                .stroke(
                    Color.gray.opacity(0.2),
                    lineWidth: 8
                )

            // Progress circle
            Circle()
                .trim(from: 0, to: quality.progressValue)
                .stroke(
                    quality.color,
                    style: StrokeStyle(
                        lineWidth: 8,
                        lineCap: .round
                    )
                )
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.3), value: quality.progressValue)

            // RSSI text in center
            Text("\(rssi)")
                .font(.system(size: 14, design: .monospaced))
                .fontWeight(.bold)
                .foregroundColor(quality.color)
        }
        .frame(width: 60, height: 60)
    }
}

#Preview {
    HStack(spacing: 20) {
        VStack {
            SignalMeterView(rssi: -45, quality: .excellent)
            Text("Excellent")
                .font(.caption)
        }

        VStack {
            SignalMeterView(rssi: -72, quality: .good)
            Text("Good")
                .font(.caption)
        }

        VStack {
            SignalMeterView(rssi: -88, quality: .fair)
            Text("Fair")
                .font(.caption)
        }

        VStack {
            SignalMeterView(rssi: -98, quality: .poor)
            Text("Poor")
                .font(.caption)
        }
    }
    .padding()
}
