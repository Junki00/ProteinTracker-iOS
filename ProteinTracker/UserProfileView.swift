//
//  UserProfileView.swift
//  ProteinTracker
//
//  Created by drx on 2025/12/26.
//

import SwiftData
import SwiftUI

struct UserProfileView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var userProfiles: [UserProfile]

    @State private var tempName = ""
    @State private var tempWeight = 0.0
    @State private var tempMultiplier = 1.6
    @State private var showResetConfirmation = false
    @FocusState private var focusedField: Field?

    private enum Field {
        case name, weight, multiplier
    }

    private var userProfile: UserProfile? {
        userProfiles.first
    }

    var body: some View {
        ScrollView {
            VStack {
                Form {
                    Section(header: Text(String(localized: "profile.sectionProfile"))) {
                        HStack {
                            Text(String(localized: "profile.name"))
                            Spacer()
                            TextField(String(localized: "profile.namePlaceholder"), text: $tempName)
                                .focused($focusedField, equals: .name)
                                .multilineTextAlignment(.trailing)
                        }
                    }

                    Section(header: Text(String(localized: "profile.sectionGoal")), footer: Text(String(localized: "profile.goalFooter"))) {
                        HStack {
                            Text(String(localized: "profile.weight"))
                            Spacer()
                            TextField("0.0", value: $tempWeight, format: .number)
                                .keyboardType(.decimalPad)
                                .focused($focusedField, equals: .weight)
                                .multilineTextAlignment(.trailing)
                                .accessibilityLabel(String(localized: "accessibility.weightInput"))
                        }

                        HStack {
                            Text(String(localized: "profile.multiplier"))
                            Spacer()
                            TextField("1.6", value: $tempMultiplier, format: .number.precision(.fractionLength(1)))
                                .keyboardType(.decimalPad)
                                .focused($focusedField, equals: .multiplier)
                                .multilineTextAlignment(.trailing)
                                .accessibilityLabel(String(localized: "accessibility.multiplierInput"))
                        }
                    }

                    Section {
                        HStack {
                            Text(String(localized: "profile.dailyTarget"))
                            Spacer()
                            let target = tempWeight * tempMultiplier
                            Text("\(target, specifier: "%.0f") g")
                                .bold()
                                .foregroundColor(.appPrimaryColor)
                        }
                        .accessibilityElement(children: .combine)
                        .accessibilityLabel(String(localized: "accessibility.dailyTarget.\(Int(tempWeight * tempMultiplier))"))
                    }
                }
                .frame(minHeight: 400)

                Button(String(localized: "profile.loadSampleData")) {
                    showResetConfirmation = true
                }
                .font(.footnote)
                .foregroundColor(.appSecondaryTextColor)
                .padding(.bottom, 20)
            }
        }
        .background(Color.appBackgroundColor)
        .navigationTitle(String(localized: "profile.title"))
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Save") {
                    saveProfile()
                    focusedField = nil
                }
                .accessibilityLabel(String(localized: "profile.saveChanges"))
            }
        }
        .alert(String(localized: "profile.loadSampleData"), isPresented: $showResetConfirmation) {
            Button(String(localized: "profile.loadSampleDataConfirm"), role: .destructive) {
                ProteinDataStore.resetToMockData(in: modelContext)
                DS.Haptics.success()
            }
            Button(String(localized: "common.cancel"), role: .cancel) {}
        } message: {
            Text(String(localized: "profile.loadSampleDataMessage"))
        }
        .onAppear {
            tempName = userProfile?.userName ?? "User"
            tempWeight = userProfile?.userWeight ?? 120
            tempMultiplier = userProfile?.proteinMultiplier ?? 2.2
        }
    }

    private func saveProfile() {
        let profile = userProfile ?? UserProfile()

        if userProfile == nil {
            modelContext.insert(profile)
        }

        profile.userName = tempName
        profile.userWeight = tempWeight
        profile.proteinMultiplier = tempMultiplier
        ProteinDataStore.saveIfNeeded(modelContext)
    }
}

#Preview {
    NavigationView {
        UserProfileView()
    }
    .modelContainer(ProteinDataStore.previewContainer())
}
