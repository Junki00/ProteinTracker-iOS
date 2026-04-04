//
//  EntryRowView.swift
//  ProteinTracker
//
//  Created by drx on 2025/08/16.
//

import SwiftData
import SwiftUI

struct EntryRowView: View {
    @Environment(\.modelContext) private var modelContext
    
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
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(String(localized: "accessibility.proteinGrams.\(String(format: "%.1f", entry.proteinAmount))"))
            
            //Column Middle
            VStack(alignment: .leading) {
                VStack(alignment:.leading) {
                    Text(entry.foodName)
                        .foregroundColor(.appPrimaryTextColor)
                        .font(.headline)
                        .lineLimit(1)
                    Text(entry.entryDescription)
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
                                Text(String(localized: "entryRow.addToPlan"))
                                    .font(.caption)
                            }
                            .foregroundColor(.appPrimaryColor)
                        }
                        .buttonStyle(.borderless)
                        .accessibilityLabel(String(localized: "accessibility.addToPlan.\(entry.foodName)"))
                    }
                }
            }
            .frame(height: 80)
            Spacer()
            
            //Column Right: Star Icon, Check Icon
            VStack(alignment: .trailing) {
                if entry.isFavorite {
                    Text(String(localized: "entryRow.favorite"))
                        .font(.caption)
                        .accessibilityLabel(String(localized: "accessibility.isFavorite"))
                } else {
                    Button(
                        action: {
                            let generator = UINotificationFeedbackGenerator()
                            generator.notificationOccurred(.success)
                            
                            ProteinDataStore.addFavoriteEntry(from: entry, in: modelContext)
                        }
                    ) {
                        Image(systemName: ("star"))
                            //.font(.system(size: 25))
                            .foregroundColor(.appPrimaryColor)
                    }
                    .buttonStyle(.borderless)
                    .accessibilityLabel(String(localized: "accessibility.addToFavorites"))
                }
                            
                Spacer()
                if type == .history {
                    Button(
                        action: {
                            
                            let generator = UIImpactFeedbackGenerator(style: .medium)
                            generator.impactOccurred()
                            
                            ProteinDataStore.revertToPlan(entry, in: modelContext)
                        }
                    ) {
                        Image(systemName: ("checkmark.circle.fill"))
                    }
                    .buttonStyle(.borderless)
                    .accessibilityLabel(String(localized: "accessibility.revertToPlan"))
                } else if type == .plan {
                    Button(
                        action: {
                            
                            let generator = UINotificationFeedbackGenerator()
                            generator.notificationOccurred(.success)
                            
                            ProteinDataStore.completePlan(entry, in: modelContext)
                        }
                    ) {
                        Image(systemName: ("checkmark.circle"))
                    }
                    .buttonStyle(.borderless)
                    .accessibilityLabel(String(localized: "accessibility.completePlan"))
                } else {
                    Button(
                        action: {
                            
                            let generator = UINotificationFeedbackGenerator()
                            generator.notificationOccurred(.success)
                            
                            ProteinDataStore.addHistoryEntry(from: entry, in: modelContext)
                            
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
                    .accessibilityLabel(isAdded ? String(localized: "accessibility.added") : String(localized: "accessibility.addToHistory"))
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
    PreviewEntryRowView(type: .plan)
        .modelContainer(ProteinDataStore.previewContainer())

    PreviewEntryRowView(type: .favorite)
        .modelContainer(ProteinDataStore.previewContainer())

    PreviewEntryRowView(type: .history)
        .modelContainer(ProteinDataStore.previewContainer())
}

private struct PreviewEntryRowView: View {
    @Query private var entries: [ProteinEntry]

    let type: EntryType

    var body: some View {
        if let entry = entries.first {
            ZStack {
                if type == .history {
                    Color.appAccentColor.ignoresSafeArea()
                }

                EntryRowView(
                    entry: entry,
                    type: type,
                    onAddToPlanTapped: {
                        print("Add to Plan button tapped in preview.")
                    }
                )
                .padding()
            }
        }
    }
}
