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
    
    init(id: UUID = UUID(), proteinAmount: Double, foodName: String, description: String, addTime: Date = Date()) {
        self.id = id
        self.proteinAmount = proteinAmount
        self.foodName = foodName
        self.description = description
        self.addTime = addTime
    }
    
    
}
