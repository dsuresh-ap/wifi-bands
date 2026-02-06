//
//  Wifi_BandsApp.swift
//  Wifi Bands
//
//  Created by Dhananjay Suresh on 2/6/26.
//

import SwiftUI

@main
struct Wifi_BandsApp: App {
    @State private var viewModel = WiFiScannerViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(viewModel)
        }
    }
}
