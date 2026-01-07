//
//  Utils.swift
//  TMM Mini
//
//  Created by Brijesh Ajudia on 05/01/26.
//

import Foundation
import UIKit

class Utils {

    static let sharedInstance: Utils = {
        let instance = Utils()
        return instance
    }()

    class func loadVC(strStoryboardId: String, strVCId: String)
        -> UIViewController
    {
        let vc = getStoryboard(storyboardName: strStoryboardId)
            .instantiateViewController(withIdentifier: strVCId)
        return vc
    }

    class func getStoryboard(storyboardName: String) -> UIStoryboard {
        return UIStoryboard(name: storyboardName, bundle: nil)
    }

    func createBulletList(strings: [String]) -> NSAttributedString {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.headIndent = 20
        paragraphStyle.firstLineHeadIndent = 0
        paragraphStyle.paragraphSpacing = 8

        let attributedString = NSMutableAttributedString()

        for string in strings {
            let bulletPoint = "• \(string)\n"
            let attributes: [NSAttributedString.Key: Any] = [
                .paragraphStyle: paragraphStyle,
                .font: AppFont.font(type: .I_Regular, size: 16.0),
                .foregroundColor: UIColor.App_bodyText,
            ]
            attributedString.append(
                NSAttributedString(string: bulletPoint, attributes: attributes)
            )
        }

        return attributedString
    }

    func minutesToHoursMinutes(_ minutes: Int) -> (Int, Int) {
        return ((minutes / 60), (minutes % 60))
    }

    func formatTimeZoneOffset(offsetMinutes: Int) -> String {
        let sign = offsetMinutes < 0 ? "-" : "+"
        let hours = abs(offsetMinutes) / 60
        let minutes = abs(offsetMinutes) % 60
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        let timeZoneOffset = TimeZone(secondsFromGMT: offsetMinutes * 60)
        formatter.timeZone = timeZoneOffset
        //let formattedOffset = formatter.string(from: Date())
        return
            "UTC\(sign)\(String(format: "%02d", hours)):\(String(format: "%02d", minutes))"  // (\(formattedOffset))"
    }

    func format(with mask: String, phone: String) -> String {
        let numbers = phone.replacingOccurrences(
            of: "[^0-9]",
            with: "",
            options: .regularExpression
        )
        var result = ""
        var index = numbers.startIndex  // numbers iterator
        // iterate over the mask characters until the iterator of numbers ends
        for ch in mask where index < numbers.endIndex {
            if ch == "X" {
                // mask requires a number in this place, so take the next one
                result.append(numbers[index])
                // move numbers iterator to the next index
                index = numbers.index(after: index)
            } else {
                result.append(ch)  // just append a mask character
            }
        }
        return result
    }

    func randomString(length: Int) -> String {
        let letters =
            "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<length).map { _ in letters.randomElement()! })
    }

    func randomKey() -> Int {
        let minNumber = 1_000_000
        let maxNumber = 9_999_999
        let random7DigitNumber =
            Int(arc4random_uniform(UInt32(maxNumber - minNumber + 1)))
            + minNumber
        return random7DigitNumber
    }

    func getUTCDate(dateStr: String, selectedDate: Date) -> String {

        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = .withInternetDateTime

        let calendar = Calendar.current

        let newTime = self.convertTo24HourFormat(timeString: dateStr) ?? ""

        let hour = Int(newTime.components(separatedBy: ":").first ?? "") ?? 0
        let min = Int(newTime.components(separatedBy: ":").last ?? "") ?? 0

        var dateComponents = DateComponents()
        dateComponents.year = calendar.component(.year, from: selectedDate)
        dateComponents.month = calendar.component(.month, from: selectedDate)
        dateComponents.day = calendar.component(.day, from: selectedDate)
        dateComponents.hour = hour
        dateComponents.minute = min

        if let dateWithTime = calendar.date(from: dateComponents) {
            let utcDateString = dateFormatter.string(from: dateWithTime)
            return utcDateString
        } else {
            return ""
        }
    }

