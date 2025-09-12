//
//  EntryRowView.swift
//  ProteinTracker
//
//  Created by drx on 2025/08/16.
//

import SwiftUI

struct EntryRowView: View {
    @EnvironmentObject var viewModel: ProteinDataViewModel
    let entry: ProteinEntry
    var type: EntryType
    let onAddToPlanTapped: (() -> Void)?
    
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
                        HStack {
                            Image(systemName: "alarm")
                            Image(systemName: "repeat")
                            Text(entry.timeStamp.formattedRelativeString())
                        }
                        .font(.subheadline)
                    } else {
                        Button(
                            action: {
                                onAddToPlanTapped?()
                            }
                        ) {
                            HStack {
                                Image(systemName: "calendar.badge.plus")
                                    .font(.subheadline)
                                Text("Add to Plan")
                                    .font(.caption)
                            }
                            .foregroundColor(.appPrimary)
                        }
                        .buttonStyle(.borderless)
                    }
                }
            }
            .frame(height: 80)
            
            Spacer()

            //Column Right: Star Icon, Check Icon
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
                .buttonStyle(.borderless)
                
                Spacer()
        
                if type == .history {
                    Button(
                        action: {
                            viewModel.revertToPlan(withID: entry.id)
                        }
                    ) {
                        Image(systemName: ("checkmark.circle.fill"))
                    }
                    .buttonStyle(.borderless)
                } else if type == .plan {
                    Button(
                        action: {
                            viewModel.completePlan(withID: entry.id)
                        }
                    ) {
                        Image(systemName: ("checkmark.circle"))
                    }
                    .buttonStyle(.borderless)
                } else {
                    Button(
                        action: {
                            viewModel.addFavoriteToHistory(uuid: entry.id)
                        }
                    ) {
                        Image(systemName: ("plus.circle.fill"))
                    }
                    .buttonStyle(.borderless)
                }
            }
            .foregroundColor(.appPrimary)
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
    
    init(entry: ProteinEntry, type: EntryType,onAddToPlanTapped: (()->Void)? = nil) {
        self.entry = entry
        self.type = type
        self.onAddToPlanTapped = onAddToPlanTapped
    }
}



#Preview {
    
    ZStack {
        EntryRowView(entry: ProteinDataViewModel().entries[0], type: .plan)
            .padding()
    }
    
    
    ZStack {
        EntryRowView(entry: ProteinDataViewModel().entries[0], type: .favorite, onAddToPlanTapped: {
            print("✅ Add to Plan button tapped in Preview.")
        })
            .padding()
    }
    
    ZStack {
        Color.appSecondary.ignoresSafeArea()
        EntryRowView(entry: ProteinDataViewModel().entries[0], type: .history)
            .padding()
    }
}
