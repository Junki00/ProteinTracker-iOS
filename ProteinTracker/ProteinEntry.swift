//
//  ProteinEntry.swift
//  ProteinTracker
//
//  Created by drx on 2025/07/25.
//

import Foundation

struct ProteinEntry: Identifiable, Codable {
    let id: UUID
    
    var proteinAmount: Double
    var foodName: String
    var description: String
    var addTime: Date
    var isFavorite: Bool
    var isPlan: Bool
    var isTakenIn: Bool
    var emojiImage: String {
        if proteinAmount < 40 {
            "🥚"
        } else if proteinAmount < 80 {
            "🍗"
        } else {
            "🥩"
        }
    }
    
    init(id: UUID = UUID(), proteinAmount: Double, foodName: String, description: String, addTime: Date = Date()) {
        self.id = id
        self.proteinAmount = proteinAmount
        self.foodName = foodName
        self.description = description
        self.addTime = addTime
        self.isFavorite = false
        self.isPlan = false
        self.isTakenIn = true
    }
}
