//
//  HealthKitRepository.swift
//  TMM Mini
//
//  Created by Brijesh Ajudia on 05/01/26.
//

import HealthKit
import Combine

// MARK: - HealthKit Repository Protocol
protocol HealthKitRepositoryProtocol {
    func checkAuthorizationStatus() -> AnyPublisher<HealthKitAuthorizationStatus, Never>
    func requestAuthorization() -> AnyPublisher<Bool, HealthKitError>
    func fetchStepCount(for date: Date) -> AnyPublisher<Double, HealthKitError>
    func fetchActiveEnergy(for date: Date) -> AnyPublisher<Double, HealthKitError>
    func fetchHealthData(for date: Date) -> AnyPublisher<HealthData, HealthKitError>
}

// MARK: - HealthKit Repository Implementation
class HealthKitRepository: HealthKitRepositoryProtocol {
    
    private let healthStore = HKHealthStore()
    
    // MARK: - Check Authorization Status
    func checkAuthorizationStatus() -> AnyPublisher<HealthKitAuthorizationStatus, Never> {
        return Future<HealthKitAuthorizationStatus, Never> { [weak self] promise in
            guard let self = self else {
                promise(.success(.unavailable))
                return
            }
            
            guard HKHealthStore.isHealthDataAvailable() else {
                promise(.success(.unavailable))
                return
            }
            
            guard let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount) else {
                promise(.success(.unavailable))
                return
            }
            
            // Try to query recent data to check actual access
            let predicate = HKQuery.predicateForSamples(
                withStart: Date.distantPast,
                end: Date(),
                options: .strictEndDate
            )
            
            let query = HKSampleQuery(
                sampleType: stepType,
                predicate: predicate,
                limit: 1,
                sortDescriptors: nil
            ) { _, samples, error in
                if let error = error as NSError? {
                    print("HealthKit check error: \(error.localizedDescription) (code: \(error.code), domain: \(error.domain))")
                    
                    // Check for authorization error more reliably
                    if error.domain == HKErrorDomain {
                        // HKError.errorAuthorizationDenied = 4
                        // HKError.errorAuthorizationNotDetermined = 5
                        if error.code == HKError.errorAuthorizationDenied.rawValue {
                            print("HealthKit: Authorization explicitly denied")
                            promise(.success(.denied))
                            return
                        } else if error.code == HKError.errorAuthorizationNotDetermined.rawValue {
                            print("HealthKit: Authorization not determined")
                            // Check if we've asked before
                            if UserDefaultHelper.shared.hasRequestedHealthKit {
                                // Asked before but got notDetermined = likely denied
                                promise(.success(.denied))
                            } else {
                                promise(.success(.notDetermined))
                            }
                            return
                        }
                    }
                    
                    // Other errors - assume denied if we've asked before
                    if UserDefaultHelper.shared.hasRequestedHealthKit {
                        print("HealthKit: Unknown error after requesting - assuming denied")
                        promise(.success(.denied))
                    } else {
                        print("HealthKit: Unknown error before requesting - not determined")
                        promise(.success(.notDetermined))
                    }
                    return
                }
                
                // Query succeeded - we have access!
                print("HealthKit: Authorization confirmed (samples: \(samples?.count ?? 0))")
                promise(.success(.authorized))
            }
            
            self.healthStore.execute(query)
        }
        .eraseToAnyPublisher()
    }
    
    // MARK: - Request Authorization
    func requestAuthorization() -> AnyPublisher<Bool, HealthKitError> {
        return Future<Bool, HealthKitError> { [weak self] promise in
            guard let self = self else {
                promise(.failure(.unavailable))
                return
            }
            
            guard HKHealthStore.isHealthDataAvailable() else {
                promise(.failure(.unavailable))
                return
            }
            
            let typesToRead: Set<HKObjectType> = [
                HKQuantityType.quantityType(forIdentifier: .stepCount)!,
                HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!
            ]
            
            print("HealthKit: Requesting authorization...")
            
            self.healthStore.requestAuthorization(toShare: nil, read: typesToRead) { success, error in
                if let error = error {
                    print("HealthKit authorization error: \(error.localizedDescription)")
                    promise(.failure(.authorizationDenied))
                    return
                }
                
                // NOTE: success=true just means dialog was shown, NOT that user granted permission
                print("HealthKit: Authorization dialog completed (success: \(success))")
                promise(.success(success))
            }
        }
        .eraseToAnyPublisher()
    }
    
    // MARK: - Fetch Step Count
    func fetchStepCount(for date: Date) -> AnyPublisher<Double, HealthKitError> {
        return Future<Double, HealthKitError> { [weak self] promise in
            guard let self = self else {
                promise(.failure(.unavailable))
                return
            }
            
            // Check if HealthKit is available first
            guard HKHealthStore.isHealthDataAvailable() else {
                print("HealthKit: Not available on this device")
                promise(.failure(.unavailable))
                return
            }
            
            guard let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount) else {
                print("HealthKit: Step count type not available")
                promise(.failure(.invalidData))
                return
            }
            
            let startOfDay = Calendar.current.startOfDay(for: date)
            let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)!
            let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: endOfDay, options: .strictStartDate)
            
            let query = HKStatisticsQuery(
                quantityType: stepType,
                quantitySamplePredicate: predicate,
                options: .cumulativeSum
            ) { _, result, error in
                // Better error handling
                if let error = error {
                    let nsError = error as NSError
                    
                    // Check for authorization errors
                    if nsError.domain == HKErrorDomain {
                        if nsError.code == HKError.errorAuthorizationDenied.rawValue {
                            print("HealthKit: Authorization denied for steps")
                            promise(.failure(.authorizationDenied))
                            return
                        }
                    }
                    
                    print("HealthKit: Query failed for steps: \(error.localizedDescription)")
                    promise(.failure(.queryFailed))
                    return
                }
                
                // Return value or 0 if no data
                guard let result = result, let sum = result.sumQuantity() else {
                    print("HealthKit: No step data for \(startOfDay.toString(format: "MMM d"))")
                    promise(.success(0))
                    return
                }
                
                let steps = sum.doubleValue(for: HKUnit.count())
                print("HealthKit: Fetched \(Int(steps)) steps for \(startOfDay.toString(format: "MMM d"))")
                promise(.success(steps))
            }
            
            self.healthStore.execute(query)
        }
        .eraseToAnyPublisher()
    }

    // MARK: - Fetch Active Energy
    func fetchActiveEnergy(for date: Date) -> AnyPublisher<Double, HealthKitError> {
        return Future<Double, HealthKitError> { [weak self] promise in
            guard let self = self else {
                promise(.failure(.unavailable))
                return
            }
            
            // Check if HealthKit is available first
            guard HKHealthStore.isHealthDataAvailable() else {
                print("HealthKit: Not available on this device")
                promise(.failure(.unavailable))
                return
            }
            
            guard let energyType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned) else {
                print("HealthKit: Active energy type not available")
                promise(.failure(.invalidData))
                return
            }
            
            let startOfDay = Calendar.current.startOfDay(for: date)
            let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)!
            let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: endOfDay, options: .strictStartDate)
            
            let query = HKStatisticsQuery(
                quantityType: energyType,
                quantitySamplePredicate: predicate,
                options: .cumulativeSum
            ) { _, result, error in
                // Better error handling
                if let error = error {
                    let nsError = error as NSError
                    
                    // Check for authorization errors
                    if nsError.domain == HKErrorDomain {
                        if nsError.code == HKError.errorAuthorizationDenied.rawValue {
                            print("HealthKit: Authorization denied for calories")
                            promise(.failure(.authorizationDenied))
                            return
                        }
                    }
                    
                    print("HealthKit: Query failed for calories: \(error.localizedDescription)")
                    promise(.failure(.queryFailed))
                    return
                }
                
                // Return value or 0 if no data
                guard let result = result, let sum = result.sumQuantity() else {
                    print("HealthKit: No calorie data for \(startOfDay.toString(format: "MMM d"))")
                    promise(.success(0))
                    return
                }
                
                let calories = sum.doubleValue(for: HKUnit.kilocalorie())
                print("HealthKit: Fetched \(Int(calories)) calories for \(startOfDay.toString(format: "MMM d"))")
                promise(.success(calories))
            }
            
            self.healthStore.execute(query)
        }
        .eraseToAnyPublisher()
    }
    
    // MARK: - Fetch Complete Health Data
    func fetchHealthData(for date: Date) -> AnyPublisher<HealthData, HealthKitError> {
        return Publishers.Zip(
            fetchStepCount(for: date),
            fetchActiveEnergy(for: date)
        )
        .map { steps, energy in
            HealthData(stepCount: steps, activeEnergy: energy, date: date)
        }
        .eraseToAnyPublisher()
    }
}
