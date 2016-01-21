//
//  AddNewTreatmentEndDateViewController.swift
//  CancerSN
//
//  Created by lily on 8/23/15.
//  Copyright (c) 2015 lily. All rights reserved.
//

import UIKit

class AddNewTreatmentEndDateViewController: CalenderViewController {
//    var animationFinished = true
    let profileSet = NSUserDefaults.standardUserDefaults()
    
//    @IBOutlet weak var menuView: CVCalendarMenuView!
//
//    @IBOutlet weak var calendarView: CVCalendarView!
//    @IBOutlet weak var monthLabel: UIButton!
//    var datePickerContainerView = UIView()
//    var datePicker = UIDatePicker()
//    var dateInserted:NSDate?
    
    @IBOutlet weak var currentmonthLabel: UIButton!
    @IBOutlet weak var currentmenuView: CVCalendarMenuView!
    @IBOutlet weak var currentcalendarView: CVCalendarView!
    
    @IBAction func loadPreviousView(sender: UIButton) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
//    @IBAction func selectDate(sender: UIButton) {
//        let datePickerHeight :CGFloat = 200
//        let confirmButtonWidth:CGFloat = 100
//        let confirmButtonHeight:CGFloat = 30
//        datePickerContainerView = UIView(frame: CGRectMake(0, UIScreen.mainScreen().bounds.height - datePickerHeight - 30 - 80, UIScreen.mainScreen().bounds.width, datePickerHeight + 30))
//        datePickerContainerView.backgroundColor = UIColor.whiteColor()
//        self.datePicker = UIDatePicker(frame: CGRectMake(0 , 30, UIScreen.mainScreen().bounds.width, datePickerHeight))
//        self.datePicker.datePickerMode = UIDatePickerMode.Date
//        let confirmButton = UIButton(frame: CGRectMake(UIScreen.mainScreen().bounds.width - confirmButtonWidth, 0, confirmButtonWidth, confirmButtonHeight))
//        confirmButton.setTitle("确定", forState: UIControlState.Normal)
//        confirmButton.setTitleColor(mainColor, forState: UIControlState.Normal)
//        confirmButton.addTarget(self, action: "dateChanged", forControlEvents: UIControlEvents.TouchUpInside)
//        datePickerContainerView.addSubview(self.datePicker)
//        datePickerContainerView.addSubview(confirmButton)
//        self.view.addSubview(datePickerContainerView)
//    }
//    
//    func dateChanged(){
//        dateInserted = datePicker.date
//        profileSet.setObject(dateInserted?.timeIntervalSince1970, forKey: newTreatmentEnddate)
//        monthLabel.setTitle(CVDate(date: dateInserted!).globalDescription, forState: UIControlState.Normal)
//        self.datePickerContainerView.removeFromSuperview()
//    }
    
    
    @IBAction func loadPrevious(sender: AnyObject) {
        calendarView.loadPreviousView()
    }
    
    
    @IBAction func loadNext(sender: AnyObject) {
        calendarView.loadNextView()
    }
    
    override func viewDidLoad() {
        super.calendarView = self.currentcalendarView
        super.menuView = self.currentmenuView
        super.monthLabel = self.currentmonthLabel
        super.viewDidLoad()
        profileSet.removeObjectForKey(newTreatmentEnddate)

//        self.calendarView.calendarAppearanceDelegate = self
//        
//        // Animator delegate [Unnecessary]
//        self.calendarView.animatorDelegate = self
//        
//        // Calendar delegate [Required]
//        self.calendarView.calendarDelegate = self
//        
//        // Menu delegate [Required]
//        self.menuView.menuViewDelegate = self
//        monthLabel.text = CVDate(date: NSDate()).globalDescription
        monthLabel.setTitle(CVDate(date: NSDate()).globalDescription, forState: UIControlState.Normal)

    }

//    @IBAction func unselectNewTreatmentEndDate(sender: UIButton) {
//        profileSet.setObject(defaultTreatmentEndDate, forKey: newTreatmentEnddate)
//        self.performSegueWithIdentifier("treatmentDetailSegue", sender: self)
//
//    }
    
    @IBAction func submitTreatmentEndDate(sender: UIButton) {
        if profileSet.objectForKey(newTreatmentEnddate) == nil{
            profileSet.setObject(NSDate().timeIntervalSince1970, forKey: newTreatmentEnddate)
        }
        self.performSegueWithIdentifier("treatmentDetailSegue", sender: self)
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
    
    override func didSelectDayView(dayView: CVCalendarDayView) {
        let date = dayView.date
        super.didSelectDayView(dayView)
        profileSet.setObject(calendarView.presentedDate.convertedDate()?.timeIntervalSince1970, forKey: newTreatmentBegindate)
    }
}


