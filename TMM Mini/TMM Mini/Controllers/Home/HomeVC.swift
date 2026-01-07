//
//  HomeVC.swift
//  TMM Mini
//
//  Created by Brijesh Ajudia on 05/01/26.
//

import UIKit
import SwiftUI
import Lottie
import Combine
import SkeletonView

class HomeVC: UIViewController {
    
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var btnLogMeal: UIButton!
    
    
    @IBOutlet weak var tblHealthData: UITableView!
    @IBOutlet weak var emptyView: CustomEmptyView!
    
    private lazy var viewModel = DependencyContainer.shared.makeHomeViewModel()
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Private Properties
    private var animationView: LottieAnimationView?
    private lazy var refreshControl: UIRefreshControl = {
        let refresh = UIRefreshControl()
        refresh.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        return refresh
    }()

    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.lblDate.text = Date().toStringWithDay_DMMM(format: "EEEE, d MMM")
        
        self.setUpUI()
        self.setupBindings()
        
        // Trigger initial data load
        viewModel.viewDidLoad.send()
        
        let healthKitService = HealthKitService()
        healthKitService.checkAuthorizationStatus()
            .sink { status in
                print("DEBUG: HealthKit Status = \(status)")
            }
            .store(in: &cancellables)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    // MARK: - Setup UI
    func setUpUI() {
        self.tblHealthData.register(cellTypes: [
            RingsTVCell.self,
            ChartTVCell.self,
            CarouselTVCell.self,
            CustomButtonTVCell.self
        ])
        
        self.tblHealthData.backgroundColor = UIColor.BG
        self.tblHealthData.separatorStyle = .none
        self.tblHealthData.showsVerticalScrollIndicator = false
        
        var frame = CGRect.zero
        frame.size.height = .leastNormalMagnitude
        self.tblHealthData.tableHeaderView = UIView(frame: frame)
        self.tblHealthData.tableFooterView = UIView(frame: .zero)
        
        let insets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        self.tblHealthData.contentInset = insets
        self.tblHealthData.estimatedRowHeight = 5
        self.tblHealthData.contentInsetAdjustmentBehavior = .never
        self.tblHealthData.isUserInteractionEnabled = true
        
        self.tblHealthData.delegate = self
        self.tblHealthData.dataSource = self
        
        // Add pull to refresh
        self.tblHealthData.refreshControl = refreshControl
        
        // Setup skeleton
        setupSkeleton()
    }
    
    // MARK: - Setup Skeleton
    private func setupSkeleton() {
        // Enable skeleton on table view
        tblHealthData.isSkeletonable = true
        
        // Configure skeleton appearance
        SkeletonAppearance.default.gradient = SkeletonGradient(
            baseColor: UIColor.systemGray5,
            secondaryColor: UIColor.systemGray6
        )
        SkeletonAppearance.default.multilineHeight = 20
        SkeletonAppearance.default.multilineSpacing = 8
        SkeletonAppearance.default.multilineLastLineFillPercent = 70
        SkeletonAppearance.default.multilineCornerRadius = 8
    }
    
    // MARK: - Setup Bindings
    private func setupBindings() {
        // Observe view state
        viewModel.$viewState
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.handleViewState(state)
            }
            .store(in: &cancellables)
        
