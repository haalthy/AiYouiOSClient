//
//  CVCalendarMenuView.swift
//  CVCalendar
//
//  Created by E. Mozharovsky on 12/26/14.
//  Copyright (c) 2014 GameApp. All rights reserved.
//

import UIKit

class CVCalendarMenuView: UIView {
    var symbols = [String]()
    var symbolViews: [UILabel]?

    var firstWeekday: Weekday? = .sunday
    var dayOfWeekTextColor: UIColor? = .darkGray
    var dayOfWeekTextUppercase: Bool? = true
    var dayOfWeekFont: UIFont? = UIFont(name: "Avenir", size: 10)

    @IBOutlet weak var menuViewDelegate: AnyObject? {
        set {
            if let delegate = newValue as? MenuViewDelegate {
                self.delegate = delegate
            }
        }
        
        get {
            return delegate as? AnyObject
        }
    }
    
    var delegate: MenuViewDelegate? {
        didSet {
            setupAppearance()
            setupWeekdaySymbols()
            createDaySymbols()
        }
    }

    init() {
        super.init(frame: CGRect.zero)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    func setupAppearance() {
        if let delegate = delegate {
            firstWeekday~>delegate.firstWeekday?()
            dayOfWeekTextColor~>delegate.dayOfWeekTextColor?()
            dayOfWeekTextUppercase~>delegate.dayOfWeekTextUppercase?()
            dayOfWeekFont~>delegate.dayOfWeekFont?()
        }
    }

    func setupWeekdaySymbols() {
        var calendar = Calendar(identifier: Calendar.Identifier.chinese)
        (calendar as NSCalendar).components([NSCalendar.Unit.month, NSCalendar.Unit.day], from: Foundation.Date())
        calendar.firstWeekday = firstWeekday!.rawValue

        symbols = calendar.weekdaySymbols 
    }
    
    func createDaySymbols() {
        // Change symbols with their places if needed.
        let dateFormatter = DateFormatter()
        var weekdays = dateFormatter.shortWeekdaySymbols as NSArray

        let firstWeekdayIndex = firstWeekday!.rawValue - 1
        if (firstWeekdayIndex > 0) {
            let copy = weekdays
            weekdays = (weekdays.subarray(with: NSMakeRange(firstWeekdayIndex, 7 - firstWeekdayIndex)) as NSArray)
            weekdays = weekdays.addingObjects(from: copy.subarray(with: NSMakeRange(0, firstWeekdayIndex))) as NSArray
        }
        
        self.symbols = weekdays as! [String]
        
        // Add symbols.
        self.symbolViews = [UILabel]()
        let space = 0 as CGFloat
        let width = self.frame.width / 7 - space
        let height = self.frame.height
        
        var x: CGFloat = 0
        let y: CGFloat = 0
        
        for i in 0..<7 {
            x = CGFloat(i) * width + space
            
            let symbol = UILabel(frame: CGRect(x: x, y: y, width: width, height: height))
            symbol.textAlignment = .center
            symbol.text = self.symbols[i]
            
            //周一 周二 周三
            switch (symbol.text)! {
                case "Sun":
                    symbol.text = "日"
                break
            case "Mon":
                symbol.text = "一"
                break
            case "Tue":
                symbol.text = "二"
                break
            case "Wed":
                symbol.text = "三"
                break
            case "Thu":
                symbol.text = "四"
                break
            case "Fri":
                symbol.text = "五"
                break
            case "Sat":
                symbol.text = "六"
                break
            default:
                break
            }
//            if (dayOfWeekTextUppercase!) {
//                symbol.text = (self.symbols[i]).uppercaseString
//            }

            symbol.font = dayOfWeekFont
            symbol.textColor = dayOfWeekTextColor

            self.symbolViews?.append(symbol)
            self.addSubview(symbol)
        }
    }
    
    func commitMenuViewUpdate() {
        if let delegate = delegate {
            let space = 0 as CGFloat
            let width = self.frame.width / 7 - space
            let height = self.frame.height
            
            var x: CGFloat = 0
            let y: CGFloat = 0
            
            for i in 0..<self.symbolViews!.count {
                x = CGFloat(i) * width + space
                
                let frame = CGRect(x: x, y: y, width: width, height: height)
                let symbol = self.symbolViews![i]
                symbol.frame = frame
            }
        }
    }
}
