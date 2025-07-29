//
//  ContentView.swift
//  ProteinTracker
//
//  Created by drx on 2025/07/21.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = ProteinDataViewModel()
    var body: some View {
        TabView {
            TodayView()
                .tabItem {
                    Image(systemName: "doc.text.image")
                    Text("Today")
                }
            
            FavoritesView()
                .tabItem {
                    Image(systemName: "star")
                    Text("Favorites")
                }
            
            StatsView()
                .tabItem {
                    Image(systemName: "chart.bar.xaxis")
                    Text("Stats")
                }
        }
        .tint(Color.appPrimary)
        .environmentObject(viewModel)
    }
}

#Preview {
    ContentView()
}
