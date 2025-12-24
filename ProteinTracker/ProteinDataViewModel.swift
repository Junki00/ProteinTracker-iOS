//
//  ProteinDataViewModel.swift
//  ProteinTracker
//
//  Created by drx on 2025/07/25.
//

import Combine
import Foundation

enum FavoriteStatus {
    case added
    case alreadyExists
}

let favoriteStatusPublisher = PassthroughSubject<FavoriteStatus, Never>()

class ProteinDataViewModel: ObservableObject {
    private var cancellables = Set<AnyCancellable>()

    @Published var dailyGoal:Double = 260.0
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
    
    
    
    //From Primitive Data to History Entry
    func addHistoryEntry (proteinAmount: Double, foodName: String, description: String, isFavorite: Bool = false) {
        let newEntry = ProteinEntry(proteinAmount: proteinAmount, foodName: foodName, description: description, isFavorite: isFavorite, isPlan: false, isHistory: true)
        entries.append(newEntry)
    }
    
    //From Favorite Entry to History Entry
    func addHistoryEntry (from favoriteEntry: ProteinEntry) {
        let newEntry = ProteinEntry(proteinAmount: favoriteEntry.proteinAmount, foodName: favoriteEntry.foodName, description: favoriteEntry.description, isFavorite: true, isPlan: false, isHistory: true)
        entries.append(newEntry)
    }
    
    //From Primitive Data to Plan Entry
    func addPlanEntry(proteinAmount: Double, foodName: String, description: String, date: Date, isFavorite: Bool = false) {
        let newEntry = ProteinEntry(proteinAmount: proteinAmount, foodName: foodName, description: description, timeStamp: date, isFavorite: isFavorite, isPlan: true, isHistory: false)
        entries.append(newEntry)
    }
    
    //From Favorite Entry to Plan Entry
    func addPlanEntry(from favoriteEntry: ProteinEntry, on date: Date) {
        let newEntry = ProteinEntry(proteinAmount: favoriteEntry.proteinAmount, foodName: favoriteEntry.foodName, description: favoriteEntry.description, timeStamp: date, isFavorite: true, isPlan: true, isHistory: false)
        entries.append(newEntry)
    }
    
    //From Primitive Data to Favorite Entry
    func addFavoriteEntry(proteinAmount: Double, foodName: String, description: String) {
        let newEntry = ProteinEntry(proteinAmount: proteinAmount, foodName: foodName, description: description, isFavorite: true, isPlan: false, isHistory: false)
        entries.append(newEntry)
    }
    
    //From other entries to Favorite Entry, click Star Icon to add a copy.
    func addFavoriteEntry(from otherEntry: ProteinEntry) {
        let favoriteTemplateExists = entries.contains {
            $0.foodName == otherEntry.foodName && $0.isFavorite && !$0.isPlan && !$0.isHistory
        }
        
        if !favoriteTemplateExists {
            addFavoriteEntry(proteinAmount: otherEntry.proteinAmount, foodName: otherEntry.foodName, description: otherEntry.description)
        }
                
        for index in entries.indices {
            if entries[index].foodName == otherEntry.foodName {
                entries[index].isFavorite = true
            }
        }
    }
    

    func completePlan(withID uuid: UUID) {
        if let index = entries.firstIndex(where: { $0.id == uuid }) {
            entries[index].isPlan = false
            entries[index].isHistory = true
            entries[index].timeStamp = Date()
        }
    }

    func revertToPlan(withID uuid: UUID) {
        if let index = entries.firstIndex(where: { $0.id == uuid }) {
            entries[index].isPlan = true
            entries[index].isHistory = false
        }
    }

    func deleteEntries(_ entriesToDelete: [ProteinEntry]) {
        let idsToDelete = Set(entriesToDelete.map { $0.id })

        entries.removeAll { entry in
            idsToDelete.contains(entry.id)
        }
    }
    
