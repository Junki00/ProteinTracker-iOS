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
    
    func addHistoryEntry (proteinAmount: Double, foodName: String, description: String, isFavorite: Bool = false) {
        let newEntry = ProteinEntry(proteinAmount: proteinAmount, foodName: foodName, description: description, isFavorite: isFavorite, isPlan: false, isHistory: true)
        entries.append(newEntry)
    }
    
    func addFavoriteToHistory (uuid: UUID) {
        if let index = entries.firstIndex(where: {$0.id == uuid}) {
            addHistoryEntry(proteinAmount: entries[index].proteinAmount, foodName: entries[index].foodName, description: entries[index].description, isFavorite: true)
        }
    }
    
    func deleteEntry (at offsets: IndexSet) {
        entries.remove(atOffsets: offsets)
    }
    
    func changeEntry (uuid: UUID, proteinAmount: Double, foodName: String, description: String) {
        if let index = entries.firstIndex(where: {$0.id == uuid}) {
            entries[index].proteinAmount = proteinAmount
            entries[index].foodName = foodName
            entries[index].description = description
        }
    }
    
    func togglePlanStatus (id: UUID) {
        if let index = entries.firstIndex(where: {$0.id == id}) {
            entries[index].isPlan.toggle()
        }
    }
    
    func toggleTakenInStatus (id: UUID) {
        if let index = entries.firstIndex(where: {$0.id == id}) {
            entries[index].isPlan.toggle()
        }
    }
    
    func toggleFavoriteStatus (id: UUID) {
        if let index = entries.firstIndex(where: {$0.id == id}) {
            entries[index].isFavorite.toggle()
        }
    }
    
    // temprory for development
    func resetToMockData() {
        print("🔄 Resetting to mock data.")
        loadMockData()
    }
    
    var totalProteinToday: Double {
        let todaysEntries = entries.filter{ Calendar.current.isDateInToday($0.timeStamp) && $0.isPlan == false }
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
            // history
            ProteinEntry(proteinAmount: 48.0, foodName: "Whey Protein Shake", description: "Post-workout", timeStamp: Date().addingTimeInterval(-1800), isFavorite: false, isPlan: false, isHistory: true),
            ProteinEntry(proteinAmount: 40.2, foodName: "Grilled Chicken Breast", description: "Lunch", timeStamp: Date().addingTimeInterval(-10800), isFavorite: false, isPlan: false, isHistory: true),
            ProteinEntry(proteinAmount: 15.0, foodName: "Greek Yogurt", description: "Snack", timeStamp: Date().addingTimeInterval(-18000), isFavorite: false, isPlan: false, isHistory: true),
            ProteinEntry(proteinAmount: 21.0, foodName: "Scrambled Eggs (3)", description: "Breakfast", timeStamp: Date().addingTimeInterval(-36000), isFavorite: false, isPlan: false, isHistory: true),
            ProteinEntry(proteinAmount: 30.8, foodName: "Salmon Fillet", description: "Dinner yesterday", timeStamp: Date().addingTimeInterval(-93600), isFavorite: false, isPlan: false, isHistory: true),
            ProteinEntry(proteinAmount: 12.5, foodName: "Cottage Cheese", description: "Late night snack yesterday", timeStamp: Date().addingTimeInterval(-82800), isFavorite: false, isPlan: false, isHistory: true),
            
            // favorite
            ProteinEntry(proteinAmount: 40.2, foodName: "Grilled Chicken Breast", description: "Lunch", timeStamp: Date().addingTimeInterval(-10800), isFavorite: true, isPlan: false, isHistory: false),
            ProteinEntry(proteinAmount: 15.0, foodName: "Greek Yogurt", description: "Snack", timeStamp: Date().addingTimeInterval(-18000), isFavorite: true, isPlan: false, isHistory: false),
            ProteinEntry(proteinAmount: 21.0, foodName: "Scrambled Eggs (3)", description: "Breakfast", timeStamp: Date().addingTimeInterval(-36000), isFavorite: true, isPlan: false, isHistory: false),
            ProteinEntry(proteinAmount: 30.8, foodName: "Salmon Fillet", description: "Dinner yesterday", timeStamp: Date().addingTimeInterval(-93600), isFavorite: true, isPlan: false, isHistory: false),
            ProteinEntry(proteinAmount: 12.5, foodName: "Cottage Cheese", description: "Late night snack yesterday", timeStamp: Date().addingTimeInterval(-82800), isFavorite: true, isPlan: false, isHistory: false),
            
            // plan
            ProteinEntry(proteinAmount: 48.0, foodName: "Whey Protein Shake", description: "Post-workout", timeStamp: Date().addingTimeInterval(1800), isFavorite: false, isPlan: true, isHistory: false),
            ProteinEntry(proteinAmount: 40.2, foodName: "Grilled Chicken Breast", description: "Lunch", timeStamp: Date().addingTimeInterval(10800), isFavorite: false, isPlan: true, isHistory: false),
        ]
    }
}
