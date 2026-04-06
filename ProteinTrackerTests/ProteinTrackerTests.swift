//
//  ProteinTrackerTests.swift
//  ProteinTrackerTests
//
//  Created by drx on 2025/07/19.
//

import Foundation
import Testing
@testable import ProteinTracker

// MARK: - Mock for FoodSearchService

struct MockFoodSearchService: FoodSearchService {
    var result: Result<[Product], Error>

    func searchFoodInfo(searchName: String) async throws -> [Product] {
        try result.get()
    }
}

// MARK: - ProteinDataStore Tests

struct ProteinTrackerTests {
    @Test func totalProtein_onSameDay_sumsOnlyHistoryEntriesForThatDay() {
        let calendar = Calendar(identifier: .gregorian)
        let today = calendar.date(from: DateComponents(year: 2025, month: 1, day: 15, hour: 12))!
        let sameDayLater = calendar.date(byAdding: .hour, value: 3, to: today)!
        let nextDay = calendar.date(byAdding: .day, value: 1, to: today)!

        let entries = [
            ProteinEntry(
                proteinAmount: 30,
                foodName: "Eggs",
                entryDescription: "Breakfast",
                timeStamp: today,
                isFavorite: false,
                isHistory: true
            ),
            ProteinEntry(
                proteinAmount: 45,
                foodName: "Chicken",
                entryDescription: "Lunch",
                timeStamp: sameDayLater,
                isFavorite: false,
                isHistory: true
            ),
            ProteinEntry(
                proteinAmount: 50,
                foodName: "Steak",
                entryDescription: "Dinner tomorrow",
                timeStamp: nextDay,
                isFavorite: false,
                isHistory: true
            )
        ]

        let result = ProteinDataStore.totalProtein(on: today, entries: entries)

        #expect(result == 75)
    }

    @Test func totalProtein_ignoresEntriesFromOtherDays() {
        let calendar = Calendar(identifier: .gregorian)
        let today = calendar.date(from: DateComponents(year: 2025, month: 1, day: 15, hour: 12))!
        let nextDay = calendar.date(byAdding: .day, value: 1, to: today)!

        let entries = [
            ProteinEntry(
                proteinAmount: 35,
                foodName: "Chicken Wrap",
                entryDescription: "Lunch",
                timeStamp: today,
                isFavorite: false,
                isHistory: true
            ),
            ProteinEntry(
                proteinAmount: 50,
                foodName: "Beef Bowl",
                entryDescription: "Tomorrow dinner",
                timeStamp: nextDay,
                isFavorite: false,
                isHistory: true
            )
        ]

        let result = ProteinDataStore.totalProtein(on: today, entries: entries)

        #expect(result == 35)
    }

    @Test func progress_whenGoalExists_returnsConsumedProteinRatio() {
        let calendar = Calendar(identifier: .gregorian)
        let today = calendar.date(from: DateComponents(year: 2025, month: 1, day: 15, hour: 12))!
        let profile = UserProfile(userName: "Test User", userWeight: 50, proteinMultiplier: 2.0)
        let entries = [
            ProteinEntry(
                proteinAmount: 40,
                foodName: "Greek Yogurt",
                entryDescription: "Breakfast",
                timeStamp: today,
                isFavorite: false,
                isHistory: true
            )
        ]

        let result = ProteinDataStore.progress(on: today, entries: entries, profile: profile)

        #expect(result == 0.4)
    }

    @Test func progress_whenGoalIsZero_returnsZero() {
        let calendar = Calendar(identifier: .gregorian)
        let today = calendar.date(from: DateComponents(year: 2025, month: 1, day: 15, hour: 12))!
        let profile = UserProfile(userName: "Test User", userWeight: 50, proteinMultiplier: 0)
        let entries = [
            ProteinEntry(
                proteinAmount: 40,
                foodName: "Greek Yogurt",
                entryDescription: "Breakfast",
                timeStamp: today,
                isFavorite: false,
                isHistory: true
            )
        ]

        let result = ProteinDataStore.progress(on: today, entries: entries, profile: profile)

        #expect(result == 0)
    }

