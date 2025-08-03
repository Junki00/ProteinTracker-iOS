//
//  TodayView.swift
//  ProteinTracker
//
//  Created by drx on 2025/07/19.
//

import SwiftUI

struct TodayView: View {
    @EnvironmentObject var viewModel: ProteinDataViewModel
    @State private var isShowingAddSheet = false
    @State private var isShowingList = true
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            ScrollView {
                VStack(spacing: 20) {
                    
                    HStack {
                        Text("June 30, 2025")
                        Spacer()
                        
                        // Temporary for Reset
                        Button(action: {viewModel.resetToMockData()}) {
                            Image(systemName: "arrow.counterclockwise.circle.fill")
                                .foregroundColor(.gray)
                                .font(.title2)
                        }
                    }
                    
                    VStack {
                        HStack {
                            HStack {
                                Text("Still Need")
                                    .font(.title2)
                                    .bold()
                                Spacer()
                                Button(action: {print("Tapped")}) {
                                    Text("Change Goal")
                                        .font(.subheadline.weight(.bold))
                                        .foregroundColor(.appPrimary)
                                        .padding(.vertical, 8)
                                        .padding(.horizontal, 12)
                                        .background(Color.appBackground)
                                        .cornerRadius(16)
                                }
                            }
                            .foregroundColor(.appSecondary)
                        }
                        
                        HStack {
                            Text("\(String(format: "%.1f" ,viewModel.stillNeedProtein)) Grams")
                                .font(.system(size: 40, weight: .heavy))
                                .bold()
                                .foregroundColor(.appBackground)
                            Spacer()
                        }
                        
                        HStack {
                            Text("❤️ Your Daily Protein Goal is \(String(format: "%.1f", viewModel.dailyGoal)) Grams")
                            Image(systemName: "info.circle")
                            Spacer()
                        }
                        .font(.subheadline)
                        .foregroundColor(.appBackground)
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 12)
                    .fill( Color.appPrimary))
                    
                    VStack(spacing: 10) {
                        HStack{
                            Text("You've already taken in \(String(format: "%.1f", viewModel.totalProteinToday)) Grams until now.")
                                .font(.subheadline)
                                .bold()
                            Image(systemName: "chevron.down")
                                .rotationEffect(.degrees(isShowingList ? -90:0))
                        }.onTapGesture {
                            withAnimation { isShowingList.toggle() }
                        }
                            
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 3)
                                    .fill(Color.gray.opacity(0.3))
                                GeometryReader { geometry in
                                    RoundedRectangle(cornerRadius: 3).fill(Color.blue)
                                        .frame(width: geometry.size.width * viewModel.progess)
                                }
                            }
                            .frame(height: 4)
                            .padding(.horizontal)
                            
                            // View of Already Taken List
                            if isShowingList {
                                if viewModel.totalProteinToday > 0 {
                                    List {
                                        ForEach(viewModel.entries) { entry in
                                            HistoryEntryRowView(entry: entry)
                                                .listRowBackground(Color.clear)
                                                .listRowSeparator(.hidden)
                                                .listRowInsets(EdgeInsets())
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
                                }
                            }
                        }
                        .padding(.vertical)
                        .background(RoundedRectangle(cornerRadius: 12).fill( Color.appSecondary))
                        
                        PlanCard()
                        Spacer().frame(height: 100)
                    }
                    .padding()
                }
                
            // FAB: Floating Action Button
            Button(
                action: {isShowingAddSheet = true}
            ) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.appPrimary)
                    .shadow(color: .primaryText.opacity(0.5), radius: 5, y: 3)
            }
            .padding()
        }
        .sheet(isPresented: $isShowingAddSheet) {
            AddEntryModalView()
        }
    }
}
    
    
#Preview {
    TodayView()
        .environmentObject(ProteinDataViewModel())
}
