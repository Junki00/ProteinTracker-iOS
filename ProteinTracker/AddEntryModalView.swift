//
//  AddEntryModalView.swift
//  ProteinTracker
//
//  Created by drx on 2025/07/21.
//

import SwiftUI

enum EntryType {
    case planned, favorites
}

struct AddEntryModalView: View {
    @Environment(\.dismiss) var dismiss
    
    @State private var proteinAmount: String = ""
    @State private var foodName: String = ""
    @State private var description: String = ""
    @State private var selection: EntryType = .favorites
    
    var body: some View {
        
        ScrollView {
            VStack {
                HStack {
                    Button (action: {
                        dismiss()
                    }) {
                        Text("Cancel")
                    }
                    Spacer()
                    Text("Fast Add or Pick Below")
                        .font(.headline)
                    Spacer()
                    Button (action: { dismiss() }) {
                        Text("Add")
                            .bold()
                    }
                    
                }
                .padding()
                .font(.body)
                .tint(Color.appPrimary)
                
                
                
                
                VStack(spacing: 16) {
                    TextField ("Protein (grams)", text: $proteinAmount).keyboardType(.decimalPad)
                    
                    TextField ("Name (e.g., Whey Protein Powder)", text: $foodName)
                    
                    ZStack(alignment: .topLeading) {
                        TextEditor(text: $description)

                        
                        if description.isEmpty {
                            Text("What's about this food...")
                                .foregroundColor(.gray.opacity(0.7))
                                .padding(.top, 8)
                                .padding(.leading, 5)
                        }
                    }
                    .frame(minHeight: 100)
                    .padding(4)
                    .background(RoundedRectangle(cornerRadius: 8).fill(Color.white))
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.4), lineWidth: 1))
                }
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal)
                .tint(Color.appPrimary)
                
                Picker("Selection", selection: $selection) {
                    Text("Planned").tag(EntryType.planned)
                    Text("Favorites").tag(EntryType.favorites)
                }
                .pickerStyle(.segmented)
                .padding()
                
                
                switch selection {
                case .planned:
                    PlanCard().padding()
                case .favorites:
                    FavoriteCard().padding()
                }

            }
        }.background(Color.secondaryBackground)
    }
}

#Preview {
    AddEntryModalView()
}
