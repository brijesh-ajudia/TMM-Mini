//
//  Date+Extension.swift
//  TMM Mini
//
//  Created by Brijesh Ajudia on 06/01/26.
//

import Foundation
extension Date {
    func year() -> Int {
        let calendar = Calendar.current
        return calendar.component(.year, from: self)
    }
    
    func month() -> Int {
        let calendar = Calendar.current
        return calendar.component(.month, from: self)
    }
    
    /// Returns the amount of hours from another date
    func hours(from date: Date) -> Int {
        return Calendar.current.dateComponents([.hour], from: date, to: self).hour ?? 0
    }
    
    func removeTimeStamp() -> Date {
        guard let date = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month, .day], from: self)) else {
            fatalError("Failed to strip time from Date object")
        }
        return date
    }
    
    var day: Int {
        return Calendar.current.component(.day, from: self)
    }
    
    func toStringWithDay_DMMM(format: String) -> String {
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = format
        return dateFormat.string(from: self)
    }

    func toStringWithFormat(format: String) -> String {
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = format
        return dateFormat.string(from: self)
    }
    
    
    var toTimeStamp: Double {
        return self.timeIntervalSince1970 * 1000.0
    }
    
    func convertDate(format: String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        let dateObj = dateFormatter.string(from: self)
        return dateFormatter.date(from: dateObj)!
    }
    
    func convertDateString(format: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }
    
    func previousWeek() -> Date {
        return self.addingTimeInterval(-7*24*60*60)
    }
    var startOfWeek: Date? {
        let gregorian = Calendar(identifier: .gregorian)
        guard let sunday = gregorian.date(from: gregorian.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)) else { return nil }
        return gregorian.date(byAdding: .day, value: 1, to: sunday)
    }
    
    var endOfWeek: Date? {
        let gregorian = Calendar(identifier: .gregorian)
        guard let sunday = gregorian.date(from: gregorian.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)) else { return nil }
        return gregorian.date(byAdding: .day, value: 7, to: sunday)
    }
    
    func dayOfWeek() -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        return dateFormatter.string(from: self).capitalized
    }
    
    static func today() -> Date {
        return Date()
    }
    
    
    func next(_ weekday: Weekday, considerToday: Bool = false) -> Date {
        return get(.Next,
                   weekday,
                   considerToday: considerToday)
    }
    
    func previous(_ weekday: Weekday, considerToday: Bool = false) -> Date {
        return get(.Previous,
                   weekday,
                   considerToday: considerToday)
    }
    
    func get(_ direction: SearchDirection,
             _ weekDay: Weekday,
             considerToday consider: Bool = false) -> Date {
        
        let dayName = weekDay.rawValue
        
        let weekdaysName = getWeekDaysInEnglish().map { $0.lowercased() }
        
        assert(weekdaysName.contains(dayName), "weekday symbol should be in form \(weekdaysName)")
        
        let searchWeekdayIndex = weekdaysName.firstIndex(of: dayName)! + 1
        
        let calendar = Calendar(identifier: .gregorian)
        
        if consider && calendar.component(.weekday, from: self) == searchWeekdayIndex {
            return self
        }
        
        var nextDateComponent = DateComponents()
        nextDateComponent.weekday = searchWeekdayIndex
        
        
        let date = calendar.nextDate(after: self,
                                     matching: nextDateComponent,
                                     matchingPolicy: .nextTime,
                                     direction: direction.calendarSearchDirection)
        
        return date!
    }
    
    func getWeekDaysInEnglish() -> [String] {
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = Locale(identifier: "en_US_POSIX")
        return calendar.weekdaySymbols
    }
    
    enum Weekday: String {
        case monday, tuesday, wednesday, thursday, friday, saturday, sunday
    }
    
    enum SearchDirection {
        case Next
        case Previous
        
        var calendarSearchDirection: Calendar.SearchDirection {
            switch self {
            case .Next:
                return .forward
            case .Previous:
                return .backward
            }
        }
    }
    
    func getISO8601Date() -> String {
        let isoDateFormatter = ISO8601DateFormatter()
        print("ISO8601 string: \(isoDateFormatter.string(from: self))")
        let iso8601String = isoDateFormatter.string(from: self)
        return iso8601String
    }
    
    func startOfDate() -> Date {
        let startOfDate = Calendar.current.startOfDay(for: self)
        return startOfDate
    }
    
    var startOfMonth: Date {
        let calendar = Calendar(identifier: .gregorian)
        let components = calendar.dateComponents([.year, .month], from: self)
        
        return  calendar.date(from: components)!
    }
    
    var endOfMonth: Date {
        var components = DateComponents()
        components.month = 1
        components.second = -1
        return Calendar(identifier: .gregorian).date(byAdding: components, to: startOfMonth)!
    }
    
    func toMilliseconds() -> Int64 {
        Int64(self.timeIntervalSince1970 * 1000)
    }
    
    var yearsFromNow: Int {
        return Calendar.current.dateComponents([.year], from: self, to: Date()).year!
    }
    var monthsFromNow: Int {
        return Calendar.current.dateComponents([.month], from: self, to: Date()).month!
    }
    var weeksFromNow: Int {
        return Calendar.current.dateComponents([.weekOfYear], from: self, to: Date()).weekOfYear!
    }
    var daysFromNow: Int {
        return Calendar.current.dateComponents([.day], from: self, to: Date()).day!
    }
    var isInYesterday: Bool {
        return Calendar.current.isDateInYesterday(self)
    }
    var hoursFromNow: Int {
        return Calendar.current.dateComponents([.hour], from: self, to: Date()).hour!
    }
    var minutesFromNow: Int {
        return Calendar.current.dateComponents([.minute], from: self, to: Date()).minute!
    }
    var secondsFromNow: Int {
        return Calendar.current.dateComponents([.second], from: self, to: Date()).second!
    }
    var relativeTime: String {
        //if yearsFromNow > 0 { return "\(yearsFromNow) year" + (yearsFromNow > 1 ? "s" : "") + " ago" }
        if monthsFromNow > 0 { return "\(monthsFromNow) month" + (monthsFromNow > 1 ? "s" : "") + " ago" }
        if weeksFromNow > 0 { return "\(weeksFromNow) week" + (weeksFromNow > 1 ? "s" : "") + " ago" }
        if isInYesterday { return "Yesterday" }
        if daysFromNow > 0 { return "\(daysFromNow) day" + (daysFromNow > 1 ? "s" : "") + " ago" }
        if hoursFromNow > 0 { return "\(hoursFromNow) hr" + (hoursFromNow > 1 ? "s" : "") + " ago" }
        if minutesFromNow > 0 { return "\(minutesFromNow) min" + (minutesFromNow > 1 ? "s" : "") + " ago" }
        if secondsFromNow > 0 { return secondsFromNow < 15 ? "Just now"
            : "\(secondsFromNow) " + (secondsFromNow > 1 ? "s" : "") + " ago"}
        return ""
    }
    
    func formatLastSeenDate() -> String {
        let calendar = Calendar.current
        let now = Date()
        
        let isToday = calendar.isDateInToday(self)
        let isYesterday = calendar.isDateInYesterday(self)
        
        let isSameMonth = calendar.isDate(self, equalTo: now, toGranularity: .month)
        let isLastMonth = calendar.isDate(self, equalTo: now.addingTimeInterval(-60 * 60 * 24 * 30), toGranularity: .month)
        
        let formatter = DateFormatter()
        
        if isToday {
            formatter.dateFormat = "h:mm a"
            return "Last seen today at \(formatter.string(from: self))"
        } else if isYesterday {
            formatter.dateFormat = "h:mm a"
            return "Last seen yesterday at \(formatter.string(from: self))"
        } else if isSameMonth {
            formatter.dateFormat = "d MMM 'at' h:mm a"
            return "Last seen on \(formatter.string(from: self))"
        } else if isLastMonth {
            formatter.dateFormat = "d MMM 'at' h:mm a"
            return "Last seen on \(formatter.string(from: self))"
        } else {
            formatter.dateFormat = "d MMM, yyyy 'at' h:mm a"
            return "Last seen on \(formatter.string(from: self))"
        }
    }
    
    func convertDateToString(serverFormate:String = "yyyy-MM-dd HH:mm:ss", convertForm: String) -> String {
        let formatter = DateFormatter()
        // initially set the format based on your datepicker date / server String
        formatter.dateFormat = serverFormate
        let myString = formatter.string(from: self) // string purpose I add here
        // convert your string to date
        if let yourDate = formatter.date(from: myString){
            //then again set the date format whhich type of output you need
            formatter.dateFormat = convertForm
            // again convert your date to string
            return formatter.string(from: yourDate)
        }
        return ""
    }
    
    func convertDateFormat(inputDateString: String, convertForm: String) -> String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = convertForm
        
        if let date = inputFormatter.date(from: inputDateString) {
            let outputFormatter = DateFormatter()
            outputFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
            return outputFormatter.string(from: date)
        }
        
        return ""
    }
}
