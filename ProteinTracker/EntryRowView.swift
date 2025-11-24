//
//  EntryRowView.swift
//  ProteinTracker
//
//  Created by drx on 2025/08/16.
//

import SwiftUI

struct EntryRowView: View {
    @EnvironmentObject var viewModel: ProteinDataViewModel
    
    @State private var isAdded = false
    
    let entry: ProteinEntry
    var type: EntryType
    let onAddToPlanTapped: (() -> Void)?
    
    var body: some View {
        HStack(spacing: 16) {
            //Column Left
            ZStack {
                Circle()
                    .fill(Color.appPrimaryColor)
                Text(String(format: "%.1f", entry.proteinAmount))
                    .font(.headline)
                    .foregroundColor(.appBackgroundColor)
            }
            .frame(width: 60, height: 60)
            
            //Column Middle
            VStack(alignment: .leading) {
                VStack(alignment:.leading) {
                    Text(entry.foodName)
                        .foregroundColor(.appPrimaryTextColor)
                        .font(.headline)
                        .lineLimit(1)
                    Text(entry.description)
                        .foregroundColor(.appSecondaryTextColor)
                        .font(.subheadline)
                        .lineLimit(1)
                }
                Spacer()
                HStack {
                    if (type != .favorite) {
                        HStack {
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
                            .foregroundColor(.appPrimaryColor)
                        }
                        .buttonStyle(.borderless)
                    }
                }
            }
            .frame(height: 80)
            Spacer()
            
            //Column Right: Star Icon, Check Icon
            VStack(alignment: .trailing) {
                if entry.isFavorite {
                    Text("Favorite")
                        .font(.caption)
                } else {
                    Button(
                        action: {
                            viewModel.addFavoriteEntry(from: entry)
                        }
                    ) {
                        Image(systemName: ("star"))
                            //.font(.system(size: 25))
                            .foregroundColor(.appPrimaryColor)
                    }
                    .buttonStyle(.borderless)
                }
                            
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
                            viewModel.addHistoryEntry(from: entry)
                            
                            isAdded = true
                            
                            
                            // Reset after delay
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                isAdded = false
                            }
                        }
                    ) {
                        Image(systemName: isAdded ? "checkmark.circle.fill" : "plus.circle.fill")
                            .font(.subheadline)
                            .foregroundColor(isAdded ? .green : .appPrimaryColor)
                    }
                    .buttonStyle(.borderless)
                }
            }
            .foregroundColor(.appPrimaryColor)
            .frame(height: 80)
        }
        .entryRowStyle(type: type, isFavorite: entry.isFavorite)
    }
    
    
    init(entry: ProteinEntry, type: EntryType,onAddToPlanTapped: (()->Void)? = nil) {
        self.entry = entry
        self.type = type
        self.onAddToPlanTapped = onAddToPlanTapped
    }
}

extension View {
    func entryRowStyle(type: EntryType, isFavorite: Bool) -> some View {
        self
            .foregroundColor(.appSecondaryTextColor)
            .padding()
            .background(Color.appSubCardBackgroundColor)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 2)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        type == .favorite || isFavorite ?  Color.appPrimaryColor : Color.clear,
                        lineWidth: 2
                    )
            )
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
        Color.appAccentColor.ignoresSafeArea()
        EntryRowView(entry: ProteinDataViewModel().entries[0], type: .history)
            .padding()
    }
}

