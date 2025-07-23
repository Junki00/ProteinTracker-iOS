//
//  PlanCard.swift
//  ProteinTracker
//
//  Created by drx on 2025/07/23.
//

import SwiftUI

struct PlanCard: View {
    var body: some View {
        VStack (alignment: .leading, spacing: 10 ) {
            Text("Today's Plan")
                .font(.subheadline)
                .bold()
            
            Text("🌍 You’ve already planned 232.5g, still need extra 8.0 grams.")
                .font(.subheadline)
            
            PlanEntryRowView()
            PlanEntryRowView()
            PlanEntryRowView()
            
            
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 12).fill(Color.appBackground).shadow(color: .primaryText.opacity(0.5), radius: 2, x: 0, y: 2))
    }
}

#Preview {
    PlanCard()
}
