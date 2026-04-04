//
//  FavoritesView.swift
//  ProteinTracker
//
//  Created by drx on 2025/07/21.
//

import SwiftUI

struct FavoritesView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                EntryCardView(type: .favorite, date: Date())
                    .padding()
            }
            .navigationTitle(String(localized: "favorites.title"))
            .background(Color.appBackgroundColor)
        }
    }
}

#Preview {
    FavoritesView()
        .modelContainer(ProteinDataStore.previewContainer())
}
