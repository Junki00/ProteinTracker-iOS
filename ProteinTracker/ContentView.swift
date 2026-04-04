//
//  ContentView.swift
//  ProteinTracker
//
//  Created by drx on 2025/07/21.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            TodayView()
                .tabItem {
                    Image(systemName: "doc.text.image")
                    Text(String(localized: "tab.today"))
                }
            
            FavoritesView()
                .tabItem {
                    Image(systemName: "star")
                    Text(String(localized: "tab.favorites"))
                }
            
            StatsView()
                .tabItem {
                    Image(systemName: "chart.bar.xaxis")
                    Text(String(localized: "tab.stats"))
                }
        }
        .tint(Color.appPrimaryColor)
    }
}

#Preview {
    ContentView()
        .modelContainer(ProteinDataStore.previewContainer())
}
