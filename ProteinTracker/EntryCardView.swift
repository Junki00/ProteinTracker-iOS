//
//  EntryCardView.swift
//  ProteinTracker
//
//  Created by drx on 2025/08/17.
//

import SwiftUI

struct EntryCardView: View {
    @EnvironmentObject var viewModel: ProteinDataViewModel
    @State private var selectedEntry: ProteinEntry? = nil
    
    var type: EntryType
    var date: Date

    var body: some View {
        VStack {
            if type == .favorite {
                if viewModel.getEntries(for: .favorite).isEmpty {
                    //Favorite View, Empty
                    VStack(spacing: 16) {
                        Spacer()
                        Text("No favorites yet.")
                            .multilineTextAlignment(.center)
                            .foregroundColor(.appPrimaryColor)
                            .font(.headline)
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, minHeight: 300)
                    .padding(.horizontal)
                } else {
                    //Favorite View, Not Empty
                    let favoriteEntries = viewModel.getEntries(for: .favorite)
                
                    VStack(spacing: 12) {
                        ForEach(favoriteEntries) { entry in
                            NavigationLink {
                                EntryDetailView(entry: binding(for: entry))
                            } label: {
                                EntryRowView(entry: entry, type: .favorite, onAddToPlanTapped: {self.selectedEntry = entry})
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            } else if type == .plan {
                if viewModel.getEntries(for: .plan, on: date).isEmpty {
                    //Plan View, Empty
                    VStack(spacing: 16) {
                        Spacer()
                        Text("No plans yet.")
                            .multilineTextAlignment(.center)
                            .foregroundColor(.appPrimaryColor)
                            .font(.headline)
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, minHeight: 300)
                    .padding(.horizontal)
                } else {
                    //Plan View, Not Empty
                    let somedayPlanEntries = viewModel.getEntries(for: .plan, on: date)
                    
                    VStack(spacing: 12) {
                        ForEach(somedayPlanEntries) { entry in
                            NavigationLink {
                                EntryDetailView(entry: binding(for: entry))
                            } label: {
                                EntryRowView(entry: entry, type: .plan)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            } else {
                if viewModel.getEntries(for: .history, on: date).isEmpty {
                    //History View, Empty
                    VStack(spacing: 16) {
                        Spacer()
                        Image(systemName:  "fork.knife.circle.fill")
                            .font(.system(size: 100))
                            .foregroundColor(.appSecondaryTextColor.opacity(0.6))
                        Text("No entries yet.")
                            .multilineTextAlignment(.center)
                            .foregroundColor(.appPrimaryColor)
                            .font(.headline)
                        Text("Tap the '+' button at Today Tab to add\nyour first protein entry.")
                            .multilineTextAlignment(.center)
                            .foregroundColor(.appSecondaryTextColor)
                            .font(.subheadline)
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, minHeight: 300)
                    .padding(.horizontal)
                    .background(Color.appAccentColor)
                } else {
                    //History View, Not Empty
                    let somedayHistoryEntries = viewModel.getEntries(for: .history, on: date)
                    
                    VStack(spacing: 12) {
                        ForEach(somedayHistoryEntries) { entry in
                            NavigationLink {
                                EntryDetailView(entry: binding(for: entry))
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
    
    // --- Helper Method ---
    private func binding(for entry: ProteinEntry) -> Binding<ProteinEntry> {
        let getter = {
            if let index = viewModel.entries.firstIndex(where: { $0.id == entry.id }) {
                return viewModel.entries[index]
            }
            return entry
        }
        
        let setter = { (newValue: ProteinEntry) in
            if let index = viewModel.entries.firstIndex(where: { $0.id == entry.id }) {
                viewModel.entries[index] = newValue
            }
        }
        
        return Binding(get: getter, set: setter)
    }
}

#Preview {
    EntryCardView(type: .favorite, date: Date())
        .environmentObject(ProteinDataViewModel())
}
