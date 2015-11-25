//
//  AddNewTreatmentEndDateViewController.swift
//  CancerSN
//
//  Created by lily on 8/23/15.
//  Copyright (c) 2015 lily. All rights reserved.
//

import UIKit

class AddNewTreatmentEndDateViewController: UIViewController {
    var animationFinished = true
    let profileSet = NSUserDefaults.standardUserDefaults()
    
    @IBOutlet weak var menuView: CVCalendarMenuView!

    @IBOutlet weak var calendarView: CVCalendarView!
    @IBOutlet weak var monthLabel: UIButton!
    var datePickerContainerView = UIView()
    var datePicker = UIDatePicker()
    var dateInserted:NSDate?
    
    @IBAction func selectDate(sender: UIButton) {
        let datePickerHeight:CGFloat = 200
        let confirmButtonWidth:CGFloat = 100
        let confirmButtonHeight:CGFloat = 30
        datePickerContainerView = UIView(frame: CGRectMake(0, UIScreen.mainScreen().bounds.height - datePickerHeight - 30 - 80, UIScreen.mainScreen().bounds.width, datePickerHeight + 30))
        datePickerContainerView.backgroundColor = UIColor.whiteColor()
        self.datePicker = UIDatePicker(frame: CGRectMake(0 , 30, UIScreen.mainScreen().bounds.width, datePickerHeight))
        self.datePicker.datePickerMode = UIDatePickerMode.Date
        let confirmButton = UIButton(frame: CGRectMake(UIScreen.mainScreen().bounds.width - confirmButtonWidth, 0, confirmButtonWidth, confirmButtonHeight))
        confirmButton.setTitle("确定", forState: UIControlState.Normal)
        confirmButton.setTitleColor(mainColor, forState: UIControlState.Normal)
        confirmButton.addTarget(self, action: "dateChanged", forControlEvents: UIControlEvents.TouchUpInside)
        datePickerContainerView.addSubview(self.datePicker)
        datePickerContainerView.addSubview(confirmButton)
        self.view.addSubview(datePickerContainerView)
    }
    
    func dateChanged(){
        dateInserted = datePicker.date
        profileSet.setObject(dateInserted?.timeIntervalSince1970, forKey: newTreatmentEnddate)
        monthLabel.setTitle(CVDate(date: dateInserted!).globalDescription, forState: UIControlState.Normal)
        self.datePickerContainerView.removeFromSuperview()
    }
    
    
    @IBAction func loadPrevious(sender: AnyObject) {
        calendarView.loadPreviousView()
    }
    
    
    @IBAction func loadNext(sender: AnyObject) {
        calendarView.loadNextView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        profileSet.removeObjectForKey(newTreatmentEnddate)

        self.calendarView.calendarAppearanceDelegate = self
        
        // Animator delegate [Unnecessary]
        self.calendarView.animatorDelegate = self
        
        // Calendar delegate [Required]
        self.calendarView.calendarDelegate = self
        
        // Menu delegate [Required]
        self.menuView.menuViewDelegate = self
//        monthLabel.text = CVDate(date: NSDate()).globalDescription
        monthLabel.setTitle(CVDate(date: NSDate()).globalDescription, forState: UIControlState.Normal)

    }

    @IBAction func unselectNewTreatmentEndDate(sender: UIButton) {
//        let tenYrIntervalSec:Int = 60*60*24*365*10
//        let tenYrTimeInterval = NSTimeInterval(tenYrIntervalSec)
//        var date = NSDate(timeIntervalSinceNow: tenYrTimeInterval)
//        println(date)
//        profileSet.setObject(date.timeIntervalSince1970, forKey: newTreatmentEnddate)
        profileSet.setObject(defaultTreatmentEndDate, forKey: newTreatmentEnddate)

    }
    
