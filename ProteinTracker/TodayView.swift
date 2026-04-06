//
//  TodayView.swift
//  ProteinTracker
//
//  Created by drx on 2025/07/19.
//

import SwiftData
import SwiftUI

struct TodayView: View {
    @Query private var entries: [ProteinEntry]
    @Query private var userProfiles: [UserProfile]

    @State private var viewModel: TodayViewModel
    @State private var isShowingAddSheet = false
    @State private var isShowingList = true
    @State private var searchTerm = ""
    @State private var selectedProduct: Product?

    init(viewModel: TodayViewModel = TodayViewModel()) {
        _viewModel = State(initialValue: viewModel)
    }

    private let today = Date()

    private var userProfile: UserProfile? {
        userProfiles.first
    }

    private var totalProteinToday: Double {
        ProteinDataStore.totalProtein(on: today, entries: entries)
    }

    private var stillNeededToday: Double {
        ProteinDataStore.stillNeededProtein(on: today, entries: entries, profile: userProfile)
    }

    private var progressToday: Double {
        ProteinDataStore.progress(on: today, entries: entries, profile: userProfile)
    }

    var body: some View {
        NavigationStack {
            mainContent
                .searchable(text: $searchTerm, prompt: String(localized: "today.searchPrompt"))
                .onSubmit(of: .search) {
                    viewModel.performSearch(for: searchTerm)
                }
                .sheet(isPresented: $isShowingAddSheet) {
                    AddEntryModalView(date: today)
                }
                .sheet(item: $selectedProduct) { product in
                    AddEntryModalView(product: product, date: today)
                }
                .alert(String(localized: "today.searchFailed"), isPresented: $viewModel.isShowingErrorAlert, actions: {
                    Button(String(localized: "common.ok")) {}
                }, message: {
                    Text(viewModel.searchError?.localizedDescription ?? String(localized: "today.unknownError"))
                })
        }
    }

    @ViewBuilder
    private var mainContent: some View {
        if searchTerm.isEmpty {
            dashboardView
        } else {
            searchResultView
        }
    }

    private var dashboardView: some View {
        ZStack(alignment: .bottomTrailing) {
            ScrollView {
                VStack(spacing: DS.Spacing.l) {
                    headerSection
                    stillNeedCard
                    historyCard
                    Spacer().frame(height: 100)
                }
                .padding(DS.Spacing.m)
            }

            fabButton
        }
        .navigationTitle(String(localized: "tab.today"))
        .background(Color.appBackgroundColor)
    }

    private var searchResultView: some View {
        ZStack {
            Color.appBackgroundColor.ignoresSafeArea()

            if viewModel.isSearching {
                ProgressView()
                    .accessibilityLabel(String(localized: "accessibility.searching"))
            } else {
                List(viewModel.searchResults) { product in
                    SearchResultRowView(product: product)
                        .onTapGesture {
                            selectedProduct = product
                        }
                }
                .scrollContentBackground(.hidden)
            }
        }
    }

    private var headerSection: some View {
        HStack {
            Text("🌍 \(today, format: .dateTime.weekday().month().day()), \(String(localized: "today.goodDay \(userProfile?.userName ?? "User")"))")
                .font(.body)
            Spacer()
        }
    }

    private var stillNeedCard: some View {
        VStack {
            HStack {
                Text(String(localized: "today.stillNeed"))
                    .font(.headline)
                    .foregroundColor(.appBackgroundColor)
                Spacer()
            }
            .padding(.bottom, DS.Spacing.xxs)
            

            HStack(alignment: .firstTextBaseline, spacing: DS.Spacing.xs) {
                Text(verbatim: "\(String(format: "%.1f", stillNeededToday)) Grams")
                    .font(.system(size: 40, weight: .heavy))
                    .foregroundColor(.appBackgroundColor)
                    .contentTransition(.numericText())
                    .animation(DS.Animation.snappy, value: stillNeededToday)

                Spacer()
            }

            HStack {
                Text(String(localized: "today.dailyGoal.\(String(format: "%.1f", userProfile?.dailyGoal ?? 0))"))
                Spacer()
            }
            .font(.subheadline)
            .fontWeight(.medium)
            .foregroundColor(.appBackgroundColor)
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: DS.Radius.card).fill(Color.appPrimaryColor))
        .accessibilityElement(children: .combine)
        .accessibilityLabel(
            String(
                localized: "accessibility.stillNeed.\(String(format: "%.1f", stillNeededToday)).\(String(format: "%.1f", userProfile?.dailyGoal ?? 0))"
            )
        )
    }

    private var historyCard: some View {
        VStack {
            HStack {
                Text(String(localized: "today.alreadyTaken.\(String(format: "%.1f", totalProteinToday))"))
                    .font(.headline)
                    .foregroundColor(.appPrimaryTextColor.opacity(0.7))
                    .font(.subheadline)
                    .bold()
                Spacer()
                Image(systemName: "chevron.down")
                    .bold()
                    .rotationEffect(.degrees(isShowingList ? -90 : 0))
            }
            .padding(.top)
            .padding(.horizontal)
            .onTapGesture {
                DS.Haptics.medium()
                withAnimation(DS.Animation.snappy) {
                    isShowingList.toggle()
                }
            }
            .accessibilityElement(children: .combine)
            .accessibilityAddTraits(.isButton)
            .accessibilityLabel(String(localized: "accessibility.historyList"))
            .accessibilityValue(isShowingList ? String(localized: "accessibility.expanded") : String(localized: "accessibility.collapsed"))
            .accessibilityHint(String(localized: "accessibility.toggleHint"))

            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color.appSecondaryTextColor.opacity(0.3))
                GeometryReader { geometry in
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color.appPrimaryColor)
                        .frame(width: geometry.size.width * progressToday)
                        .animation(.spring(response: 0.5, dampingFraction: 0.9), value: progressToday)
                }
            }
            .frame(height: 4)
            .padding(.top)
            .padding(.horizontal)
            .padding(.bottom, 8)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(String(localized: "accessibility.progressBar"))
            .accessibilityValue(String(localized: "accessibility.progressPercent.\(Int(progressToday * 100))"))

            if isShowingList {
                EntryCardView(type: .history, date: today)
            }
        }
        .padding(isShowingList ? .top : .vertical)
        .background(RoundedRectangle(cornerRadius: 28).fill(Color.appAccentColor))
    }

    private var fabButton: some View {
        Button(
            action: {
                DS.Haptics.medium()
                isShowingAddSheet = true
            }
        ) {
            Image(systemName: "plus.circle.fill")
                .font(.system(size: 50))
                .foregroundColor(.appPrimaryColor)
                .shadow(color: .appPrimaryTextColor.opacity(0.3), radius: 5, y: 3)
        }
        .accessibilityLabel(String(localized: "accessibility.addEntry"))
        .padding()
    }

}

private struct SearchResultRowView: View {
    let product: Product

    var body: some View {
        VStack(alignment: .leading) {
            Text(product.productName ?? String(localized: "today.unknownProduct"))
                .font(.headline)
            Text(String(localized: "today.proteinPer100g.\(String(format: "%.1f", product.proteinValue))"))
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(product.productName ?? String(localized: "today.unknownProduct")), \(String(localized: "today.proteinPer100g.\(String(format: "%.1f", product.proteinValue))"))")
    }
}

#Preview {
    TodayView()
        .modelContainer(ProteinDataStore.previewContainer())
}
