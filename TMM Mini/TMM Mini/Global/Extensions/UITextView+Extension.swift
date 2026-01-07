//
//  UITextView+Extension.swift
//  TMM Mini
//
//  Created by Brijesh Ajudia on 05/01/26.
//

import UIKit

extension UITextView {
   
    @IBInspectable var doneAccessory: Bool {
        get{
            return self.doneAccessory
        }
        set (hasDone) {
            if hasDone{
                addDoneButtonOnKeyboard()
            }
        }
    }

    func addDoneButtonOnKeyboard() {
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        doneToolbar.barStyle = .default
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.doneButtonAction))
        
        let items = [flexSpace, done]
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        
        self.inputAccessoryView = doneToolbar
    }

    @objc func doneButtonAction() {
        self.resignFirstResponder()
    }
    
    func setAttributesPlaceHolder_Color(placeHolderString: String, placeHolderColor: String = "DarkGray") {
        self.text = placeHolderString
        self.textColor = UIColor(named: placeHolderColor)!
    }
    
    func resolveHashTagsNew() {
        let nsText: NSString = NSString(string: self.text ?? "")
        
        //print(" <----------- TEXT ----------->\n ", nsText)
        let wordsNew = nsText.replacingOccurrences(of: "\n", with: " ").components(separatedBy: " ")
        //print(" <----------- WORDS_NEW ----------->\n", wordsNew)
        //print(" <---------------------->\n ")
        
        //let words = nsText.components(separatedBy: CharacterSet(charactersIn: "#ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789~`!@$%^&*()_-+={[}}|\":;'<,.>™?/").inverted)
        
        let mutableAttributesString = NSMutableAttributedString()
        
        var count : Int = -1
    
        for word in wordsNew {
            count += 1
            if word.hasPrefix("#") {
                let attributes: [NSAttributedString.Key : Any] = [NSAttributedString.Key.foregroundColor: UIColor(named: "8391A1")!, NSAttributedString.Key.font: UIFont(name: "Urbanist-Medium", size: 16.0)!]
                
                var attriString = NSAttributedString()
                if count == (wordsNew.count - 1) {
                    attriString = NSAttributedString(string: word, attributes: attributes)
                }
                else {
                    attriString = NSAttributedString(string: word + " ", attributes: attributes)
                }
                mutableAttributesString.append(attriString)
            }
            if !word.hasPrefix("#") {
                let attributes: [NSAttributedString.Key : Any] = [NSAttributedString.Key.foregroundColor: UIColor(named: "333333")!, NSAttributedString.Key.font: UIFont(name: "Urbanist-Medium", size: 16.0)!]
                
                var attriString = NSAttributedString()
                if count == (wordsNew.count - 1) {
                    attriString = NSAttributedString(string: word, attributes: attributes)
                }
                else {
                    attriString = NSAttributedString(string: word + " ", attributes: attributes)
                }
                mutableAttributesString.append(attriString)
            }
        }
        self.attributedText = mutableAttributesString
    }
    
    func centerVertically() {
        let fittingSize = CGSize(width: bounds.width, height: CGFloat.greatestFiniteMagnitude)
        let size = sizeThatFits(fittingSize)
        let topOffset = (bounds.size.height - size.height * zoomScale) / 2
        let positiveTopOffset = max(1, topOffset)
        contentOffset.y = -positiveTopOffset
    }
    
    func calculateMaxLines() -> Int {
        let maxSize = CGSize(width: frame.size.width, height: CGFloat(Float.infinity))
        let charSize = font?.lineHeight
        let text = (self.text ?? "") as NSString
        let textSize = text.boundingRect(with: maxSize, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font!], context: nil)
        let linesRoundedUp = Int(ceil(textSize.height/charSize!))
        return linesRoundedUp
    }
}
