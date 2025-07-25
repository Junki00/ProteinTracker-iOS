//
//  ProteinDataViewModel.swift
//  ProteinTracker
//
//  Created by drx on 2025/07/25.
//

import Foundation

class ProteinDataViewModel: ObservableObject {
    
    @Published var entries: [ProteinEntry] = []
    
    init() {
        loadMockData()
    }
    
    func addEntry (proteinAmount: Double, foodName: String, description: String) {
        let newEntry = ProteinEntry(proteinAmount: proteinAmount, foodName: foodName, description: description)
        entries.append(newEntry)
    }
    
    func deleteEntry (at offsets: IndexSet) {
        entries.remove(atOffsets: offsets)
    }
    
    private func loadMockData() {
        self.entries = [
            ProteinEntry(proteinAmount: 25.5, foodName: "Whey Protein Shake", description: "Post-workout", addTime: Date().addingTimeInterval(-1800)),
            ProteinEntry(proteinAmount: 40.2, foodName: "Grilled Chicken Breast", description: "Lunch", addTime: Date().addingTimeInterval(-10800)),
            ProteinEntry(proteinAmount: 15.0, foodName: "Greek Yogurt", description: "Snack", addTime: Date().addingTimeInterval(-18000)),
            ProteinEntry(proteinAmount: 21.0, foodName: "Scrambled Eggs (3)", description: "Breakfast", addTime: Date().addingTimeInterval(-36000)),
            ProteinEntry(proteinAmount: 30.8, foodName: "Salmon Fillet", description: "Dinner yesterday", addTime: Date().addingTimeInterval(-93600)),
            ProteinEntry(proteinAmount: 12.5, foodName: "Cottage Cheese", description: "Late night snack yesterday", addTime: Date().addingTimeInterval(-82800))
        ]
    }
}
