//
//  AddEntryModalView.swift
//  ProteinTracker
//
//  Created by drx on 2025/07/21.
//

import SwiftUI

struct AddEntryModalView: View {
    
    @EnvironmentObject var viewModel: ProteinDataViewModel
    @Environment(\.dismiss) var dismiss
    
    var date: Date
    
    @State private var proteinAmount: String
    @State private var foodName: String
    @State private var description: String
    @State private var selection: EntryType = .favorite
    
    private var isFormValid: Bool {
        Double(proteinAmount) != nil
    }
    
    init(product: Product? = nil, date: Date) {
        if let product = product {
            _proteinAmount = State(initialValue: "\(product.proteinValue)")
            _foodName = State(initialValue: product.productName ?? "")
            _description = State(initialValue: "")
        } else {
            _proteinAmount = State(initialValue: "")
            _foodName = State(initialValue: "")
            _description = State(initialValue: "")
        }

        self.date = date
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    HStack {
                        Button (action: {
                            dismiss()
                        }) {
                            Text("Cancel")
                        }
                        Spacer()
                        Text("Fast Add or Pick Below")
                            .font(.headline)
                        Spacer()
                        Button (action: {
                            if let amount = Double(proteinAmount) {
                                let finalFoodName: String
                                if foodName.isEmpty {
                                    let formatter = DateFormatter()
                                    formatter.dateFormat = "HH:mm"
                                    let timeString = formatter.string(from: Date())
                                    finalFoodName = "Quick Add at \(timeString)"
                                } else {
                                    finalFoodName = foodName
                                }
                                
                                viewModel.addHistoryEntry(proteinAmount: amount, foodName: finalFoodName, description: description)
                            }
                            dismiss()
                        }) {
                            Text("Add")
                                .bold()
                                .foregroundColor(isFormValid ? .appPrimary : .gray)
                        }
                        .disabled(!isFormValid)
                    }
                    .padding()
                    .font(.body)
                    .tint(Color.appPrimary)
                    
                    
                    VStack(spacing: 16) {
                        TextField ("Protein (grams)", text: $proteinAmount).keyboardType(.decimalPad)
                        
                        TextField ("Name (e.g., Whey Protein Powder)", text: $foodName)
                        
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
                    
                    Picker("Selection", selection: $selection) {
                        Text("Planned").tag(EntryType.plan)
                        Text("Favorites").tag(EntryType.favorite)
                    }
                    .pickerStyle(.segmented)
                    .padding()
                    
                    switch selection {
                    case .plan:
                        EntryCardView(type: .plan, date: date).padding()
                    case .favorite:
                        EntryCardView(type: .favorite, date: date).padding()
                    case .history:
                        EntryCardView(type: .history, date: date).padding()
                    }
                    
                }
            }
            .background(Color.secondaryBackground)
            .presentationDetents([.fraction(0.62), .large])
        }
    }
}

#Preview {
    AddEntryModalView(date: Date())
        .environmentObject(ProteinDataViewModel())
}
