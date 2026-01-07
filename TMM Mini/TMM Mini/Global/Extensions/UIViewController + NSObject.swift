//
//  UIViewController+Extension.swift
//  TMM Mini
//
//  Created by Brijesh Ajudia on 05/01/26.
//

import Foundation
import UIKit

extension UIViewController {
    func showAlert(title: String, message: String, okTitle: String = "OK", cancelTitle: String? = nil, oKCallback: (() -> Void)? = nil, cancelCallback: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: okTitle, style: .default, handler: {(alertAction) in
            oKCallback?()
        }))
        if cancelTitle != nil {
            alert.addAction(UIAlertAction(title: cancelTitle, style: .default, handler: {(alertAction) in
                cancelCallback?()
            }))
        }
        self.present(alert, animated: true, completion: nil)
    }
    
    func addInputAccessoryForTextFields(textFields: [UITextField], dismissable: Bool = true, previousNextable: Bool = false) {
        for (index, textField) in textFields.enumerated() {
            let toolbar: UIToolbar = UIToolbar()
            toolbar.sizeToFit()
            
            var items = [UIBarButtonItem]()
            if previousNextable {
                var previousButton = UIBarButtonItem()
                if #available(iOS 13.0, *) {
                    previousButton = UIBarButtonItem(image: UIImage(systemName: "chevron.up"), style: .plain, target: nil, action: nil)
                } else {
                    previousButton = UIBarButtonItem(title: "Prev", style: .plain, target: nil, action: nil)
                    // Fallback on earlier versions
                }
                previousButton.tintColor = .black
                //if traitCollection.userInterfaceStyle == .dark {
                //    previousButton.tintColor = .white
                //}
                previousButton.width = 30
                if textField == textFields.first {
                    previousButton.isEnabled = false
                } else {
                    previousButton.target = textFields[index - 1]
                    previousButton.action = #selector(UITextField.becomeFirstResponder)
                }
                
                var nextButton = UIBarButtonItem()
                if #available(iOS 13.0, *) {
                    nextButton = UIBarButtonItem(image: UIImage(systemName: "chevron.down"), style: .plain, target: nil, action: nil)
                } else {
                    nextButton = UIBarButtonItem(title: "Next", style: .plain, target: nil, action: nil)
                    // Fallback on earlier versions
                }
                nextButton.tintColor = .black
                //if traitCollection.userInterfaceStyle == .dark {
                //    nextButton.tintColor = .white
                //}
                nextButton.width = 30
                if textField == textFields.last {
                    nextButton.isEnabled = false
                } else {
                    nextButton.target = textFields[index + 1]
                    nextButton.action = #selector(UITextField.becomeFirstResponder)
                }
                items.append(contentsOf: [previousButton, nextButton])
            }
            
            let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
            let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: view, action: #selector(UIView.endEditing))
            doneButton.tintColor = .black
            //if traitCollection.userInterfaceStyle == .dark {
            //    doneButton.tintColor = .white
            //}
            items.append(contentsOf: [spacer, doneButton])
            
            
            toolbar.setItems(items, animated: false)
            textField.inputAccessoryView = toolbar
        }
    }
    
    func addInputAccessoryForTextFields(textViews: [UITextView], dismissable: Bool = true, previousNextable: Bool = false) {
        for (index, textView) in textViews.enumerated() {
            let toolbar: UIToolbar = UIToolbar()
            toolbar.sizeToFit()
            
            var items = [UIBarButtonItem]()
            if previousNextable {
                var previousButton = UIBarButtonItem()
                if #available(iOS 13.0, *) {
                    previousButton = UIBarButtonItem(image: UIImage(systemName: "chevron.up"), style: .plain, target: nil, action: nil)
                } else {
                    previousButton = UIBarButtonItem(title: "Prev", style: .plain, target: nil, action: nil)
                    // Fallback on earlier versions
                }
                previousButton.tintColor = .black
                //if traitCollection.userInterfaceStyle == .dark {
                //    previousButton.tintColor = .white
                //}
                previousButton.width = 30
                if textView == textViews.first {
                    previousButton.isEnabled = false
                } else {
                    previousButton.target = textViews[index - 1]
                    previousButton.action = #selector(UITextField.becomeFirstResponder)
                }
                
                var nextButton = UIBarButtonItem()
                if #available(iOS 13.0, *) {
                    nextButton = UIBarButtonItem(image: UIImage(systemName: "chevron.down"), style: .plain, target: nil, action: nil)
                } else {
                    nextButton = UIBarButtonItem(title: "Next", style: .plain, target: nil, action: nil)
                    // Fallback on earlier versions
                }
                nextButton.tintColor = .black
                //if traitCollection.userInterfaceStyle == .dark {
                //    nextButton.tintColor = .white
                //}
                nextButton.width = 30
                if textView == textViews.last {
                    nextButton.isEnabled = false
                } else {
                    nextButton.target = textViews[index + 1]
                    nextButton.action = #selector(UITextField.becomeFirstResponder)
                }
                items.append(contentsOf: [previousButton, nextButton])
            }
            
            let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
            let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: view, action: #selector(UIView.endEditing))
            doneButton.tintColor = .black
            //if traitCollection.userInterfaceStyle == .dark {
            //    doneButton.tintColor = .white
            //}
            items.append(contentsOf: [spacer, doneButton])
            
            
            toolbar.setItems(items, animated: false)
            textView.inputAccessoryView = toolbar
        }
    }
}

