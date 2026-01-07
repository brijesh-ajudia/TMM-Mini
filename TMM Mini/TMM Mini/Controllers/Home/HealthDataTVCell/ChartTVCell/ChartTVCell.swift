//
//  ChartTVCell.swift
//  TMM Mini
//
//  Created by Brijesh Ajudia on 06/01/26.
//

import UIKit
import SwiftUI
import SkeletonView

class ChartTVCell: UITableViewCell {
    
    @IBOutlet weak var chartContainerView: UIView!
    @IBOutlet weak var segmentControl: UISegmentedControl! // Add this outlet
    
    private var hostingController: UIHostingController<AnyView>?
    weak var parentViewController: UIViewController?
    
    private var weeklyStepsData: [DailyData] = []
    private var weeklyCaloriesData: [DailyData] = []
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
        setupSkeleton()
    }
    
    private func setupUI() {
        chartContainerView.backgroundColor = .clear
        selectionStyle = .none
        
        setupSegmentControl()
    }
    
    private func setupSkeleton() {
        isSkeletonable = true
        contentView.isSkeletonable = true
        
        chartContainerView.isSkeletonable = true
        chartContainerView.skeletonCornerRadius = 12
        
        segmentControl.isSkeletonable = false
        segmentControl.isHiddenWhenSkeletonIsActive = true
    }
    
    private func setupSegmentControl() {
        segmentControl.selectedSegmentIndex = 0
        
        segmentControl.backgroundColor = .clear
        
        segmentControl.selectedSegmentTintColor = .toggleBG
        
        let normalText: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.toggleUnSelectText,
            .font: UIFont.systemFont(ofSize: 14, weight: .medium)
        ]
        
        let selectedText: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.toggleText,
            .font: UIFont.systemFont(ofSize: 14, weight: .semibold)
        ]
        
        segmentControl.setTitleTextAttributes(normalText, for: .normal)
        segmentControl.setTitleTextAttributes(selectedText, for: .selected)
    }
    
    func configure(with data: [DailyData], parentVC: UIViewController) {
        self.parentViewController = parentVC
        
        self.weeklyStepsData = data
        self.weeklyCaloriesData = data
        
        updateChart()
    }
    
    // Chart based on segment selection
    private func updateChart() {
        let isSteps = segmentControl.selectedSegmentIndex == 0
        
        if isSteps {
            setupStepsChart()
        } else {
            setupCaloriesChart()
        }
    }
    
    // Setup Steps Chart
    private func setupStepsChart() {
        let color = Color(red: 0.6, green: 0.5, blue: 0.9) // Purple
        setupChart(data: weeklyStepsData, color: color, valueType: .steps)
    }
    
    // Setup Calories Chart
    private func setupCaloriesChart() {
        let color = Color.orange // Orange for calories
        setupChart(data: weeklyCaloriesData, color: color, valueType: .calories)
    }
    
    // Setup chart method with value type
    private func setupChart(data: [DailyData], color: Color, valueType: ChartValueType) {
        guard let parentVC = parentViewController else { return }
        
        // Remove existing hosting controller
        hostingController?.view.removeFromSuperview()
        hostingController?.removeFromParent()
        
        // Create chart view
        let chartView: AnyView
        if #available(iOS 16.0, *) {
            chartView = AnyView(
                DailyBarChartView(
                    data: data,
                    accentColor: color,
                    valueType: valueType
                )
            )
        } else {
            chartView = AnyView(
                FallbackChartView(data: data, accentColor: color)
            )
        }
        
        // Create hosting controller
        let hosting = UIHostingController(rootView: chartView)
        hosting.view.backgroundColor = .clear
        hosting.view.translatesAutoresizingMaskIntoConstraints = false
        
        // Add as child
        parentVC.addChild(hosting)
        chartContainerView.addSubview(hosting.view)
        hosting.didMove(toParent: parentVC)
        
        // Setup constraints
        NSLayoutConstraint.activate([
            hosting.view.topAnchor.constraint(equalTo: chartContainerView.topAnchor),
            hosting.view.leadingAnchor.constraint(equalTo: chartContainerView.leadingAnchor),
            hosting.view.trailingAnchor.constraint(equalTo: chartContainerView.trailingAnchor),
            hosting.view.bottomAnchor.constraint(equalTo: chartContainerView.bottomAnchor)
        ])
        
        self.hostingController = hosting
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        hostingController?.view.removeFromSuperview()
        hostingController?.removeFromParent()
        hostingController = nil
    }
}

// MARK: - Actions
extension ChartTVCell {
    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
        updateChart()
    }
}

