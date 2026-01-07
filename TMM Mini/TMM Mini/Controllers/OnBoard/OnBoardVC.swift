//
//  OnBoardVC.swift
//  TMM Mini
//
//  Created by Brijesh Ajudia on 05/01/26.
//

import Combine
import UIKit

class OnBoardVC: UIViewController {

    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblPoints: UILabel!

    @IBOutlet weak var btnConnectHealth: CustomButton!

    // MARK: - ViewModel
    private lazy var viewModel = DependencyContainer.shared
        .makeOnBoardViewModel()
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
    }

    // MARK: - Setup UI
    private func setupUI() {
        let regularFont = [
            NSAttributedString.Key.font: AppFont.font(
                type: .I_Regular,
                size: 34.0
            )
        ]
        let boldFont = [
            NSAttributedString.Key.font: AppFont.font(type: .I_Bold, size: 34.0)
        ]

        let firstString = NSMutableAttributedString(
            string: "Your Health, ",
            attributes: regularFont
        )
        let secondString = NSMutableAttributedString(
            string: "Clearly Tracked.",
            attributes: boldFont
        )
        firstString.append(secondString)
        self.lblTitle.attributedText = firstString

        let bulletPoints = [
            "See your daily steps and calories at a glance",
            "Track weekly trends without the noise",
            "Stay motivated with simple insights",
        ]

        self.lblPoints.attributedText = Utils.sharedInstance.createBulletList(
            strings: bulletPoints
        )

        btnConnectHealth.lblTitle.font = AppFont.font(type: .I_Bold, size: 16)
        btnConnectHealth.onToggle = { [weak self] isPressed in
            if isPressed {
                self?.viewModel.connectHealthButtonTapped.send()
            }
        }
    }

    // MARK: - Setup Bindings
    private func setupBindings() {
        // Observe loading state
        viewModel.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                self?.updateLoadingState(isLoading: isLoading)
            }
            .store(in: &cancellables)
        
        viewModel.$authorizationStatus
            .receive(on: DispatchQueue.main)
            .dropFirst()
            .sink { [weak self] status in
                print("OnBoardVC: Status changed to \(status)")
                self?.handleAuthorizationStatus(status)
            }
            .store(in: &cancellables)
    }

    // MARK: - Handle Authorization Status
    private func handleAuthorizationStatus(_ status: HealthKitAuthorizationStatus) {
        switch status {
        case .authorized:
            redirectToHome()
            break

        case .denied:
            showLimitedModeAlert()

        case .notDetermined:
            showLimitedModeAlert()

        case .unavailable:
            showLimitedModeAlert()
        }
    }

    // MARK: - Update Loading State
    private func updateLoadingState(isLoading: Bool) {
        self.btnConnectHealth.isActive = isLoading
        self.btnConnectHealth.isUserInteractionEnabled = !isLoading
    }

    private func showLimitedModeAlert() {
        self.btnConnectHealth.isActive = false
        self.btnConnectHealth.isUserInteractionEnabled = true
        
        self.showCustomNotifyAlert { positive, negative in
            if positive {
                self.viewModel.openHealthSettings()
            } else {

            }
        }
    }

    // MARK: - Navigation
    private func redirectToHome() {
        Utils.sharedInstance.redirectToHome()
    }
}
