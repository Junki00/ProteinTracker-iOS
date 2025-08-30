//
//  FavoritesView.swift
//  ProteinTracker
//
//  Created by drx on 2025/07/21.
//

import SwiftUI

struct FavoritesView: View {
    @EnvironmentObject var viewModel: ProteinDataViewModel
    
    
    var body: some View {
        EntryCardView(type: .favorite, date: Date())
    }
}

#Preview {
    FavoritesView()
        .environmentObject(ProteinDataViewModel())
}
