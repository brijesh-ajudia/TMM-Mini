//
//  SplashVC.swift
//  TMM Mini
//
//  Created by Brijesh Ajudia on 05/01/26.
//

import Combine
import UIKit

class SplashVC: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet weak var imgLogo: UIImageView!
    @IBOutlet weak var lblAppName: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    // MARK: - ViewModel
    private lazy var viewModel = DependencyContainer.shared
        .makeSplashViewModel()
    private lazy var onBoardViewModel = DependencyContainer.shared
        .makeOnBoardViewModel()
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.viewDidAppear.send()
    }

    // MARK: - Setup UI
    private func setupUI() {
        lblAppName.font = AppFont.font(type: .I_Bold, size: 24)
        activityIndicator.startAnimating()

        animateUIElements()
    }

    // MARK: - Animations
    private func animateUIElements() {
        imgLogo.alpha = 0
        imgLogo.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        lblAppName.alpha = 0

        UIView.animate(
            withDuration: 0.8,
            delay: 0.2,
            usingSpringWithDamping: 0.7,
            initialSpringVelocity: 0.5,
            options: .curveEaseOut
        ) {
            self.imgLogo.alpha = 1
            self.imgLogo.transform = .identity
        }

        UIView.animate(withDuration: 0.8, delay: 0.4, options: .curveEaseOut) {
            self.lblAppName.alpha = 1
        }
    }

    // MARK: - Setup Bindings
    private func setupBindings() {
        // Observe navigation destination
        viewModel.$navigationDestination
            .receive(on: DispatchQueue.main)
            .compactMap { $0 }
            .sink { [weak self] destination in
                self?.navigate(to: destination)
            }
            .store(in: &cancellables)

        // Observe loading state
        viewModel.$isCheckingPermission
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isChecking in
                self?.activityIndicator.isHidden = !isChecking
            }
            .store(in: &cancellables)

        viewModel.$shouldShowLimitedMode
            .receive(on: DispatchQueue.main)
            .filter { $0 }
            .sink { [weak self] _ in
                print("SplashVC: Showing limited mode alert for returning user")
                self?.showLimitedModeAlert()
            }
            .store(in: &cancellables)
    }

    // MARK: - Handle Authorization Status
    private func handleAuthorizationStatus(
        _ status: HealthKitAuthorizationStatus?
    ) {
        guard let status = status else { return }

        switch status {
        case .authorized:
            print("SplashVC: HealthKit not accessible - Status: \(status)")
            break

        case .denied, .notDetermined, .unavailable:
            print("SplashVC: HealthKit not accessible - Status: \(status)")
            showLimitedModeAlert()
        }
    }

    // MARK: - Limited Mode Alert
    private func showLimitedModeAlert() {
        self.showCustomNotifyAlert { [weak self] positive, negative in
            if positive {
                // Open Health Settings
                self?.onBoardViewModel.openHealthSettings()
            } else {
                // Continue to onboarding
                Utils.sharedInstance.redirectToOnboarding()
            }
        }
    }

    // MARK: - Navigation
    private func navigate(to destination: SplashViewModel.NavigationDestination) {
        // Add fade out animation before navigation
        UIView.animate(
            withDuration: 0.3,
            animations: {
                self.view.alpha = 0
            }
        ) { _ in
            switch destination {
            case .onboarding:
                Utils.sharedInstance.redirectToOnboarding()
            case .home:
                Utils.sharedInstance.redirectToHome()
            }
        }
    }
}
