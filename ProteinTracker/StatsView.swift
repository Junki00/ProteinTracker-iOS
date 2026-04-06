//
//  StatsView.swift
//  ProteinTracker
//
//  Created by drx on 2025/07/21.
//

import Charts
import SwiftData
import SwiftUI

struct StatsView: View {
    @Query private var entries: [ProteinEntry]
    @Query private var userProfiles: [UserProfile]
    @State private var selectedDate: Date?

    private var weeklyData: [DailyProteinData] {
        ProteinDataStore.weeklyProteinData(entries: entries)
    }

    private var userProfile: UserProfile? {
        userProfiles.first
    }

    var body: some View {
        NavigationStack {
            ScrollView{
                VStack(spacing: 0) {
                    ProteinTrendChart(
                        weeklyData: weeklyData,
                        dailyGoal: userProfile?.dailyGoal ?? 0,
                        selectedDate: $selectedDate
                    )
                    .navigationTitle(String(localized: "stats.weeklyStatistics"))

                    if let selectedDate {
                        HStack(alignment: .firstTextBaseline, spacing: 4) {
                            Text(String(localized: "stats.detailsFor.\(selectedDate.formatted(.dateTime.weekday(.wide).day().month(.wide)))"))
                                .font(.caption)
                                .foregroundColor(.appSecondaryTextColor)

                            Text("\(ProteinDataStore.totalProtein(on: selectedDate, entries: entries), specifier: "%.1f")g")
                                .font(.caption)
                                .bold()
                                .foregroundColor(.appPrimaryColor)

                            Text(String(localized: "stats.consumed"))
                                .font(.caption)
                                .foregroundColor(.appSecondaryTextColor)

                            Spacer()
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 10)
                        .accessibilityElement(children: .combine)
                        .accessibilityLabel(
                            String(
                                localized: "accessibility.statsDetail.\(selectedDate.formatted(.dateTime.weekday(.wide).day().month(.wide))).\(String(format: "%.1f", ProteinDataStore.totalProtein(on: selectedDate, entries: entries)))"
                            )
                        )
                    }

                    if let selectedDate {
                        EntryCardView(type: .history, date: selectedDate)
                            .padding()
                    } else {
                        VStack {
                            Text(String(localized: "stats.tapBarHint"))
                                .font(.caption)
                                .foregroundColor(.appSecondaryTextColor)
                                .padding()
                        }
                        .frame(minHeight: 200)
                        .padding()
                    }
                    
                }
            }
            .background(Color.appBackgroundColor)
        }
    }
}

private struct ProteinTrendChart: View {
    let weeklyData: [DailyProteinData]
    let dailyGoal: Double
    @Binding var selectedDate: Date?

    var body: some View {
        Chart {
            ForEach(weeklyData) { dataPoint in
                let isSelected = selectedDate.map {
                    Calendar.current.isDate(dataPoint.date, inSameDayAs: $0)
                } ?? false

                BarMark(
                    x: .value("Date", dataPoint.date, unit: .day),
                    y: .value("Protein", dataPoint.totalProtein)
                )
                .foregroundStyle(isSelected ? Color.appPrimaryColor : Color.appAccentColor)
            }
        }
        .chartYScale(domain: 0...(max(dailyGoal, 1) * 4 / 3))
        .chartYAxis {
            AxisMarks()

            AxisMarks(values: [dailyGoal]) { _ in
                AxisGridLine(stroke: StrokeStyle(lineWidth: 1, dash: [5]))
                    .foregroundStyle(Color.appPrimaryColor)

                AxisValueLabel {
                    Text("\(dailyGoal, specifier: "%.0f")")
                        .foregroundStyle(Color.appPrimaryColor)
                        .font(.caption.bold())
                }
            }
        }
        .chartOverlay { proxy in
            GeometryReader { _ in
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

                                    selectedDate = selectedDay?.date

                                    if let dayData = selectedDay {
                                        if dayData.totalProtein >= dailyGoal {
                                            DS.Haptics.success()
                                        } else {
                                            DS.Haptics.light()
                                        }
                                    }
                                }
                            }
                    )
            }
        }
        .frame(height: 250)
        .padding()
        .background(Color.appCardBackgroundColor)
        .cornerRadius(28)
        .padding()
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(String(localized: "accessibility.weeklyChart"))
        .accessibilityValue(weeklyData.map { "\($0.date.formatted(.dateTime.weekday(.abbreviated))): \(String(format: "%.0f", $0.totalProtein))\(String(localized: "addEntry.grams"))" }.joined(separator: ", "))
        .accessibilityHint(String(localized: "accessibility.chartHint"))
    }
}

#Preview {
    StatsView()
        .modelContainer(ProteinDataStore.previewContainer())
}
