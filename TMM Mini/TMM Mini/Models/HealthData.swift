//
//  HealthData.swift
//  TMM Mini
//
//  Created by Brijesh Ajudia on 05/01/26.
//

import Foundation

// MARK: - HealthKit Models
struct HealthData {
    let stepCount: Double
    let activeEnergy: Double
    let date: Date
}

enum HealthKitAuthorizationStatus {
    case notDetermined
    case authorized
    case denied
    case unavailable
    
    var isAuthorized: Bool {
        return self == .authorized
    }
}

enum HealthKitError: Error {
    case unavailable
    case authorizationDenied
    case queryFailed
    case invalidData
    
    var localizedDescription: String {
        switch self {
        case .unavailable:
            return "HealthKit is not available on this device"
        case .authorizationDenied:
            return "HealthKit access was denied"
        case .queryFailed:
            return "Failed to fetch health data"
        case .invalidData:
            return "Invalid health data received"
        }
    }
}
