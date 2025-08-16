//
//  EditEntryView.swift
//  ProteinTracker
//
//  Created by drx on 2025/08/06.
//

import SwiftUI

struct EditEntryView: View {
        
    @EnvironmentObject var entries: ProteinDataViewModel
    @Environment(\.dismiss) var dismiss
    let entry: ProteinEntry
    
    @State private var proteinAmount: String
    @State private var foodName: String
    @State private var description: String
    
    private var isSaveValid: Bool {
        if let amount = Double(proteinAmount) {
            return amount > 0
        } else {
            return false
        }
    }

    init(entry: ProteinEntry) {
        self.entry = entry
        
        _proteinAmount = State(initialValue: String(format: "%.1f", entry.proteinAmount))
        _foodName = State(initialValue: entry.foodName)
        _description = State(initialValue: entry.description)
    }
    
    var body: some View {
        VStack(spacing: 20) {
            TextField("Protein Amount", text: $proteinAmount)
                        
            TextField("Food Name", text: $foodName)

            ZStack {
                TextEditor(text: $description)
                if description.isEmpty {
                    Text("Description (optional)")
                        .foregroundColor(.gray.opacity(0.7))
                        .padding(5)
                        .allowsHitTesting(false)
                }
            }
        }
        .textFieldStyle(.roundedBorder)
        .padding(.horizontal)
        .tint(.appPrimary)
        

        
        Spacer()
            .frame(height: 20)
        
        Button( action: {
            guard let amount = Double(proteinAmount), amount > 0 else {
                print("Invalid Protein Amount.")
                return
            }
            entries.changeEntry(uuid: entry.id, proteinAmount: amount, foodName: foodName, description: description)
            dismiss()
        } ) {
            Text("Save")
                .foregroundColor(.white)
                .font(.headline)
                .padding()
                .frame(maxWidth: .infinity)
                .background(RoundedRectangle(cornerRadius: 5).fill(Color.appPrimary))
        }
        .disabled(!isSaveValid)
    }
}

#Preview {
    EditEntryView(entry: ProteinDataViewModel().entries[5])
}