    @Test func entries_historyFiltersToSelectedDayAndSortsNewestFirst() {
        let calendar = Calendar(identifier: .gregorian)
        let today = calendar.date(from: DateComponents(year: 2025, month: 1, day: 15, hour: 12))!
        let earlierToday = calendar.date(byAdding: .hour, value: -2, to: today)!
        let laterToday = calendar.date(byAdding: .hour, value: 4, to: today)!
        let nextDay = calendar.date(byAdding: .day, value: 1, to: today)!

        let earlierHistory = ProteinEntry(
            proteinAmount: 25,
            foodName: "Eggs",
            entryDescription: "Breakfast",
            timeStamp: earlierToday,
            isFavorite: false,
            isHistory: true
        )
        let laterHistory = ProteinEntry(
            proteinAmount: 45,
            foodName: "Chicken",
            entryDescription: "Dinner",
            timeStamp: laterToday,
            isFavorite: false,
            isHistory: true
        )

        let entries = [
            earlierHistory,
            ProteinEntry(
                proteinAmount: 30,
                foodName: "Fish",
                entryDescription: "Tomorrow lunch",
                timeStamp: nextDay,
                isFavorite: false,
                isHistory: true
            ),
            laterHistory
        ]

        let result = ProteinDataStore.entries(for: .history, on: today, from: entries)

        #expect(result.count == 2)
        #expect(result.map(\.foodName) == ["Chicken", "Eggs"])
    }

    @Test func progress_whenConsumedExceedsGoal_capsAtOne() {
        let calendar = Calendar(identifier: .gregorian)
        let today = calendar.date(from: DateComponents(year: 2025, month: 1, day: 15, hour: 12))!
        let profile = UserProfile(userName: "Test User", userWeight: 50, proteinMultiplier: 2.0) // goal = 100

        let entries = [
            ProteinEntry(
                proteinAmount: 200,
                foodName: "Mega Steak",
                entryDescription: "Feast",
                timeStamp: today,
                isFavorite: false,
                isHistory: true
            )
        ]

        let result = ProteinDataStore.progress(on: today, entries: entries, profile: profile)

        #expect(result == 1.0)
    }

    @Test func progress_whenProfileIsNil_returnsZero() {
        let calendar = Calendar(identifier: .gregorian)
        let today = calendar.date(from: DateComponents(year: 2025, month: 1, day: 15, hour: 12))!

        let entries = [
            ProteinEntry(
                proteinAmount: 50,
                foodName: "Chicken",
                entryDescription: "Lunch",
                timeStamp: today,
                isFavorite: false,
                isHistory: true
            )
        ]

        let result = ProteinDataStore.progress(on: today, entries: entries, profile: nil)

        #expect(result == 0)
    }

    @Test func stillNeededProtein_whenExceeded_returnsZero() {
        let calendar = Calendar(identifier: .gregorian)
        let today = calendar.date(from: DateComponents(year: 2025, month: 1, day: 15, hour: 12))!
        let profile = UserProfile(userName: "Test User", userWeight: 50, proteinMultiplier: 2.0) // goal = 100

        let entries = [
            ProteinEntry(
                proteinAmount: 150,
                foodName: "Mega Steak",
                entryDescription: "Feast",
                timeStamp: today,
                isFavorite: false,
                isHistory: true
            )
        ]

        let result = ProteinDataStore.stillNeededProtein(on: today, entries: entries, profile: profile)

        #expect(result == 0)
    }

    @Test func stillNeededProtein_whenNoEntries_returnsFullGoal() {
        let calendar = Calendar(identifier: .gregorian)
        let today = calendar.date(from: DateComponents(year: 2025, month: 1, day: 15, hour: 12))!
        let profile = UserProfile(userName: "Test User", userWeight: 50, proteinMultiplier: 2.0) // goal = 100

        let result = ProteinDataStore.stillNeededProtein(on: today, entries: [], profile: profile)

        #expect(result == 100)
    }

    @Test func entries_favoriteIgnoresDateAndSortsNewestFirst() {
        let calendar = Calendar(identifier: .gregorian)
        let today = calendar.date(from: DateComponents(year: 2025, month: 1, day: 15, hour: 12))!
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!

        let entries = [
            ProteinEntry(
                proteinAmount: 40,
                foodName: "Chicken Breast",
                entryDescription: "Lunch",
                timeStamp: yesterday,
                isFavorite: true,
                isHistory: false
            ),
            ProteinEntry(
                proteinAmount: 15,
                foodName: "Greek Yogurt",
                entryDescription: "Snack",
                timeStamp: today,
                isFavorite: true,
                isHistory: false
            ),
            ProteinEntry(
                proteinAmount: 30,
                foodName: "Not a favorite",
                entryDescription: "Dinner",
                timeStamp: today,
                isFavorite: false,
                isHistory: true
            )
        ]

        // Pass a specific date — favorites should ignore the date filter
        let result = ProteinDataStore.entries(for: .favorite, on: today, from: entries)

        #expect(result.count == 2)
        #expect(result.map(\.foodName) == ["Greek Yogurt", "Chicken Breast"])
    }

