//
//  HomeViewModel.swift
//  TMM Mini
//
//  Created by Brijesh Ajudia on 05/01/26.
//

import Foundation
import Combine

// MARK: - Carousel Insight Model
struct CarouselInsight {
    let title: String
    let subtitle: String
    let iconName: String
}

enum HomeViewState: Equatable {
    case loading
    case loaded
    case empty
    case error(String)
    
    static func == (lhs: HomeViewState, rhs: HomeViewState) -> Bool {
        switch (lhs, rhs) {
        case (.loading, .loading): return true
        case (.loaded, .loaded): return true
        case (.empty, .empty): return true
        case (.error, .error): return true
        default: return false
        }
    }
}

class HomeViewModel {
    
    // MARK: - Published Properties
    @Published var healthData: HealthData?
    @Published var last7DaysData: [HealthData] = []
    @Published var carouselInsights: [CarouselInsight] = []
    @Published var viewState: HomeViewState = .loading
    @Published var isRefreshing: Bool = false
    
    // MARK: - Computed Properties for Rings
    var stepsProgress: Double {
        guard let data = healthData else { return 0 }
        return min(data.stepCount / 10000.0, 1.5) // 10,000 steps goal, max 1.5 for overflow
    }
    
    var caloriesProgress: Double {
        guard let data = healthData else { return 0 }
        return min(data.activeEnergy / 500.0, 1.5) // 500 calories goal, max 1.5 for overflow
    }
    
    // MARK: - Private Properties
    private let healthKitService: HealthKitServiceProtocol
    private let dataRepository: HealthDataRepositoryProtocol
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Inputs
    let viewDidLoad = PassthroughSubject<Void, Never>()
    let refreshData = PassthroughSubject<Void, Never>()
    
    // MARK: - Initialization
    init(
        healthKitService: HealthKitServiceProtocol = HealthKitService(),
        dataRepository: HealthDataRepositoryProtocol = HealthDataRepository()
    ) {
        self.healthKitService = healthKitService
        self.dataRepository = dataRepository
        setupBindings()
    }
    
    // MARK: - Setup Bindings
    private func setupBindings() {
        // View Did Load - Load cached data first, then fetch fresh
        viewDidLoad
            .sink { [weak self] _ in
                self?.loadInitialData()
            }
            .store(in: &cancellables)
        
        // Refresh Data - Force fetch from HealthKit
        refreshData
            .sink { [weak self] _ in
                self?.refreshHealthData()
            }
            .store(in: &cancellables)
    }
    
    private func loadInitialData() {
        print(" HomeVM: Loading initial data...")
        viewState = .loading
        
        // NEW: Check authorization FIRST
        healthKitService.checkAuthorizationStatus()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] status in
                guard let self = self else { return }
                
                switch status {
                case .authorized:
                    print(" HomeVM: HealthKit authorized")
                    // Load cached data
                    self.loadCachedData()
                    
                    // Fetch fresh data
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        self.fetchFreshHealthData()
                    }
                    
                case .denied, .notDetermined, .unavailable:
                    print("HomeVM: No HealthKit access, using cached data only")
                    self.loadCachedData()
                    
