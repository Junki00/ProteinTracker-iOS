//
//  EntryDetailView.swift
//  ProteinTracker
//
//  Created by drx on 2025/08/04.
//

import SwiftData
import SwiftUI

struct EntryDetailView: View {
    let entry: ProteinEntry

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var proteinAmount: String = ""
    @State private var foodName: String = ""
    @State private var description: String = ""
    @State private var isEditing = false
    @State private var showDeleteConfirmation = false

    private var isDataValid: Bool {
        guard let amount = Double(proteinAmount) else {
            return false
        }

        return amount >= 0
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
            .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 20) {
                if isEditing {
                    VStack(alignment: .leading, spacing: 16) {
                        Text(String(localized: "entryDetail.proteinAmount"))
                            .font(.subheadline)
                            .foregroundColor(.appSecondaryTextColor)

                        TextField(String(localized: "entryDetail.proteinPlaceholder"), text: $proteinAmount)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(.roundedBorder)
                            .accessibilityLabel(String(localized: "entryDetail.proteinAmount"))

                        Text(String(localized: "entryDetail.foodName"))
                            .font(.subheadline)
                            .foregroundColor(.appSecondaryTextColor)

                        TextField(String(localized: "entryDetail.foodNamePlaceholder"), text: $foodName)
                            .textFieldStyle(.roundedBorder)
                            .accessibilityLabel(String(localized: "entryDetail.foodName"))

                        Text(String(localized: "entryDetail.description"))
                            .font(.subheadline)
                            .foregroundColor(.appSecondaryTextColor)

                        ZStack(alignment: .topLeading) {
                            if description.isEmpty {
                                Text(String(localized: "entryDetail.descriptionPlaceholder"))
                                    .foregroundColor(.appSecondaryTextColor.opacity(0.5))
                                    .padding(.top, 8)
                                    .padding(.leading, 5)
                                    .accessibilityHidden(true)
                            }

                            TextEditor(text: $description)
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
                } else {
                    detailRow(
                        item: String(localized: "entryDetail.proteinAmount"),
                        is: String(localized: "entryDetail.proteinGrams.\(String(format: "%.1f", entry.proteinAmount))")
                    )
                    Divider()
                    detailRow(item: String(localized: "entryDetail.foodName"), is: entry.foodName)
                    Divider()
                    detailRow(item: String(localized: "entryDetail.description"), is: entry.entryDescription)
                    Divider()

                    if entry.isPlan {
                        detailRow(item: String(localized: "entryDetail.scheduledFor"), is: entry.timeStamp.formattedRelativeString())
                    } else if entry.isHistory {
                        detailRow(item: String(localized: "entryDetail.consumedAt"), is: entry.timeStamp.formattedRelativeString())
                    } else {
                        detailRow(item: String(localized: "entryDetail.createdAt"), is: entry.timeStamp.formattedRelativeString())
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
                    Button(String(localized: "entryDetail.done")) {
                        guard let amount = Double(proteinAmount), amount >= 0 else {
                            return
                        }

                        entry.proteinAmount = amount
                        entry.foodName = foodName
                        entry.entryDescription = description
                        ProteinDataStore.saveIfNeeded(modelContext)

                        withAnimation {
                            isEditing = false
                        }
                    }
                    .buttonStyle(.bigAction(isEnabled: isDataValid))
                    .disabled(!isDataValid)
                } else {
                    Button(String(localized: "entryDetail.edit")) {
                        proteinAmount = String(format: "%.1f", entry.proteinAmount)
                        foodName = entry.foodName
                        description = entry.entryDescription

                        withAnimation {
                            isEditing = true
                        }
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
                    Button(String(localized: "common.cancel")) {
                        withAnimation {
                            isEditing = false
                        }
                    }
                }
            }

            ToolbarItem(placement: .destructiveAction) {
                Button(role: .destructive) {
                    showDeleteConfirmation = true
                } label: {
                    Image(systemName: "trash")
                }
                .accessibilityLabel(String(localized: "accessibility.deleteEntry"))
            }
        }
        .navigationBarBackButtonHidden(isEditing)
        .alert(String(localized: "entryDetail.deleteEntry"), isPresented: $showDeleteConfirmation) {
            Button(String(localized: "common.delete"), role: .destructive) {
                ProteinDataStore.delete(entry, in: modelContext)
                dismiss()
            }

            Button(String(localized: "common.cancel"), role: .cancel) {}
        } message: {
            Text(String(localized: "entryDetail.deleteConfirmation"))
        }
    }

    @ViewBuilder
    private func detailRow(item: String, is itemDetail: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(item)
                .font(.subheadline)
                .foregroundColor(.appSecondaryTextColor)

            Text(itemDetail)
                .font(.headline)
                .foregroundColor(.appPrimaryTextColor)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

#Preview {
    PreviewEntryDetailView()
        .modelContainer(ProteinDataStore.previewContainer())
}

private struct PreviewEntryDetailView: View {
    @Query private var entries: [ProteinEntry]

    var body: some View {
        if let entry = entries.first {
            NavigationView {
                EntryDetailView(entry: entry)
            }
        }
    }
}
