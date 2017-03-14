//
//  CVCalendarMonthView.swift
//  CVCalendar
//
//  Created by E. Mozharovsky on 12/26/14.
//  Copyright (c) 2014 GameApp. All rights reserved.
//

import UIKit

class CVCalendarMonthView: UIView {
    // MARK: - Non public properties
    fileprivate var interactiveView: UIView!
    
    override var frame: CGRect {
        didSet {
            if let calendarView = calendarView {
                if calendarView.calendarMode == CalendarMode.monthView {
                    updateInteractiveView()
                }
            }
        }
    }
    
    fileprivate var touchController: CVCalendarTouchController {
        return calendarView.touchController
    }
    
    // MARK: - Public properties
    
    weak var calendarView: CVCalendarView!
    var date: Foundation.Date!
    var numberOfWeeks: Int!
    var weekViews: [CVCalendarWeekView]!
    
    var weeksIn: [[Int : [Int]]]?
    var weeksOut: [[Int : [Int]]]?
    var currentDay: Int?
    
    var potentialSize: CGSize {
        get {
            return CGSize(width: bounds.width, height: CGFloat(weekViews.count) * weekViews[0].bounds.height + calendarView.appearance.spaceBetweenWeekViews! * CGFloat(weekViews.count))
        }
    }
    
    // MARK: - Initialization
    
    init(calendarView: CVCalendarView, date: Foundation.Date) {
        super.init(frame: CGRect.zero)
        self.calendarView = calendarView
        self.date = date
        commonInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func mapDayViews(_ body: (DayView) -> Void) {
        for weekView in self.weekViews {
            for dayView in weekView.dayViews {
                body(dayView)
            }
        }
    }
}

// MARK: - Creation and destruction

extension CVCalendarMonthView {
    func commonInit() {
        let calendarManager = calendarView.manager
        safeExecuteBlock({
            self.numberOfWeeks = calendarManager?.monthDateRange(self.date).countOfWeeks
            self.weeksIn = calendarManager?.weeksWithWeekdaysForMonthDate(self.date).weeksIn
            self.weeksOut = calendarManager?.weeksWithWeekdaysForMonthDate(self.date).weeksOut
            self.currentDay = Manager.dateRange(Foundation.Date()).day
            }, collapsingOnNil: true, withObjects: date as AnyObject?)
    }
}

// MARK: Content reload

extension CVCalendarMonthView {
    func reloadViewsWithRect(_ frame: CGRect) {
        self.frame = frame
        
        safeExecuteBlock({
            for (index, weekView) in self.weekViews.enumerated() {
                if let size = self.calendarView.weekViewSize {
                    weekView.frame = CGRect(x: 0, y: size.height * CGFloat(index), width: size.width, height: size.height)
                    weekView.reloadDayViews()
                }
            }
        }, collapsingOnNil: true, withObjects: weekViews as AnyObject?)
    }
}

// MARK: - Content fill & update

extension CVCalendarMonthView {
    func updateAppearance(_ frame: CGRect) {
        self.frame = frame
        createWeekViews()
    }
    
    func createWeekViews() {
        weekViews = [CVCalendarWeekView]()
        
        safeExecuteBlock({
            for i in 0..<self.numberOfWeeks! {
                let weekView = CVCalendarWeekView(monthView: self, index: i)
                
                self.safeExecuteBlock({
                    self.weekViews!.append(weekView)
                    }, collapsingOnNil: true, withObjects: self.weekViews as AnyObject?)
                
                self.addSubview(weekView)
            }
            }, collapsingOnNil: true, withObjects: numberOfWeeks as AnyObject?)
    }
}

// MARK: - Interactive view management & update

extension CVCalendarMonthView {
    func updateInteractiveView() {
        safeExecuteBlock({
            let mode = self.calendarView!.calendarMode!
            if mode == .monthView {
                if let interactiveView = self.interactiveView {
                    interactiveView.frame = self.bounds
                    interactiveView.removeFromSuperview()
                    self.addSubview(interactiveView)
                } else {
                    self.interactiveView = UIView(frame: self.bounds)
                    self.interactiveView.backgroundColor = .clear
                    
                    let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(CVCalendarMonthView.didTouchInteractiveView(_:)))
                    let pressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(CVCalendarMonthView.didPressInteractiveView(_:)))
                    pressRecognizer.minimumPressDuration = 0.3
                    
                    self.interactiveView.addGestureRecognizer(pressRecognizer)
                    self.interactiveView.addGestureRecognizer(tapRecognizer)
                    
                    self.addSubview(self.interactiveView)
                }
            }
            
            }, collapsingOnNil: false, withObjects: calendarView)
    }
    
    func didPressInteractiveView(_ recognizer: UILongPressGestureRecognizer) {
        let location = recognizer.location(in: self.interactiveView)
        let state: UIGestureRecognizerState = recognizer.state
        
        switch state {
        case .began:
            touchController.receiveTouchLocation(location, inMonthView: self, withSelectionType: .range(.started))
        case .changed:
            touchController.receiveTouchLocation(location, inMonthView: self, withSelectionType: .range(.changed))
        case .ended:
            touchController.receiveTouchLocation(location, inMonthView: self, withSelectionType: .range(.ended))
            
        default: break
        }
    }
    
    func didTouchInteractiveView(_ recognizer: UITapGestureRecognizer) {
        let location = recognizer.location(in: self.interactiveView)
        touchController.receiveTouchLocation(location, inMonthView: self, withSelectionType: .single)
    }
}

// MARK: - Safe execution

extension CVCalendarMonthView {
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
