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

    /// Runs a single submitted search request and updates the screen state.
    func performSearch(for term: String) {
        let trimmed = term.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            searchResults = []
            searchError = NetworkError.invalidSearchTerm
            isShowingErrorAlert = true
            return
        }

        Task {
            isSearching = true
            defer { isSearching = false }

            do {
                let results = try await foodSearchService.searchFoodInfo(searchName: trimmed)
                searchResults = results
            } catch {
                searchError = error
                isShowingErrorAlert = true
            }
        }
    }
}
