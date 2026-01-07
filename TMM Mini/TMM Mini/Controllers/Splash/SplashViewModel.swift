//
//  SplashViewModel.swift
//  TMM Mini
//
//  Created by Brijesh Ajudia on 05/01/26.
//

import Combine
import Foundation

class SplashViewModel {

    // MARK: - Published Properties
    @Published var navigationDestination: NavigationDestination?
    @Published var isCheckingPermission: Bool = true
    @Published var shouldShowLimitedMode: Bool = false

    // MARK: - Navigation Destination
    enum NavigationDestination {
        case onboarding
        case home
    }

    // MARK: - Private Properties
    private let healthKitService: HealthKitServiceProtocol
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Inputs
    let viewDidAppear = PassthroughSubject<Void, Never>()

    // MARK: - Initialization
    init(healthKitService: HealthKitServiceProtocol = HealthKitService()) {
        self.healthKitService = healthKitService
        setupBindings()
    }

    // MARK: - Setup Bindings
    private func setupBindings() {
        viewDidAppear
            .sink { [weak self] _ in
                self?.checkPermissionAndNavigate()
            }
            .store(in: &cancellables)
    }

    // MARK: - Check Permission and Navigate
    func checkPermissionAndNavigate() {
        isCheckingPermission = true

        // Check if user has ever requested permission
        let hasRequested = UserDefaultHelper.shared.hasRequestedHealthKit

        if !hasRequested {
            // FIRST LAUNCH: Go directly to onboarding, NO alert
            print("SplashVM: First launch detected - navigating to onboarding")
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                [weak self] in
                self?.isCheckingPermission = false
                self?.shouldShowLimitedMode = false
                self?.navigationDestination = .onboarding
            }
            return
        }

        // NOT FIRST LAUNCH: Check actual permission status
        print("SplashVM: Returning user - checking HealthKit status")
        
        let minimumDisplayTime = Just(())
            .delay(for: .seconds(1.5), scheduler: DispatchQueue.main)

        Publishers.Zip(
            healthKitService.checkAuthorizationStatus(),
            minimumDisplayTime
        )
        .receive(on: DispatchQueue.main)
        .sink { [weak self] status, _ in
            self?.isCheckingPermission = false

            switch status {
            case .authorized:
                print("SplashVM: Authorized - navigating to home")
                self?.shouldShowLimitedMode = false
                self?.navigationDestination = .home

            case .denied, .notDetermined:
                print("SplashVM: Denied/NotDetermined - showing limited mode alert")
                self?.shouldShowLimitedMode = true
                // Don't set navigationDestination yet - wait for user choice in alert

            case .unavailable:
                print("SplashVM: HealthKit unavailable - showing limited mode alert")
                self?.shouldShowLimitedMode = true
            }
        }
        .store(in: &cancellables)
    }
}
