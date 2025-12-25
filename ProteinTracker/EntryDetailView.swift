//
//  EntryDetailView.swift
//  ProteinTracker
//
//  Created by drx on 2025/08/04.
//

import SwiftUI

struct EntryDetailView: View {
    
    @Binding var entry: ProteinEntry
    @EnvironmentObject var viewModel: ProteinDataViewModel
    @Environment(\.dismiss) var dismiss
    
    @State var proteinAmount: String = ""
    @State var foodName: String = ""
    @State var description: String = ""
    @State var isEditing: Bool = false
    
    @State private var showDeleteConfirmation = false
    
    var isDataValid: Bool {
        if let amount = Double(proteinAmount) {
            return amount >= 0
        }
        return false
    }
        
    var body: some View {
        VStack(spacing: 24) {
            ZStack {
                Circle()
                    .fill(Color.appCardBackgroundColor)
                    .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                    .frame(width: 120, height: 120)
                
                Text(entry.emojiImage)
                    .font(.system(size: 80))
            }
            
            // 2. Main Content Card
            VStack(alignment: .leading, spacing: 20) {
                if isEditing {
                    // --- Editing Mode ---
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Protein Amount")
                            .font(.subheadline)
                            .foregroundColor(.appSecondaryTextColor)
                        TextField ("Protein (grams)", text: $proteinAmount)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(.roundedBorder)
                                                                        
                        Text("Food Name")
                            .font(.subheadline)
                            .foregroundColor(.appSecondaryTextColor)
                        TextField ("Name (e.g., Whey Protein Powder)", text: $foodName)
                            .textFieldStyle(.roundedBorder)
                        
                        Text("Description")
                            .font(.subheadline)
                            .foregroundColor(.appSecondaryTextColor)
                        
                        ZStack(alignment: .topLeading) {
                            if description.isEmpty {
                                Text("What's about this food...")
                                    .foregroundColor(.appSecondaryTextColor.opacity(0.5))
                                    .padding(.top, 8)
                                    .padding(.leading, 5)
                            }
                            TextEditor(text: $description)
                                .scrollContentBackground(.hidden)
                                .background(Color.clear)
                        }
                        .frame(minHeight: 100)
                        .padding(4)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.appSubCardBackgroundColor)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.appSecondaryTextColor.opacity(0.2), lineWidth: 1)
                        )
                    }
                } else {
                    // --- Viewing Mode ---
                    detailRow(item: "Protein Amount", is: "\(String(format: "%.1f", entry.proteinAmount)) Grams")
                    Divider() // Add separators for clarity
                    detailRow(item: "Food Name", is: entry.foodName)
                    Divider()
                    detailRow(item: "Description", is: entry.description)
                    Divider()
                    // Manually editing time is forbidden
                    
                    if entry.isPlan {
                        detailRow(item: "Scheduled For", is: entry.timeStamp.formattedRelativeString())

                    } else if entry.isHistory {
                        detailRow(item: "Consumed At", is: entry.timeStamp.formattedRelativeString())
                    } else {
                        detailRow(item: "Created At", is: entry.timeStamp.formattedRelativeString())
                    }
                }
            }
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.appCardBackgroundColor)
                    .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 4)
            )
            .padding(.horizontal)
            
            Spacer()
                  
            VStack {
                if isEditing {
                    Button("Done") {
                        guard let amount = Double(proteinAmount), amount >= 0 else {return}
                        entry.proteinAmount = amount
                        entry.foodName = foodName
                        entry.description = description
                        withAnimation { isEditing = false }
                    }
                    .buttonStyle(.bigAction(isEnabled: isDataValid))
                    .disabled(!isDataValid)
                } else {
                    Button("Edit") {
                        proteinAmount = String(format: "%.1f", entry.proteinAmount)
                        foodName = entry.foodName
                        description = entry.description
                        withAnimation { isEditing = true }
                    }
                    .buttonStyle(.bigAction())
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 10)
        }
        .padding(.top, 20)
        .background(Color.appBackgroundColor)
        .toolbar {
            if isEditing {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        withAnimation { isEditing = false }
                    }
                }
            }
            
            ToolbarItem(placement: .destructiveAction) {
                Button(role: .destructive) {
                    showDeleteConfirmation = true
                } label: {
                    Image(systemName: "trash")
                }
            }
        }
        .navigationBarBackButtonHidden(isEditing)
        .alert("Delete Entry?", isPresented: $showDeleteConfirmation) {
            Button("Delete", role: .destructive) {
                viewModel.deleteEntry(withId: entry.id)
                dismiss()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This action cannot be undone.")
        }
    }
        
    // Helper Methods
    @ViewBuilder
    private func detailRow(item: String, is itemDetail: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(item)
                .font(.subheadline)
                .foregroundColor(.appSecondaryTextColor) // Label is secondary
            
            Text(itemDetail)
                .font(.headline)
                .foregroundColor(.appPrimaryTextColor)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}


#Preview {
    let viewModel = ProteinDataViewModel()

    struct PreviewWrapper: View {

        private let initialEntry: ProteinEntry
        @State private var entry: ProteinEntry
        
        init(entry: ProteinEntry) {
            self.initialEntry = entry
            _entry = State(initialValue: entry)
        }
        
        var body: some View {
            NavigationView {
                EntryDetailView(entry: $entry)
            }
        }
    }
    
    return PreviewWrapper(entry: viewModel.entries[2])
        .environmentObject(viewModel)
}




