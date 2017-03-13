//
//  CVCalendarWeekView.swift
//  CVCalendar
//
//  Created by E. Mozharovsky on 12/26/14.
//  Copyright (c) 2014 GameApp. All rights reserved.
//

import UIKit
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}


class CVCalendarWeekView: UIView {
    // MARK: - Non public properties
    fileprivate var interactiveView: UIView!
    
    override var frame: CGRect {
        didSet {
            if let calendarView = calendarView {
                if calendarView.calendarMode == CalendarMode.weekView {
                    updateInteractiveView()
                }
            }
        }
    }
    
    fileprivate var touchController: CVCalendarTouchController {
        return calendarView.touchController
    }
    
    // MARK: - Public properties
    
    weak var monthView: CVCalendarMonthView!
    var dayViews: [CVCalendarDayView]!
    var index: Int!
    
    var weekdaysIn: [Int : [Int]]?
    var weekdaysOut: [Int : [Int]]?
    var utilizable = false /// Recovery service.
    
    weak var calendarView: CVCalendarView! {
        get {
            var calendarView: CVCalendarView!
            if let monthView = monthView, let activeCalendarView = monthView.calendarView {
                calendarView = activeCalendarView
            }
            
            return calendarView
        }
    }
    
    // MARK: - Initialization
    
    init(monthView: CVCalendarMonthView, index: Int) {
        
        
        self.monthView = monthView
        self.index = index
        
        if let size = monthView.calendarView.weekViewSize {
            super.init(frame: CGRect(x: 0, y: CGFloat(index) * size.height, width: size.width, height: size.height))
        } else {
            super.init(frame: CGRect.zero)
        }
        
        // Get weekdays in.
        let weeksIn = self.monthView!.weeksIn!
        self.weekdaysIn = weeksIn[self.index!]
        
        // Get weekdays out.
        if let weeksOut = self.monthView!.weeksOut {
            if self.weekdaysIn?.count < 7 {
                if weeksOut.count > 1 {
                    let daysOut = 7 - self.weekdaysIn!.count
                    
                    var result: [Int : [Int]]?
                    for weekdaysOut in weeksOut {
                        if weekdaysOut.count == daysOut {
                            let manager = calendarView.manager
                            
                            
                            let key = weekdaysOut.keys.first!
                            let value = weekdaysOut[key]![0]
                            if value > 20 {
                                if self.index == 0 {
                                    result = weekdaysOut
                                    break
                                }
                            } else if value < 10 {
                                if self.index == (manager?.monthDateRange(self.monthView!.date!).countOfWeeks)! - 1 {
                                    result = weekdaysOut
                                    break
                                }
                            }
                        }
                    }
                    
                    self.weekdaysOut = result!
                } else {
                    self.weekdaysOut = weeksOut[0]
                }
                
            }
        }
        
        self.createDayViews()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func mapDayViews(_ body: (DayView) -> ()) {
        if let dayViews = dayViews {
            for dayView in dayViews {
                body(dayView)
            }
        }
    }
}

// MARK: - Interactive view setup & management

extension CVCalendarWeekView {
    func updateInteractiveView() {
        safeExecuteBlock({
            
            let mode = self.monthView!.calendarView!.calendarMode!
            if mode == .weekView {
                if let interactiveView = self.interactiveView {
                    interactiveView.frame = self.bounds
                    interactiveView.removeFromSuperview()
                    self.addSubview(interactiveView)
                } else {
                    self.interactiveView = UIView(frame: self.bounds)
                    self.interactiveView.backgroundColor = .clear
                    
                    let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(CVCalendarWeekView.didTouchInteractiveView(_:)))
                    let pressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(CVCalendarWeekView.didPressInteractiveView(_:)))
                    pressRecognizer.minimumPressDuration = 0.3
                    
                    self.interactiveView.addGestureRecognizer(pressRecognizer)
                    self.interactiveView.addGestureRecognizer(tapRecognizer)
                    
                    self.addSubview(self.interactiveView)
                }
            }
            
            }, collapsingOnNil: false, withObjects: monthView, monthView?.calendarView)
    }
    
    func didPressInteractiveView(_ recognizer: UILongPressGestureRecognizer) {
        let location = recognizer.location(in: self.interactiveView)
        let state: UIGestureRecognizerState = recognizer.state
        
        switch state {
        case .began:
            touchController.receiveTouchLocation(location, inWeekView: self, withSelectionType: .range(.started))
        case .changed:
            touchController.receiveTouchLocation(location, inWeekView: self, withSelectionType: .range(.changed))
        case .ended:
            touchController.receiveTouchLocation(location, inWeekView: self, withSelectionType: .range(.ended))
            
        default: break
        }
    }
    
    func didTouchInteractiveView(_ recognizer: UITapGestureRecognizer) {
        let location = recognizer.location(in: self.interactiveView)
        touchController.receiveTouchLocation(location, inWeekView: self, withSelectionType: .single)
    }
}

// MARK: - Content fill & reload

extension CVCalendarWeekView {
    func createDayViews() {
        dayViews = [CVCalendarDayView]()
        for i in 1...7 {
            let dayView = CVCalendarDayView(weekView: self, weekdayIndex: i)
            
            safeExecuteBlock({
                self.dayViews!.append(dayView)
                }, collapsingOnNil: true, withObjects: dayViews as AnyObject?)
            
            addSubview(dayView)
        }
    }
    
    func reloadDayViews() {
        
        if let size = calendarView.dayViewSize, let dayViews = dayViews {
            let hSpace = calendarView.appearance.spaceBetweenDayViews!
            
            for (index, dayView) in dayViews.enumerated() {
                let hSpace = calendarView.appearance.spaceBetweenDayViews!
                let x = CGFloat(index) * CGFloat(size.width + hSpace) + hSpace/2
                dayView.frame = CGRect(x: x, y: 0, width: size.width, height: size.height)
                dayView.reloadContent()
            }
        }
    }
}

// MARK: - Safe execution

extension CVCalendarWeekView {
    func safeExecuteBlock(_ block: (Void) -> Void, collapsingOnNil collapsing: Bool, withObjects objects: AnyObject?...) {
        for object in objects {
            if object == nil {
                if collapsing {
                    fatalError("Object { \(object) } must not be nil!")
                } else {
                    return
                }
            }
        }
        
        block()
    }
}
