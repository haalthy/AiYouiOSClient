//
//  AddTreatmentDateViewController.swift
//  CancerSN
//
//  Created by hui luo on 18/1/2016.
//  Copyright © 2016 lily. All rights reserved.
//

import UIKit

class AddTreatmentDateViewController: CalenderViewController {
    
    var haalthyService = HaalthyService()
    var keychainAccess = KeychainAccess()
    var username:String?
    let profileSet = NSUserDefaults.standardUserDefaults()
    var datePickerContainerView = UIView()
    var datePicker = UIDatePicker()
    var dateInserted:NSDate?
    
    @IBOutlet weak var currentmonthLabel: UIButton!
    @IBOutlet weak var currentmenuView: CVCalendarMenuView!
    @IBOutlet weak var currentcalendarView: CVCalendarView!
    
    override func viewDidLoad() {
        super.calendarView = self.currentcalendarView
        super.menuView = self.currentmenuView
        super.monthLabel = self.currentmonthLabel
        super.viewDidLoad()

        username = keychainAccess.getPasscode(usernameKeyChain) as! String
        profileSet.removeObjectForKey(newTreatmentBegindate)
    }
    
//    @IBAction func selectDate(sender: UIButton) {
//        let datePickerHeight:CGFloat = 200
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
    
    func dateChanged(){
        dateInserted = datePicker.date
        profileSet.setObject(dateInserted?.timeIntervalSince1970, forKey: newTreatmentBegindate)
        monthLabel.setTitle(CVDate(date: dateInserted!).globalDescription, forState: UIControlState.Normal)
        self.datePickerContainerView.removeFromSuperview()
    }
    
    @IBAction func loadPrevious(sender: AnyObject) {
        calendarView.loadPreviousView()
    }
    
    
    @IBAction func loadNext(sender: AnyObject) {
        calendarView.loadNextView()
    }
    
    @IBAction func cancelNewTreatment(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func submitNewTreatmentBeginDate(sender: UIButton) {
        if profileSet.objectForKey(newTreatmentBegindate) == nil{
            profileSet.setObject(NSDate().timeIntervalSince1970, forKey: newTreatmentBegindate)
        }
        self.performSegueWithIdentifier("selectEndDateSegue", sender: self)
    }
    
    override func didSelectDayView(dayView: CVCalendarDayView) {
        super.didSelectDayView(dayView)
        profileSet.setObject(calendarView.presentedDate.convertedDate()?.timeIntervalSince1970, forKey: newTreatmentBegindate)
    }
}
