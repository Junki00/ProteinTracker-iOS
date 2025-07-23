//
//  FavoriteEntryRowView.swift
//  ProteinTracker
//
//  Created by drx on 2025/07/23.
//

import SwiftUI

struct FavoriteEntryRowView: View {
    var body: some View {
        HStack(spacing: 16){
            ZStack {
                Circle()
                    .fill(Color.appPrimary)
                Text("20.5")
                    .font(.headline)
                    .foregroundColor(.appBackground)
            }
            .frame(width: 50, height: 50)
            
            VStack(alignment:.leading, spacing: 4) {
                Text("On Whey Protein Powder, Strawberry Flavor")
                    .font(.headline)
                    .foregroundColor(.primaryText)
                    .lineLimit(1)
                Text("1 Spoon")
                    .font(.subheadline)
                    .foregroundColor(.appPrimary)
                    .bold()
            }
            Spacer()
            Image(systemName: "alarm")
                .font(.headline)
                .foregroundColor(.primaryText)
            Image(systemName: "repeat")
                .font(.headline)
                .foregroundColor(.primaryText)
            Text("15:45")
                .font(.subheadline)
                .foregroundColor(.secondaryText)
    
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
                .shadow(color: .primaryText.opacity(0.1), radius: 2, x: 0, y: 2)
        )
        

        
    }
}


#Preview {
    FavoriteEntryRowView()
}
