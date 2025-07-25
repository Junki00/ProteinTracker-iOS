//
//  HistoryEntryRowView.swift
//  ProteinTracker
//
//  Created by drx on 2025/07/20.
//

import SwiftUI

struct HistoryEntryRowView: View {
    
    let entry: ProteinEntry
    
    var body: some View {
        HStack(spacing: 16){
            ZStack {
                Circle()
                    .fill(Color.appPrimary)
                Text(String(format: "%.1f", entry.proteinAmount))
                    .font(.headline)
                    .foregroundColor(.appBackground)
            }
            .frame(width: 50, height: 50)
            
            VStack(alignment:.leading, spacing: 4) {
                Text(entry.foodName)
                    .font(.headline)
                    .foregroundColor(.primaryText)
                    .lineLimit(1)
                Text(entry.description)
                    .font(.subheadline)
                    .foregroundColor(.appPrimary)
                    .bold()
            }
            Spacer()
            Text(entry.addTime, style: .time)
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
    let mockEntry = ProteinEntry(proteinAmount: 25.5, foodName: "Whey dProtein Shake", description: "Post-workout")
    
    ZStack {
        Color.appSecondary.ignoresSafeArea()
        HistoryEntryRowView(entry: mockEntry)
            .padding()
    }
}

