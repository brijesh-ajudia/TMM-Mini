//
//  HealthKitService.swift
//  TMM Mini
//
//  Created by Brijesh Ajudia on 05/01/26.
//

import Foundation
import Combine

// MARK: - HealthKit Service Protocol
protocol HealthKitServiceProtocol {
    func checkAuthorizationStatus() -> AnyPublisher<HealthKitAuthorizationStatus, Never>
    func requestAuthorization() -> AnyPublisher<Bool, HealthKitError>
    func getTodayHealthData() -> AnyPublisher<HealthData, HealthKitError>
    func getHealthData(for date: Date) -> AnyPublisher<HealthData, HealthKitError>
}

// MARK: - HealthKit Service Implementation
class HealthKitService: HealthKitServiceProtocol {
    
    private let repository: HealthKitRepositoryProtocol
    
    init(repository: HealthKitRepositoryProtocol = HealthKitRepository()) {
        self.repository = repository
    }
    
    func checkAuthorizationStatus() -> AnyPublisher<HealthKitAuthorizationStatus, Never> {
        return repository.checkAuthorizationStatus()
    }
    
    func requestAuthorization() -> AnyPublisher<Bool, HealthKitError> {
        return repository.requestAuthorization()
    }
    
    func getTodayHealthData() -> AnyPublisher<HealthData, HealthKitError> {
        return repository.fetchHealthData(for: Date())
    }
    
    func getHealthData(for date: Date) -> AnyPublisher<HealthData, HealthKitError> {
        return repository.fetchHealthData(for: date)
    }
}
