//
//  FavoriteCard.swift
//  ProteinTracker
//
//  Created by drx on 2025/07/23.
//

import SwiftUI

struct FavoriteCard: View {
    var body: some View {
        VStack (alignment: .leading, spacing: 10 ) {
            Text("Favorites")
                .font(.subheadline)
                .bold()
                .foregroundColor(.appPrimary)
            
            Text("❤️ Maybe they are not your favorites, but they work.")
                .font(.subheadline)
            
            FavoriteEntryRowView()
            FavoriteEntryRowView()
            FavoriteEntryRowView()
            
            
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 12).fill(Color.appBackground).shadow(color: .primaryText.opacity(0.5), radius: 2, x: 0, y: 2))
    }
}

#Preview {
    FavoriteCard()
}