    func convertTo24HourFormat(timeString: String) -> String? {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "hh:mm a"  // 12-hour format with AM/PM

        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "HH:mm"  // 24-hour format

        if let date = inputFormatter.date(from: timeString) {
            // Format the parsed date to 24-hour time format
            let formattedTime = outputFormatter.string(from: date)
            return formattedTime
        } else {
            // Invalid input time string
            return nil
        }
    }

    func convertTo12HourFormat(timeString: String) -> String? {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = TIME_24HOUR

        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = HMMAFormat

        if let date = inputFormatter.date(from: timeString) {
            // Format the parsed date to 24-hour time format
            let formattedTime = outputFormatter.string(from: date)
            return formattedTime
        } else {
            // Invalid input time string
            return nil
        }
    }

    func convertToUTC(from dateStr: String, in timeZoneIdentifier: String)
        -> String?
    {
        // Create a date formatter
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd hh:mm a"
        dateFormatter.timeZone = TimeZone(identifier: timeZoneIdentifier)

        // Parse the input date string to a Date object
        guard let date = dateFormatter.date(from: dateStr) else {
            return nil
        }

        // Set the date format for the output date string
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        let utcDateStr = dateFormatter.string(from: date)

        return utcDateStr
    }

    func convertUTCToLocalTimeZone(
        utcDateStr: String,
        toFormat outputFormat: String,
        userTimeZone: String
    ) -> String? {
        // Create a date formatter
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")

        // Parse the input UTC date string to a Date object
        guard let date = dateFormatter.date(from: utcDateStr) else {
            return nil
        }

        // Set the date format for the output date string
        dateFormatter.dateFormat = outputFormat
        dateFormatter.timeZone = TimeZone(identifier: userTimeZone)
        let localDateStr = dateFormatter.string(from: date)

        return localDateStr
    }

    func convertUTCToLocalTimeZone(
        dateFormat: String,
        utcDateStr: String,
        toFormat outputFormat: String,
        userTimeZone: String
    ) -> String? {
        // Create a date formatter
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")

        // Parse the input UTC date string to a Date object
        guard let date = dateFormatter.date(from: utcDateStr) else {
            return nil
        }

        // Set the date format for the output date string
        dateFormatter.dateFormat = outputFormat
        dateFormatter.timeZone = TimeZone(identifier: userTimeZone)
        let localDateStr = dateFormatter.string(from: date)

        return localDateStr
    }
    
    func resizedSize(for originalSize: CGSize, maxDimension: CGFloat) -> CGSize {
        let isLandscape = originalSize.width >= originalSize.height
        
        let newWidth: CGFloat
        let newHeight: CGFloat
        
        if isLandscape {
            newWidth = maxDimension
            newHeight = (originalSize.height / originalSize.width) * maxDimension
        } else {
            newHeight = maxDimension
            newWidth = (originalSize.width / originalSize.height) * maxDimension
        }
        
        return CGSize(width: round(newWidth), height: round(newHeight))
    }
    
    func resizeImage(_ image: UIImage, to newSize: CGSize) -> UIImage? {
        let renderer = UIGraphicsImageRenderer(size: newSize)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
    
    func getMimeType(for url: URL) -> String {
        let pathExtension = url.pathExtension.lowercased()
        
        switch pathExtension {
        case "jpg", "jpeg":
            return "image/jpeg"
        case "png":
            return "image/png"
        case "gif":
            return "image/gif"
        case "heic":
            return "image/heic"
        case "pdf":
            return "application/pdf"
        default:
            return "application/octet-stream"
        }
    }

    func convertDateToTimeZone(
        dateString: String,
        fromTimeZone: String,
        toTimeZone: String,
        outputFormat: String
    ) -> String? {
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withInternetDateTime]

        guard let date = dateFormatter.date(from: dateString) else {
            return nil
        }

        let fromTimeZone = TimeZone(identifier: fromTimeZone)!
        let toTimeZone = TimeZone(identifier: toTimeZone)!

        let fromOffset = TimeInterval(fromTimeZone.secondsFromGMT(for: date))
        let toOffset = TimeInterval(toTimeZone.secondsFromGMT(for: date))

        let correctedDate = date.addingTimeInterval(toOffset - fromOffset)

        let formatter = DateFormatter()
        formatter.dateFormat = outputFormat
        formatter.timeZone = toTimeZone

        return formatter.string(from: correctedDate)
    }

