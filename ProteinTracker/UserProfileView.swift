//
//  UserProfileView.swift
//  ProteinTracker
//
//  Created by drx on 2025/12/26.
//

import SwiftUI

struct UserProfileView: View {
    @EnvironmentObject var viewModel: ProteinDataViewModel
    @Environment(\.dismiss) var dismiss
    
    // Temp State
    @State private var tempName: String = ""
    @State private var tempWeight: Double = 0.0
    @State private var tempMultiplier: Double = 1.6
    
    var body: some View {
        VStack {
            Form {
                // 1. Profile Section
                Section(header: Text("Profile")) {
                    HStack {
                        Text("Name")
                        Spacer()
                        TextField("Your Name", text: $tempName)
                            .multilineTextAlignment(.trailing)
                    }
                }
                
                // 2. Goal Settings Section
                Section(header: Text("Protein Goal Settings"), footer: Text("Standard advice: 1.6g - 2.2g per kg of body weight.")) {
                    
                    HStack {
                        Text("Weight (kg)")
                        Spacer()
                        TextField("0.0", value: $tempWeight, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    HStack {
                        Text("Multiplier (g/kg)")
                        Spacer()
                        TextField("1.6", value: $tempMultiplier, format: .number.precision(.fractionLength(1)))
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                }
                
                // 3. Live Preview Section
                Section {
                    HStack {
                        Text("Daily Target")
                        Spacer()
                        let target = tempWeight * tempMultiplier
                        Text("\(target, specifier: "%.0f") g")
                            .bold()
                            .foregroundColor(.appPrimaryColor)
                    }
                }
            }
            
            Spacer()
            
            // Save Button
            Button("Save Changes") {
                // Update ViewModel
                viewModel.userProfile.userName = tempName
                viewModel.updateDailyGoal(by: tempWeight, times: tempMultiplier)
                dismiss()
            }
            .buttonStyle(.bigAction())
            .padding(.horizontal)
            .padding(.bottom, 10)
        }
        .background(Color.appBackgroundColor)
        .navigationTitle("Profile & Goal")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            // Load initial data
            tempName = viewModel.userProfile.userName
            tempWeight = viewModel.userProfile.userWeight
            tempMultiplier = viewModel.userProfile.proteinMultiplier
        }
    }
}

#Preview {
    NavigationView {
        UserProfileView()
            .environmentObject(ProteinDataViewModel())
    }
}
