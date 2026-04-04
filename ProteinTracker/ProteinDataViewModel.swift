//
//  ProteinDataViewModel.swift
//  ProteinTracker
//
//  Created by drx on 2025/07/25.
//

import Foundation
import SwiftData

enum ProteinDataStore {
    static func ensureSeedData(in context: ModelContext) {
        let entryCount = (try? context.fetchCount(FetchDescriptor<ProteinEntry>())) ?? 0
        let profileCount = (try? context.fetchCount(FetchDescriptor<UserProfile>())) ?? 0

        if profileCount == 0 {
            context.insert(UserProfile())
        }

        if entryCount == 0 {
            for entry in makeMockEntries() {
                context.insert(entry)
            }
        }

        saveIfNeeded(context)
    }

    @MainActor
    static func previewContainer() -> ModelContainer {
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)

        do {
            let container = try ModelContainer(
                for: ProteinEntry.self,
                UserProfile.self,
                configurations: configuration
            )
            ensureSeedData(in: container.mainContext)
            return container
        } catch {
            fatalError("Failed to create preview ModelContainer: \(error)")
        }
    }

    static func entries(for type: EntryType, on date: Date? = nil, from entries: [ProteinEntry]) -> [ProteinEntry] {
        let filteredByType: [ProteinEntry]

        switch type {
        case .history:
            filteredByType = entries.filter { $0.isHistory && !$0.isPlan }
        case .plan:
            filteredByType = entries.filter { $0.isPlan && !$0.isHistory }
        case .favorite:
            filteredByType = entries.filter { $0.isFavorite && !$0.isPlan && !$0.isHistory }
        }

        let filteredByDate: [ProteinEntry]
        if let date, type != .favorite {
            filteredByDate = filteredByType.filter { Calendar.current.isDate($0.timeStamp, inSameDayAs: date) }
        } else {
            filteredByDate = filteredByType
        }

        switch type {
        case .history, .favorite:
            return filteredByDate.sorted { $0.timeStamp > $1.timeStamp }
        case .plan:
            return filteredByDate.sorted { $0.timeStamp < $1.timeStamp }
        }
    }

    static func totalProtein(on date: Date, entries allEntries: [ProteinEntry]) -> Double {
        entries(for: .history, on: date, from: allEntries).reduce(0) { $0 + $1.proteinAmount }
    }

    static func stillNeededProtein(on date: Date, entries allEntries: [ProteinEntry], profile: UserProfile?) -> Double {
        let needed = (profile?.dailyGoal ?? 0) - totalProtein(on: date, entries: allEntries)
        return max(0, needed)
    }

    static func progress(on date: Date, entries allEntries: [ProteinEntry], profile: UserProfile?) -> Double {
        guard let goal = profile?.dailyGoal, goal > 0 else {
            return 0
        }

        let calculatedProgress = totalProtein(on: date, entries: allEntries) / goal
        return min(1, calculatedProgress)
    }

    static func weeklyProteinData(on date: Date = Date(), entries allEntries: [ProteinEntry]) -> [DailyProteinData] {
        let calendar = Calendar.current

        return (0..<7).reversed().compactMap { dayIndex in
            guard let loopDate = calendar.date(byAdding: .day, value: -dayIndex, to: date) else {
                return nil
            }

            return DailyProteinData(date: loopDate, totalProtein: totalProtein(on: loopDate, entries: allEntries))
        }
    }

    static func addHistoryEntry(
        proteinAmount: Double,
        foodName: String,
        description: String,
        date: Date = Date(),
        isFavorite: Bool = false,
        in context: ModelContext
    ) {
        let newEntry = ProteinEntry(
            proteinAmount: proteinAmount,
            foodName: foodName,
            entryDescription: description,
            timeStamp: date,
            isFavorite: isFavorite,
            isPlan: false,
            isHistory: true
        )
        context.insert(newEntry)
        saveIfNeeded(context)
    }

    static func addHistoryEntry(from favoriteEntry: ProteinEntry, in context: ModelContext) {
        addHistoryEntry(
            proteinAmount: favoriteEntry.proteinAmount,
            foodName: favoriteEntry.foodName,
            description: favoriteEntry.entryDescription,
            isFavorite: true,
            in: context
        )
    }

    static func addPlanEntry(
        proteinAmount: Double,
        foodName: String,
        description: String,
        date: Date,
        isFavorite: Bool = false,
        in context: ModelContext
    ) {
        let newEntry = ProteinEntry(
            proteinAmount: proteinAmount,
            foodName: foodName,
            entryDescription: description,
            timeStamp: date,
            isFavorite: isFavorite,
            isPlan: true,
            isHistory: false
        )
        context.insert(newEntry)
        saveIfNeeded(context)
    }

    static func addPlanEntry(from favoriteEntry: ProteinEntry, on date: Date, in context: ModelContext) {
        addPlanEntry(
            proteinAmount: favoriteEntry.proteinAmount,
            foodName: favoriteEntry.foodName,
            description: favoriteEntry.entryDescription,
            date: date,
            isFavorite: true,
            in: context
        )
    }

    static func addFavoriteEntry(proteinAmount: Double, foodName: String, description: String, in context: ModelContext) {
        let newEntry = ProteinEntry(
            proteinAmount: proteinAmount,
            foodName: foodName,
            entryDescription: description,
            isFavorite: true,
            isPlan: false,
            isHistory: false
        )
        context.insert(newEntry)
        saveIfNeeded(context)
    }

    static func addFavoriteEntry(from otherEntry: ProteinEntry, in context: ModelContext) {
        let existingEntries = (try? context.fetch(FetchDescriptor<ProteinEntry>())) ?? []
        let favoriteTemplateExists = existingEntries.contains {
            $0.foodName == otherEntry.foodName && $0.isFavorite && !$0.isPlan && !$0.isHistory
        }

        if !favoriteTemplateExists {
            addFavoriteEntry(
                proteinAmount: otherEntry.proteinAmount,
                foodName: otherEntry.foodName,
                description: otherEntry.entryDescription,
                in: context
            )
        }

        for entry in existingEntries where entry.foodName == otherEntry.foodName {
            entry.isFavorite = true
        }

        saveIfNeeded(context)
    }

    static func completePlan(_ entry: ProteinEntry, in context: ModelContext) {
        entry.isPlan = false
        entry.isHistory = true
        entry.timeStamp = Date()
        saveIfNeeded(context)
    }

    static func revertToPlan(_ entry: ProteinEntry, in context: ModelContext) {
        entry.isPlan = true
        entry.isHistory = false
        saveIfNeeded(context)
    }

    static func delete(_ entry: ProteinEntry, in context: ModelContext) {
        context.delete(entry)
        saveIfNeeded(context)
    }

    static func resetToMockData(in context: ModelContext) {
        let existingEntries = (try? context.fetch(FetchDescriptor<ProteinEntry>())) ?? []

        for entry in existingEntries {
            context.delete(entry)
        }

        for entry in makeMockEntries() {
            context.insert(entry)
        }

        saveIfNeeded(context)
    }

    static func saveIfNeeded(_ context: ModelContext) {
        guard context.hasChanges else {
            return
        }

        do {
            try context.save()
        } catch {
            assertionFailure("Failed to save model context: \(error)")
        }
    }

    private static func makeMockEntries() -> [ProteinEntry] {
        let today = Date()
        let calendar = Calendar.current

        let breakfastItems = [
            ("Oatmeal & Double Whey", 45.0),
            ("4 Eggs Scrambled", 50.0),
            ("Mega Yogurt Parfait", 60.3),
            ("Protein Pancakes Stack", 40.0)
        ]
        let lunchItems = [
            ("Double Chicken Salad", 60.0),
            ("Tuna Melt & Shake", 55.8),
            ("Beef Burrito XL", 55.0),
            ("Turkey Club w/ Extra Meat", 68.6)
        ]
        let dinnerItems = [
            ("Salmon Fillet (200g)", 50.7),
            ("Steak (300g)", 65.0),
            ("Tofu & Beans Stew", 55.0),
            ("Cod & Lentils", 52.0)
        ]
        let snackItems = [
            ("Large Protein Bar", 45.6),
            ("Casein Shake", 30.0),
            ("Cottage Cheese Tub", 55.0),
            ("Beef Jerky Pack", 42.7)
        ]

        let newHistoryEntries: [ProteinEntry] = (0..<7).flatMap { dayIndex -> [ProteinEntry] in
            guard let date = calendar.date(byAdding: .day, value: -dayIndex, to: today) else {
                return []
            }

            let isHighDay = Double.random(in: 0...1) < 0.7
            let targetTotal = isHighDay ? Double.random(in: 260...280) : Double.random(in: 240...260)

            var dailyEntries: [ProteinEntry] = []
            var currentTotal = 0.0
            let meals = [
                (breakfastItems, "Breakfast"),
                (lunchItems, "Lunch"),
                (dinnerItems, "Dinner")
            ]

            for (items, description) in meals {
                let item = items.randomElement()!
                dailyEntries.append(
                    ProteinEntry(
                        proteinAmount: item.1,
                        foodName: item.0,
                        entryDescription: description,
                        timeStamp: date,
                        isFavorite: false,
                        isPlan: false,
                        isHistory: true
                    )
                )
                currentTotal += item.1
            }

            var snackCount = 0
            while currentTotal < targetTotal && snackCount < 3 {
                let remaining = targetTotal - currentTotal

                if remaining < 15 {
                    if let lastEntry = dailyEntries.last {
                        lastEntry.proteinAmount += remaining
                        if !lastEntry.foodName.contains("& Side") {
                            lastEntry.foodName += " & Side"
                        }
                    }
                    currentTotal += remaining
                } else {
                    let snackItem = snackItems.randomElement()!
                    let amountToAdd = min(snackItem.1, remaining + 5)
                    dailyEntries.append(
                        ProteinEntry(
                            proteinAmount: amountToAdd,
                            foodName: snackItem.0,
                            entryDescription: "Snack",
                            timeStamp: date,
                            isFavorite: false,
                            isPlan: false,
                            isHistory: true
                        )
                    )
                    currentTotal += amountToAdd
                    snackCount += 1
                }
            }

            return dailyEntries
        }

        return newHistoryEntries + [
            ProteinEntry(
                proteinAmount: 40.2,
                foodName: "Grilled Chicken Breast",
                entryDescription: "Lunch",
                timeStamp: Date().addingTimeInterval(-10800),
                isFavorite: true,
                isPlan: false,
                isHistory: false
            ),
            ProteinEntry(
                proteinAmount: 15.0,
                foodName: "Greek Yogurt",
                entryDescription: "Snack",
                timeStamp: Date().addingTimeInterval(-18000),
                isFavorite: true,
                isPlan: false,
                isHistory: false
            ),
            ProteinEntry(
                proteinAmount: 21.0,
                foodName: "Scrambled Eggs (3)",
                entryDescription: "Breakfast",
                timeStamp: Date().addingTimeInterval(-36000),
                isFavorite: true,
                isPlan: false,
                isHistory: false
            ),
            ProteinEntry(
                proteinAmount: 30.8,
                foodName: "Salmon Fillet",
                entryDescription: "Dinner yesterday",
                timeStamp: Date().addingTimeInterval(-93600),
                isFavorite: true,
                isPlan: false,
                isHistory: false
            ),
            ProteinEntry(
                proteinAmount: 12.5,
                foodName: "Cottage Cheese",
                entryDescription: "Late night snack yesterday",
                timeStamp: Date().addingTimeInterval(-82800),
                isFavorite: true,
                isPlan: false,
                isHistory: false
            ),
            ProteinEntry(
                proteinAmount: 48.0,
                foodName: "Whey Protein Shake",
                entryDescription: "Post-workout",
                timeStamp: Date().addingTimeInterval(1800),
                isFavorite: false,
                isPlan: true,
                isHistory: false
            ),
            ProteinEntry(
                proteinAmount: 40.2,
                foodName: "Grilled Chicken Breast",
                entryDescription: "Lunch",
                timeStamp: Date().addingTimeInterval(10800),
                isFavorite: false,
                isPlan: true,
                isHistory: false
            )
        ]
    }
}
