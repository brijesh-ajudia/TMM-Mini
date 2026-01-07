//
//  UserDefaultHelper.swift
//  TMM Mini
//
//  Created by Brijesh Ajudia on 05/01/26.
//

import Foundation

class UserDefaultHelper {
    fileprivate let userDefaults = UserDefaults.standard

    static let shared: UserDefaultHelper = {
        let instance = UserDefaultHelper()
        return instance
    }()

    private let hasRequestedHealthKitKey = "hasRequestedHealthKit"
    private let hasSeenOnboardingKey = "hasSeenOnboarding"

    var hasRequestedHealthKit: Bool {
        get { UserDefaults.standard.bool(forKey: hasRequestedHealthKitKey) }
        set {
            UserDefaults.standard.set(
                newValue,
                forKey: hasRequestedHealthKitKey
            )
        }
    }

    var hasSeenOnboarding: Bool {
        get { UserDefaults.standard.bool(forKey: hasSeenOnboardingKey) }
        set {
            UserDefaults.standard.set(newValue, forKey: hasSeenOnboardingKey)
        }
    }

    func reset() {
        UserDefaults.standard.removeObject(forKey: hasRequestedHealthKitKey)
        UserDefaults.standard.removeObject(forKey: hasSeenOnboardingKey)
    }

}
