//
//  ContentView.swift
//  Wifi Bands
//
//  Created by Dhananjay Suresh on 2/6/26.
//

import SwiftUI

struct ContentView: View {
    @Environment(WiFiScannerViewModel.self) private var viewModel

    var body: some View {
        TabView {
            NetworksListView()
                .tabItem {
                    Label("Networks", systemImage: "wifi")
                }

            SignalHistoryView()
                .tabItem {
                    Label("Signal Chart", systemImage: "chart.xyaxis.line")
                }

            AnalyticsView()
                .tabItem {
                    Label("Analytics", systemImage: "chart.bar")
                }

            InfoView()
                .tabItem {
                    Label("Info", systemImage: "info.circle")
                }
        }
        .frame(minWidth: 800, minHeight: 600)
    }
}

#Preview {
    ContentView()
        .environment(WiFiScannerViewModel())
}
