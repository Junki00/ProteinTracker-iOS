//
//  ProteinDataViewModel.swift
//  ProteinTracker
//
//  Created by drx on 2025/07/25.
//

import Combine
import Foundation

class ProteinDataViewModel: ObservableObject {
    private var cancellables = Set<AnyCancellable>()

    @Published var dailyGoal:Double = 240.0
    @Published var entries: [ProteinEntry] = []
    
    private var dataFileURL: URL {
        let docDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return docDirectory.appendingPathComponent("protein_entries.json")
    }
    
    init() {
        load()
        $entries
            .debounce(for: .seconds(0.8), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                self?.save()
            }
            .store(in: &cancellables)
    }
    
    func addEntry (proteinAmount: Double, foodName: String, description: String) {
        let newEntry = ProteinEntry(proteinAmount: proteinAmount, foodName: foodName, description: description)
        entries.append(newEntry)
    }
    
    func deleteEntry (at offsets: IndexSet) {
        entries.remove(atOffsets: offsets)
    }
    
    // temprory for development
    func resetToMockData() {
        print("🔄 Resetting to mock data.")
        loadMockData()
    }
    
    var totalProteinToday: Double {
        let todaysEntries = entries.filter{ Calendar.current.isDateInToday($0.addTime) }
        return todaysEntries.reduce(0) { sum, entry in
            sum + entry.proteinAmount
        }
    }
    
    var stillNeedProtein: Double {
        max(0, dailyGoal - totalProteinToday)
    }
    
    var progess: Double {
        if dailyGoal == 0 {
            return 0
        }
        return min(1, totalProteinToday / dailyGoal)
    }
    
    func save() {
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            
            let data = try encoder.encode(entries)
            
            try data.write(to: dataFileURL)
            
            print("✅ Data saved successfully to: \(dataFileURL)")
        } catch {
            print("❌ Failed to save data: \(error.localizedDescription)")
        }
    }
    
    func load() {
        guard let data = try? Data(contentsOf: dataFileURL) else {
            print("📝 No saved data found. Loading mock data.")
            loadMockData()
            return
        }
        
        do {
            let decoder = JSONDecoder()
            self.entries = try decoder.decode([ProteinEntry].self, from: data)
            print("✅ Data loaded successfully.")
        } catch {
            print("❌ Failed to decode data: \(error.localizedDescription). Loading mock data as a fallback.")
            loadMockData()
        }
    }
    
    private func loadMockData() {
        self.entries = [
            ProteinEntry(proteinAmount: 48.0, foodName: "Whey Protein Shake", description: "Post-workout", addTime: Date().addingTimeInterval(-1800)),
            ProteinEntry(proteinAmount: 40.2, foodName: "Grilled Chicken Breast", description: "Lunch", addTime: Date().addingTimeInterval(-10800)),
            ProteinEntry(proteinAmount: 15.0, foodName: "Greek Yogurt", description: "Snack", addTime: Date().addingTimeInterval(-18000)),
            ProteinEntry(proteinAmount: 21.0, foodName: "Scrambled Eggs (3)", description: "Breakfast", addTime: Date().addingTimeInterval(-36000)),
            ProteinEntry(proteinAmount: 30.8, foodName: "Salmon Fillet", description: "Dinner yesterday", addTime: Date().addingTimeInterval(-93600)),
            ProteinEntry(proteinAmount: 12.5, foodName: "Cottage Cheese", description: "Late night snack yesterday", addTime: Date().addingTimeInterval(-82800))
        ]
    }
}
