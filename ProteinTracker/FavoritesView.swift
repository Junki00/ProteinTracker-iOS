//
//  FavoritesView.swift
//  ProteinTracker
//
//  Created by drx on 2025/07/21.
//

import SwiftUI

struct FavoritesView: View {
    @State private var isShowingAddSheet = false

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                ScrollView {
                    EntryCardView(type: .favorite, date: Date())
                        .padding()
                }

                Button(action: {
                    DS.Haptics.medium()
                    isShowingAddSheet = true
                }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.appPrimaryColor)
                        .shadow(color: .appPrimaryTextColor.opacity(0.3), radius: 5, y: 3)
                }
                .accessibilityLabel(String(localized: "accessibility.addFavorite"))
                .padding()
            }
            .navigationTitle(String(localized: "favorites.title"))
            .background(Color.appBackgroundColor)
            .sheet(isPresented: $isShowingAddSheet) {
                AddEntryModalView(date: Date(), entryType: .favorite)
            }
        }
    }
}

#Preview {
    FavoritesView()
        .modelContainer(ProteinDataStore.previewContainer())
}
