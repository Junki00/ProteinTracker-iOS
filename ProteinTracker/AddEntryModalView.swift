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
    @FocusState private var isInputFocused: Bool
    
    private var isFormValid: Bool {
        Double(proteinAmount) != nil
    }
    
    init(product: Product? = nil, date: Date) {
        if let product = product {
            _proteinAmount = State(initialValue: "\(product.proteinValue)")
        } else {
            _proteinAmount = State(initialValue: "")
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
                    }
                    .padding()
                    .font(.body)
                    .tint(Color.appPrimaryColor)
                    
                    Spacer()

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
                        .toolbar {
                            ToolbarItemGroup(placement: .keyboard) {
                                Button(action: {
                                    saveEntry()
                                    let generator = UINotificationFeedbackGenerator()
                                    generator.notificationOccurred(.success)
                                    proteinAmount = ""
                                }) {
                                    Text("Add Next")
                                        .font(.headline)
                                        .bold()
                                        .foregroundColor(isFormValid ? .appPrimaryColor : .gray)
                                            .bold()
                                }
                                .disabled(!isFormValid)
                              
                                Spacer()
                                
                                Button(action: {
                                    saveEntry()
                                    let generator = UINotificationFeedbackGenerator()
                                    generator.notificationOccurred(.success)
                                    dismiss()
                                }) {
                                    Text("Done")
                                        .font(.headline)
                                        .bold()
                                        .foregroundColor(isFormValid ? .appPrimaryColor : .gray)
                                            .bold()
                                }
                                .disabled(!isFormValid)
                            }
                        }
                        .onChange(of: proteinAmount) {
                            let generator = UIImpactFeedbackGenerator(style: .light)
                            generator.impactOccurred(intensity: 0.5)
                        }
                    
                    Text("GRAMS")
                        .bold()
                        .font(.title)
                        .foregroundColor(.appPrimaryTextColor)
                    
                    Spacer().frame(height: 40)

                    Text("Default name will be used. Tap entry to edit details later.")
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
            let timeString = formatter.string(from: Date())
            let finalFoodName = "Quick Add at \(timeString)"
            
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
            
            viewModel.addHistoryEntry(proteinAmount: amount, foodName: finalFoodName, description: "Click to edit description.")
        }
    }
}



#Preview {
    AddEntryModalView(date: Date())
        .environmentObject(ProteinDataViewModel())
}