    @IBAction func newTreatmentEndDate(sender: UIButton) {
        if profileSet.objectForKey(newTreatmentEnddate) == nil{
            profileSet.setObject(NSDate().timeIntervalSince1970, forKey: newTreatmentEnddate)
        }
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

extension AddNewTreatmentEndDateViewController: CVCalendarViewDelegate
{
    func presentationMode() -> CalendarMode {
        return .MonthView
    }
    
    func shouldShowWeekdaysOut() -> Bool {
        return true
    }
    
    func firstWeekday() -> Weekday {
        return .Sunday
    }
    
    
    func didSelectDayView(dayView: CVCalendarDayView) {
        let date = dayView.date
        print("\(calendarView.presentedDate.commonDescription) is selected!")
        profileSet.setObject(calendarView.presentedDate.convertedDate()?.timeIntervalSince1970, forKey: newTreatmentEnddate)
    }
    
    
    func topMarker(shouldDisplayOnDayView dayView: CVCalendarDayView) -> Bool {
        return true
    }
    func presentedDateUpdated(date: CVDate) {
        if monthLabel.titleLabel!.text != date.globalDescription && self.animationFinished {
            let updatedMonthLabel = UILabel()
            updatedMonthLabel.textColor = monthLabel.titleLabel!.textColor
            updatedMonthLabel.font = monthLabel.titleLabel!.font
            updatedMonthLabel.textAlignment = .Center
            updatedMonthLabel.text = date.globalDescription
            updatedMonthLabel.sizeToFit()
            updatedMonthLabel.alpha = 0
            updatedMonthLabel.center = self.monthLabel.center
            
            let offset = CGFloat(48)
            updatedMonthLabel.transform = CGAffineTransformMakeTranslation(0, offset)
            updatedMonthLabel.transform = CGAffineTransformMakeScale(1, 0.1)
            
            UIView.animateWithDuration(0.35, delay: 0, options: UIViewAnimationOptions.CurveEaseIn, animations: {
                self.animationFinished = false
                self.monthLabel.transform = CGAffineTransformMakeTranslation(0, -offset)
                self.monthLabel.transform = CGAffineTransformMakeScale(1, 0.1)
                self.monthLabel.alpha = 0
                
                updatedMonthLabel.alpha = 1
                updatedMonthLabel.transform = CGAffineTransformIdentity
                
                }) { _ in
                    
                    self.animationFinished = true
                    self.monthLabel.frame = updatedMonthLabel.frame
//                    self.monthLabel.text = updatedMonthLabel.text
                    self.monthLabel.setTitle(updatedMonthLabel.text, forState: UIControlState.Normal)
                    self.monthLabel.transform = CGAffineTransformIdentity
                    self.monthLabel.alpha = 1
                    updatedMonthLabel.removeFromSuperview()
            }
            
            self.view.insertSubview(updatedMonthLabel, aboveSubview: self.monthLabel)
        }
    }
    
    func preliminaryView(viewOnDayView dayView: DayView) -> UIView
    {
        let circleView = CVAuxiliaryView(dayView: dayView, rect: dayView.bounds, shape: CVShape.Circle)
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

extension AddNewTreatmentEndDateViewController: CVCalendarViewAppearanceDelegate {
    func dayLabelPresentWeekdayInitallyBold() -> Bool {
        return false
    }
    
    func spaceBetweenDayViews() -> CGFloat {
        return 2
    }
}

// MARK: - CVCalendarMenuViewDelegate

extension AddNewTreatmentEndDateViewController: CVCalendarMenuViewDelegate {
    // firstWeekday() has been already implemented.
}

// MARK: - IB Actions

extension AddNewTreatmentEndDateViewController {
    
    @IBAction func todayMonthView() {
        calendarView.toggleCurrentDayView()
    }
    
    /// Switch to WeekView mode.
    @IBAction func toWeekView(sender: AnyObject) {
        calendarView.changeMode(.WeekView)
    }
    
    /// Switch to MonthView mode.
    @IBAction func toMonthView(sender: AnyObject) {
        calendarView.changeMode(.MonthView)
    }
    
}

// MARK: - Convenience API Demo

extension AddNewTreatmentEndDateViewController {
    func toggleMonthViewWithMonthOffset(offset: Int) {
        let calendar = NSCalendar.currentCalendar()
        let calendarManager = calendarView.manager
        let components = Manager.componentsForDate(NSDate()) // from today
        
        components.month += offset
        
        let resultDate = calendar.dateFromComponents(components)!
        
        self.calendarView.toggleViewWithDate(resultDate)
    }
}

