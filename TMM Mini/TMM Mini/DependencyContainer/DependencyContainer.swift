//
//  DependencyContainer.swift
//  TMM Mini
//
//  Created by Brijesh Ajudia on 05/01/26.
//

import Foundation

class DependencyContainer {
    static let shared = DependencyContainer()
    
    private init() {}
    
    // MARK: - Repositories
    lazy var healthKitRepository: HealthKitRepositoryProtocol = {
        return HealthKitRepository()
    }()
    
    // MARK: - Services
    lazy var healthKitService: HealthKitServiceProtocol = {
        return HealthKitService(repository: healthKitRepository)
    }()
    
    // MARK: - ViewModels
    func makeSplashViewModel() -> SplashViewModel {
        return SplashViewModel(healthKitService: healthKitService)
    }
    
    func makeOnBoardViewModel() -> OnBoardViewModel {
        return OnBoardViewModel(healthKitService: healthKitService)
    }
}

extension DependencyContainer {
    
    // MARK: - Home
    func makeHomeViewModel() -> HomeViewModel {
        return HomeViewModel(
            healthKitService: makeHealthKitService(),
            dataRepository: makeHealthDataRepository()
        )
    }
    
    // MARK: - Health Data Repository
    func makeHealthDataRepository() -> HealthDataRepositoryProtocol {
        return HealthDataRepository()
    }
    
    // MARK: - HealthKit Service (if not already present)
    func makeHealthKitService() -> HealthKitServiceProtocol {
        return HealthKitService(repository: makeHealthKitRepository())
    }
    
    func makeHealthKitRepository() -> HealthKitRepositoryProtocol {
        return HealthKitRepository()
    }
}
