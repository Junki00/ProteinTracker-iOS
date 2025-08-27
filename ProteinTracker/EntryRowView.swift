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
            
            //Column Left
            ZStack {
                Circle()
                    .fill(Color.appPrimary)
                Text(String(format: "%.1f", entry.proteinAmount))
                    .font(.headline)
                    .foregroundColor(.appBackground)
            }
            .frame(width: 60, height: 60)
            
            //Column Middle
            VStack(alignment: .leading) {
                VStack(alignment:.leading) {
                    Text(entry.foodName)
                        .foregroundColor(.primaryText)
                        .font(.headline)
                        .lineLimit(1)
                    Text(entry.description)
                        .font(.subheadline)
                        .bold()
                        .lineLimit(1)
                }
                
                Spacer()
                
                HStack {
                    if (type != .favorite) {
                        Image(systemName: "alarm")
                            .font(.subheadline)
                        Image(systemName: "repeat")
                            .font(.subheadline)
                        Text(entry.timeStamp.formattedRelativeString())
                            .font(.subheadline)
                    } else {
                        Text("Favorited Item")
                            .font(.system(size: 12))
                            .italic()
                    }
                }
            }
            .frame(height: 80)
            
            Spacer()

            //Column Right: Star Button and Check Button
            VStack {
                VStack {
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
                
                Spacer()
                
                VStack {
                    Button(
                        action: {
                            viewModel.toggleTakenInStatus(id: entry.id)
                            viewModel.togglePlanStatus(id: entry.id)
                        }
                    ) {
                        if type == .history {
                            Image(systemName: ("checkmark.circle"))
                                .font(.subheadline)
                                .foregroundColor(.appPrimary)
                        } else {
                            Button(
                                action: {
                                    if (type == .plan) {
                                        viewModel.togglePlanStatus(id: entry.id)
                                        viewModel.toggleTakenInStatus(id: entry.id)
                                    } else if (type == .favorite) {
                                        viewModel.addFavoriteToHistory(uuid: entry.id)
                                    }
                                }
                            ) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.subheadline)
                                    .foregroundColor(.appPrimary)
                            }
                            .padding()
                        }
                    }
                }
            }
            .frame(height: 80)
        }
        .foregroundColor(.secondaryText)
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
        EntryRowView(entry: ProteinDataViewModel().entries[0], type: .favorite)
            .padding()
    }
}
