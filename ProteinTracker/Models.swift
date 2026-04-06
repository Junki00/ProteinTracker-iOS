//
//  Models.swift
//  ProteinTracker
//
//  Created by drx on 2025/07/25.
//

import Foundation
import SwiftData

enum EntryType {
    case history, favorite
}

@Model
final class ProteinEntry {
    @Attribute(.unique) var id: UUID
    var proteinAmount: Double
    var foodName: String
    var entryDescription: String
    var timeStamp: Date
    var isFavorite: Bool
    var isHistory: Bool
    var customEmoji: String?

    var emojiImage: String {
        if let customEmoji, !customEmoji.isEmpty {
            return customEmoji
        }
        
        return "🍽️"
    }

    init(
        id: UUID = UUID(),
        proteinAmount: Double,
        foodName: String,
        entryDescription: String,
        timeStamp: Date = Date(),
        isFavorite: Bool,
        isHistory: Bool,
        customEmoji: String? = nil
    ) {
        self.id = id
        self.proteinAmount = proteinAmount
        self.foodName = foodName
        self.entryDescription = entryDescription
        self.timeStamp = timeStamp
        self.isFavorite = isFavorite
        self.isHistory = isHistory
        self.customEmoji = customEmoji
    }
}

@Model
final class UserProfile {
    @Attribute(.unique) var id: UUID
    var userName: String = "User"
    var userWeight: Double = 120
    var proteinMultiplier: Double = 2.2

    init(id: UUID = UUID(), userName: String = "User", userWeight: Double = 120, proteinMultiplier: Double = 2.2) {
        self.id = id
        self.userName = userName
        self.userWeight = userWeight
        self.proteinMultiplier = proteinMultiplier
    }

    var dailyGoal: Double {
        userWeight * proteinMultiplier
    }
}

struct DailyProteinData: Identifiable {
    let date: Date
    let totalProtein: Double
    var id: Date { date }
}
