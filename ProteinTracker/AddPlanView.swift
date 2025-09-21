//
//  AddPlanView.swift
//  ProteinTracker
//
//  Created by drx on 2025/09/21.
//

import SwiftUI

struct AddPlanView: View {
    let entry: ProteinEntry
    
    @State private var selectedDate: Date = Date()  //其实需要有循环的话，才会好用。但是去考虑循环会变得很复杂，我就暂时没用。
    
    @EnvironmentObject var viewModel: ProteinDataViewModel
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 40) {
                Text("\(entry.emojiImage)")
                    .font(.system(size: 200))
                Text("\(entry.foodName)")
                    .font(.title)
                    .bold()
                Text("\(entry.proteinAmount, specifier: "%.1f") Grams")
                    .font(.title2)
                    .bold()
                    .foregroundColor(.appPrimary)
                DatePicker("Eat At", selection: $selectedDate, displayedComponents: [.hourAndMinute, .date])
                
                Text("Repeat   Never")

                Text("Alert   None")
                
                
                Button ("Save Plan") {
                    viewModel.addPlanEntry(from: entry, on: selectedDate)
                    print("Adding \(entry.foodName) to plan on \(selectedDate)")
                    withAnimation {
                        dismiss()
                    }
                }
                .foregroundColor(.white)
                .font(.headline)
                .padding()
                .frame(maxWidth: .infinity)
                .background(RoundedRectangle(cornerRadius: 5).fill(Color.appPrimary))
            }
            .padding()
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .navigationTitle("Add to Plan")
            .tint(Color.appPrimary)
        }
    }
}

#Preview {
    AddPlanView(entry: ProteinDataViewModel().entries[2])
}
