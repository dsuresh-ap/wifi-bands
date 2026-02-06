//
//  AnalyticsView.swift
//  Wifi Bands
//
//  Created by Claude Code
//

import SwiftUI

/// Main analytics view showing channel interference, band utilization, and recommendations
struct AnalyticsView: View {
    @Environment(WiFiScannerViewModel.self) private var viewModel

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text("WiFi Analytics")
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    Text("Analyze channel interference, band utilization, and get actionable recommendations")
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)

                if viewModel.networks.isEmpty {
                    // Empty state
                    VStack(spacing: 16) {
                        Image(systemName: "chart.bar.xaxis")
                            .font(.system(size: 60))
                            .foregroundColor(.secondary)

                        Text("No networks detected")
                            .font(.title2)
                            .foregroundColor(.secondary)

                        Text("Start scanning to see analytics")
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.top, 60)
                } else {
                    // Channel interference
                    ChannelMapView(
                        interferenceData: viewModel.getChannelInterference()
                    )
                    .padding(.horizontal)

                    // Band utilization
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Band Utilization")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.horizontal)

                        LazyVGrid(columns: gridColumns, spacing: 16) {
                            ForEach(viewModel.getBandUtilization()) { report in
                                BandUtilizationCard(report: report)
                            }
                        }
                        .padding(.horizontal)
                    }

                    // Recommendations
                    let recommendations = viewModel.getTopRecommendations()
                    if !recommendations.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Top Recommendations")
                                .font(.title2)
                                .fontWeight(.bold)
                                .padding(.horizontal)

                            VStack(spacing: 12) {
                                ForEach(recommendations.prefix(3)) { recommendation in
                                    RecommendationCard(recommendation: recommendation)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
            }
            .padding(.vertical)
        }
    }

    private var gridColumns: [GridItem] {
        [
            GridItem(.flexible(), spacing: 16),
            GridItem(.flexible(), spacing: 16),
            GridItem(.flexible(), spacing: 16)
        ]
    }
}

#Preview {
    AnalyticsView()
        .environment(WiFiScannerViewModel())
        .frame(width: 900, height: 700)
}
