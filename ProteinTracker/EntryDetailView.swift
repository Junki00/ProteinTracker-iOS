//
//  EntryDetailView.swift
//  ProteinTracker
//
//  Created by drx on 2025/08/04.
//

import SwiftUI

struct EntryDetailView: View {
    
    let entryDetails: ProteinEntry
        
    var body: some View {
        VStack(spacing: 20) {
            Text(entryDetails.emojiImage)
                .font(.system(size: 200))
            VStack(alignment: .leading, spacing: 20) {
                detailRow(item: "Protein Amount", is: "\(String(format: "%.1f", entryDetails.proteinAmount)) Grams")
                detailRow(item: "Food Name", is: entryDetails.foodName)
                detailRow(item: "Description", is: entryDetails.description)
                detailRow(item: "Adding Time", is: entryDetails.addTime.formattedRelativeString())
                Spacer().frame(height: 20)
                
                
                NavigationLink {
                    EditEntryView(entry: entryDetails)
                } label: {
                    Text("Go to Edit Page (Temporary)")
                        .foregroundColor(.white)
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(RoundedRectangle(cornerRadius: 5).fill(Color.appPrimary))
                }
                
                
                
                Button( action: {print("Add Tapped")} ) {
                    Text("Add to Favorites")
                        .foregroundColor(.white)
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(RoundedRectangle(cornerRadius: 5).fill(Color.appPrimary))
                }
            }
            .padding()
        }
    }
        // Helper Methods
    @ViewBuilder
    private func detailRow(item: String, is itemDetail: String) -> some View {
        VStack(alignment: .leading) {
            Text(item)
                .font(.subheadline)
                .foregroundColor(.primaryText)
            
            Text(itemDetail)
                .font(.headline)
                .foregroundColor(.secondaryText)
        }
        .font(.body)
    }
}
    
#Preview {
    NavigationView {
        EntryDetailView(entryDetails: ProteinDataViewModel().entries[5])
    }
}
