//
//  UITextField+Extension.swift
//  TMM Mini
//
//  Created by Brijesh Ajudia on 05/01/26.
//

import Foundation
import UIKit

extension UITextField {
    func setAttributePlaceHolder(title: String) {
        var placeHolder = NSMutableAttributedString()
        
        // Set the Font
        placeHolder = NSMutableAttributedString(string:title, attributes: [NSAttributedString.Key.font: UIFont(name: "Helvetica", size: 15.0)!])
        
        // Set the color
        //placeHolder.addAttribute(NSAttributedString.Key.foregroundColor, value: textPlaceHolderColor, range:NSRange(location:0,length:title.count))
        
        // Add attribute
        self.attributedPlaceholder = placeHolder
        
    }
    
    func setAttributePlaceHolderWithFont(title: String, font: UIFont) {
        var placeHolder = NSMutableAttributedString()
        placeHolder = NSMutableAttributedString(string:title, attributes: [NSAttributedString.Key.font: font])
        self.attributedPlaceholder = placeHolder
        
    }
    
    func setAttributesPlaceHolder_Color(placeHolderString: String, placeHolderColor: String = "body_Text") {
        self.attributedPlaceholder = NSAttributedString(string: placeHolderString, attributes: [NSAttributedString.Key.foregroundColor : UIColor(named: placeHolderColor)!])
    }
    
    func setLeftViewMode() {
        self.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        self.leftViewMode = .always
    }
    
    func setLeftPaddingPoints(_ amount:CGFloat){
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
    
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
    
    func resolveHashTags() {
        let nsText = NSString(string: self.text ?? "")
        
        let words = nsText.components(separatedBy: CharacterSet(charactersIn: "#ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789_").inverted)
        
        let attrString = NSMutableAttributedString()
        attrString.setAttributedString(self.attributedText!)
        
        for word in words {
            if word.count < 3 {
                continue
            }
            if word.hasPrefix("#") {
                let matchRange:NSRange = nsText.range(of: word as String)
                let stringifiedWord = word.dropFirst()
                if let firstChar = stringifiedWord.unicodeScalars.first, NSCharacterSet.decimalDigits.contains(firstChar) {
                } else {
                    let attributes: [NSAttributedString.Key : Any] = [NSAttributedString.Key.foregroundColor: UIColor(named: "8391A1")!, NSAttributedString.Key.font: UIFont(name: "Urbanist-Medium", size: 16.0)!]
                    attrString.addAttributes(attributes, range: matchRange)
                }
                
            }
        }
        self.attributedText = attrString
    }
    
    func resolveHashTagsNew() {
        let nsText: NSString = NSString(string: self.text ?? "")
        let words: [String] = nsText.components(separatedBy: " ")
        //let attrString = NSMutableAttributedString(string: nsText as String)
        
        let mutableAttributesString = NSMutableAttributedString()
        
        var count : Int = -1
        
        for word in words {
            count += 1
            if word.hasPrefix("#") {
                let attributes: [NSAttributedString.Key : Any] = [NSAttributedString.Key.foregroundColor: UIColor(named: "8391A1")!, NSAttributedString.Key.font: UIFont(name: "Urbanist-Medium", size: 16.0)!]
                
                var attriString = NSAttributedString()
                if count == (words.count - 1) {
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
                if count == (words.count - 1) {
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
}


func convertHTMLToAttributedString(htmlString: String, font: UIFont, color: UIColor) -> NSAttributedString? {
    guard let data = htmlString.data(using: .utf8) else {
        return nil
    }
    let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
        .documentType: NSAttributedString.DocumentType.html,
        .characterEncoding: String.Encoding.utf8.rawValue
    ]
    do {
        let attributedString = try NSAttributedString(data: data, options: options, documentAttributes: nil)
        let updatedAttributedString = NSMutableAttributedString(attributedString: attributedString)
        let range = NSRange(location: 0, length: updatedAttributedString.length)
        updatedAttributedString.addAttribute(.font, value: font, range: range)
        updatedAttributedString.addAttribute(.foregroundColor, value: color, range: range)
        return updatedAttributedString
    } catch {
        print("Error converting HTML to attributed string: \(error)")
        return nil
    }
}

func createAttributedText(htmlString: String, boldColor: UIColor, boldFont: UIFont, normalColor: UIColor, normalFont: UIFont) -> NSAttributedString? {
    // Input text
    let inputText = htmlString
    
    let attributedString = NSMutableAttributedString(string: inputText)
    
    do {
        let regex = try NSRegularExpression(pattern: "<b>(.*?)</b>")
        let matches = regex.matches(in: inputText, range: NSRange(inputText.startIndex..., in: inputText))
        
        let normalRange = (inputText as NSString).range(of: inputText)
        attributedString.addAttribute(.foregroundColor, value: normalColor, range: normalRange)
        attributedString.addAttribute(.font, value: normalFont, range: normalRange)
        
        for match in matches {
            let range = match.range(at: 1)
            let boldRange = Range(range, in: inputText)!
            
            attributedString.addAttribute(.foregroundColor, value: boldColor, range: NSRange(boldRange, in: inputText))
            attributedString.addAttribute(.font, value: boldFont, range: NSRange(boldRange, in: inputText))
        }
    } catch {
        print("Error creating regular expression: \(error)")
    }
    
    return attributedString
}

func extractTextBetweenTags(_ inputString: String) -> [String] {
    do {
        let pattern = "<b>(.*?)</b>"
        let regex = try NSRegularExpression(pattern: pattern, options: [])
        let nsString = inputString as NSString
        let matches = regex.matches(in: inputString, options: [], range: NSRange(location: 0, length: nsString.length))
        
        return matches.map { match in
            let range = match.range(at: 1)
            return nsString.substring(with: range)
        }
    } catch {
        print("Error creating regular expression: \(error)")
        return []
    }
}

extension Array where Element: Equatable {
    func removeDuplicates() -> [Element] {
        var result: [Element] = []
        for item in self {
            if !result.contains(item) {
                result.append(item)
            }
        }
        return result
    }
}

extension Array {
    public func toDictionary<Key: Hashable>(with selectKey: (Element) -> Key) -> [Key:Element] {
        var dict = [Key:Element]()
        for element in self {
            dict[selectKey(element)] = element
        }
        return dict
    }
}

extension Array where Element: Hashable {
    func containsAny(searchTerms: Set<Element>) -> Bool {
        return !searchTerms.isDisjoint(with: self)
    }
}

extension Dictionary where Value: RangeReplaceableCollection {
    public mutating func append(element: Value.Iterator.Element, toValueOfKey key: Key) -> Value? {
        var value: Value = self[key] ?? Value()
        value.append(element)
        self[key] = value
        return value
    }
}

extension StringProtocol {
    subscript(offset: Int) -> Character {
        self[index(startIndex, offsetBy: offset)]
    }
}

extension Double {
    func rounded(toPlace place:Int) -> Double {
        let divisor = pow(10.0, Double(place))
        return (self * divisor).rounded() / divisor
    }
}
