//
//  TodayView.swift
//  ProteinTracker
//
//  Created by drx on 2025/07/19.
//

import SwiftUI

struct TodayView: View {
    @EnvironmentObject var viewModel: ProteinDataViewModel
    
    //for addEntryModal
    @State private var isShowingAddSheet = false
    @State private var isShowingList = true
    
    //for searching
    @State private var searchTerm: String = ""
    @State private var searchResults: [Product] = []
    @State private var isSearching: Bool = false
    @State private var selectedProduct: Product?
    @State private var searchError: Error?
    @State private var isShowingErrorAlert = false
    
    let today = Date()

    var body: some View {
        NavigationStack {
            if searchTerm.isEmpty {
                ZStack(alignment: .bottomTrailing) {
                    ScrollView {
                        VStack(spacing: 20) {
                            HStack {
                                HStack {
                                    Text("🌍 Good Day, Junn!")
                                }
                                
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
                .navigationTitle("Today")
            } else {
                if isSearching {
                    ProgressView()
                } else {
                    List(searchResults) { product in
                        SearchResultRowView(product: product)
                            .onTapGesture {
                                self.selectedProduct = product
                            }
                    }
                }
            }
        }
        .searchable(text: $searchTerm, prompt: "Search for a food...")
        .onSubmit(of: .search) {
            Task {
                await performSearch()
            }
        }
        .sheet(isPresented: $isShowingAddSheet) {
            AddEntryModalView(date: today)
        }
        .sheet(item: $selectedProduct) { product in
            AddEntryModalView(product: product, date: today)
        }
        .alert("Search Failed", isPresented: $isShowingErrorAlert, actions: {
            Button("OK") { }
        }, message: {
            if let networkError = searchError as? NetworkError {
                Text(networkError.userFriendlyDescription)
            } else {
                Text(searchError?.localizedDescription ?? "An unknown error occurred.")
            }
        })
    }
    
    @MainActor
    private func performSearch() async {
        isSearching = true
        
        defer {
            isSearching = false
        }
        
        do {
            let service = NetworkService()
            let products = try await service.searchFoodInfo(searchName: searchTerm)
            self.searchResults = products
        } catch {
            print("❌ Search failed: \(error)")
            self.searchError = error
            self.isShowingErrorAlert = true
        }
    }
}

private struct SearchResultRowView: View {
    let product: Product

    var body: some View {
        VStack(alignment: .leading) {
            Text(product.productName ?? "Unknown Product")
                .font(.headline)
            Text("\(product.proteinValue, specifier: "%.1f")g protein per 100g")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    TodayView()
        .environmentObject(ProteinDataViewModel())
}
