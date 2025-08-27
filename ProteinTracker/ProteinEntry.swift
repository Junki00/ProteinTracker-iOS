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
    var timeStamp: Date
    var isFavorite: Bool
    var isPlan: Bool
    var isHistory: Bool
    var emojiImage: String {
        if proteinAmount < 40 {
            "🥚"
        } else if proteinAmount < 80 {
            "🍗"
        } else {
            "🥩"
        }
    }
    
    init(id: UUID = UUID(), proteinAmount: Double, foodName: String, description: String, timeStamp: Date = Date(), isFavorite: Bool, isPlan: Bool, isHistory: Bool) {
        self.id = id
        self.proteinAmount = proteinAmount
        self.foodName = foodName
        self.description = description
        self.timeStamp = timeStamp
        self.isFavorite = isFavorite
        self.isPlan = isPlan
        self.isHistory = isHistory
    }
}
