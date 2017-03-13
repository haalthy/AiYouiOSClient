//
//  CVDate.swift
//  CVCalendar
//
//  Created by Мак-ПК on 12/31/14.
//  Copyright (c) 2014 GameApp. All rights reserved.
//

import UIKit

class CVDate: NSObject {
    fileprivate let date: Foundation.Date
    
    let year: Int
    let month: Int
    let week: Int
    let day: Int
    
    init(date: Foundation.Date) {
        let dateRange = Manager.dateRange(date)
        
        self.date = date
        self.year = dateRange.year
        self.month = dateRange.month
        self.week = dateRange.weekOfMonth
        self.day = dateRange.day
        
        super.init()
    }
    
    init(day: Int, month: Int, week: Int, year: Int) {
        if let date = Manager.dateFromYear(year, month: month, week: week, day: day) {
            self.date = date
        } else {
            self.date = Foundation.Date()
        }
        
        self.year = year
        self.month = month
        self.week = week
        self.day = day
        
        super.init()
    }
}

extension CVDate {
    func convertedDate() -> Foundation.Date? {
        let calendar = Calendar.current
        var comps = Manager.componentsForDate(Foundation.Date())
        
        comps.year = year
        comps.month = month
        comps.weekOfMonth = week
        comps.day = day
        
        return calendar.date(from: comps)
    }
}

extension CVDate {
    var globalDescription: String {
        get {
//            let month = dateFormattedStringWithFormat("MMMM", fromDate: date)
//            return "\(month), \(year)"
            return "\(CVDate(date: date).year)年\(CVDate(date: date).month)月"
            
        }
    }
    
    var commonDescription: String {
        get {
            let month = dateFormattedStringWithFormat("MMMM", fromDate: date)
            return "\(day) \(month), \(year)"
        }
    }
}

private extension CVDate {
    func dateFormattedStringWithFormat(_ format: String, fromDate date: Foundation.Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: date)
    }
}
