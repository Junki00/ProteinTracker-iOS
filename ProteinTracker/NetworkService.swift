//
//  NetworkService.swift
//  ProteinTracker
//
//  Created by drx on 2025/10/21.
//

import Foundation

enum NetworkError: LocalizedError {
    case invalidSearchTerm
    case invalidURL(components: String)
    case httpError(statusCode: Int)
    case decodingFailed(underlying: Error)
    case noConnection(underlying: Error)

    var errorDescription: String? {
        switch self {
        case .invalidSearchTerm, .invalidURL:
            return String(localized: "network.constructionError")
        case .httpError, .decodingFailed, .noConnection:
            return String(localized: "network.requestFailed")
        }
    }
}

struct SearchResponse: Codable {
    let products: [Product]
}

struct Product: Codable, Identifiable {
    let productName: String?
    let nutriments: Nutriments
    var id: String { productName ?? UUID().uuidString }
    var proteinValue: Double {
        nutriments.proteins100g ?? 0.0
    }
    enum CodingKeys: String, CodingKey {
        case productName = "product_name"
        case nutriments
    }
}

struct Nutriments: Codable {
    let proteins100g: Double?
    enum CodingKeys: String, CodingKey {
        case proteins100g = "proteins_100g"
    }
}

/// Abstraction for food search functionality, enabling dependency injection and testing.
protocol FoodSearchService: Sendable {
    func searchFoodInfo(searchName: String) async throws -> [Product]
}

struct NetworkService: FoodSearchService {
    private static let baseURL = "https://world.openfoodfacts.org/cgi/search.pl"
    private static let timeoutInterval: TimeInterval = 30

    private func createURL(for searchTerm: String) throws -> URL {
        let trimmed = searchTerm.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { throw NetworkError.invalidSearchTerm }

        var components = URLComponents(string: Self.baseURL)
        components?.queryItems = [
            URLQueryItem(name: "search_terms", value: trimmed),
            URLQueryItem(name: "search_simple", value: "1"),
            URLQueryItem(name: "action", value: "process"),
            URLQueryItem(name: "json", value: "1"),
        ]

        guard let url = components?.url else {
            throw NetworkError.invalidURL(components: components?.string ?? "nil")
        }

        return url
    }

    func searchFoodInfo(searchName: String) async throws -> [Product] {
        let url = try createURL(for: searchName)

        var request = URLRequest(url: url, timeoutInterval: Self.timeoutInterval)
        request.setValue("ProteinTracker/1.0", forHTTPHeaderField: "User-Agent")

        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await URLSession.shared.data(for: request)
        } catch let error as URLError where error.code == .notConnectedToInternet
            || error.code == .networkConnectionLost {
            throw NetworkError.noConnection(underlying: error)
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.httpError(statusCode: -1)
        }
        guard httpResponse.statusCode == 200 else {
            throw NetworkError.httpError(statusCode: httpResponse.statusCode)
        }

        do {
            return try JSONDecoder().decode(SearchResponse.self, from: data).products
        } catch {
            throw NetworkError.decodingFailed(underlying: error)
        }
    }
}


