//
//  BrandButtonStyle.swift
//  ProteinTracker
//
//  Created by drx on 2025/12/25.
//

import SwiftUI

struct BigButtonStyle: ButtonStyle {
    var backgroundColor: Color = .appPrimaryColor
    var disabledColor: Color = .appSecondaryTextColor.opacity(0.3)
    var isEnabled: Bool = true

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .bold()
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                isEnabled ? backgroundColor : disabledColor
            )
            .cornerRadius(16)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.spring(), value: configuration.isPressed)
    }
}

extension ButtonStyle where Self == BigButtonStyle {
    static func bigAction(isEnabled: Bool = true, color: Color = .appPrimary) -> BigButtonStyle {
        BigButtonStyle(backgroundColor: color, isEnabled: isEnabled)
    }
}
