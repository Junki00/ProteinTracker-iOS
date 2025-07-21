//
//  HistoryEntryRowView.swift
//  ProteinTracker
//
//  Created by drx on 2025/07/20.
//

import SwiftUI

struct HistoryEntryRowView: View {
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
            Text("15:45")
                .font(.subheadline)
                .foregroundColor(.secondaryText)
            Image(systemName: "checkmark")
                .font(.headline)
                .foregroundColor(.primaryText)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.appPrimary, lineWidth: 1.5)
        )
    }
}

#Preview {
    ZStack {
        Color.appSecondary.ignoresSafeArea()
        HistoryEntryRowView()
            .padding()
    }
}
