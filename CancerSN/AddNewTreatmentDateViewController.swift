//
//  AddNewTreatmentDateViewController.swift
//  CancerSN
//
//  Created by lily on 8/20/15.
//  Copyright (c) 2015 lily. All rights reserved.
//

import UIKit
import CoreData

class AddNewTreatmentDateViewController: UIViewController, UIPopoverPresentationControllerDelegate {

    var haalthyService = HaalthyService()
    var keychainAccess = KeychainAccess()
    var username:String?
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var menuView: CVCalendarMenuView!
    @IBOutlet weak var calendarView: CVCalendarView!
    let profileSet = NSUserDefaults.standardUserDefaults()

    
    @IBAction func cancelNewTreatment(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    var treatmentList = NSArray()
    var previousTreatment = NSDictionary()
    
    func getProcessingTreatmentsFromLocalDB(){
        var appDel:AppDelegate = (UIApplication.sharedApplication().delegate as! AppDelegate)
        var context:NSManagedObjectContext = appDel.managedObjectContext!
        var request = NSFetchRequest(entityName: "Treatment")
        let resultPredicate = NSPredicate(format: "endDate = nil")
        request.predicate = resultPredicate
        request.returnsObjectsAsFaults = false
        request.sortDescriptors = [NSSortDescriptor(key: "beginDate", ascending: false)]
        treatmentList = context.executeFetchRequest(request, error: nil)!
    }
    
    @IBAction func submitNewTreatmentBeginDate(sender: UIButton) {
        if profileSet.objectForKey(newTreatmentBegindate) == nil{
            profileSet.setObject(NSDate().timeIntervalSince1970, forKey: newTreatmentBegindate)
        }
    }
    
    func getProcessingTreatments(){
        var getTreatmentListData = haalthyService.getTreatments(username!)
        var jsonResult = NSJSONSerialization.JSONObjectWithData(getTreatmentListData, options: NSJSONReadingOptions.MutableContainers, error: nil)
        if(jsonResult is NSArray){
            self.treatmentList = jsonResult as! NSArray
        }
    }
    
    var animationFinished = true
    override func viewDidLoad() {
        super.viewDidLoad()
        
        username = keychainAccess.getPasscode(usernameKeyChain) as! String
        profileSet.removeObjectForKey(newTreatmentBegindate)
        
        // Do any additional setup after loading the view.
        self.calendarView.calendarAppearanceDelegate = self
        
        // Animator delegate [Unnecessary]
        self.calendarView.animatorDelegate = self
        
        // Calendar delegate [Required]
        self.calendarView.calendarDelegate = self
        
        // Menu delegate [Required]
        self.menuView.menuViewDelegate = self
        monthLabel.text = CVDate(date: NSDate()).globalDescription
        
        //        getProcessingTreatmentsFromLocalDB()
        getProcessingTreatments()
        if treatmentList.count > 0 {
            previousTreatment = treatmentList[0] as! NSDictionary
            println(previousTreatment.objectForKey("endDate"))
            println(NSDate().timeIntervalSince1970)
            if (previousTreatment.objectForKey("endDate") as! Double) > ((NSDate().timeIntervalSince1970) as! Double){
                self.performSegueWithIdentifier("showPreviousTreatment", sender: self)
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showPreviousTreatment"{
            var vc = segue.destinationViewController as! UpdatePreviousTreatmentViewController
            var controller = vc.popoverPresentationController
            if controller != nil{
                controller?.delegate = self
                controller?.permittedArrowDirections = nil
            }
            vc.treatment = previousTreatment
        }
    }
    
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return .None
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

extension AddNewTreatmentDateViewController: CVCalendarViewDelegate
{
    func presentedDateUpdated(date: CVDate) {
        if monthLabel.text != date.globalDescription && self.animationFinished {
            let updatedMonthLabel = UILabel()
            updatedMonthLabel.textColor = monthLabel.textColor
            updatedMonthLabel.font = monthLabel.font
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
                    self.monthLabel.text = updatedMonthLabel.text
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


extension AddNewTreatmentDateViewController: CVCalendarViewDelegate {
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
        println("\(calendarView.presentedDate.commonDescription) is selected!")
        profileSet.setObject(calendarView.presentedDate.convertedDate()?.timeIntervalSince1970, forKey: newTreatmentBegindate)
    }
    
    
    func topMarker(shouldDisplayOnDayView dayView: CVCalendarDayView) -> Bool {
        return true
    }
    
}

// MARK: - CVCalendarViewAppearanceDelegate

extension AddNewTreatmentDateViewController: CVCalendarViewAppearanceDelegate {
    func dayLabelPresentWeekdayInitallyBold() -> Bool {
        return false
    }
    
    func spaceBetweenDayViews() -> CGFloat {
        return 2
    }
}

// MARK: - CVCalendarMenuViewDelegate

extension AddNewTreatmentDateViewController: CVCalendarMenuViewDelegate {
    // firstWeekday() has been already implemented.
}

// MARK: - IB Actions

extension AddNewTreatmentDateViewController {
    
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

extension AddNewTreatmentDateViewController {
    func toggleMonthViewWithMonthOffset(offset: Int) {
        let calendar = NSCalendar.currentCalendar()
        let calendarManager = calendarView.manager
        let components = Manager.componentsForDate(NSDate()) // from today
        
        components.month += offset
        
        let resultDate = calendar.dateFromComponents(components)!
        
        self.calendarView.toggleViewWithDate(resultDate)
    }
}

