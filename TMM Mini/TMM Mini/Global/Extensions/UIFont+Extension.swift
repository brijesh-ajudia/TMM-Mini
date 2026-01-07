//
//  UIFont+Extension.swift
//  TMM Mini
//
//  Created by Brijesh Ajudia on 05/01/26.
//

import UIKit

//MARK: - Fonts
protocol FontApplicable {
    func setFont(name: String, size: CGFloat)
}

extension FontApplicable where Self: UIView {
    func setFont(name: String, size: CGFloat) {
        if let textField = self as? UITextField {
            textField.font = UIFont(name: name, size: size)
        } else if let label = self as? UILabel {
            label.font = UIFont(name: name, size: size)
        } else if let button = self as? UIButton {
            button.titleLabel?.font = UIFont(name: name, size: size)
        }
    }
}

// Common extension for UITextField, UILabel, and UIButton
extension UITextField: FontApplicable {}
extension UILabel: FontApplicable {}
extension UIButton: FontApplicable {}

extension UIView {
    @IBInspectable
    var I_Bold: CGFloat {
        get {
            return 0.0
        }
        set {
            (self as? FontApplicable)?.setFont(name: "Inter-Bold", size: newValue)
        }
    }

    @IBInspectable
    var I_Medium: CGFloat {
        get {
            return 0.0
        }
        set {
            (self as? FontApplicable)?.setFont(name: "Inter-Medium", size: newValue)
        }
    }
    
    @IBInspectable
    var I_Regular: CGFloat {
        get {
            return 0.0
        }
        set {
            (self as? FontApplicable)?.setFont(name: "Inter-Regular", size: newValue)
        }
    }
    
    @IBInspectable
    var I_SemiBold: CGFloat {
        get {
            return 0.0
        }
        set {
            (self as? FontApplicable)?.setFont(name: "Inter-SemiBold", size: newValue)
        }
    }
}
