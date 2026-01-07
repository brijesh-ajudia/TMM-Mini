//
//  CarouselCVCell.swift
//  TMM Mini
//
//  Created by Brijesh Ajudia on 06/01/26.
//

import UIKit

class CarouselCVCell: UICollectionViewCell {
    
    @IBOutlet weak var viewMain: UIView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblData: UILabel!
    
    @IBOutlet weak var imgIcon: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.viewMain.clipsToBounds = false
        
        self.viewMain.layer.masksToBounds = false
        self.viewMain.layer.shadowOffset = CGSize(width: 0, height: 2)
        self.viewMain.layer.shadowRadius = 4
        self.viewMain.layer.shadowOpacity = 0.10
        self.viewMain.layer.shadowColor = UIColor.desc.cgColor
    }

}
