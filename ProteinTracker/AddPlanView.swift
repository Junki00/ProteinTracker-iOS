//
//  AddPlanView.swift
//  ProteinTracker
//
//  Created by drx on 2025/09/21.
//

import SwiftUI

struct AddPlanView: View {
    let entry: ProteinEntry
    
    @State private var selectedDate: Date = Date()
    @EnvironmentObject var viewModel: ProteinDataViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
            NavigationStack {
                // Use a ZStack to set the background color for the whole sheet
                ZStack {
                    Color.appBackgroundColor.ignoresSafeArea()
                    
                    VStack(spacing: 32) {
                        
                        // 1. Information Card
                        VStack(spacing: 24) {
                            // Emoji
                            Text(entry.emojiImage)
                                .font(.system(size: 80))
                                .padding(.top, 10)
                            
                            VStack(spacing: 8) {
                                Text(entry.foodName)
                                    .font(.title2)
                                    .bold()
                                    .multilineTextAlignment(.center)
                                    .foregroundColor(.appPrimaryTextColor)
                                
                                Text("\(entry.proteinAmount, specifier: "%.1f") Grams Protein")
                                    .font(.headline)
                                    .foregroundColor(.appPrimaryColor)
                            }
                            
                            Divider()
                            
                            // Date Picker Row
                            HStack {
                                Image(systemName: "calendar")
                                    .foregroundColor(.appSecondaryTextColor)
                                Text("Eat at")
                                    .foregroundColor(.appPrimaryTextColor)
                                    .bold()
                                Spacer()
                                DatePicker("", selection: $selectedDate, displayedComponents: [.hourAndMinute, .date])
                                    .labelsHidden()
                            }
                            .padding(.top, 8)
                        }
                        .padding(24)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.appCardBackgroundColor)
                                .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
                        )
                        .padding(.horizontal)
                        
                        Spacer()
                        
                        // 2. Big Action Button
                        Button(action: {
                            viewModel.addPlanEntry(from: entry, on: selectedDate)
                            withAnimation {
                                dismiss()
                            }
                        }) {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                Text("Add to Plan")
                            }
                            .font(.headline)
                            .foregroundColor(.white) // Always white on primary button
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.appPrimaryColor)
                                    .shadow(color: Color.appPrimaryColor.opacity(0.3), radius: 8, x: 0, y: 4)
                            )
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 10)
                    }
                    .padding(.top, 20)
                }
                .navigationTitle("Add to Plan")
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Cancel") {
                            dismiss()
                        }
                        .foregroundColor(.appSecondaryTextColor)
                    }
                }
            }
        }
}

#Preview {
    AddPlanView(entry: ProteinDataViewModel().entries[2])
}