        // Observe refresh state
        viewModel.$isRefreshing
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isRefreshing in
                if !isRefreshing {
                    self?.refreshControl.endRefreshing()
                }
            }
            .store(in: &cancellables)
        
        // Observe data changes to reload table
        viewModel.$healthData
            .receive(on: DispatchQueue.main)
            .dropFirst()
            .sink { [weak self] _ in
                self?.tblHealthData.reloadData()
            }
            .store(in: &cancellables)
        
        viewModel.$last7DaysData
            .receive(on: DispatchQueue.main)
            .dropFirst()
            .sink { [weak self] _ in
                self?.tblHealthData.reloadData()
            }
            .store(in: &cancellables)
        
        viewModel.$carouselInsights
            .receive(on: DispatchQueue.main)
            .dropFirst()
            .sink { [weak self] _ in
                self?.tblHealthData.reloadData()
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Handle View State
    private func handleViewState(_ state: HomeViewState) {
        switch state {
        case .loading:
            print("HomeVC: Loading state - showing skeleton")
            self.emptyView.isHidden = true
            tblHealthData.isHidden = false
            showSkeleton()
            
        case .loaded:
            print("HomeVC: Loaded state - showing data")
            hideSkeleton()
            self.emptyView.isHidden = true
            tblHealthData.isHidden = false
            tblHealthData.reloadData()
            
        case .empty:
            print("HomeVC: Empty state - no data")
            hideSkeleton()
            tblHealthData.isHidden = true
            self.emptyView.isHidden = false
            
        case .error(let message):
            print("HomeVC: Error state - \(message)")
            hideSkeleton()
            // Show error alert or keep showing cached data
            if viewModel.healthData == nil {
                tblHealthData.isHidden = true
                self.emptyView.isHidden = false
            } else {
                tblHealthData.reloadData()
            }
        }
    }
    
    // MARK: - Skeleton Methods
    private func showSkeleton() {
        
        let gradient = SkeletonGradient(baseColor: .systemGray5, secondaryColor: .systemGray6)
        
        let animation = SkeletonAnimationBuilder()
            .makeSlidingAnimation(withDirection: .leftRight)
        
        tblHealthData.showAnimatedGradientSkeleton(
            usingGradient: gradient,
            animation: animation,
            transition: .crossDissolve(0.25)
        )
    }
    
    private func hideSkeleton() {
        tblHealthData.hideSkeleton(transition: .crossDissolve(0.25))
    }
    
    // MARK: - Pull to Refresh
    @objc private func handleRefresh() {
        print("🔄 HomeVC: Pull to refresh triggered")
        showSkeleton()
        viewModel.refreshData.send()
    }
    
    // MARK: - Confetti Animation
    func showConfettiAboveButton(for cell: CustomButtonTVCell) {
        // Remove existing animation
        animationView?.removeFromSuperview()
        
        // Create animation
        let animation = LottieAnimationView(name: "Confetti")
        animation.contentMode = .scaleAspectFit
        animation.loopMode = .playOnce
        animation.animationSpeed = 1.0
        
        // Add to view
        view.addSubview(animation)
        
        // Position above button
        animation.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            animation.centerXAnchor.constraint(equalTo: cell.btnDelight.centerXAnchor),
            animation.bottomAnchor.constraint(equalTo: cell.btnDelight.topAnchor, constant: -10),
            animation.widthAnchor.constraint(equalToConstant: 200),
            animation.heightAnchor.constraint(equalToConstant: 200)
        ])
        
        // Store reference
        animationView = animation
        
        // Play and reset button after completion
        animation.play { [weak self, weak cell] finished in
            if finished {
                animation.removeFromSuperview()
                self?.animationView = nil
                
                // Re-enable button interaction
                cell?.setButtonState(isActive: false, isEnabled: true)
            }
        }
    }
}


// MARK: - UITableView Methods
extension HomeVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view: UIView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: 1))
        view.backgroundColor = .clear
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 0:
            return 0
        case 1:
            return 16
        case 2, 3:
            return 11
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view: UIView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: 1))
        view.backgroundColor = .clear
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: RingsTVCell.className, for: indexPath) as! RingsTVCell

            if viewModel.viewState != .loading {
                cell.viewRings.setProgress(
                    move: viewModel.stepsProgress,
                    exercise: viewModel.caloriesProgress
                )
                
                if let healthData = viewModel.healthData {
                    cell.configureData(
                        steps: Int(healthData.stepCount),
                        calories: Int(healthData.activeEnergy)
                    )
                }
            }
            
            return cell
            
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: ChartTVCell.className, for: indexPath) as! ChartTVCell
            
            let chartData = viewModel.last7DaysData.map { healthData in
                DailyData(
                    date: healthData.date,
                    weekday: healthData.date.toString(format: "EEE"),
                    steps: healthData.stepCount,
                    calories: healthData.activeEnergy
                )
            }
            
            cell.configure(with: chartData, parentVC: self)
            
            return cell
            
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: CarouselTVCell.className, for: indexPath) as! CarouselTVCell
            
            let carouselData = viewModel.carouselInsights.map {
                ($0.title, $0.subtitle, $0.iconName)
            }
            
            if !carouselData.isEmpty {
                cell.configure(with: carouselData)
            }
            
            return cell
            
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: CustomButtonTVCell.className, for: indexPath) as! CustomButtonTVCell
            
            cell.onToggle = { [weak self, weak cell] isPressed in
                guard let self = self, let cell = cell else { return }
                
                if isPressed {
                    cell.setButtonState(isActive: true, isEnabled: false)
                    self.showConfettiAboveButton(for: cell)
                }
            }
            
            return cell
        default:
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return 166
        case 1:
            return 204
        case 2:
            return 94
        case 3:
            return 50
        default:
            return 0
        }
    }
}

// MARK: - SkeletonTableViewDataSource
extension HomeVC: SkeletonTableViewDataSource {
    
    func collectionSkeletonView(_ skeletonView: UITableView, cellIdentifierForRowAt indexPath: IndexPath) -> ReusableCellIdentifier {
        switch indexPath.section {
        case 0:
            return RingsTVCell.className
        case 1:
            return ChartTVCell.className
        case 2:
            return CarouselTVCell.className
        case 3:
            return CustomButtonTVCell.className
        default:
            return ""
        }
    }
    
    func collectionSkeletonView(_ skeletonView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func numSections(in collectionSkeletonView: UITableView) -> Int {
        return 4
    }
}


// MARK: - Button Actions
extension HomeVC {
    
    @IBAction func logMealAction(_ sender: UIButton) {
        let nutritionVC = Utils.loadVC(strStoryboardId: StoryBoard.SB_Nutrition, strVCId: ViewControllerID.VC_Nutrition) as! NutritionVC
        self.navigationController?.pushViewController(nutritionVC, animated: true)
    }
}
