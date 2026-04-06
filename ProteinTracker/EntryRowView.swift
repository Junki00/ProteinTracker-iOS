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
    let type: EntryType
    
    var body: some View {
        HStack(spacing: DS.Spacing.m) {
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
                VStack(alignment: .leading) {
                    Text(entry.foodName)
                        .foregroundColor(.appPrimaryTextColor)
                        .font(.headline)
                        .lineLimit(1)
                    if !entry.entryDescription.isEmpty {
                        Text(entry.entryDescription)
                            .foregroundColor(.appSecondaryTextColor)
                            .font(.subheadline)
                            .lineLimit(1)
                    }
                }
                Spacer()
                if type == .history {
                    Text(entry.timeStamp.formattedRelativeString())
                        .font(.subheadline)
                } else {
                    Button(
                        action: {
                            DS.Haptics.success()
                            ProteinDataStore.addHistoryEntry(from: entry, in: modelContext)
                            isAdded = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                isAdded = false
                            }
                        }
                    ) {
                        HStack(spacing: DS.Spacing.xs) {
                            Image(systemName: isAdded ? "checkmark.circle.fill" : "plus.circle.fill")
                            Text(isAdded ? String(localized: "entryRow.added") : String(localized: "entryRow.addToToday"))
                                .font(.caption)
                        }
                        .foregroundColor(isAdded ? .green : .appPrimaryColor)
                        .font(.subheadline)
                    }
                    .buttonStyle(.borderless)
                    .accessibilityLabel(isAdded ? String(localized: "accessibility.added") : String(localized: "accessibility.addToHistory"))
                }
            }
            .frame(height: 80)
            Spacer()
            
            //Column Right: Navigate indicator
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.appSecondaryTextColor)
        }
        .entryRowStyle(type: type, isFavorite: entry.isFavorite)
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

                EntryRowView(entry: entry, type: type)
                    .padding()
            }
        }
    }
}
