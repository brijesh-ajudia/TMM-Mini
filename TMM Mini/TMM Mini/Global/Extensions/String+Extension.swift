//
//  String+Extension.swift
//  TMM Mini
//
//  Created by Brijesh Ajudia on 05/01/26.
//

import UIKit

extension String {
    var lines: [String] { return self.components(separatedBy: NSCharacterSet.newlines)}
    
    func trim() -> String {
        return self.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }
    
    func toDate(dateFormat: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        return dateFormatter.date(from: self)
    }
    
    func convertToNextDate(dateFormat: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        let myDate = dateFormatter.date(from: self)!
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: myDate)
        return dateFormatter.string(from: tomorrow!)
    }
    
    func convertToPreviousDate(dateFormat: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        let myDate = dateFormatter.date(from: self)!
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: myDate)
        return dateFormatter.string(from: yesterday!)
    }
    
    func convertToNextMonth(monthFormat: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = monthFormat
        let myDate = dateFormatter.date(from: self)!
        let nextMonth = Calendar.current.date(byAdding: .month, value: 1, to: myDate)
        return dateFormatter.string(from: nextMonth!)
    }
    
    func convertToPreviousMonth(monthFormat: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = monthFormat
        let myDate = dateFormatter.date(from: self)!
        let lastMonth = Calendar.current.date(byAdding: .month, value: -1, to: myDate)
        return dateFormatter.string(from: lastMonth!)
    }
    
    func convertDateFormater(convertFrom: String = DD_MMM_YYYY , convertTo: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = convertFrom
        let date = dateFormatter.date(from: self)
        dateFormatter.dateFormat = convertTo
        return dateFormatter.string(from: date!)
    }
    
    func convertDateFromLong(convertFrom: String = DateFormatLong , convertTo: String = DateFormatLongNew) -> String {
        let originalDateFormatter = DateFormatter()
        originalDateFormatter.dateFormat = convertFrom
        originalDateFormatter.timeZone = TimeZone(secondsFromGMT: 0)

        // Step 2: Parse the original date string to a Date object
        if let date = originalDateFormatter.date(from: self) {
            let newDateFormatter = DateFormatter()
            newDateFormatter.dateFormat = convertTo
            newDateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
            
            let newDateString = newDateFormatter.string(from: date)
            return newDateString // Output: "2024-07-08T13:30:00Z"
        } else {
            print("Failed to parse date")
            return ""
        }
    }
    
    var attributedStringStrikeThrough: NSAttributedString? {
        let oldPriceAttributes: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.strikethroughStyle: NSUnderlineStyle.single.rawValue,
            NSAttributedString.Key.strikethroughColor: UIColor.black,
            NSAttributedString.Key.foregroundColor: UIColor.black,
            NSAttributedString.Key.font: AppFont.font(type: .G_Medium, size: 12.0)]
        let attributedText = NSMutableAttributedString()
        attributedText.append(NSAttributedString(string: "\(self)"))
        if let rangePrice = attributedText.string.range(of: "\(self)") {
            attributedText.addAttributes(oldPriceAttributes, range: NSRange(rangePrice, in: attributedText.string))
        }
        return attributedText
    }
    
    var attributedStringStrikeThroughNew: NSAttributedString? {
        let oldPriceAttributes: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.strikethroughStyle: NSUnderlineStyle.single.rawValue,
            NSAttributedString.Key.strikethroughColor: UIColor(named: "NewCourseTextColor")!,
            NSAttributedString.Key.foregroundColor: UIColor(named: "NewCourseTextColor")!,
            NSAttributedString.Key.font: AppFont.font(type: .C_Medium, size: 12.0)]
        let attributedText = NSMutableAttributedString()
        attributedText.append(NSAttributedString(string: "\(self)"))
        if let rangePrice = attributedText.string.range(of: "\(self)") {
            attributedText.addAttributes(oldPriceAttributes, range: NSRange(rangePrice, in: attributedText.string))
        }
        return attributedText
    }
    
    
    func fromBase64() -> String? {
        guard let data = Data(base64Encoded: self) else {
            return nil
        }
        
        return String(data: data, encoding: .utf8)
    }
    
    func toBase64() -> String {
        return Data(self.utf8).base64EncodedString()
    }
    
    func convertToDictionary() -> [String: Any]? {
        if let data = self.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
    
    mutating func insert(string:String, ind:Int) {
        self.insert(contentsOf: string, at:self.index(self.startIndex, offsetBy: ind) )
    }
    
    var firstUppercased: String { prefix(1).uppercased() + dropFirst() }
    var firstCapitalized: String { prefix(1).capitalized + dropFirst() }
    var firstLowerCased: String { prefix(1).lowercased() + dropFirst() }
    
    var attributedHTMLString: NSAttributedString? {
        guard let data = data(using: .utf8) else { return nil }
        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue
        ]
        return try? NSAttributedString(data: data, options: options, documentAttributes: nil)
    }
    
    func getConvertStringToHtml() -> NSAttributedString? {
        guard let stringUnicode = (self as NSString).data(using: String.Encoding.unicode.rawValue) else {
            return nil
        }
        do {
            let attribute = try NSAttributedString(data: stringUnicode,options: [.documentType:NSAttributedString.DocumentType.html], documentAttributes: nil)
            return attribute
        } catch let error {
            print("Cannot Convert to html",error.localizedDescription)
            return nil
        }
    }
    
    subscript(_ index: Int) -> Character {
        self[self.index(self.startIndex, offsetBy: index)]
    }
}

