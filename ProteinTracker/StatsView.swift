//
//  StatsView.swift
//  ProteinTracker
//
//  Created by drx on 2025/07/21.
//

import SwiftUI
import Charts

struct StatsView: View {
    @EnvironmentObject var viewModel: ProteinDataViewModel
    @State private var selectedDate: Date?
    
    var body: some View {
        let weeklyData = viewModel.getWeeklyProteinData()

        
        NavigationStack {
            VStack(spacing:0) {
                VStack {
                        Chart {
                            ForEach(weeklyData) { dataPoint in
                                
                                let isSelected = {
                                    if let selectedDate = self.selectedDate {
                                        return Calendar.current.isDate(dataPoint.date, inSameDayAs: selectedDate)
                                    }
                                    return false
                                }()
                                
                                if isSelected {
                                    BarMark(
                                        x: .value("Date", dataPoint.date, unit: .day),
                                        y: .value("protein", dataPoint.totalProtein)
                                    )
                                    .foregroundStyle(Color.appPrimary)
                                    .annotation(position: .top) {
                                        Image(systemName: "arrow.down")
                                            .font(.caption)
                                            .foregroundColor(.appPrimary)
                                    }
                                } else {
                                    BarMark(
                                        x: .value("Date", dataPoint.date, unit: .day),
                                        y: .value("protein", dataPoint.totalProtein)
                                    )
                                    .foregroundStyle(Color.appSecondary)
                                }
                            }
                            
                            RuleMark(
                                y: .value("Daily Goal", viewModel.dailyGoal)
                            )
                            .foregroundStyle(Color.appPrimary)
                            .annotation(position: .top, alignment: .leading) {
                                Text("Goal")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .chartYScale(domain: 0...(viewModel.dailyGoal * 4 / 3))
                        .chartOverlay { proxy in
                            GeometryReader { geometry in
                                Rectangle()
                                    .fill(Color.clear)
                                    .contentShape(Rectangle())
                                    .gesture(
                                        SpatialTapGesture()
                                            .onEnded { value in
                                                if let date = proxy.value(atX: value.location.x, as: Date.self) {
                                                    let selectedDay = weeklyData.min(by: {
                                                        abs($0.date.distance(to: date)) < abs($1.date.distance(to: date))
                                                    })
                                                    
                                                    self.selectedDate = selectedDay?.date
                                                }
                                            }
                                    )
                            }
                        }
                        .frame(height: 300)
                        .padding()
                    }
                    .navigationTitle("Weekly Statistics")
                            
                ScrollView {
                    if let selectedDate {
                        HStack {
                            Text("Details for \(selectedDate, format: .dateTime.weekday(.wide).day().month(.wide))")
                                .font(.caption)
                                .foregroundColor(.primaryText)
                            Spacer()
                        }
                        .padding(.horizontal)
                        EntryCardView(type: .history, date: selectedDate)
                            .padding(.vertical)
                            .background(RoundedRectangle(cornerRadius: 12).fill( Color.appSecondary))
                            .padding()
                    } else {
                        VStack {
                            Text("Tap on a bar to see daily details.")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding()
                        }
                        .frame(minHeight: 200)
                        .padding()
                    }
                }
            }
        }

    }
}

#Preview {
    StatsView()
        .environmentObject(ProteinDataViewModel())
}




