//
//  TodayView.swift
//  ProteinTracker
//
//  Created by drx on 2025/07/19.
//

import SwiftUI

struct TodayView: View {
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            ScrollView {
                VStack(spacing: 20) {
                    HStack {
                        Text("June 30, 2025")
                            .foregroundColor(.gray)
                        Spacer()
                        Image(systemName: "person.circle")
                    }
                    
                    VStack {
                        HStack {
                            HStack {
                                Text("Still Need")
                                    .font(.title2)
                                    .bold()
                                
                                Spacer()
                                
                                Button(action: {
                                    print("Tapped")
                                }) {
                                    Text("Change Goal")
                                        .font(.subheadline.weight(.bold))
                                        .foregroundColor(.appPrimary)
                                        .padding(.vertical, 8)
                                        .padding(.horizontal, 12)
                                        .background(Color.appBackground)
                                        .cornerRadius(16)
                                }
                            }
                            .foregroundColor(.appSecondary)
                            
                        }
                        
                        
                        HStack {
                            Text("100.0 Gram")
                                .font(.system(size: 40, weight: .heavy))
                                .bold()
                                .foregroundColor(.appBackground)
                            Spacer()
                        }
                        
                        HStack {
                            Text("❤️ Your Daily Protein Goal is 240.5 Grams")
                            Image(systemName: "info.circle")
                            Spacer()
                        }
                        .font(.subheadline)
                        .foregroundColor(.appBackground)
                        
                        
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 12).fill( Color.appPrimary))
                    
                    
                    
                    
                    VStack(spacing: 10) {
                        Text("You've already taken in 140.2 Grams until now.").font(.subheadline).bold()
                        
                        ZStack (alignment: .leading) {
                            RoundedRectangle(cornerRadius: 2).fill(Color.gray).frame(height: 2)
                                .padding()
                            RoundedRectangle(cornerRadius: 2).fill(Color.blue).frame(width: 200, height: 3)
                                .padding()
                        }
                        
                        HistoryEntryRowView()
                        HistoryEntryRowView()
                        HistoryEntryRowView()

                        
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 12).fill( Color.appSecondary))
                    
                    VStack (alignment: .leading, spacing: 10 ) {
                        Text("Today's Plan")
                            .font(.subheadline)
                            .bold()
                        
                        Text("🌍 You’ve already planned 232.5g, still need extra 8.0 grams.")
                            .font(.subheadline)
                        
                        PlanEntryRowView()
                        PlanEntryRowView()
                        PlanEntryRowView()
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 12).fill(Color.appBackground).shadow(color: .primaryText.opacity(0.5), radius: 2, x: 0, y: 2))

                }
                .padding(20)
            }
            

            
            Button(
                action: {print("FAB Tapped!")}
            ) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.appPrimary)
                    .shadow(color: .primaryText.opacity(0.5), radius: 5, y: 3)
            }.padding()
            
            
            

            
        }
    }
}

#Preview {
    TodayView()
}