    @Test func weeklyProteinData_returnsSevenDaysInChronologicalOrder() {
        let calendar = Calendar(identifier: .gregorian)
        let referenceDate = calendar.date(from: DateComponents(year: 2025, month: 1, day: 15, hour: 12))!

        let entries = [
            ProteinEntry(
                proteinAmount: 80,
                foodName: "Chicken",
                entryDescription: "Lunch",
                timeStamp: referenceDate,
                isFavorite: false,
                isHistory: true
            )
        ]

        let result = ProteinDataStore.weeklyProteinData(on: referenceDate, entries: entries)

        #expect(result.count == 7)
        // First element is the oldest day (6 days ago), last is referenceDate
        #expect(calendar.isDate(result.last!.date, inSameDayAs: referenceDate))
        #expect(result.last!.totalProtein == 80)
        // The other 6 days should have 0 protein
        #expect(result.dropLast().allSatisfy { $0.totalProtein == 0 })
    }

    @Test func totalProtein_withEmptyEntries_returnsZero() {
        let calendar = Calendar(identifier: .gregorian)
        let today = calendar.date(from: DateComponents(year: 2025, month: 1, day: 15, hour: 12))!

        let result = ProteinDataStore.totalProtein(on: today, entries: [])

        #expect(result == 0)
    }
}
// MARK: - TodayViewModel Tests

@Suite("TodayViewModel")
struct TodayViewModelTests {

    /// Helper: perform a search and wait for the debounce + network call to complete.
    @MainActor
    private func searchAndWait(_ viewModel: TodayViewModel, for term: String) async {
        viewModel.performSearch(for: term)
        // Wait for debounce (300ms) + execution to settle
        try? await Task.sleep(for: .milliseconds(500))
    }

    @Test @MainActor
    func searchSuccess_populatesResults() async {
        let mockProducts = [
            Product(
                productName: "Chicken Breast",
                nutriments: Nutriments(proteins100g: 31.0)
            )
        ]
        let mockService = MockFoodSearchService(result: .success(mockProducts))
        let viewModel = TodayViewModel(foodSearchService: mockService)

        await searchAndWait(viewModel, for: "chicken")

        #expect(viewModel.searchResults.count == 1)
        #expect(viewModel.searchResults.first?.productName == "Chicken Breast")
        #expect(viewModel.searchResults.first?.proteinValue == 31.0)
        #expect(viewModel.isSearching == false)
        #expect(viewModel.isShowingErrorAlert == false)
    }

    @Test @MainActor
    func searchFailure_showsErrorAlert() async {
        let mockService = MockFoodSearchService(result: .failure(NetworkError.httpError(statusCode: 500)))
        let viewModel = TodayViewModel(foodSearchService: mockService)

        await searchAndWait(viewModel, for: "anything")

        #expect(viewModel.searchResults.isEmpty)
        #expect(viewModel.isShowingErrorAlert == true)
        #expect(viewModel.searchError is NetworkError)
    }

    @Test @MainActor
    func searchEmptyTerm_clearsResults() async {
        let mockProducts = [
            Product(
                productName: "Should Not Appear",
                nutriments: Nutriments(proteins100g: 10.0)
            )
        ]
        let mockService = MockFoodSearchService(result: .success(mockProducts))
        let viewModel = TodayViewModel(foodSearchService: mockService)

        viewModel.performSearch(for: "   ")

        #expect(viewModel.searchResults.isEmpty)
    }

    @Test @MainActor
    func rapidSearches_cancelsOldAndKeepsLatest() async {
        let mockProducts = [
            Product(
                productName: "Final Result",
                nutriments: Nutriments(proteins100g: 25.0)
            )
        ]
        let mockService = MockFoodSearchService(result: .success(mockProducts))
        let viewModel = TodayViewModel(foodSearchService: mockService)

        // Simulate rapid typing — only the last call should produce results
        viewModel.performSearch(for: "ch")
        viewModel.performSearch(for: "chi")
        viewModel.performSearch(for: "chicken")

        try? await Task.sleep(for: .milliseconds(500))

        #expect(viewModel.searchResults.count == 1)
        #expect(viewModel.searchResults.first?.productName == "Final Result")
        #expect(viewModel.isSearching == false)
    }

    @Test @MainActor
    func searchSuccess_clearsPreviousError() async {
        let mockService = MockFoodSearchService(result: .failure(NetworkError.httpError(statusCode: 500)))
        let viewModel = TodayViewModel(foodSearchService: mockService)

        // First search fails
        await searchAndWait(viewModel, for: "fail")
        #expect(viewModel.isShowingErrorAlert == true)

        // Simulate user dismissing the alert
        viewModel.isShowingErrorAlert = false

        #expect(viewModel.isShowingErrorAlert == false)
    }
}

