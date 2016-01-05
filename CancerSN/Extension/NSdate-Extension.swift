//
//  NSdate-Extension.swift
//  CancerSN
//
//  Created by lay on 16/1/5.
//  Copyright © 2016年 lily. All rights reserved.
//

import Foundation

extension NSDate {

    // 使日期字符串 创建NSDate
    class func createDate(timeInterval: Int64) -> NSDate? {
        
//        // 创建fomater
//        let ft = NSDateFormatter()
//        
//        // 设置本地化
//        // 在真机调试的时候，一定要指定区域，否则以前版本同样无法转换
//        ft.locale = NSLocale(localeIdentifier: "Asia/Beijing")
//        
//        // 设置日期格式
//        ft.dateFormat = "EEE MMM dd HH:mm:ss zzz yyyy"
//        
//        // 生成日期
//        return ft.dateFromString(fullDateString)
        
        // 生成日期
        let updateDate = NSDate(timeIntervalSince1970: Double(timeInterval))
        
        return updateDate
    }
    
    func fullDescription() -> String {
        
        // 用日历类获得当前的日期
        let calendar = NSCalendar.currentCalendar()
        
        // 创建datefomater
        let ft = NSDateFormatter()
        
        // 当天
        if calendar.isDateInToday(self) {
            // 获取日期与当前时间的差值
            let delta = Int(NSDate().timeIntervalSinceDate(self))
            if delta < 60 {
                return "刚刚"
            }
            
            if delta < 3600 {
                
                return "\(delta/60)分钟前"
            }
            return "\(delta/3600)小时前"
        }
        
        // 昨天
        if calendar.isDateInYesterday(self) {
            ft.dateFormat = "昨天 HH:mm"
            return ft.stringFromDate(self)
        }
        
        // 计算年度差值
        let coms = calendar.components(NSCalendarUnit.Year, fromDate: NSDate(), toDate: self, options: NSCalendarOptions(rawValue: 0))
        
        // 今年
        if coms.year == 0 {
            ft.dateFormat = "MM-dd"
            return ft.stringFromDate(self)
        }
        
        // 剩下的都是往年了
        ft.dateFormat = "yyyy-MM-dd"
        return ft.stringFromDate(self)
    }
    
}