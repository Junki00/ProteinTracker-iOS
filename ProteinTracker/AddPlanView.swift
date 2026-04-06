//
//  AddPlanView.swift
//  ProteinTracker
//
//  Created by drx on 2025/09/21.
//

import SwiftData
import SwiftUI

struct AddPlanView: View {
    let entry: ProteinEntry
    
    @State private var selectedDate: Date = Date()
    @Environment(\.modelContext) private var modelContext
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
                                .accessibilityHidden(true)
                            
                            VStack(spacing: 8) {
                                Text(entry.foodName)
                                    .font(.title2)
                                    .bold()
                                    .multilineTextAlignment(.center)
                                    .foregroundColor(.appPrimaryTextColor)
                                
                                Text(String(localized: "addPlan.gramsProtein.\(String(format: "%.1f", entry.proteinAmount))"))
                                    .font(.headline)
                                    .foregroundColor(.appPrimaryColor)
                            }
                            
                            Divider()
                            
                            // Date Picker Row
                            HStack {
                                Image(systemName: "calendar")
                                    .foregroundColor(.appSecondaryTextColor)
                                    .accessibilityHidden(true)
                                Text(String(localized: "addPlan.eatAt"))
                                    .foregroundColor(.appPrimaryTextColor)
                                    .bold()
                                Spacer()
                                DatePicker("", selection: $selectedDate, displayedComponents: [.hourAndMinute, .date])
                                    .labelsHidden()
                                    .accessibilityLabel(String(localized: "accessibility.planDate"))
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
                            DS.Haptics.success()
                            ProteinDataStore.addPlanEntry(from: entry, on: selectedDate, in: modelContext)
                            withAnimation {
                                dismiss()
                            }
                        }) {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                Text(String(localized: "addPlan.addToPlan"))
                            }
                        }
                        .buttonStyle(.bigAction())
                        .accessibilityLabel(String(localized: "accessibility.confirmAddToPlan.\(entry.foodName)"))
                        .padding(.horizontal)
                        .padding(.bottom, 10)
                    }
                    .padding(.top, 20)
                }
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(String(localized: "common.cancel")) {
                            dismiss()
                        }
                        .foregroundColor(.appSecondaryTextColor)
                    }
                }
            }
        }
}

#Preview {
    PreviewAddPlanView()
        .modelContainer(ProteinDataStore.previewContainer())
}

private struct PreviewAddPlanView: View {
    @Query private var entries: [ProteinEntry]

    var body: some View {
        if let entry = entries.first {
            AddPlanView(entry: entry)
        }
    }
}
