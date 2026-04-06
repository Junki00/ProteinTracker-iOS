//
//  EntryCardView.swift
//  ProteinTracker
//
//  Created by drx on 2025/08/17.
//

import SwiftData
import SwiftUI

struct EntryCardView: View {
    private static let minimumCardHeight: CGFloat = 300

    @Environment(\.modelContext) private var modelContext
    @Query private var entries: [ProteinEntry]

    let type: EntryType
    let date: Date

    private var displayedEntries: [ProteinEntry] {
        ProteinDataStore.entries(for: type, on: date, from: entries)
    }

    var body: some View {
        VStack {
            if type == .favorite {
                if displayedEntries.isEmpty {
                    VStack(spacing: DS.Spacing.m) {
                        Spacer()
                        Text(String(localized: "entryCard.noFavorites"))
                            .multilineTextAlignment(.center)
                            .foregroundColor(.appPrimaryColor)
                            .font(.headline)
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, minHeight: Self.minimumCardHeight)
                    .padding(.horizontal, DS.Spacing.m)
                } else {
                    VStack(spacing: DS.Spacing.s) {
                        ForEach(displayedEntries) { entry in
                            NavigationLink {
                                EntryDetailView(entry: entry)
                            } label: {
                                EntryRowView(entry: entry, type: .favorite)
                            }
                            .contextMenu {
                                deleteButton(for: entry)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, minHeight: Self.minimumCardHeight, alignment: .top)
                    .padding(.horizontal, DS.Spacing.m)
                }
            } else {
                if displayedEntries.isEmpty {
                    VStack(spacing: DS.Spacing.m) {
                        Spacer()
                        Image(systemName: "fork.knife.circle.fill")
                            .font(.system(size: 100))
                            .foregroundColor(.appSecondaryTextColor.opacity(0.6))
                        Text(String(localized: "entryCard.noEntries"))
                            .multilineTextAlignment(.center)
                            .foregroundColor(.appPrimaryColor)
                            .font(.headline)
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, minHeight: Self.minimumCardHeight)
                    .padding(.horizontal, DS.Spacing.m)
                    .background(Color.appAccentColor)
                } else {
                    VStack(spacing: DS.Spacing.s) {
                        ForEach(displayedEntries) { entry in
                            NavigationLink {
                                EntryDetailView(entry: entry)
                            } label: {
                                EntryRowView(entry: entry, type: .history)
                            }
                            .contextMenu {
                                deleteButton(for: entry)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, minHeight: Self.minimumCardHeight, alignment: .top)
                    .padding(.horizontal, DS.Spacing.m)
                }
            }
        }
        .padding(.vertical)
        .background(
            RoundedRectangle(cornerRadius: DS.Radius.card)
                .fill(type == .history ? Color.appAccentColor : .appCardBackgroundColor)
        )
        .shadow(color: type == .history ? .clear : Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
    }

    private func deleteButton(for entry: ProteinEntry) -> some View {
        Button(role: .destructive) {
            withAnimation(DS.Animation.snappy) {
                ProteinDataStore.delete(entry, in: modelContext)
            }
        } label: {
            Label(String(localized: "common.delete"), systemImage: "trash")
        }
    }
}

#Preview {
    EntryCardView(type: .favorite, date: Date())
        .modelContainer(ProteinDataStore.previewContainer())
}
