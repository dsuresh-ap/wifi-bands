//
//  RecommendationCard.swift
//  Wifi Bands
//
//  Created by Claude Code
//

import SwiftUI

/// Card displaying an actionable network recommendation
struct RecommendationCard: View {
    let recommendation: NetworkRecommendation

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Priority indicator
            Circle()
                .fill(recommendation.priority.color)
                .frame(width: 10, height: 10)
                .padding(.top, 4)

            // Icon
            Image(systemName: recommendation.type.icon)
                .font(.title3)
                .foregroundColor(recommendation.priority.color)
                .frame(width: 30)

            // Message
            VStack(alignment: .leading, spacing: 4) {
                Text(recommendation.priority.label)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(recommendation.priority.color)
                    .textCase(.uppercase)

                Text(recommendation.message)
                    .font(.body)
                    .foregroundColor(.primary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(recommendation.priority.color.opacity(0.1))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(recommendation.priority.color.opacity(0.3), lineWidth: 1)
        )
    }
}

#Preview {
    VStack(spacing: 12) {
        RecommendationCard(
            recommendation: NetworkRecommendation(
                type: .improveSignal,
                priority: .critical,
                message: "Signal-to-noise ratio is poor (12 dB). Move closer to the router or remove obstacles."
            )
        )

        RecommendationCard(
            recommendation: NetworkRecommendation(
                type: .switchChannel,
                priority: .warning,
                message: "Channel 6 is congested (8 networks). Consider switching to channel 1 (2 networks)."
            )
        )

        RecommendationCard(
            recommendation: NetworkRecommendation(
                type: .switchBand,
                priority: .info,
                message: "5 GHz band has less congestion and offers faster speeds. Check if your router supports dual-band."
            )
        )
    }
    .frame(width: 600)
    .padding()
}