    func convertHTMLToStringWithFontAndCountLines(
        html: String,
        font: UIFont,
        color: UIColor
    ) -> (
        plainText: String, lineCount: Int, attributedString: NSAttributedString
    ) {
        // Convert the HTML string to Data
        guard let data = html.data(using: .utf8) else {
            return ("", 0, NSAttributedString())
        }

        // Define options for NSAttributedString initialization
        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue,
        ]

        // Create an NSAttributedString from the HTML data
        let attributedString: NSMutableAttributedString
        do {
            let tempAttributedString = try NSAttributedString(
                data: data,
                options: options,
                documentAttributes: nil
            )
            attributedString = NSMutableAttributedString(
                attributedString: tempAttributedString
            )
        } catch {
            print("Error creating attributed string from HTML: \(error)")
            return ("", 0, NSAttributedString())
        }

        // Apply the specified font to the entire attributed string
        let range = NSRange(location: 0, length: attributedString.length)
        attributedString.addAttributes(
            [.font: font, .foregroundColor: color],
            range: range
        )

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .justified
        attributedString.addAttribute(
            .paragraphStyle,
            value: paragraphStyle,
            range: range
        )

        // Extract the plain text from the NSAttributedString
        let plainText = attributedString.string

        // Calculate the number of lines in the plain text
        let lines = plainText.components(separatedBy: .newlines)
        let lineCount = lines.count

