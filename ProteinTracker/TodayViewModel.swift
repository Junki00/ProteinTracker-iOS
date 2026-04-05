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

    // MARK: - Private

    private var currentSearchTask: Task<Void, Never>?

    // MARK: - Init (Dependency Injection)

    nonisolated init(foodSearchService: FoodSearchService = NetworkService()) {
        self.foodSearchService = foodSearchService
    }

    // MARK: - Actions

    /// Cancels any in-flight search and starts a new one after a short debounce.
    func performSearch(for term: String) {
        currentSearchTask?.cancel()

        let trimmed = term.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            searchResults = []
            return
        }

        currentSearchTask = Task {
            // Debounce: wait 300ms before firing the request.
            // If the user types another character, this task is cancelled.
            try? await Task.sleep(for: .milliseconds(300))
            guard !Task.isCancelled else { return }

            isSearching = true
            defer { isSearching = false }

            do {
                let results = try await foodSearchService.searchFoodInfo(searchName: trimmed)
                // Check cancellation after the network call returns
                guard !Task.isCancelled else { return }
                searchResults = results
            } catch is CancellationError {
                // Task was cancelled — ignore silently
            } catch {
                guard !Task.isCancelled else { return }
                searchError = error
                isShowingErrorAlert = true
            }
        }
    }
}