final class PopoverPushController: UIViewController {
    private let wrappedNavigationController: UINavigationController

    init(rootViewController: UIViewController) {
        self.wrappedNavigationController = UINavigationController(rootViewController: rootViewController)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        wrappedNavigationController.willMove(toParent: self)
        self.addChild(wrappedNavigationController)
        self.view.addSubview(wrappedNavigationController.view)
    }
}

extension UIView {
    func addInputAccessoryForTextFields(textFields: [UITextField], dismissable: Bool = true, previousNextable: Bool = false) {
        for (index, textField) in textFields.enumerated() {
            let toolbar: UIToolbar = UIToolbar()
            toolbar.sizeToFit()
            
            var items = [UIBarButtonItem]()
            if previousNextable {
                var previousButton = UIBarButtonItem()
                if #available(iOS 13.0, *) {
                    previousButton = UIBarButtonItem(image: UIImage(systemName: "chevron.up"), style: .plain, target: nil, action: nil)
                } else {
                    previousButton = UIBarButtonItem(title: "Prev", style: .plain, target: nil, action: nil)
                    // Fallback on earlier versions
                }
                previousButton.tintColor = .black
                //if traitCollection.userInterfaceStyle == .dark {
                //    previousButton.tintColor = .white
                //}
                previousButton.width = 30
                if textField == textFields.first {
                    previousButton.isEnabled = false
                } else {
                    previousButton.target = textFields[index - 1]
                    previousButton.action = #selector(UITextField.becomeFirstResponder)
                }
                
                var nextButton = UIBarButtonItem()
                if #available(iOS 13.0, *) {
                    nextButton = UIBarButtonItem(image: UIImage(systemName: "chevron.down"), style: .plain, target: nil, action: nil)
                } else {
                    nextButton = UIBarButtonItem(title: "Next", style: .plain, target: nil, action: nil)
                    // Fallback on earlier versions
                }
                nextButton.tintColor = .black
                //if traitCollection.userInterfaceStyle == .dark {
                //    nextButton.tintColor = .white
                //}
                nextButton.width = 30
                if textField == textFields.last {
                    nextButton.isEnabled = false
                } else {
                    nextButton.target = textFields[index + 1]
                    nextButton.action = #selector(UITextField.becomeFirstResponder)
                }
                items.append(contentsOf: [previousButton, nextButton])
            }
            
            let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
            let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(UIView.endEditing))
            doneButton.tintColor = .black
            //if traitCollection.userInterfaceStyle == .dark {
            //    doneButton.tintColor = .white
            //}
            items.append(contentsOf: [spacer, doneButton])
            
            
            toolbar.setItems(items, animated: false)
            textField.inputAccessoryView = toolbar
        }
    }
}


extension NSObject {
    func showCustomNotifyAlert(completion:@escaping ((_ positive:Bool, _ negative:Bool)->Void)) {
        DispatchQueue.main.async {
            let limitedModeView = Bundle.main.loadNibNamed(String(describing: LimitedModeView.self), owner: self, options: nil)![0] as! LimitedModeView
            limitedModeView.frame = (sceneDelegate?.window?.frame)!
            
            limitedModeView.setUpUI()
            
            limitedModeView.closureAction = { (positive, negative) in
                limitedModeView.removeFromSuperview()
                completion(positive,negative)
            }
            
            limitedModeView.closureAction = { (positive, negative) in
                UIView.transition(with: sceneDelegate!.window!,
                                  duration: 0.4,
                                  options: .transitionCrossDissolve,
                                  animations: {limitedModeView.removeFromSuperview()}) { action in
                    completion(positive, negative)
                }
            }
            
            UIView.transition(with: sceneDelegate!.window!,
                              duration: 0.5,
                              options: UIView.AnimationOptions.transitionCrossDissolve,
                              animations: {sceneDelegate?.window?.addSubview(limitedModeView)},
                              completion: nil)
            
        }
    }
}
