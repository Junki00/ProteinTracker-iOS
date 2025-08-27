//
//  EntryCardView.swift
//  ProteinTracker
//
//  Created by drx on 2025/08/17.
//

import SwiftUI

struct EntryCardView: View {
    @EnvironmentObject var viewModel: ProteinDataViewModel
    
    var type: EntryRowType

    var body: some View {
        VStack {
            if type == .favorite {
                Text("Favorites")
                    .font(.subheadline)
                    .bold()
                    .foregroundColor(.appPrimary)
                Text("❤️ Maybe they are not your favorites, but they work.")
                    .font(.subheadline)
                
                let favoriteEntries = viewModel.entries.filter{ $0.isFavorite == true }
                
                // favorite card 🌟TBD
                if !favoriteEntries.isEmpty {
                    List {
                        ForEach(favoriteEntries) { entry in
                            NavigationLink(destination: EntryDetailView(entry: entry)) {
                                
                                EntryRowView(entry: entry, type: type)
                                    .listRowBackground(Color.clear)
                                    .listRowSeparator(.hidden)
                                    .listRowInsets(EdgeInsets())
                            }
                        }
                        .onDelete { indexSet in
                            viewModel.deleteEntry(at: indexSet)
                        }
                    }
                    .listStyle(.plain)
                    .frame(height: CGFloat(viewModel.entries.count*80))
                } else {
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

                }
            } else if type == .plan {
                Text("Today's Plan")
                    .font(.subheadline)
                    .bold()
                    .foregroundColor(.appPrimary)
                Text("🌞 Here is your plan of today.")
                    .font(.subheadline)
                
                // plan card 🌟TBD
                
                
                let todaysPlanEntries = viewModel.entries.filter{ Calendar.current.isDateInToday($0.timeStamp) && $0.isPlan == true }
                                
                if !todaysPlanEntries.isEmpty {
                    List {
                        ForEach(todaysPlanEntries) { entry in
                            NavigationLink(destination: EntryDetailView(entry: entry)) {
                                
                                EntryRowView(entry: entry, type: type)
                                    .listRowBackground(Color.clear)
                                    .listRowSeparator(.hidden)
                                    .listRowInsets(EdgeInsets())
                            }
                        }
                        .onDelete { indexSet in
                            viewModel.deleteEntry(at: indexSet)
                        }
                    }
                    .listStyle(.plain)
                    .frame(height: CGFloat(viewModel.entries.count*80))
                } else {
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
                }
     
            } else {
                // history card
                let todaysHistoryEntries = viewModel.entries.filter{ Calendar.current.isDateInToday($0.timeStamp) && $0.isHistory == true }
                
                if !todaysHistoryEntries.isEmpty {
                    // MARK: - TODO for next session
                    /*
                     
                     The current ForEach iterates over a filtered copy of the array,
                     which prevents creating a Binding to the original data source.
                     
                     NEXT STEP:
                     1. Change ForEach to iterate over the binding of the original array:
                        ForEach($viewModel.entries) { $entry in ... }
                     
                     2. Move the filtering logic (if isHistory && isToday) INSIDE the ForEach loop.
                     
                     3. Pass the binding `$entry` to the NavigationLink destination (EntryDetailView).
                     
                     */
                    List {
                        ForEach(todaysHistoryEntries) { entry in
                            NavigationLink(destination: EntryDetailView(entry: entry)) {
                                EntryRowView(entry: entry, type: type)
                                    .listRowBackground(Color.appSecondary)
                                    .listRowSeparator(.hidden)
                                    .listRowInsets(EdgeInsets())
                            }
                        }
                        .onDelete { indexSet in
                            viewModel.deleteEntry(at: indexSet)
                        }
                    }
                    .listStyle(.plain)
                    .background(Color.appSecondary)
                    .frame(height: CGFloat(viewModel.entries.count*80))
                } else {
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
                }
            }

        }
        .background(type == .history ? Color.appSecondary: .white)
    }
}


#Preview {
    EntryCardView(type: .history)
        .environmentObject(ProteinDataViewModel())
}
