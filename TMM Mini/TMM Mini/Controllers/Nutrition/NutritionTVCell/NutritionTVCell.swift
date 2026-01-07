//
//  NutritionTVCell.swift
//  TMM Mini
//
//  Created by Brijesh Ajudia on 07/01/26.
//

import UIKit

class NutritionTVCell: UITableViewCell {
    
    // MARK: - UI Elements
    @IBOutlet weak var lblFoodName: UILabel!
    @IBOutlet weak var lblCalories: UILabel!
    @IBOutlet weak var lblProtein: UILabel!
    @IBOutlet weak var lblCarbs: UILabel!
    @IBOutlet weak var lblFat: UILabel!
    @IBOutlet weak var viewMain: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    func setupUI() {
        self.selectionStyle = .none

        // Container styling
        self.viewMain.clipsToBounds = false
        
        self.viewMain.layer.masksToBounds = false
        self.viewMain.layer.shadowOffset = CGSize(width: 0, height: 2)
        self.viewMain.layer.shadowRadius = 4
        self.viewMain.layer.shadowOpacity = 0.10
        self.viewMain.layer.shadowColor = UIColor.desc.cgColor
        
        // Font setup
        lblFoodName.font = AppFont.font(type: .I_SemiBold, size: 16)
        lblCalories.font = AppFont.font(type: .I_Medium, size: 14)
        lblProtein.font = AppFont.font(type: .I_Regular, size: 14)
        lblCarbs.font = AppFont.font(type: .I_Regular, size: 14)
        lblFat.font = AppFont.font(type: .I_Regular, size: 14)
    }
    
    func configure(with foodEntry: FoodEntry) {
        lblFoodName.text = foodEntry.foodName
        lblCalories.text = "\(Int(foodEntry.calories)) cal"
        lblProtein.text = "\(formatValue(foodEntry.protein)) g"
        lblCarbs.text = "\(formatValue(foodEntry.carbs)) g"
        lblFat.text = "\(formatValue(foodEntry.fat)) g"
    }
    
    private func formatValue(_ value: Double) -> String {
        if value.truncatingRemainder(dividingBy: 1) == 0 {
            // Whole number (e.g., 21.0 → "21")
            return String(format: "%.0f", value)
        } else {
            // Decimal number (e.g., 21.5 → "21.5")
            return String(format: "%.1f", value)
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
