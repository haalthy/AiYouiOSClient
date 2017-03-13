//
//  CalenderViewController.swift
//  CancerSN
//
//  Created by hui luo on 18/1/2016.
//  Copyright © 2016 lily. All rights reserved.
//

import UIKit

class CalenderViewController: UIViewController {
    

    var monthLabel: UIButton!
    var menuView: CVCalendarMenuView!
    var calendarView: CVCalendarView!
    
    var animationFinished = true
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.calendarView.calendarAppearanceDelegate = self
        
        // Animator delegate [Unnecessary]
        self.calendarView.animatorDelegate = self
        
        // Calendar delegate [Required]
        self.calendarView.calendarDelegate = self
        
        // Menu delegate [Required]
        self.menuView.menuViewDelegate = self

        monthLabel.setTitle(CVDate(date: Foundation.Date()).globalDescription, for: UIControlState())

    }
    
    func adaptivePresentationStyleForPresentationController(_ controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        calendarView.commitCalendarViewUpdate()
        menuView.commitMenuViewUpdate()
    }
}

extension CalenderViewController: CVCalendarViewDelegate
{
    func presentedDateUpdated(_ date: CVDate) {
        if monthLabel.titleLabel!.text != date.globalDescription && self.animationFinished {
            let updatedMonthLabel = UILabel()
            updatedMonthLabel.textColor = monthLabel.titleLabel!.textColor
            updatedMonthLabel.font = monthLabel.titleLabel!.font
            updatedMonthLabel.textAlignment = .center
            updatedMonthLabel.text = date.globalDescription
            updatedMonthLabel.sizeToFit()
            updatedMonthLabel.alpha = 0
            updatedMonthLabel.center = self.monthLabel.center
            
            let offset = CGFloat(48)
            updatedMonthLabel.transform = CGAffineTransform(translationX: 0, y: offset)
            updatedMonthLabel.transform = CGAffineTransform(scaleX: 1, y: 0.1)
            
            UIView.animate(withDuration: 0.35, delay: 0, options: UIViewAnimationOptions.curveEaseIn, animations: {
                self.animationFinished = false
                self.monthLabel.transform = CGAffineTransform(translationX: 0, y: -offset)
                self.monthLabel.transform = CGAffineTransform(scaleX: 1, y: 0.1)
                self.monthLabel.alpha = 0
                
                updatedMonthLabel.alpha = 1
                updatedMonthLabel.transform = CGAffineTransform.identity
                
                }) { _ in
                    
                    self.animationFinished = true
                    self.monthLabel.frame = updatedMonthLabel.frame
                    self.monthLabel.setTitle(updatedMonthLabel.text, for: UIControlState())
                    self.monthLabel.transform = CGAffineTransform.identity
                    self.monthLabel.alpha = 1
                    updatedMonthLabel.removeFromSuperview()
            }
            
            self.view.insertSubview(updatedMonthLabel, aboveSubview: self.monthLabel)
        }
    }
    
    func preliminaryView(viewOnDayView dayView: DayView) -> UIView
    {
        let circleView = CVAuxiliaryView(dayView: dayView, rect: dayView.bounds, shape: CVShape.circle)
        circleView.fillColor = .colorFromCode(0xCCCCCC)
        return circleView
    }
    
    func preliminaryView(shouldDisplayOnDayView dayView: DayView) -> Bool
    {
        if (dayView.isCurrentDay) {
            return true
        }
        return false
    }
    
    
    func supplementaryView(shouldDisplayOnDayView dayView: DayView) -> Bool
    {
        if (Int(arc4random_uniform(3)) == 1)
        {
            return true
        }
        return false
    }
}

// MARK: - CVCalendarViewAppearanceDelegate

extension CalenderViewController: CVCalendarViewAppearanceDelegate {
    func presentationMode() -> CalendarMode {
        return .monthView
    }
    
    func shouldShowWeekdaysOut() -> Bool {
        return true
    }
    
    func firstWeekday() -> Weekday {
        return .sunday
    }
    
    
    func didSelectDayView(_ dayView: CVCalendarDayView) {
        let date = dayView.date
    }
    
    
    func topMarker(shouldDisplayOnDayView dayView: CVCalendarDayView) -> Bool {
        return true
    }
    
    func dayLabelPresentWeekdayInitallyBold() -> Bool {
        return false
    }
    
    func spaceBetweenDayViews() -> CGFloat {
        return 2
    }
}

// MARK: - CVCalendarMenuViewDelegate

extension CalenderViewController: CVCalendarMenuViewDelegate {
    // firstWeekday() has been already implemented.
}

extension CalenderViewController {
    func toggleMonthViewWithMonthOffset(_ offset: Int) {
        let calendar = Calendar.current
        let calendarManager = calendarView.manager
        var components = Manager.componentsForDate(Foundation.Date()) // from today
        
        components.month = components.month! + offset
        
        let resultDate = calendar.date(from: components)!
        
        self.calendarView.toggleViewWithDate(resultDate)
    }
}

