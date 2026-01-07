//
//  SplashVC.swift
//  TMM Mini
//
//  Created by Brijesh Ajudia on 05/01/26.
//

import Combine
import UIKit

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
    
    // Track animation state
    private var isAnimationComplete = false
    private var isDataLoaded = false
    
    // Store original positions
    private var logoOriginalCenter: CGPoint = .zero

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Store original center for animation reference
        if logoOriginalCenter == .zero {
            logoOriginalCenter = imgLogo.center
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startAnimationSequence()
        viewModel.viewDidAppear.send()
    }

    // MARK: - Setup UI
    private func setupUI() {
        lblAppName.font = AppFont.font(type: .I_Bold, size: 22)
        
        // Initially hide everything
        imgLogo.alpha = 0
        lblAppName.alpha = 0
        activityIndicator.alpha = 0
        activityIndicator.startAnimating()
    }

    // MARK: - Rich Animation Sequence
    private func startAnimationSequence() {
        // Step 1: Logo appears at center with scale
        animateLogoAppearance()
    }
    
    // Logo appears at center with bounce
    private func animateLogoAppearance() {
        imgLogo.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        
        UIView.animate(
            withDuration: 0.6,
            delay: 0.2,
            usingSpringWithDamping: 0.7,
            initialSpringVelocity: 0.5,
            options: .curveEaseOut,
            animations: {
                self.imgLogo.alpha = 1
                self.imgLogo.transform = CGAffineTransform(scaleX: 1.1, y: 1.1) // Slight overshoot
            }
        ) { _ in
            // Scale back and move up
            self.animateLogoMoveUp()
        }
    }
    
    // Logo moves up to top
    private func animateLogoMoveUp() {
        // Calculate final position (100pt from top)
        let finalY = view.safeAreaInsets.top + 100
        let finalCenter = CGPoint(x: logoOriginalCenter.x, y: finalY)
        
        UIView.animate(
            withDuration: 0.8,
            delay: 0.3,
            usingSpringWithDamping: 0.8,
            initialSpringVelocity: 0.3,
            options: .curveEaseInOut,
            animations: {
                // Scale back to normal
                self.imgLogo.transform = .identity
                
                // Move to top
                self.imgLogo.center = finalCenter
            }
        ) { _ in
            // Show app name
            self.animateAppNameAppearance()
        }
    }
    
    // App name fades in with slide up effect
    private func animateAppNameAppearance() {
        // Start below and slide up
        lblAppName.transform = CGAffineTransform(translationX: 0, y: 20)
        
        UIView.animate(
            withDuration: 0.6,
            delay: 0.1,
            options: .curveEaseOut,
            animations: {
                self.lblAppName.alpha = 1
                self.lblAppName.transform = .identity
            }
        ) { _ in
            // Animation complete
            self.isAnimationComplete = true
            self.showActivityIndicatorIfNeeded()
        }
    }
    
    // Show activity indicator only if data is still loading
    private func showActivityIndicatorIfNeeded() {
        if !isDataLoaded {
            print("SplashVC: Showing activity indicator")
            UIView.animate(withDuration: 0.3) {
                self.activityIndicator.alpha = 1
            }
        } else {
            print("SplashVC: Data already loaded, skipping activity indicator")
        }
    }
    
    // Hide activity indicator when data loads
    private func hideActivityIndicator() {
        print("SplashVC: Hiding activity indicator")
        UIView.animate(withDuration: 0.3) {
            self.activityIndicator.alpha = 0
        }
    }

    // MARK: - Setup Bindings
    private func setupBindings() {
        // Observe navigation destination
        viewModel.$navigationDestination
            .receive(on: DispatchQueue.main)
            .compactMap { $0 }
            .sink { [weak self] destination in
                print("SplashVC: Navigation destination received: \(destination)")
                self?.isDataLoaded = true
                self?.hideActivityIndicator()
                
                // Small delay before navigating for smooth transition
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self?.navigate(to: destination)
                }
            }
            .store(in: &cancellables)

        // Observe loading state
        viewModel.$isCheckingPermission
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isChecking in
                guard let self = self else { return }
                
                print("SplashVC: isChecking = \(isChecking)")
                
                if !isChecking {
                    self.isDataLoaded = true
                    self.hideActivityIndicator()
                } else if self.isAnimationComplete {
                    // Only show if animation is complete
                    self.showActivityIndicatorIfNeeded()
                }
            }
            .store(in: &cancellables)

        // Observe limited mode alert
        viewModel.$shouldShowLimitedMode
            .receive(on: DispatchQueue.main)
            .filter { $0 }
            .sink { [weak self] _ in
                print("SplashVC: Showing limited mode alert")
                self?.isDataLoaded = true
                self?.hideActivityIndicator()
                self?.showLimitedModeAlert()
            }
            .store(in: &cancellables)
    }

    // MARK: - Limited Mode Alert
    private func showLimitedModeAlert() {
        self.showCustomNotifyAlert { [weak self] positive, negative in
            if positive {
                print("SplashVC: User chose to open settings")
                self?.onBoardViewModel.openHealthSettings()
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    Utils.sharedInstance.redirectToOnboarding()
                }
            } else {
                print("SplashVC: User chose to continue")
                Utils.sharedInstance.redirectToOnboarding()
            }
        }
    }

    // MARK: - Navigation
    private func navigate(to destination: SplashViewModel.NavigationDestination) {
        // Fade out entire screen
        UIView.animate(
            withDuration: 0.4,
            animations: {
                self.view.alpha = 0
            }
        ) { _ in
            switch destination {
            case .onboarding:
                print("SplashVC: Navigating to onboarding")
                Utils.sharedInstance.redirectToOnboarding()
            case .home:
                print("SplashVC: Navigating to home")
                Utils.sharedInstance.redirectToHome()
            }
        }
    }
}
