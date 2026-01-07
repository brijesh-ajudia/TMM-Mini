//
//  CustomEmptyView.swift
//  TMM Mini
//
//  Created by Brijesh Ajudia on 06/01/26.
//

import UIKit

class CustomEmptyView: UIView {

    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblSubTitle: UILabel!
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        print("CustomEmptyView Init with frame EmptyView")
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        print("CustomEmptyView Init with coder EmptyView")
        commonInit()
    }
    
    func commonInit() {
        let viewFromXIB = Bundle.main.loadNibNamed("CustomEmptyView", owner: self, options: nil)![0] as! UIView
        viewFromXIB.frame = self.bounds
        viewFromXIB.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        Utils.sharedInstance.applyLineSpacing(to: self.lblSubTitle, lineSpacing: 5, alignment: .center)
        
        addSubview(viewFromXIB)
    }

}
