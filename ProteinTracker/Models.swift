//
//  Models.swift
//  ProteinTracker
//
//  Created by drx on 2025/07/25.
//

import Foundation

enum EntryType {
    case history, plan, favorite
}

struct ProteinEntry: Identifiable, Codable, Equatable {
    let id: UUID
    
    var proteinAmount: Double
    var foodName: String
    var description: String
    var timeStamp: Date
    var isFavorite: Bool
    var isPlan: Bool
    var isHistory: Bool
    var emojiImage: String {
        if proteinAmount < 20 {
            "😳"
        } else if proteinAmount < 50 {
            "🥰"
        } else {
            "🤩"
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

struct UserProfile: Codable {
    var userName: String = "User"
    var userWeight: Double = 120
    var proteinMultiplier: Double = 2.2
    var dailyGoal: Double {
        userWeight * proteinMultiplier
    }
}

struct DailyProteinData: Identifiable {
    let date: Date
    let totalProtein: Double
    var id: Date { date }
}

struct AppData: Codable {
    let entries: [ProteinEntry]
    let profile: UserProfile
}
