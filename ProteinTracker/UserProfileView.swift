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
    @Environment(\.dismiss) private var dismiss
    @Query private var userProfiles: [UserProfile]

    @State private var tempName = ""
    @State private var tempWeight = 0.0
    @State private var tempMultiplier = 1.6

    private var userProfile: UserProfile? {
        userProfiles.first
    }

    var body: some View {
        VStack {
            Form {
                Section(header: Text(String(localized: "profile.sectionProfile"))) {
                    HStack {
                        Text(String(localized: "profile.name"))
                        Spacer()
                        TextField(String(localized: "profile.namePlaceholder"), text: $tempName)
                            .multilineTextAlignment(.trailing)
                    }
                }

                Section(header: Text(String(localized: "profile.sectionGoal")), footer: Text(String(localized: "profile.goalFooter"))) {
                    HStack {
                        Text(String(localized: "profile.weight"))
                        Spacer()
                        TextField("0.0", value: $tempWeight, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .accessibilityLabel(String(localized: "accessibility.weightInput"))
                    }

                    HStack {
                        Text(String(localized: "profile.multiplier"))
                        Spacer()
                        TextField("1.6", value: $tempMultiplier, format: .number.precision(.fractionLength(1)))
                            .keyboardType(.decimalPad)
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

            Spacer()

            Button(String(localized: "profile.saveChanges")) {
                let profile = userProfile ?? UserProfile()

                if userProfile == nil {
                    modelContext.insert(profile)
                }

                profile.userName = tempName
                profile.userWeight = tempWeight
                profile.proteinMultiplier = tempMultiplier
                ProteinDataStore.saveIfNeeded(modelContext)
                dismiss()
            }
            .buttonStyle(.bigAction())
            .padding(.horizontal)
            .padding(.bottom, 10)
        }
        .background(Color.appBackgroundColor)
        .navigationTitle(String(localized: "profile.title"))
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            tempName = userProfile?.userName ?? "User"
            tempWeight = userProfile?.userWeight ?? 120
            tempMultiplier = userProfile?.proteinMultiplier ?? 2.2
        }
    }
}

#Preview {
    NavigationView {
        UserProfileView()
    }
    .modelContainer(ProteinDataStore.previewContainer())
}