        // Return the plain text, line count, and the attributed string with the specified font
        return (plainText, lineCount, attributedString)
    }

    func showLoginVC() {
        let onBoardingFlow = Utils.loadVC(
            strStoryboardId: StoryBoard.SB_OnBoard,
            strVCId: "OnBoardNavVC"
        )
        sceneDelegate?.window?.rootViewController = onBoardingFlow
        sceneDelegate?.window?.makeKeyAndVisible()
    }

    func convertTimestampToTime(timestamp: Int) -> String {
        // Convert the timestamp to a TimeInterval by dividing it by 1000
        let timestampInMilliseconds = Double(timestamp)
        let timestampInSeconds = TimeInterval(timestampInMilliseconds / 1000)
        let date = Date(timeIntervalSince1970: timestampInSeconds)

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm a"

        return dateFormatter.string(from: date)
    }

    func convertTimeStringToComponents(_ timeString: String) -> DateComponents?
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"  // Use the appropriate format based on your input time string

        if let date = dateFormatter.date(from: timeString) {
            let calendar = Calendar.current
            let components = calendar.dateComponents(
                [.hour, .minute],
                from: date
            )
            return components
        }

        return nil  // Parsing failed
    }

    func getPointsAmount(amount: Double) -> (String, Double) {
        let calculatedAmount = (Double(amount))

        var formate = "%.0f"
        let isInteger = floor(calculatedAmount) == calculatedAmount
        if isInteger == false {
            formate = "%.2f"
        }

        return (formate, calculatedAmount)
    }

    func getAgeComponents(from dateString: String) -> (
        yearsOld: Int, monthsOld: Int, daysOld: Int
    ) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = DD_MM_YYYY

        guard let birthDate = dateFormatter.date(from: dateString) else {
            return (0, 0, 0)  // Return nil if the date string is invalid
        }

        let calendar = Calendar.current
        let currentDate = Date()

        let ageComponents = calendar.dateComponents(
            [.year, .month, .day],
            from: birthDate,
            to: currentDate
        )

        guard let yearsOld = ageComponents.year,
            let monthsOld = ageComponents.month, let daysOld = ageComponents.day
        else {
            return (0, 0, 0)
        }

        return (yearsOld, monthsOld, daysOld)
    }

    func extractNumericValue(from string: String) -> String? {
        let pattern = "[0-9.]+"
        let regex = try! NSRegularExpression(pattern: pattern, options: [])
        let matches = regex.matches(
            in: string,
            options: [],
            range: NSRange(location: 0, length: string.utf16.count)
        )

        guard let match = matches.first else {
            return nil
        }

        return (string as NSString).substring(with: match.range)
    }

    func imageRatioCalculate(
        imageRatio: String,
        widthThatMinus: CGFloat,
        heightWouldBe: CGFloat
    ) -> CGFloat {
        var contentHeight: CGFloat = heightWouldBe
        let contentWidth: CGFloat = screenWidth() - widthThatMinus

        let widthHeightRatio = imageRatio.components(separatedBy: ":")

        var widthRatio: CGFloat = 0.0
        let width = widthHeightRatio.first ?? ""
        if let number = NumberFormatter().number(from: width) {
            let widthFloat = CGFloat(truncating: number)
            widthRatio = widthFloat
        }

        var heightRatio: CGFloat = 0.0
        let height = widthHeightRatio.last ?? ""
        if let number = NumberFormatter().number(from: height) {
            let heightFloat = CGFloat(truncating: number)
            heightRatio = heightFloat
        }

        var ratio: CGFloat = 0.0

        if widthRatio > heightRatio {
            ratio = 1 / (widthRatio / heightRatio)
            contentHeight = contentWidth * ratio
        } else if widthRatio < heightRatio {
            ratio = widthRatio / heightRatio
            contentHeight = contentWidth / ratio
        } else if widthRatio == heightRatio {
            ratio = 1
            contentHeight = contentWidth * ratio
        } else {
            ratio = 0
            contentHeight = contentWidth * ratio
        }

        return contentHeight
    }

    func imageRatioCalculateWidth(
        imageRatio: String,
        widthThatMinus: CGFloat,
        heightWouldBe: CGFloat
    ) -> CGFloat {
        let contentHeight: CGFloat = heightWouldBe
        var contentWidth: CGFloat = screenWidth() - widthThatMinus

        let widthHeightRatio = imageRatio.components(separatedBy: ":")

        var widthRatio: CGFloat = 0.0
        let width = widthHeightRatio.first ?? ""
        if let number = NumberFormatter().number(from: width) {
            let widthFloat = CGFloat(truncating: number)
            widthRatio = widthFloat
        }

        var heightRatio: CGFloat = 0.0
        let height = widthHeightRatio.last ?? ""
        if let number = NumberFormatter().number(from: height) {
            let heightFloat = CGFloat(truncating: number)
            heightRatio = heightFloat
        }

        var ratio: CGFloat = 0.0

        if widthRatio > heightRatio {
            ratio = 1 / (widthRatio / heightRatio)
            contentWidth = contentHeight / ratio
        } else if widthRatio < heightRatio {
            ratio = widthRatio / heightRatio
            contentWidth = contentHeight * ratio
        } else if widthRatio == heightRatio {
            ratio = 1
            contentWidth = contentHeight * ratio
        } else {
            ratio = 0
            contentWidth = contentHeight * ratio
        }

        return contentWidth
    }

    func alert(message: String, title: String? = App_Name) {
        DispatchQueue.main.async {
            let alert = UIAlertController(
                title: title,
                message: message,
                preferredStyle: .alert
            )
            let action = UIAlertAction(
                title: "OK",
                style: .cancel,
                handler: nil
            )
            alert.addAction(action)
            alert.show()
        }
    }

    func alert(
        message: String,
        title: String? = App_Name,
        button: String?,
        action: @escaping (Int) -> Void
    ) {
        DispatchQueue.main.async {
            let alert = UIAlertController(
                title: title,
                message: message,
                preferredStyle: UIAlertController.Style.alert
            )
            let action1 = UIAlertAction(title: button, style: .default) { _ in
                action(0)
            }
            alert.addAction(action1)
            alert.show()
        }
    }

    func createValueWithoutComma(value: String) -> String {
        let tempValue = value.components(separatedBy: ",")
        let againTempValue = tempValue.joined(separator: "")
        return againTempValue
    }

    func imageOrientation(_ src: UIImage) -> UIImage {
        if src.imageOrientation == UIImage.Orientation.up {
            return src
        }
        var transform: CGAffineTransform = CGAffineTransform.identity
        switch src.imageOrientation {
        case UIImage.Orientation.down, UIImage.Orientation.downMirrored:
            transform = transform.translatedBy(
                x: src.size.width,
                y: src.size.height
            )
            transform = transform.rotated(by: CGFloat(Double.pi))
            break
        case UIImage.Orientation.left, UIImage.Orientation.leftMirrored:
            transform = transform.translatedBy(x: src.size.width, y: 0)
            transform = transform.rotated(by: CGFloat(Double.pi))
            break
        case UIImage.Orientation.right, UIImage.Orientation.rightMirrored:
            transform = transform.translatedBy(x: 0, y: src.size.height)
            transform = transform.rotated(by: CGFloat(-(Double.pi / 2)))
            break
        case UIImage.Orientation.up, UIImage.Orientation.upMirrored:
            break
        @unknown default:
            break
        }

        switch src.imageOrientation {
        case UIImage.Orientation.upMirrored, UIImage.Orientation.downMirrored:
            transform.translatedBy(x: src.size.width, y: 0)
            transform.scaledBy(x: -1, y: 1)
            break
        case UIImage.Orientation.leftMirrored,
            UIImage.Orientation.rightMirrored:
            transform.translatedBy(x: src.size.height, y: 0)
            transform.scaledBy(x: -1, y: 1)
        case UIImage.Orientation.up, UIImage.Orientation.down,
            UIImage.Orientation.left, UIImage.Orientation.right:
            break
        @unknown default:
            break
        }

        let ctx: CGContext = CGContext(
            data: nil,
            width: Int(src.size.width),
            height: Int(src.size.height),
            bitsPerComponent: (src.cgImage)!.bitsPerComponent,
            bytesPerRow: 0,
            space: (src.cgImage)!.colorSpace!,
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        )!

        ctx.concatenate(transform)

        switch src.imageOrientation {
        case UIImage.Orientation.left, UIImage.Orientation.leftMirrored,
            UIImage.Orientation.right, UIImage.Orientation.rightMirrored:
            ctx.draw(
                src.cgImage!,
                in: CGRect(
                    x: 0,
                    y: 0,
                    width: src.size.height,
                    height: src.size.width
                )
            )
            break
        default:
            ctx.draw(
                src.cgImage!,
                in: CGRect(
                    x: 0,
                    y: 0,
                    width: src.size.width,
                    height: src.size.height
                )
            )
            break
        }

        let cgimg: CGImage = ctx.makeImage()!
        let img: UIImage = UIImage(cgImage: cgimg)

        return img
    }

    func weekDaysSet(from startDate: Date, to endDate: Date) -> (
        [String], [Int]
    ) {
        let calendar = Calendar.current
        var currentDate = startDate
        var weekdayStrings: [String] = []
        var weekdayIndices: [Int] = []

        let components = calendar.dateComponents(
            [.day],
            from: startDate,
            to: endDate
        )
        let totalDates = components.day ?? 0
        let count = totalDates + 1

        var newCount = 0
        if count > 7 {
            while currentDate <= endDate {
                newCount += 1
                if newCount < 8 {
                    let weekdayIndex = calendar.component(
                        .weekday,
                        from: currentDate
                    )
                    let weekdayString = calendar.shortWeekdaySymbols[
                        weekdayIndex - 1
                    ]
                    weekdayStrings.append(weekdayString)
                    weekdayIndices.append(weekdayIndex)
                    currentDate = calendar.date(
                        byAdding: .day,
                        value: 1,
                        to: currentDate
                    )!
                } else {
                    return (weekdayStrings, weekdayIndices)
                }
            }
            return (weekdayStrings, weekdayIndices)
        } else {
            while currentDate <= endDate {
                let weekdayIndex = calendar.component(
                    .weekday,
                    from: currentDate
                )
                let weekdayString = calendar.shortWeekdaySymbols[
                    weekdayIndex - 1
                ]
                weekdayStrings.append(weekdayString)
                weekdayIndices.append(weekdayIndex)
                currentDate = calendar.date(
                    byAdding: .day,
                    value: 1,
                    to: currentDate
                )!
            }
            return (weekdayStrings, weekdayIndices)
        }
    }

    func removeBoldTags(from input: String) -> String {
        // Define the regular expression pattern to match <b> and </b> tags
        let pattern = "<b>|</b>"

        do {
            // Create a regular expression object
            let regex = try NSRegularExpression(pattern: pattern, options: [])

            // Replace the matched pattern with an empty string
            let range = NSRange(location: 0, length: input.utf16.count)
            let result = regex.stringByReplacingMatches(
                in: input,
                options: [],
                range: range,
                withTemplate: ""
            )

            return result
        } catch {
            print("Error creating regular expression: \(error)")
            return input
        }
    }

    func maskAccountNumber(_ accountNumber: String) -> String {
        var maskedString = ""

        for index in 0..<accountNumber.count {
            if index < accountNumber.count - 4 {
                if index % 4 == 0 && index != 0 {
                    maskedString += " "
                }
                maskedString += "X"
            } else {
                maskedString.append(
                    accountNumber[
                        accountNumber.index(
                            accountNumber.startIndex,
                            offsetBy: index
                        )
                    ]
                )
            }
        }

        return maskedString
    }

    func createYearArray() -> [Int] {
        let currentYear = Calendar.current.component(.year, from: Date())
        let startingYear = 1950

        var years: [Int] = []

        for year in stride(from: currentYear, through: startingYear, by: -1) {
            years.append(year)
        }

        return years
    }

    func formatTime(seconds: Int) -> String {
        let hours = Int(seconds) / 3600
        let minutes = (Int(seconds) % 3600) / 60

        if hours > 1 {
            // If both hours and minutes are non-zero
            return "\(hours) hrs"
        } else if hours == 1 {
            // If only hours are non-zero
            return "\(hours) hr"
        } else if minutes > 0 {
            // If only minutes are non-zero
            return "\(minutes) min"
        } else {
            // If both hours and minutes are zero
            return "0 min"
        }
    }

    func generateTimeSlots(
        startTime: String,
        endTime: String,
        intervalMinutes: Int
    ) -> [String] {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"

        guard let startDate = dateFormatter.date(from: startTime),
            let endDate = dateFormatter.date(from: endTime)
        else {
            return []
        }

        var timeSlots: [String] = []
        var currentDate = startDate

        while currentDate < endDate {
            guard
                let nextDate = Calendar.current.date(
                    byAdding: .minute,
                    value: intervalMinutes,
                    to: currentDate
                ),
                nextDate <= endDate
            else {
                break
            }

            let formattedStartTime = dateFormatter.string(from: currentDate)
            let formattedEndTime = dateFormatter.string(from: nextDate)
            let timeSlot = "\(formattedStartTime) - \(formattedEndTime)"
            timeSlots.append(timeSlot)

            currentDate = nextDate
        }

        return timeSlots
    }

    func generateStringFromArray(array: [String]) -> String {
        if !array.isEmpty {
            let resultString: String

            if array.count == 1 {
                resultString = array[0]
            } else {
                let lastElement = array.last!
                let joinedString = array.dropLast().joined(separator: ", ")
                resultString = "\(joinedString) and \(lastElement)"
            }
            return resultString
        } else {
            print("The array is empty.")
            return ""
        }
    }

    func show10YearsFromCurrent() -> [Int] {
        let currentYear = Calendar.current.component(.year, from: Date())
        let yearsArray = (currentYear)...(currentYear + 9)
        let arrayOfYears = yearsArray.map { $0 }
        print(arrayOfYears)
        return arrayOfYears
    }

    func show1YearsFromCurrent() -> [Int] {
        let currentYear = Calendar.current.component(.year, from: Date())
        let yearsArray = (currentYear)...(currentYear + 1)
        let arrayOfYears = yearsArray.map { $0 }
        print(arrayOfYears)
        return arrayOfYears
    }

    func getMinMaxYearsArray() -> [Int] {
        let currentYear = Calendar.current.component(.year, from: Date())
        let yearsArray = (currentYear - 4)...(currentYear + 7)
        let arrayOfYears = yearsArray.map { $0 }
        print(arrayOfYears)
        return arrayOfYears
    }

    func getSecondYearsArray() -> [Int] {
        let currentYear = Calendar.current.component(.year, from: Date())
        let yearsArray = (currentYear + 8)...(currentYear + 19)
        let arrayOfYears = yearsArray.map { $0 }
        print(arrayOfYears)
        return arrayOfYears
    }

    func getWeekendDatesInMonth(forMonth month: String) -> [Date] {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM/yyyy"

        guard let startDate = dateFormatter.date(from: month) else {
            return []
        }

        let calendar = Calendar.current
        var currentDate = Date()

        // Set currentDate to the start of the specified month
        currentDate = calendar.date(bySetting: .day, value: 1, of: startDate)!

        var weekendDates: [Date] = []

        while calendar.component(.month, from: currentDate)
            == calendar.component(.month, from: startDate)
        {
            let weekday = calendar.component(.weekday, from: currentDate)

            // Check if the current day is Saturday or Sunday
            if weekday == 1 || weekday == 7 {
                // Check if the current date is greater than or equal to the current date
                if currentDate >= Date() {
                    weekendDates.append(currentDate)
                }
            }

            // Move to the next day
            if let nextDate = calendar.date(
                byAdding: .day,
                value: 1,
                to: currentDate
            ) {
                currentDate = nextDate
            } else {
                break
            }
        }

        return weekendDates
    }

    func getWeekendDatesInYear(forYear year: String) -> [Date] {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy"

        guard let startDate = dateFormatter.date(from: year) else {
            return []
        }

        let calendar = Calendar.current
        var currentDate = Date()

        // Set currentDate to the start of the specified year
        currentDate = calendar.date(
            bySetting: .year,
            value: calendar.component(.year, from: startDate),
            of: currentDate
        )!

        var weekendDates: [Date] = []

        while calendar.component(.year, from: currentDate)
            == calendar.component(.year, from: startDate)
        {
            let weekday = calendar.component(.weekday, from: currentDate)

            // Check if the current day is Saturday or Sunday
            if weekday == 1 || weekday == 7 {
                // Check if the current date is greater than or equal to the current date
                if currentDate >= Date() {
                    weekendDates.append(currentDate)
                }
            }

            // Move to the next day
            if let nextDate = calendar.date(
                byAdding: .day,
                value: 1,
                to: currentDate
            ) {
                currentDate = nextDate
            } else {
                break
            }
        }

        return weekendDates
    }

    func daySuffix(for day: Int) -> String {
        switch day {
        case 1, 21, 31:
            return "st"
        case 2, 22:
            return "nd"
        case 3, 23:
            return "rd"
        default:
            return "th"
        }
    }

    func removeWords(from originalString: String, wordsToRemove: [String])
        -> String
    {
        var modifiedString = originalString

        for word in wordsToRemove {
            if modifiedString.contains(word) {
                modifiedString = modifiedString.replacingOccurrences(
                    of: word,
                    with: ""
                )
            }
        }

        modifiedString = modifiedString.trimmingCharacters(
            in: .whitespacesAndNewlines
        )
        return modifiedString
    }

    func redirectToOnboarding() {
        changeRootViewController(
            storyboard: StoryBoard.SB_OnBoard,
            identifier: "OnBoardNavVC"
        )
    }

    func redirectToHome() {
        changeRootViewController(
            storyboard: StoryBoard.SB_Home,
            identifier: "HomeNavVC"
        )
    }

    func changeRootViewController(storyboard: String, identifier: String) {
        let viewController = Utils.loadVC(
            strStoryboardId: storyboard,
            strVCId: identifier
        )

        // Add smooth transition
        UIView.transition(
            with: sceneDelegate!.window!,
            duration: 0.3,
            options: .transitionCrossDissolve,
            animations: {
                sceneDelegate?.window?.rootViewController = viewController
                sceneDelegate?.window?.makeKeyAndVisible()
            }
        )
    }
    
    func applyLineSpacing(to label: UILabel, lineSpacing: CGFloat, alignment: NSTextAlignment = .center) {
        guard let text = label.text else { return }
        
        let attributedString = NSMutableAttributedString(string: text)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = lineSpacing
        paragraphStyle.alignment = alignment
        
        attributedString.addAttribute(
            .paragraphStyle,
            value: paragraphStyle,
            range: NSMakeRange(0, attributedString.length)
        )
        
        label.attributedText = attributedString
    }
}

