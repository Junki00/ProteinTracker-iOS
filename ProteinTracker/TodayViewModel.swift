//
//  TodayViewModel.swift
//  ProteinTracker
//

import Foundation
import Observation

@Observable
@MainActor
final class TodayViewModel {
    // MARK: - Dependencies

    private let foodSearchService: FoodSearchService

    // MARK: - Published State

    var searchResults: [Product] = []
    var isSearching = false
    var searchError: Error?
    var isShowingErrorAlert = false

    // MARK: - Init (Dependency Injection)

    nonisolated init(foodSearchService: FoodSearchService = NetworkService()) {
        self.foodSearchService = foodSearchService
    }

    // MARK: - Actions

    func performSearch(for term: String) async {
        let trimmed = term.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        isSearching = true
        defer { isSearching = false }

        do {
            searchResults = try await foodSearchService.searchFoodInfo(searchName: trimmed)
        } catch {
            searchError = error
            isShowingErrorAlert = true
        }
    }
}
