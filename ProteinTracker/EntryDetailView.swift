//
//  EntryDetailView.swift
//  ProteinTracker
//
//  Created by drx on 2025/08/04.
//

import SwiftUI

struct EntryDetailView: View {
    
    // @Binding var entry: ProteinEntry
    let entry: ProteinEntry
    
    @EnvironmentObject var viewModel: ProteinDataViewModel
    // @Environment(\.dismiss) var dismiss
    
    @State var proteinAmount: String = ""
    @State var foodName: String = ""
    @State var description: String = ""
    @State var isEditValid: Bool = false
    
    var isDataValid: Bool {
        if let amount = Double(proteinAmount) {
            return amount >= 0
        }
        return false
    }
        
    var body: some View {
        VStack(spacing: 20) {
            Text(entry.emojiImage)
                .font(.system(size: 200))
            VStack(alignment: .leading, spacing: 20) {
                
                if isEditValid {
                    
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Protein Amount")
                            .font(.subheadline)
                            .foregroundColor(.primaryText)
                        TextField ("Protein (grams)", text: $proteinAmount).keyboardType(.decimalPad)
                        
                        Text("Food Name")
                            .font(.subheadline)
                            .foregroundColor(.primaryText)
                        TextField ("Name (e.g., Whey Protein Powder)", text: $foodName)
                        
                        Text("Description")
                            .font(.subheadline)
                            .foregroundColor(.primaryText)
                        ZStack(alignment: .topLeading) {
                            TextEditor(text: $description)

                            if description.isEmpty {
                                Text("What's about this food...")
                                    .foregroundColor(.gray.opacity(0.7))
                                    .padding(.top, 8)
                                    .padding(.leading, 5)
                            }
                        }
                        .frame(minHeight: 100)
                        .padding(4)
                        .background(RoundedRectangle(cornerRadius: 8).fill(Color.white))
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.4), lineWidth: 1))
                    }
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal)
                    .tint(Color.appPrimary)
                } else {
                    detailRow(item: "Protein Amount", is: "\(String(format: "%.1f", entry.proteinAmount)) Grams")
                    
                    detailRow(item: "Food Name", is: entry.foodName)
                    
                    detailRow(item: "Description", is: entry.description)
                }
                
                // Manually editting time is forbidden
                detailRow(item: "Adding Time", is: entry.timeStamp.formattedRelativeString())
                
                Spacer().frame(height: 20)
                
                // Do Later
                Button( action: {
                    
                    
                    print("Add Tapped")
                    
                    
                    
                } ) {
                    HStack {
                        Text("Add to / Delete from Favorites")
                        Image(systemName: "star")
                    }
                    .foregroundColor(.white)
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(RoundedRectangle(cornerRadius: 5).fill(Color.appPrimary))
                }
            }
            .padding()
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                
                
                if isEditValid {
                    Button("Done") {
                        guard let amount = Double(proteinAmount) else { return }
                        viewModel.changeEntry(uuid: entry.id, proteinAmount: amount, foodName: foodName, description: description)
                        
                        isEditValid = false
                    }
                    .disabled(!isDataValid)
                } else {
                    Button("Edit") {
                        proteinAmount = String(format: "%.1f", entry.proteinAmount)
                        foodName = entry.foodName
                        description = entry.description
                        isEditValid = true
                    }
                }
            }
        }
    }
        // Helper Methods
    @ViewBuilder
    private func detailRow(item: String, is itemDetail: String) -> some View {
        VStack(alignment: .leading) {
            Text(item)
                .font(.subheadline)
                .foregroundColor(.primaryText)
            
            Text(itemDetail)
                .font(.headline)
                .foregroundColor(.secondaryText)
        }
        .font(.body)
    }
}
    
#Preview {
    NavigationView {
        EntryDetailView(entry: ProteinDataViewModel().entries[5])
            .environmentObject(ProteinDataViewModel())
    }
}
