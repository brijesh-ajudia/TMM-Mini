//
//  CustomButton.swift
//  TMM Mini
//
//  Created by Brijesh Ajudia on 05/01/26.
//

import UIKit

class CustomButton: UIView {
    
    @IBOutlet weak var viewMain: UIView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var button: UIButton!
    
    // MARK: - Properties
    @IBInspectable var isAcceptStyle: Bool = true {
        didSet {
            updateUI()
        }
    }
    
    @IBInspectable var isForDelete: Bool = false {
        didSet {
            updateUI()
        }
    }
    
    @IBInspectable var buttonTitle: String = "" {
        didSet {
            lblTitle.text = buttonTitle
        }
    }
    
    @IBInspectable var viewMainRadius: CGFloat = 0 {
        didSet {
            self.viewMain.cornerRadiuss = viewMainRadius
        }
    }
    
    @IBInspectable var isEnabled: Bool = true {
        didSet {
            updateUI()
            button.isUserInteractionEnabled = isEnabled
        }
    }
    
    var isActive: Bool = false {
        didSet {
            updateLoadingState()
        }
    }
    
    var onToggle: ((Bool) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        print("CustomButton Init with frame")
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        print("CustomButton Init with coder")
        commonInit()
    }
    
    func commonInit() {
        guard subviews.isEmpty else { return }
        
        if let viewFromXIB = Bundle.main.loadNibNamed("CustomButton", owner: self, options: nil)?.first as? UIView {
            viewFromXIB.frame = self.bounds
            viewFromXIB.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            addSubview(viewFromXIB)
        }
        
        setupView()
    }
    
    private func setupView() {
        activityIndicator.hidesWhenStopped = true
        
        updateUI()
        
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
    }
    
    @objc private func buttonTapped() {
        isActive.toggle()
        onToggle?(isActive)
    }
    
    
    private func updateUI() {
        if !isEnabled {
            if #available(iOS 13.0, *) {
                if traitCollection.userInterfaceStyle == .dark {
                    viewMain.backgroundColor = UIColor(hex: "#1F2937")
                    lblTitle.textColor = UIColor(hex: "#6B7280")
                } else {
                    viewMain.backgroundColor = UIColor(hex: "#E5E7EB")
                    lblTitle.textColor = UIColor(hex: "#9CA3AF")
                }
            } else {
                viewMain.backgroundColor = UIColor(hex: "#E5E7EB")
                lblTitle.textColor = UIColor(hex: "#9CA3AF")
            }
            viewMain.borderWidth = 0
            lblTitle.isHidden = false
            activityIndicator.isHidden = true
            activityIndicator.stopAnimating()
        }
        else if isAcceptStyle {
            viewMain.backgroundColor = .buttonBG
            viewMain.borderWidth = 0
            lblTitle.isHidden = false
            lblTitle.textColor = .buttonTextTitle
            activityIndicator.color = .white
            activityIndicator.isHidden = true
        }
        else {
            viewMain.borderWidth = 0
            viewMain.backgroundColor = .buttonBG
            lblTitle.isHidden = false
            lblTitle.textColor = .buttonTextTitle
            activityIndicator.color = .buttonTextTitle
            activityIndicator.isHidden = true
        }
    }
    
    private func updateLoadingState() {
        if isActive {
            if isAcceptStyle {
                lblTitle.isHidden = true
                activityIndicator.isHidden = false
                activityIndicator.startAnimating()
            }
            else {
                lblTitle.isHidden = true
                activityIndicator.isHidden = false
                activityIndicator.startAnimating()
            }
        }
        else {
            updateUI()
        }
    }
    
    // MARK: - Dark Mode Support
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if #available(iOS 13.0, *) {
            if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
                updateUI()
            }
        }
    }
}
