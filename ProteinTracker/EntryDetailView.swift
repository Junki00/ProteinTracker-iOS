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
    
    @State var proteinAmount: String = ""
    @State var foodName: String = ""
    @State var description: String = ""
    @State var isEditing: Bool = false
    
    var isDataValid: Bool {
        if let amount = Double(proteinAmount) {
            return amount >= 0
        }
        return false
    }
        
    var body: some View {
        VStack(spacing: 20) {
            Text(entry.emojiImage)
                .font(.system(size: 200))
            VStack(alignment: .leading, spacing: 20) {
                
                if isEditing {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Protein Amount")
                            .font(.subheadline)
                            .foregroundColor(.primaryText)
                        TextField ("Protein (grams)", text: $proteinAmount).keyboardType(.decimalPad)
                                                                        
                        Text("Food Name")
                            .font(.subheadline)
                            .foregroundColor(.primaryText)
                        TextField ("Name (e.g., Whey Protein Powder)", text: $foodName)
                        
                        Text("Description")
                            .font(.subheadline)
                            .foregroundColor(.primaryText)
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
                } else {
                    detailRow(item: "Protein Amount", is: "\(String(format: "%.1f", entry.proteinAmount)) Grams")
                    
                    detailRow(item: "Food Name", is: entry.foodName)
                    
                    detailRow(item: "Description", is: entry.description)
                }
                
                // Manually editting time is forbidden
                detailRow(item: "Adding Time", is: entry.timeStamp.formattedRelativeString())
                
                Spacer().frame(height: 20)
                
                // Do Later: Logic of add to Favorite
                Button( action: {
                    
                    
                    print("Add Tapped")
                    
                    
                    
                } ) {
                    HStack {
                        Text("Add to / Delete from Favorites")
                        Image(systemName: "star")
                    }
                    .foregroundColor(.white)
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(RoundedRectangle(cornerRadius: 5).fill(Color.appPrimary))
                }
            }
            .padding()
        }
        .toolbar {
            if isEditing {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        withAnimation {
                            isEditing = false
                        }
                    }
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                if isEditing {
                    Button("Done") {
                        guard let amount = Double(proteinAmount), amount >= 0 else {return}
                        
                        entry.proteinAmount = amount
                        entry.foodName = foodName
                        entry.description = description
                        
                        withAnimation {
                            isEditing = false
                        }
                    }
                    .disabled(!isDataValid)
                } else {
                    Button("Edit") {
                        proteinAmount = String(format: "%.1f", entry.proteinAmount)
                        foodName = entry.foodName
                        description = entry.description
                        withAnimation {
                            isEditing = true
                        }
                    }
                }
            }
        }
        .navigationBarBackButtonHidden(isEditing)
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


//#Preview {
//    let viewModel = ProteinDataViewModel()
//
//    struct PreviewWrapper: View {
//        @State private var entry = viewModel.entries[5]
//        
//        var body: some View {
//            NavigationView {
//                EntryDetailView(entry: $entry)
//                    .environmentObject(viewModel)
//            }
//        }
//    }
//    
//    return PreviewWrapper()
//}



#Preview {
    // 把 ViewModel 的创建放到 NavigationStack/View 之外
    // 让它在 Preview 的顶层作用域
    let viewModel = ProteinDataViewModel()

    // 创建一个临时的容器 View 来持有 @State
    struct PreviewWrapper: View {
        // 1. 我们需要一个 entry 来初始化 @State
        //    所以我们通过 init 把它传进来
        private let initialEntry: ProteinEntry
        
        // 2. 用传入的 initialEntry 来初始化 @State
        @State private var entry: ProteinEntry
        
        init(entry: ProteinEntry) {
            self.initialEntry = entry
            _entry = State(initialValue: entry)
        }
        
        var body: some View {
            NavigationView {
                // 3. 把绑定 $entry 传给 EntryDetailView
                EntryDetailView(entry: $entry)
            }
        }
    }
    
    // 4. 创建 PreviewWrapper 时，传入 viewModel 的第一个 entry
    //    并把 viewModel 注入到它的环境中
    return PreviewWrapper(entry: viewModel.entries[0])
        .environmentObject(viewModel)
}

