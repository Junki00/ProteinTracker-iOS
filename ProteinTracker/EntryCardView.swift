//
//  EntryCardView.swift
//  ProteinTracker
//
//  Created by drx on 2025/08/17.
//

import SwiftData
import SwiftUI

struct EntryCardView: View {
    @Query private var entries: [ProteinEntry]
    @State private var selectedEntry: ProteinEntry?

    let type: EntryType
    let date: Date

    private var displayedEntries: [ProteinEntry] {
        ProteinDataStore.entries(for: type, on: date, from: entries)
    }

    var body: some View {
        VStack {
            if type == .favorite {
                if displayedEntries.isEmpty {
                    VStack(spacing: 16) {
                        Spacer()
                        Text(String(localized: "entryCard.noFavorites"))
                            .multilineTextAlignment(.center)
                            .foregroundColor(.appPrimaryColor)
                            .font(.headline)
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, minHeight: 300)
                    .padding(.horizontal)
                } else {
                    VStack(spacing: 12) {
                        ForEach(displayedEntries) { entry in
                            NavigationLink {
                                EntryDetailView(entry: entry)
                            } label: {
                                EntryRowView(entry: entry, type: .favorite, onAddToPlanTapped: { selectedEntry = entry })
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            } else if type == .plan {
                if displayedEntries.isEmpty {
                    VStack(spacing: 16) {
                        Spacer()
                        Text(String(localized: "entryCard.noPlans"))
                            .multilineTextAlignment(.center)
                            .foregroundColor(.appPrimaryColor)
                            .font(.headline)
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, minHeight: 300)
                    .padding(.horizontal)
                } else {
                    VStack(spacing: 12) {
                        ForEach(displayedEntries) { entry in
                            NavigationLink {
                                EntryDetailView(entry: entry)
                            } label: {
                                EntryRowView(entry: entry, type: .plan)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            } else {
                if displayedEntries.isEmpty {
                    VStack(spacing: 16) {
                        Spacer()
                        Image(systemName: "fork.knife.circle.fill")
                            .font(.system(size: 100))
                            .foregroundColor(.appSecondaryTextColor.opacity(0.6))
                        Text(String(localized: "entryCard.noEntries"))
                            .multilineTextAlignment(.center)
                            .foregroundColor(.appPrimaryColor)
                            .font(.headline)
                        Text(String(localized: "entryCard.emptyHint"))
                            .multilineTextAlignment(.center)
                            .foregroundColor(.appSecondaryTextColor)
                            .font(.subheadline)
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, minHeight: 300)
                    .padding(.horizontal)
                    .background(Color.appAccentColor)
                } else {
                    VStack(spacing: 12) {
                        ForEach(displayedEntries) { entry in
                            NavigationLink {
                                EntryDetailView(entry: entry)
                            } label: {
                                EntryRowView(entry: entry, type: .history)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
        .padding(.vertical)
        .background(
            RoundedRectangle(cornerRadius: 28)
                .fill(type == .history ? Color.appAccentColor : .appCardBackgroundColor)
        )
        .shadow(color: type == .history ? .clear : Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
        .sheet(item: $selectedEntry) { selectedEntry in
            AddPlanView(entry: selectedEntry)
        }
    }
}

#Preview {
    EntryCardView(type: .favorite, date: Date())
        .modelContainer(ProteinDataStore.previewContainer())
}