                    if self.healthData == nil {
                        self.viewState = .empty
                    } else {
                        self.viewState = .loaded
                    }
                }
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Load Cached Data
    private func loadCachedData() {
        // Load today's cached data
        if let cachedToday = dataRepository.fetchHealthData(for: Date()) {
            print("HomeVM: Loaded cached data for today")
            self.healthData = cachedToday
        }
        
        // Load last 7 days cached data
        let calendar = Calendar.current
        if let sevenDaysAgo = calendar.date(byAdding: .day, value: -6, to: Date()) {
            let cachedData = dataRepository.fetchHealthDataRange(from: sevenDaysAgo, to: Date())
            
            if !cachedData.isEmpty {
                print("HomeVM: Loaded \(cachedData.count) days of cached data")
                self.last7DaysData = ensureComplete7Days(cachedData)
                self.calculateCarouselInsights()
                
                // If we have cached data, show it
                self.viewState = .loaded
            }
        }
    }
    
    // MARK: - Fetch Fresh Health Data
    private func fetchFreshHealthData() {
        print("HomeVM: Fetching fresh data from HealthKit...")
        
        // Fetch last 7 days from HealthKit
        fetchLast7DaysFromHealthKit()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    guard let self = self else { return }
                    
                    if case .failure(let error) = completion {
                        print("HomeVM: Error fetching health data: \(error)")
                        
                        switch error {
                        case .authorizationDenied, .unavailable:
                            print("HomeVM: HealthKit not accessible")
                            if self.healthData != nil {
                                self.viewState = .loaded
                            } else {
                                self.viewState = .empty
                            }
                            
                        case .queryFailed, .invalidData:
                            print("HomeVM: Query failed, keeping cached data")
                            if self.healthData != nil {
                                self.viewState = .loaded
                            } else {
                                self.viewState = .empty
                            }
                        }
                    }
                },
                receiveValue: { [weak self] weekData in
                    guard let self = self else { return }
                    
                    print("HomeVM: Fetched \(weekData.count) days from HealthKit")
                    
                    // Log all fetched data with indices
                    print("Complete week data (sorted):")
                    for (index, data) in weekData.enumerated() {
                        print("   [\(index)] \(data.date.toString(format: "MMM d (EEE)")): \(Int(data.stepCount)) steps, \(Int(data.activeEnergy)) cal")
                    }
                    
                    // Filter out days with all zeros (failed fetches)
                    let validData = weekData.filter { $0.stepCount > 0 || $0.activeEnergy > 0 }
                    
                    if validData.isEmpty && self.healthData == nil {
                        print("HomeVM: No valid health data available")
                        self.viewState = .empty
                        return
                    }
                    
                    // Log what .last returns
                    if let last = weekData.last {
                        print("weekData.last = \(last.date.toString(format: "MMM d")): \(Int(last.stepCount)) steps, \(Int(last.activeEnergy)) cal")
                    }
                    
                    // Verify it's actually today
                    let todayDate = Calendar.current.startOfDay(for: Date())
                    print("Today's date = \(todayDate.toString(format: "MMM d (EEE)"))")
                    
                    // Find today explicitly instead of using .last
                    if let today = weekData.first(where: { Calendar.current.isDate($0.date, inSameDayAs: todayDate) }) {
                        print("Found today's data: \(Int(today.stepCount)) steps, \(Int(today.activeEnergy)) cal")
                        self.healthData = today
                    } else if let last = weekData.last {
                        print("No exact match for today, using last: \(Int(last.stepCount)) steps, \(Int(last.activeEnergy)) cal")
                        self.healthData = last
                    } else {
                        print("No data available for today!")
                    }
                    
                    // Verify healthData was set correctly
                    if let current = self.healthData {
                        print("CURRENT healthData = \(current.date.toString(format: "MMM d")): \(Int(current.stepCount)) steps, \(Int(current.activeEnergy)) cal")
                    }
                    
                    // Update 7 days data
                    self.last7DaysData = weekData
                    
                    // Save to CoreData
                    self.saveToCoreData(weekData)
                    
                    // Calculate carousel insights
                    self.calculateCarouselInsights()
                    
                    // Update state
                    self.viewState = .loaded
                    
                    // Clean up old data (older than 30 days)
                    self.dataRepository.deleteOldData(olderThan: 30)
                }
            )
            .store(in: &cancellables)
    }
    
    // RefreshHealthData with same logging
    private func refreshHealthData() {
        print("HomeVM: Pull to refresh triggered")
        isRefreshing = true
        
        fetchLast7DaysFromHealthKit()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isRefreshing = false
                    
                    if case .failure(let error) = completion {
                        print("HomeVM: Refresh error: \(error)")
                    }
                },
                receiveValue: { [weak self] weekData in
                    guard let self = self else { return }
                    
                    print("HomeVM: Refreshed \(weekData.count) days")
                    
                    // Log all data
                    print("Refreshed data:")
                    for (index, data) in weekData.enumerated() {
                        print("   [\(index)] \(data.date.toString(format: "MMM d")): \(Int(data.stepCount)) steps, \(Int(data.activeEnergy)) cal")
                    }
                    
                    // Find today explicitly
                    let todayDate = Calendar.current.startOfDay(for: Date())
                    if let today = weekData.first(where: { Calendar.current.isDate($0.date, inSameDayAs: todayDate) }) {
                        print("Found today's data: \(Int(today.stepCount)) steps, \(Int(today.activeEnergy)) cal")
                        self.healthData = today
                    } else if let last = weekData.last {
                        print("Using last as fallback: \(Int(last.stepCount)) steps, \(Int(last.activeEnergy)) cal")
                        self.healthData = last
                    }
                    
                    // Verify
                    if let current = self.healthData {
                        print("AFTER REFRESH healthData = \(Int(current.stepCount)) steps, \(Int(current.activeEnergy)) cal")
                    }
                    
                    self.last7DaysData = weekData
                    
                    // Save to CoreData
                    self.saveToCoreData(weekData)
                    
                    // Recalculate insights
                    self.calculateCarouselInsights()
                    
                    self.viewState = weekData.isEmpty ? .empty : .loaded
                }
            )
            .store(in: &cancellables)
    }
    
    // MARK: - Fetch Last 7 Days from HealthKit
    private func fetchLast7DaysFromHealthKit() -> AnyPublisher<[HealthData], HealthKitError> {
        let calendar = Calendar.current
        var publishers: [AnyPublisher<HealthData, HealthKitError>] = []
        
        for dayOffset in (0...6).reversed() {
            if let date = calendar.date(byAdding: .day, value: -dayOffset, to: Date()) {
                let publisher = healthKitService.getHealthData(for: date)
                    .catch { error -> AnyPublisher<HealthData, HealthKitError> in
                        let emptyData = HealthData(
                            stepCount: 0,
                            activeEnergy: 0,
                            date: calendar.startOfDay(for: date)
                        )
                        return Just(emptyData)
                            .setFailureType(to: HealthKitError.self)
                            .eraseToAnyPublisher()
                    }
                    .eraseToAnyPublisher()
                
                publishers.append(publisher)
            }
        }
        
        return Publishers.MergeMany(publishers)
            .collect()
            .map { $0.sorted { $0.date < $1.date } }
            .eraseToAnyPublisher()
    }
    
    // MARK: - Save to CoreData
    private func saveToCoreData(_ healthDataArray: [HealthData]) {
        for data in healthDataArray {
            dataRepository.saveHealthData(
                date: data.date,
                stepCount: data.stepCount,
                activeEnergy: data.activeEnergy
            )
        }
    }
    
    // MARK: - Ensure Complete 7 Days
    private func ensureComplete7Days(_ data: [HealthData]) -> [HealthData] {
        let calendar = Calendar.current
        var completeData: [HealthData] = []
        
        for dayOffset in (0...6).reversed() {
            if let date = calendar.date(byAdding: .day, value: -dayOffset, to: Date()) {
                let startOfDay = calendar.startOfDay(for: date)
                
                // Find existing data for this date
                if let existing = data.first(where: {
                    calendar.isDate($0.date, inSameDayAs: startOfDay)
                }) {
                    completeData.append(existing)
                } else {
                    // Create empty data for missing date
                    completeData.append(HealthData(stepCount: 0, activeEnergy: 0, date: startOfDay))
                }
            }
        }
        
        return completeData
    }
    
    // MARK: - Calculate Carousel Insights
    private func calculateCarouselInsights() {
        guard !last7DaysData.isEmpty else {
            carouselInsights = []
            return
        }
        
        var insights: [CarouselInsight] = []
        
        // 1. Best Day This Week (based on both steps and calories)
        if let bestDay = findBestDayThisWeek() {
            let dayName = bestDay.date.toString(format: "EEEE")
            let steps = Int(bestDay.stepCount)
            let calories = Int(bestDay.activeEnergy)
            
            insights.append(CarouselInsight(
                title: "Best day this week",
                subtitle: "\(dayName) · \(steps.formatted()) steps · \(calories) cal",
                iconName: "chart.bar.fill"
            ))
        }
        
        // 2. Compared to Last Week
        if let comparison = calculateWeekComparison() {
            insights.append(comparison)
        }
        
        // 3. 7-Day Average (Steps only)
        let avgSteps = calculate7DayAverage()
        insights.append(CarouselInsight(
            title: "7-day average",
            subtitle: "\(Int(avgSteps).formatted()) steps / day",
            iconName: "figure.walk.circle.fill"
        ))
        
        self.carouselInsights = insights
        print("HomeVM: Calculated \(insights.count) carousel insights")
    }
    
    // MARK: - Find Best Day This Week
    private func findBestDayThisWeek() -> HealthData? {
        // Combine steps and calories score (weighted)
        return last7DaysData.max { first, second in
            let firstScore = (first.stepCount / 10000.0) + (first.activeEnergy / 500.0)
            let secondScore = (second.stepCount / 10000.0) + (second.activeEnergy / 500.0)
            return firstScore < secondScore
        }
    }
    
    // MARK: - Calculate Week Comparison
    private func calculateWeekComparison() -> CarouselInsight? {
        // Get data from CoreData for previous week (days 7-13)
        let calendar = Calendar.current
        guard let twoWeeksAgo = calendar.date(byAdding: .day, value: -13, to: Date()),
              let oneWeekAgo = calendar.date(byAdding: .day, value: -7, to: Date()) else {
            return nil
        }
        
        let previousWeekData = dataRepository.fetchHealthDataRange(from: twoWeeksAgo, to: oneWeekAgo)
        
        guard !previousWeekData.isEmpty else { return nil }
        
        // Calculate averages
        let currentWeekAvg = last7DaysData.reduce(0.0) { $0 + $1.stepCount } / Double(last7DaysData.count)
        let previousWeekAvg = previousWeekData.reduce(0.0) { $0 + $1.stepCount } / Double(previousWeekData.count)

        let subtitle: String
        let iconName: String

        if previousWeekAvg == 0 {
            if currentWeekAvg > 0 {
                subtitle = "Great start this week!"
                iconName = "arrow.up.right"
            } else {
                subtitle = "No data to compare"
                iconName = "equal"
            }
        } else {
            // Calculate percentage difference
            let percentChange = ((currentWeekAvg - previousWeekAvg) / previousWeekAvg) * 100
            
            if percentChange > 0 {
                subtitle = "You're +\(Int(percentChange))% ahead"
                iconName = "arrow.up.right"
            } else if percentChange < 0 {
                subtitle = "You're \(Int(abs(percentChange)))% behind"
                iconName = "arrow.down.right"
            } else {
                subtitle = "Same as last week"
                iconName = "equal"
            }
        }
        
        return CarouselInsight(
            title: "Compared to last week",
            subtitle: subtitle,
            iconName: iconName
        )
    }
    
    // MARK: - Calculate 7-Day Average
    private func calculate7DayAverage() -> Double {
        guard !last7DaysData.isEmpty else { return 0 }
        let total = last7DaysData.reduce(0.0) { $0 + $1.stepCount }
        return total / Double(last7DaysData.count)
    }
}
