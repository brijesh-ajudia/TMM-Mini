//
//  CustomButtonTVCell.swift
//  TMM Mini
//
//  Created by Brijesh Ajudia on 06/01/26.
//

import UIKit
import SkeletonView

protocol CustomButtonTVCellDelegate: AnyObject {
    func delightButtonTapped(in cell: CustomButtonTVCell)
}

class CustomButtonTVCell: UITableViewCell {
    
    @IBOutlet weak var btnDelight: CustomButton!
    
    var onToggle: ((Bool) -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        setupButton()
        setupSkeleton()
    }
    
    private func setupButton() {
        btnDelight.lblTitle.font = AppFont.font(type: .I_Bold, size: 16)
        
        btnDelight.onToggle = { [weak self] isPressed in
            self?.onToggle?(isPressed)
        }
    }
    
    private func setupSkeleton() {
        isSkeletonable = true
        contentView.isSkeletonable = true
        
        btnDelight.isSkeletonable = true
        btnDelight.skeletonCornerRadius = 12
        
        btnDelight.isHiddenWhenSkeletonIsActive = true
    }
    
    // Method to update button state
    func setButtonState(isActive: Bool, isEnabled: Bool) {
        btnDelight.isActive = isActive
        btnDelight.isUserInteractionEnabled = isEnabled
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        btnDelight.isActive = false
        btnDelight.isUserInteractionEnabled = true
        onToggle = nil
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
