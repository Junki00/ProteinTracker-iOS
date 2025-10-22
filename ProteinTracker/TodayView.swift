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
    
    let today = Date()

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                ScrollView {
                    VStack(spacing: 20) {
                        HStack {
                            Text(today.formattedRelativeString())
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
                                Text("\(String(format: "%.1f" ,viewModel.stillNeededProtein(on: today))) Grams")
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
                                Text("You've already taken in \(String(format: "%.1f", viewModel.totalProtein(on: Date()))) Grams until now.")
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
                                        .frame(width: geometry.size.width * viewModel.progress(on: today))
                                }
                            }
                            .frame(height: 4)
                            .padding(.horizontal)
                            
                            // View of History List
                            if isShowingList {
                                EntryCardView(type: .history, date: today)
                            }
                        }
                        .padding(.vertical)
                        .background(RoundedRectangle(cornerRadius: 12).fill( Color.appSecondary))
                        
                        EntryCardView(type: .plan, date: today)
                        
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
                AddEntryModalView(date: today)
            }
            .navigationTitle("Today")
        }
        .onAppear {
            Task {
                let service = NetworkService()
                
                do {
                    let products = try await service.searchFoodInfo(searchName: "Chicken Breast")
                    print("✅ Successfully fetched \(products.count) products.")
                    for product in products.prefix(5) {
                        print("- \(product.id) | Protein: \(product.proteinValue)g")
                    }
                } catch {
                    print("❌ Failed to fetch products. Error: \(error)")
                }
            }
        }
    }
}
    
    
#Preview {
    TodayView()
        .environmentObject(ProteinDataViewModel())
}
