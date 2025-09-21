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
                Text("Favorites")
                    .font(.subheadline)
                    .bold()
                    .foregroundColor(.appPrimary)
                Text("❤️ Maybe they are not your favorites, but they work.")
                    .font(.subheadline)
                
                if viewModel.getEntries(for: .favorite).isEmpty {
                    //Favorite View, Empty
                    VStack(spacing: 16) {
                        Image(systemName:  "fork.knife.circle.fill")
                            .font(.system(size: 100))
                            .foregroundColor(.gray.opacity(0.6))
                        Text("No favorite yet.")
                            .multilineTextAlignment(.center)
                            .foregroundColor(.appPrimary)
                            .font(.headline)
                        Text("Tap the '+' button to add\nfavorite.")
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondaryText)
                            .font(.subheadline)
                    }
                    .padding(.horizontal)
                    .background(Color.appSecondary)
                } else {
                    //Favorite View, Not Empty
                    let favoriteEntries = viewModel.getEntries(for: .favorite)
                
                    VStack(spacing: 8) {
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
                Text("Today's Plan")
                    .font(.subheadline)
                    .bold()
                    .foregroundColor(.appPrimary)
                Text("🌞 Here is your plan of today.")
                    .font(.subheadline)
                
                if viewModel.getEntries(for: .plan, on: date).isEmpty {
                    //Plan View, Empty
                    VStack(spacing: 16) {
                        Image(systemName:  "fork.knife.circle.fill")
                            .font(.system(size: 100))
                            .foregroundColor(.gray.opacity(0.6))
                        Text("No plan yet.")
                            .multilineTextAlignment(.center)
                            .foregroundColor(.appPrimary)
                            .font(.headline)
                        Text("Tap the '+' button to add\nplans.")
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondaryText)
                            .font(.subheadline)
                    }
                    .padding(.horizontal)
                } else {
                    //Plan View, Not Empty
                    let somedayPlanEntries = viewModel.getEntries(for: .plan, on: date)
                    
                    VStack(spacing: 8) {
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
                        Image(systemName:  "fork.knife.circle.fill")
                            .font(.system(size: 100))
                            .foregroundColor(.gray.opacity(0.6))
                        Text("No entries yet.")
                            .multilineTextAlignment(.center)
                            .foregroundColor(.appPrimary)
                            .font(.headline)
                        Text("Tap the '+' button to add\nyour first protein entry.")
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondaryText)
                            .font(.subheadline)
                    }
                    .padding(.horizontal)
                    .background(Color.appSecondary)
                } else {
                    //History View, Not Empty
                    let somedayHistoryEntries = viewModel.getEntries(for: .history, on: date)
                    
                    VStack(spacing: 8) {
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
        .background(type == .history ? Color.appSecondary: .white)
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
