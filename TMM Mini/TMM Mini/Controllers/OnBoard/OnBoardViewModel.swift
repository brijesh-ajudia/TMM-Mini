//
//  OnBoardViewModel.swift
//  TMM Mini
//
//  Created by Brijesh Ajudia on 05/01/26.
//

import Combine
import Foundation
import UIKit

class OnBoardViewModel {
    
    // MARK: - Published Properties
    @Published var authorizationStatus: HealthKitAuthorizationStatus = .notDetermined
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    // MARK: - Private Properties
    private let healthKitService: HealthKitServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Inputs (Actions from View)
    let connectHealthButtonTapped = PassthroughSubject<Void, Never>()
    
    // MARK: - Outputs
    var showError: AnyPublisher<String, Never> {
        $errorMessage
            .compactMap { $0 }
            .eraseToAnyPublisher()
    }
    
    // MARK: - Initialization
    init(healthKitService: HealthKitServiceProtocol = HealthKitService()) {
        self.healthKitService = healthKitService
        setupBindings()
    }
    
    // MARK: - Setup Bindings
    private func setupBindings() {
        // When connect button tapped, request authorization
        connectHealthButtonTapped
            .sink { [weak self] _ in
                self?.requestHealthKitAuthorization()
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Request Authorization
    func requestHealthKitAuthorization() {
        isLoading = true
        errorMessage = nil
        
        print("OnBoardVM: Requesting HealthKit authorization...")
        
        healthKitService.requestAuthorization()
            .receive(on: DispatchQueue.main)
            .handleEvents(
                receiveOutput: { success in
                    // Mark that user has been asked for permission
                    print("OnBoardVM: Authorization dialog shown (success: \(success))")
                    UserDefaultHelper.shared.hasRequestedHealthKit = true
                },
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        print("OnBoardVM: Authorization request failed: \(error)")
                    }
                }
            )
        
        // The dialog closes but iOS needs a moment to update permissions
            .delay(for: .milliseconds(800), scheduler: DispatchQueue.main)
        // Now check the ACTUAL status by trying to read data
            .flatMap { [weak self] _ -> AnyPublisher<HealthKitAuthorizationStatus, Never> in
                guard let self = self else {
                    return Just(.notDetermined).eraseToAnyPublisher()
                }
                print("OnBoardVM: Checking actual authorization status...")
                return self.healthKitService.checkAuthorizationStatus()
            }
            .sink(
                receiveCompletion: { [weak self] completion in
                    // This completion is from the flatMap (checkAuthorizationStatus)
                    // which returns Never for error, so we only handle finished
                    if case .failure = completion {
                        // This shouldn't happen since checkAuthorizationStatus returns Never
                        // But keeping it for safety
                        self?.isLoading = false
                        print("OnBoardVM: Unexpected error in status check")
                    }
                },
                receiveValue: { [weak self] status in
                    self?.isLoading = false
                    self?.authorizationStatus = status
                    print("OnBoardVM: Final status = \(status)")
                }
            )
            .store(in: &cancellables)
    }
    
    // MARK: - Open Health Settings
    func openHealthSettings() {
        if let url = URL(string: "x-apple-health://") {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            } else {
                if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(settingsUrl)
                }
            }
        }
    }
}