    func deleteEntry(withId id: UUID) {
        entries.removeAll { $0.id == id }
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
    
    
    // temprory for development
    func resetToMockData() {
        print("🔄 Resetting to mock data.")
        loadMockData()
    }
    
    func getEntries(for type: EntryType, on date: Date? = nil) -> [ProteinEntry] {
        let filteredByType: [ProteinEntry]
        switch type {
            case .history: filteredByType = self.entries.filter { $0.isHistory && !$0.isPlan }
            case .favorite: filteredByType = self.entries.filter { $0.isFavorite && !$0.isPlan && !$0.isHistory}
            case .plan: filteredByType = self.entries.filter { $0.isPlan && !$0.isHistory}
        }
        
        let filteredByDate: [ProteinEntry]
        if let date = date, type != .favorite {
            filteredByDate = filteredByType.filter { Calendar.current.isDate($0.timeStamp, inSameDayAs: date) }
        } else {
            filteredByDate = filteredByType
        }
        
        switch type {
        case .history, .favorite:
            return filteredByDate.sorted(by: { $0.timeStamp > $1.timeStamp })
        case .plan:
            return filteredByDate.sorted(by: { $0.timeStamp < $1.timeStamp })
        }
    }
    
    // MARK: - Calculation Methods
    func totalProtein(on date: Date) -> Double {
        let entriesForDay = getEntries(for: .history, on: date)
        
        let total = entriesForDay.reduce(0) { sum, entry in
            sum + entry.proteinAmount
        }
        
        return total
    }

    func stillNeededProtein(on date: Date) -> Double {
        let totalToday = totalProtein(on: date)
        let needed = dailyGoal - totalToday
        return max(0, needed)
    }

    func progress(on date: Date) -> Double {
        guard dailyGoal > 0 else { return 0 }
        
        let totalToday = totalProtein(on: date)
        let calculatedProgress = totalToday / dailyGoal
        return min(1, calculatedProgress)
    }
    
    func getWeeklyProteinData(on date: Date = Date()) -> [DailyProteinData] {
        var weeklyProteinData:[DailyProteinData] = []
        let calendar = Calendar.current
        
        for i in (0..<7).reversed() {
            if let loopDate = calendar.date(byAdding: .day, value: -i, to: date) {
                let dataPoint = DailyProteinData(date: loopDate, totalProtein: totalProtein(on: loopDate))
                weeklyProteinData.append(dataPoint)
            }
        }
        return weeklyProteinData
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
        let today = Date()
        let calendar = Calendar.current
        
        // 1. 食物池 (数值调高，更像正餐)
        let breakfastItems = [
            ("Oatmeal & Double Whey", 45.0), ("4 Eggs Scrambled", 50.0), ("Mega Yogurt Parfait", 60.3), ("Protein Pancakes Stack", 40.0)
        ]
        let lunchItems = [
            ("Double Chicken Salad", 60.0), ("Tuna Melt & Shake", 55.8), ("Beef Burrito XL", 55.0), ("Turkey Club w/ Extra Meat", 68.6)
        ]
        let dinnerItems = [
            ("Salmon Fillet (200g)", 50.7), ("Steak (300g)", 65.0), ("Tofu & Beans Stew", 55.0), ("Cod & Lentils", 52.0)
        ]
        // 零食也变大一点
        let snackItems = [
            ("Large Protein Bar", 45.6), ("Casein Shake", 30.0), ("Cottage Cheese Tub", 55.0), ("Beef Jerky Pack", 42.7)
        ]
        
        let newHistoryEntries: [ProteinEntry] = (0..<7).flatMap { dayIndex -> [ProteinEntry] in
            guard let date = calendar.date(byAdding: .day, value: -dayIndex, to: today) else { return [] }
            
            // 2. 目标控制 (保持不变)
            let isHighDay = Double.random(in: 0...1) < 0.7
            let targetTotal = isHighDay ? Double.random(in: 260...280) : Double.random(in: 240...260)
            
            var dailyEntries: [ProteinEntry] = []
            var currentTotal = 0.0
            
            // 3. 基础三餐 (必吃)
            let meals = [
                (breakfastItems, "Breakfast"),
                (lunchItems, "Lunch"),
                (dinnerItems, "Dinner")
            ]
            
            for (items, desc) in meals {
                let item = items.randomElement()!
                dailyEntries.append(ProteinEntry(proteinAmount: item.1, foodName: item.0, description: desc, timeStamp: date, isFavorite: false, isPlan: false, isHistory: true))
                currentTotal += item.1
            }
            
            // 4. 智能补齐 (Loop until target reached, but max 3 snacks)
            var snackCount = 0
            while currentTotal < targetTotal && snackCount < 3 { // 限制零食最多3个，总条目最多6个
                let remaining = targetTotal - currentTotal
                
                if remaining < 15 {
                    // 缺口小于15g，直接加到上一顿饭里，不创建新条目！这样数据更整洁。
                    if var lastEntry = dailyEntries.last {
                        lastEntry.proteinAmount += remaining
                        // 稍微改下名字，显得真实
                        if !lastEntry.foodName.contains("& Side") {
                            lastEntry.foodName += " & Side"
                        }
                        dailyEntries[dailyEntries.count - 1] = lastEntry
                    }
                    currentTotal += remaining
                } else {
                    // 缺口较大，加一个零食
                    let sItem = snackItems.randomElement()!
                    // 确保不会加上去之后大大超标，取 remaining 和 sItem 的较小值，或者允许稍微超标一点点
                    let amountToAdd = min(sItem.1, remaining + 5)
                    dailyEntries.append(ProteinEntry(proteinAmount: amountToAdd, foodName: sItem.0, description: "Snack", timeStamp: date, isFavorite: false, isPlan: false, isHistory: true))
                    currentTotal += amountToAdd
                    snackCount += 1
                }
            }
            
            return dailyEntries
        }
            // --- END: New History Mock Data ---
            
        self.entries = newHistoryEntries + [
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
