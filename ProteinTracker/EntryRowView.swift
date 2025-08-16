//
//  EntryRowView.swift
//  ProteinTracker
//
//  Created by drx on 2025/08/16.
//

import SwiftUI

enum EntryRowType {
    case history, favorite, plan
}

struct EntryRowView: View {
    @EnvironmentObject var viewModel: ProteinDataViewModel
    let entry: ProteinEntry
    var type: EntryRowType
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color.appPrimary)
                Text(String(format: "%.1f", entry.proteinAmount))
                    .font(.headline)
                    .foregroundColor(.appBackground)
            }
            .frame(width: 60, height: 60)
            
            VStack() {
                HStack {
                    VStack(alignment:.leading) {
                        Text(entry.foodName)
                            .font(.headline)
                            .foregroundColor(.primaryText)
                            .lineLimit(1)
                        Text(entry.description)
                            .font(.subheadline)
                            .foregroundColor(.secondaryText)
                            .bold()
                            .lineLimit(1)
                    }
 
                    Spacer()
                    
                    Button(
                        action: {
                            viewModel.toggleFavoriteStatus(id: entry.id)
                        }
                    ) {
                        Image(systemName: (entry.isFavorite ? "star.fill": "star"))
                            .font(.system(size: 30))
                            .foregroundColor(.appPrimary)
                    }
                }
                
                Spacer().frame(height: 20)
                
                HStack {
                    Image(systemName: "alarm")
                        .font(.subheadline)
                        .foregroundColor(.primaryText)
                    Image(systemName: "repeat")
                        .font(.subheadline)
                        .foregroundColor(.primaryText)
                    Text(entry.addTime.formattedRelativeString())
                        .font(.subheadline)
                        .foregroundColor(.secondaryText)
                    Spacer()
                    Image(systemName: (type == .history ? "checkmark.circle.fill": "checkmark.circle"))
                        .font(.subheadline)
                        .foregroundColor(type == .history ? .appPrimary : .secondaryText)
                    Spacer().frame(width: 10) // magic number...well, let it go now.
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
                .shadow(color: .primaryText.opacity(0.1), radius: 2, x: 0, y: 2)
        )
        .overlay {
            if type == .history {
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.appPrimary, lineWidth: 1.5)
            }
        }
    }
}

#Preview {
    ZStack {
        Color.appSecondary.ignoresSafeArea()
        EntryRowView(entry: ProteinDataViewModel().entries[0], type: .history)
            .padding()
    }
}
