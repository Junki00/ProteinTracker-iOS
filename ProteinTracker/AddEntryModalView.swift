//
//  AddEntryModalView.swift
//  ProteinTracker
//
//  Created by drx on 2025/07/21.
//

import SwiftData
import SwiftUI

struct AddEntryModalView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) var dismiss
    
    var date: Date
    
    @State private var proteinAmount: String
    @State private var foodName: String
    @FocusState private var isInputFocused: Bool
    
    private var isFormValid: Bool {
        Double(proteinAmount) != nil
    }
    
    init(product: Product? = nil, date: Date) {
        if let product = product {
            _proteinAmount = State(initialValue: "\(product.proteinValue)")
            _foodName = State(initialValue: product.productName ?? "")
        } else {
            _proteinAmount = State(initialValue: "")
            _foodName = State(initialValue: "")
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
                            Text(String(localized: "addEntry.cancel"))
                        }
                        Spacer()
                    }
                    .padding()
                    .font(.body)
                    .tint(Color.appPrimaryColor)
                    
                    Spacer()
                    
                    if !foodName.isEmpty {
                        Text("\(foodName)")
                            .font(.headline)
                            .foregroundColor(.appPrimaryColor)
                    }

                    // --- Big Number Input ---
                    TextField("0.0", text: $proteinAmount)
                        .foregroundColor(.appPrimaryColor)
                        .keyboardType(.decimalPad)
                        .font(.system(size: 120, weight: .bold)) // Huge font
                        .multilineTextAlignment(.center) // Center text
                        .padding()
                        .background(Color.clear) // No background box
                        .tint(Color.appPrimaryColor) // Cursor color
                        .focused($isInputFocused)
                        .accessibilityLabel(String(localized: "accessibility.proteinInput"))
                        .accessibilityValue(proteinAmount.isEmpty ? String(localized: "accessibility.empty") : "\(proteinAmount) \(String(localized: "addEntry.grams"))")
                        .toolbar {
                            ToolbarItemGroup(placement: .keyboard) {
                                Button(action: {
                                    saveEntry()
                                    let generator = UINotificationFeedbackGenerator()
                                    generator.notificationOccurred(.success)
                                    proteinAmount = ""
                                }) {
                                    Text(String(localized: "addEntry.addNext"))
                                        .font(.headline)
                                        .bold()
                                        .foregroundColor(isFormValid ? .appPrimaryColor : .gray)
                                            .bold()
                                }
                                .disabled(!isFormValid)
                                .accessibilityLabel(String(localized: "addEntry.addNext"))
                                .accessibilityHint(String(localized: "accessibility.addNextHint"))
                              
                                Spacer()
                                
                                Button(action: {
                                    saveEntry()
                                    let generator = UINotificationFeedbackGenerator()
                                    generator.notificationOccurred(.success)
                                    dismiss()
                                }) {
                                    Text(String(localized: "addEntry.done"))
                                        .font(.headline)
                                        .bold()
                                        .foregroundColor(isFormValid ? .appPrimaryColor : .gray)
                                            .bold()
                                }
                                .disabled(!isFormValid)
                                .accessibilityLabel(String(localized: "addEntry.done"))
                                .accessibilityHint(String(localized: "accessibility.doneHint"))
                            }
                        }
                        .onChange(of: proteinAmount) {
                            let generator = UIImpactFeedbackGenerator(style: .light)
                            generator.impactOccurred(intensity: 0.5)
                        }
                    
                    Text(String(localized: "addEntry.grams"))
                        .bold()
                        .font(.title)
                        .foregroundColor(.appPrimaryTextColor)
                    
                    Spacer().frame(height: 40)

                    Text(String(localized: "addEntry.defaultNameHint"))
                        .font(.body)
                        .foregroundColor(.appSecondaryTextColor)
                    Spacer()
                }
            }
            .background(Color.appCardBackgroundColor)
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isInputFocused = true
            }
        }
    }
    

    private func saveEntry() {
        if let amount = Double(proteinAmount) {
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm"
            //let timeString = formatter.string(from: Date())
            
            let finalName: String
            if !foodName.isEmpty {
                finalName = foodName
            } else {
                let formatter = DateFormatter()
                formatter.dateFormat = "HH:mm"
                finalName = String(localized: "addEntry.quickAdd.\(formatter.string(from: Date()))")
            }
            
            ProteinDataStore.addHistoryEntry(
                proteinAmount: amount,
                foodName: finalName,
                description: String(localized: "addEntry.defaultDescription"),
                date: date,
                in: modelContext
            )
            
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
        }
    }
}



#Preview {
    AddEntryModalView(date: Date())
        .modelContainer(ProteinDataStore.previewContainer())
}