//MARK: - Alert Extension
private var kAlertControllerWindow = "kAlertControllerWindow"
extension UIAlertController {

    var alertWindow: UIWindow? {
        get {
            return objc_getAssociatedObject(self, &kAlertControllerWindow)
                as? UIWindow
        }
        set {
            objc_setAssociatedObject(
                self,
                &kAlertControllerWindow,
                newValue,
                .OBJC_ASSOCIATION_RETAIN
            )
        }
    }

    func show() {
        show(animated: true)
    }

    func show(animated: Bool) {
        alertWindow = UIWindow(frame: UIScreen.main.bounds)
        alertWindow?.rootViewController = UIViewController()
        alertWindow?.windowLevel = UIWindow.Level.alert + 1
        alertWindow?.makeKeyAndVisible()
        alertWindow?.rootViewController?.present(
            self,
            animated: animated,
            completion: nil
        )
    }

    open override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        alertWindow?.isHidden = true
        alertWindow = nil
    }
}

public func screenWidth() -> CGFloat {
    let screenSize = UIScreen.main.bounds
    return screenSize.width
}

public func screenHeight() -> CGFloat {
    let screenSize = UIScreen.main.bounds
    return screenSize.height
}

struct AppFont {
    enum FontType: String {
        case I_Bold = "Inter-Bold"
        case I_SemiBold = "Inter-SemiBold"
        case I_Medium = "Inter-Medium"
        case I_Regular = "Inter-Regular"
        case G_Bold = "Gilroy-Bold"
        case G_SemiBold = "Gilroy-SemiBold"
        case G_Medium = "Gilroy-Medium"
        case G_Regular = "Gilroy-Regular"
        case G_Italic = "Gilroy-RegularItalic"
        case G_BoldItalic = "Gilroy-BoldItalic"
        case C_Bold = "CircularStd-Bold"
        case C_Medium = "CircularStd-Medium"
        case C_Book = "CircularStd-Book"
        case H_Bold = "Helvetica-Bold"
        case H_Regular = "Helvetica"
    }

    static func font(type: FontType, size: CGFloat) -> UIFont {
        return UIFont(name: type.rawValue, size: size)!
    }
}
