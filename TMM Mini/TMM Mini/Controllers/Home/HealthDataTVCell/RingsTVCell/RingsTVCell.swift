//
//  RingsTVCell.swift
//  TMM Mini
//
//  Created by Brijesh Ajudia on 06/01/26.
//

import UIKit
import SkeletonView

class RingsTVCell: UITableViewCell {
    
    @IBOutlet weak var viewRings: FitnessRingsView!
    @IBOutlet weak var lblStepsCount: UILabel!
    @IBOutlet weak var lblCaloriesCount: UILabel!
    
    var stepsCount: String = ""
    var caloriesCount: String = ""
    
    private var pendingStepsProgress: Double = 0
    private var pendingCaloriesProgress: Double = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        isSkeletonable = true
        contentView.isSkeletonable = true
        
        self.viewRings.isSkeletonable = true
        lblStepsCount.isSkeletonable = true
        lblCaloriesCount.isSkeletonable = true
        
        lblStepsCount.linesCornerRadius = 8
        lblStepsCount.skeletonTextLineHeight = .fixed(20)
        
        lblCaloriesCount.linesCornerRadius = 8
        lblCaloriesCount.skeletonTextLineHeight = .fixed(20)
        
        self.viewRings.configure(outerRingSize: 110)
        
    }
    
    func configureData(steps: Int, calories: Int) {
        print("RingsTVCell: Configuring with \(steps) steps, \(calories) cal")
        
        // Update stored values
        self.stepsCount = "\(steps.formatted())"
        self.caloriesCount = "\(calories) "
        
        self.lblStepsCount.text = self.stepsCount
        
        let regularFont = [
            NSAttributedString.Key.font: AppFont.font(type: .I_Bold, size: 18.0)
        ]
        let boldFont = [
            NSAttributedString.Key.font: AppFont.font(type: .I_Bold, size: 22.0)
        ]
        
        let firstString = NSMutableAttributedString(
            string: self.caloriesCount,
            attributes: boldFont
        )
        let secondString = NSMutableAttributedString(
            string: "KCAL",
            attributes: regularFont
        )
        firstString.append(secondString)
        self.lblCaloriesCount.attributedText = firstString
        
        let stepsProgress = min(Double(steps) / 10000.0, 1.5) // Goal: 10,000 steps
        let caloriesProgress = min(Double(calories) / 500.0, 1.5) // Goal: 500 calories
        
        print("Setting progress: steps=\(stepsProgress), calories=\(caloriesProgress)")
        
        pendingStepsProgress = stepsProgress
        pendingCaloriesProgress = caloriesProgress
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

        viewRings.setProgress(
            move: pendingStepsProgress,
            exercise: pendingCaloriesProgress
        )
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        pendingStepsProgress = 0
        pendingCaloriesProgress = 0
        self.resetProgress()
    }
    
    func resetProgress() {
        self.viewRings.reset()
    }


    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
