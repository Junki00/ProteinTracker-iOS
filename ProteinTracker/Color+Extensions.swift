//
//  Color+Extensions.swift
//  ProteinTracker
//
//  Created by drx on 2025/07/20.
//

import SwiftUI

extension Color {
    // Old
//    // MARK: - Brand Colors
//    static let appPrimaryColorTemp = Color(hex: "#EB5978")
//    static let appSecondary = Color(hex: "#FBF0F2")
//    static let appBackgroundColorTemp = Color(hex: "#FFFFFF")
//    
//    // MARK: - Text Colors
//    static let primaryText = Color(hex: "#2C2C2E")
//    static let secondaryText = Color(hex: "#676769")
//    static let shallowText = Color(hex: "#FFFFFF")
//    
//    // MARK: - Apple Colors
//    static let secondaryBackground = Color(hex: "#F2F2F7")

    
    // New
    // MARK: - Brand Colors
    /// 主色调：按钮、图标、进度条、重点文字
    static let appPrimaryColor = Color("AppPrimaryColor")
    
    /// 辅助色：次要按钮背景、未选中图表柱子
    static let appAccentColor = Color("AppAccent")
    
    // MARK: - Background Colors (Hierarchy)
    /// Level 1: 最底层，用于 ScrollView/ZStack 底色
    static let appBackgroundColor = Color("AppBackgroundColor")
    
    /// Level 2: 大容器，用于 "Still Need" 等大板块的背景
    static let appCardBackgroundColor = Color("AppCardBackground")
    
    /// Level 3: 子项，用于 EntryRow 列表条目的背景
    static let appSubCardBackgroundColor = Color("AppSubCardBackground")
    
    // MARK: - Text Colors
    /// 一级文字：标题、正文
    static let appPrimaryTextColor = Color("AppPrimaryText")
    
    /// 二级文字：副标题、说明、单位
    static let appSecondaryTextColor = Color("AppSecondaryText")
    
    
    
    
    
    
    
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
    
