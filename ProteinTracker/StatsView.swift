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
            VStack(spacing: 0) {
                
                // Chart Section (Extracted View)
                ProteinTrendChart(
                    weeklyData: weeklyData,
                    dailyGoal: viewModel.dailyGoal,
                    selectedDate: $selectedDate
                )
                .navigationTitle("Weekly Statistics")
                
                // Detail Header Section
                if let selectedDate {
                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                        Text("Details for \(selectedDate, format: .dateTime.weekday(.wide).day().month(.wide)),")
                            .font(.caption)
                            .foregroundColor(.appSecondaryTextColor)
                        
                        Text("\(viewModel.totalProtein(on: selectedDate), specifier: "%.1f")g")
                            .font(.caption)
                            .bold()
                            .foregroundColor(.appPrimaryColor)
                        
                        Text("consumed.")
                            .font(.caption)
                            .foregroundColor(.appSecondaryTextColor)
                        
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 10)
                }
                
                // Scrollable List Section
                ScrollView {
                    if let selectedDate {
                        EntryCardView(type: .history, date: selectedDate)
                            .padding()
                    } else {
                        VStack {
                            Text("Tap on a bar to see daily details.")
                                .font(.caption)
                                .foregroundColor(.appSecondaryText)
                                .padding()
                        }
                        .frame(minHeight: 200)
                        .padding()
                    }
                }
            }
            .background(Color.appBackgroundColor) // Whole screen background
        }
    }
}

// MARK: - Subviews

private struct ProteinTrendChart: View {
    let weeklyData: [DailyProteinData]
    let dailyGoal: Double
    @Binding var selectedDate: Date?
    
    var body: some View {
        Chart {
            ForEach(weeklyData) { dataPoint in
                
                // Check if this bar is selected
                let isSelected = selectedDate.map {
                    Calendar.current.isDate(dataPoint.date, inSameDayAs: $0)
                } ?? false
                
                if isSelected {
                    BarMark(
                        x: .value("Date", dataPoint.date, unit: .day),
                        y: .value("Protein", dataPoint.totalProtein)
                    )
                    .foregroundStyle(Color.appPrimaryColor)
                } else {
                    BarMark(
                        x: .value("Date", dataPoint.date, unit: .day),
                        y: .value("Protein", dataPoint.totalProtein)
                    )
                    .foregroundStyle(Color.appAccentColor)
                }
            }
        }
        .chartYScale(domain: 0...(dailyGoal * 4 / 3))
        .chartYAxis {
            // 1. Default Axis Marks
            AxisMarks()
            
            // 2. Custom Goal Line and Label
            AxisMarks(values: [dailyGoal]) { _ in
                AxisGridLine(stroke: StrokeStyle(lineWidth: 1, dash: [5]))
                    .foregroundStyle(Color.appPrimary)
                
                AxisValueLabel {
                    Text("\(dailyGoal, specifier: "%.0f")")
                        .foregroundStyle(Color.appPrimary)
                        .font(.caption.bold())
                }
            }
        }
        .chartOverlay { proxy in
            GeometryReader { geometry in
                Rectangle()
                    .fill(Color.clear)
                    .contentShape(Rectangle())
                    .gesture(
                        SpatialTapGesture()
                            .onEnded { value in
                                if let date = proxy.value(atX: value.location.x, as: Date.self) {
                                    // Find the closest data point
                                    let selectedDay = weeklyData.min(by: {
                                        abs($0.date.distance(to: date)) < abs($1.date.distance(to: date))
                                    })
                                    
                                    self.selectedDate = selectedDay?.date
                                    
                                    // Haptic Feedback
                                    if let dayData = selectedDay {
                                        if dayData.totalProtein >= dailyGoal {
                                            UINotificationFeedbackGenerator().notificationOccurred(.success)
                                        } else {
                                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                        }
                                    }
                                }
                            }
                    )
            }
        }
        .frame(height: 250)
        .padding()
        .background(Color.appCardBackgroundColor) // Optional: Card background for chart
        .cornerRadius(28)
        .padding()
    }
}

#Preview {
    StatsView()
        .environmentObject(ProteinDataViewModel())
}
