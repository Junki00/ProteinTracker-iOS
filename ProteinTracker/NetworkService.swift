//
//  NetworkService.swift
//  ProteinTracker
//
//  Created by drx on 2025/10/21.
//

import Foundation

enum NetworkError: Error {
    case invalidURL
    case invalidSearchTerm
    case requestFailed
    var userFriendlyDescription: String {
        switch self {
        case .invalidURL, .invalidSearchTerm:
            return "There was a problem constructing the search request."
        case .requestFailed:
            return "The request to the server failed. Please check your internet connection and try again."
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

struct NetworkService {
    private func createURL (for searchTerm: String) throws -> URL {
        let baseURL = "https://world.openfoodfacts.org/cgi/search.pl"
        let trimmedSearchTerm = searchTerm.trimmingCharacters(in: .whitespacesAndNewlines)

        guard let encodedSearchTerm = trimmedSearchTerm.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            throw NetworkError.invalidSearchTerm
        }

        let urlString = "\(baseURL)?search_terms=\(encodedSearchTerm)&search_simple=1&action=process&json=1"

        guard let url = URL(string: urlString) else {
            throw NetworkError.invalidURL
        }

        return url
    }
    
    func searchFoodInfo(searchName: String) async throws -> [Product] {
        let url = try createURL(for: searchName)
        
        let request = URLRequest(url: url, timeoutInterval: 60.0)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw NetworkError.requestFailed
        }
        
        let decoder = JSONDecoder()
        let searchResponse = try decoder.decode(SearchResponse.self, from: data)
        
        return searchResponse.products
    }
    
    
    // temporary
    func testURLCreation() {
        do {
            let url = try createURL(for: " chicken breast ")
            print("✅ Successfully created a URL: \(url)")
        } catch let error as NetworkError {
            switch error {
            case .invalidURL:
                print("❌ Error: The generated URL was invalid.")
            case .invalidSearchTerm:
                print("❌ Error: The search term could not be encoded.")
            case .requestFailed:
                print("❌ Error: Request Failed")
            }
        } catch {
            print("An unexpected error occurred: \(error)")
        }
    }
}

