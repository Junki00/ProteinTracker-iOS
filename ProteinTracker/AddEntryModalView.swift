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
    let entryType: EntryType
    
    @State private var proteinAmount: String
    @State private var foodName: String
    @State private var entryDescription: String = ""
    @State private var selectedEmoji: String?
    @FocusState private var isInputFocused: Bool
    
    private var isFormValid: Bool {
        Double(proteinAmount) != nil
    }

    private var isFavoriteFormValid: Bool {
        guard let amount = Double(proteinAmount), amount >= 0 else { return false }
        return !foodName.isEmpty
    }
    
    private let isFromSearch: Bool

    init(product: Product? = nil, date: Date, entryType: EntryType = .history) {
        if let product = product {
            _proteinAmount = State(initialValue: "\(product.proteinValue)")
            _foodName = State(initialValue: product.productName ?? "")
            self.isFromSearch = true
        } else {
            _proteinAmount = State(initialValue: "")
            _foodName = State(initialValue: "")
            self.isFromSearch = false
        }

        self.date = date
        self.entryType = entryType
    }
    
    var body: some View {
        NavigationStack {
            Group {
                if entryType == .favorite {
                    favoriteBody
                } else {
                    historyBody
                }
            }
            .background(Color.appBackgroundColor)
        }
    }

    // MARK: - Favorite Mode (detail-style form)

    private var favoriteBody: some View {
        ScrollView {
            VStack(spacing: 24) {
                emojiPickerSection

                VStack(alignment: .leading, spacing: 16) {
                    Text(String(localized: "entryDetail.foodName"))
                        .font(.subheadline)
                        .foregroundColor(.appSecondaryTextColor)

                    TextField(String(localized: "entryDetail.foodNamePlaceholder"), text: $foodName)
                        .textFieldStyle(.roundedBorder)
                        .accessibilityLabel(String(localized: "entryDetail.foodName"))

                    Text(String(localized: "entryDetail.proteinAmount"))
                        .font(.subheadline)
                        .foregroundColor(.appSecondaryTextColor)

                    TextField(String(localized: "entryDetail.proteinPlaceholder"), text: $proteinAmount)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(.roundedBorder)
                        .accessibilityLabel(String(localized: "entryDetail.proteinAmount"))

                    Text(String(localized: "entryDetail.description"))
                        .font(.subheadline)
                        .foregroundColor(.appSecondaryTextColor)

                    ZStack(alignment: .topLeading) {
                        if entryDescription.isEmpty {
                            Text(String(localized: "entryDetail.descriptionPlaceholder"))
                                .foregroundColor(.appSecondaryTextColor.opacity(0.5))
                                .padding(.top, 8)
                                .padding(.leading, 5)
                                .accessibilityHidden(true)
                        }

                        TextEditor(text: $entryDescription)
                            .scrollContentBackground(.hidden)
                            .background(Color.clear)
                            .accessibilityLabel(String(localized: "entryDetail.description"))
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
                .padding(24)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.appCardBackgroundColor)
                        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 4)
                )
                .padding(.horizontal)

                Spacer()

                Button(String(localized: "addEntry.addFavorite")) {
                    saveFavoriteEntry()
                    DS.Haptics.success()
                    dismiss()
                }
                .buttonStyle(.bigAction(isEnabled: isFavoriteFormValid))
                .disabled(!isFavoriteFormValid)
                .padding(.horizontal)
                .padding(.bottom, 10)
            }
            .padding(.top, 20)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "xmark")
                        }
                        .accessibilityLabel(String(localized: "addEntry.cancel"))
                    }
                }
        }

    }

    private var emojiPickerSection: some View {
        VStack(spacing: DS.Spacing.s) {
            ZStack {
                Circle()
                    .fill(Color.appCardBackgroundColor)
                    .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                    .frame(width: 100, height: 100)

                Text(selectedEmoji ?? "🍽️")
                    .font(.system(size: 60))
            }
            .accessibilityHidden(true)

            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 9), spacing: DS.Spacing.s) {
                ForEach(DS.foodEmojis, id: \.self) { emoji in
                    Button {
                        DS.Haptics.light(intensity: 0.6)
                        if selectedEmoji == emoji {
                            selectedEmoji = nil
                        } else {
                            selectedEmoji = emoji
                        }
                    } label: {
                        Text(emoji)
                            .font(.system(size: 28))
                            .frame(width: 44, height: 44)
                            .background(
                                Circle()
                                    .fill(selectedEmoji == emoji ? Color.appPrimaryColor.opacity(0.2) : Color.clear)
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 24)
        }
    }

    // MARK: - History Mode (big number input, unchanged)

    private var historyBody: some View {
        ScrollView {
            VStack {
                Spacer()
                
                if !foodName.isEmpty {
                    Text("\(foodName)")
                        .font(.headline)
                        .foregroundColor(.appPrimaryColor)
                }

                if isFromSearch {
                    Text(String(localized: "addEntry.per100gHint"))
                        .font(.caption)
                        .foregroundColor(.appSecondaryTextColor)
                }

                TextField("0.0", text: $proteinAmount)
                    .foregroundColor(.appPrimaryColor)
                    .keyboardType(.decimalPad)
                    .font(.system(size: 120, weight: .bold))
                    .multilineTextAlignment(.center)
                    .padding()
                    .background(Color.clear)
                    .tint(Color.appPrimaryColor)
                    .focused($isInputFocused)
                    .accessibilityLabel(String(localized: "accessibility.proteinInput"))
                    .accessibilityValue(proteinAmount.isEmpty ? String(localized: "accessibility.empty") : "\(proteinAmount) \(String(localized: "addEntry.grams"))")
                    .toolbar {
                        ToolbarItemGroup(placement: .keyboard) {
                            Button(action: {
                                saveHistoryEntry()
                                DS.Haptics.success()
                                proteinAmount = ""
                            }) {
                                Text(String(localized: "addEntry.addNext"))
                                    .font(.headline)
                                    .bold()
                                    .foregroundColor(isFormValid ? .appPrimaryColor : .gray)
                            }
                            .disabled(!isFormValid)
                            .accessibilityLabel(String(localized: "addEntry.addNext"))
                            .accessibilityHint(String(localized: "accessibility.addNextHint"))
                          
                            Spacer()
                            
                            Button(action: {
                                saveHistoryEntry()
                                DS.Haptics.success()
                                dismiss()
                            }) {
                                Text(String(localized: "addEntry.done"))
                                    .font(.headline)
                                    .bold()
                                    .foregroundColor(isFormValid ? .appPrimaryColor : .gray)
                            }
                            .disabled(!isFormValid)
                            .accessibilityLabel(String(localized: "addEntry.done"))
                            .accessibilityHint(String(localized: "accessibility.doneHint"))
                        }
                    }
                    .onChange(of: proteinAmount) {
                        DS.Haptics.light(intensity: 0.5)
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
        .padding(.horizontal)
        .background(Color.appCardBackgroundColor)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                }
                .accessibilityLabel(String(localized: "addEntry.cancel"))
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isInputFocused = true
            }
        }
    }

    // MARK: - Save

    private func saveHistoryEntry() {
        guard let amount = Double(proteinAmount) else { return }

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
            description: "",
            date: date,
            in: modelContext
        )
    }

    private func saveFavoriteEntry() {
        guard let amount = Double(proteinAmount), !foodName.isEmpty else { return }

        let desc = entryDescription.isEmpty
            ? String(localized: "addEntry.defaultDescription")
            : entryDescription

        ProteinDataStore.addFavoriteEntry(
            proteinAmount: amount,
            foodName: foodName,
            description: desc,
            customEmoji: selectedEmoji,
            in: modelContext
        )
    }
}



#Preview("History") {
    AddEntryModalView(date: Date())
        .modelContainer(ProteinDataStore.previewContainer())
}

#Preview("Favorite") {
    AddEntryModalView(date: Date(), entryType: .favorite)
        .modelContainer(ProteinDataStore.previewContainer())
}
