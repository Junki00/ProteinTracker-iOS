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
                
                // favorite card 🌟TBD
                if viewModel.totalProteinToday > 0 { // Need a counter for favorites of all the time
                    List {
                        ForEach(viewModel.entries) { entry in
                            NavigationLink(destination: EntryDetailView(entryDetails: entry)) {
                                
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
                if viewModel.totalProteinToday > 0 { // Need a counter for plans of a specific day
                    List {
                        ForEach(viewModel.entries) { entry in
                            NavigationLink(destination: EntryDetailView(entryDetails: entry)) {
                                
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
                if viewModel.totalProteinToday > 0 {
                    List {
                        ForEach(viewModel.entries) { entry in
                            NavigationLink(destination: EntryDetailView(entryDetails: entry)) {
                                
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
                    .scrollContentBackground(.hidden)
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
    EntryCardView(type: .plan)
        .environmentObject(ProteinDataViewModel())
}
