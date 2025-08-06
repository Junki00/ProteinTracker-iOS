//
//  EditEntryView.swift
//  ProteinTracker
//
//  Created by drx on 2025/08/06.
//

import SwiftUI

struct EditEntryView: View {
    
    let entry: ProteinEntry
    
    var body: some View {
        
        
        //TextField to Change
        
        
        Text("Protein Amount")
            .font(.subheadline)
            .foregroundColor(.primaryText)
        
        Text(String(format: "%.1f", entry.proteinAmount) + " Grams") // what is wrong...
            .font(.headline)
            .foregroundColor(.secondaryText)
        
        Spacer()
            .frame(height: 20)
        
        Text("Food Name")
            .font(.subheadline)
            .foregroundColor(.primaryText)
        
        Text(entry.foodName)
            .font(.headline)
            .foregroundColor(.secondaryText)
        
        Spacer()
            .frame(height: 20)
        
        Text("Description")
            .font(.subheadline)
            .foregroundColor(.primaryText)
        
        Text(entry.description)
            .font(.headline)
            .foregroundColor(.secondaryText)
        
        Spacer()
            .frame(height: 20)
        
        Button( action: {print("Save Tapped")} ) {
            Text("Save")
                .foregroundColor(.white)
                .font(.headline)
                .padding()
                .frame(maxWidth: .infinity)
                .background(RoundedRectangle(cornerRadius: 5).fill(Color.appPrimary))
        }
        
    }
}

#Preview {
    EditEntryView(entry: ProteinDataViewModel().entries[5])
}
