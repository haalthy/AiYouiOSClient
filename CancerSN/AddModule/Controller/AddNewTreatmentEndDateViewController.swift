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
    
    @IBOutlet weak var currentmonthLabel: UIButton!
    @IBOutlet weak var currentmenuView: CVCalendarMenuView!
    @IBOutlet weak var currentcalendarView: CVCalendarView!
    
    @IBAction func loadPreviousView(sender: UIButton) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
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
        monthLabel.setTitle(CVDate(date: NSDate()).globalDescription, forState: UIControlState.Normal)

    }
    
    @IBAction func submitTreatmentEndDate(sender: UIButton) {
        if profileSet.objectForKey(newTreatmentEnddate) == nil{
            profileSet.setObject(NSDate().timeIntervalSince1970, forKey: newTreatmentEnddate)
        }
        print(profileSet.objectForKey(newTreatmentEnddate) as! Int)
        print(profileSet.objectForKey(newTreatmentBegindate) as! Int)
        if (profileSet.objectForKey(newTreatmentEnddate) as! Int) <= ((profileSet.objectForKey(newTreatmentBegindate) as! Int) + 60) {
            let alertController = UIAlertController(title: "结束时间必须大于开始时间", message: nil, preferredStyle: .Alert)
            let ContinueAction = UIAlertAction(title: "返回", style: .Default){ (action)in
            }
            alertController.addAction(ContinueAction)
//            
            self.presentViewController(alertController, animated: true) {
                // ...
            }

        }else{
            self.performSegueWithIdentifier("treatmentDetailSegue", sender: self)
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
    
    override func didSelectDayView(dayView: CVCalendarDayView) {
        let date = dayView.date
        super.didSelectDayView(dayView)
        profileSet.setObject(calendarView.presentedDate.convertedDate()?.timeIntervalSince1970, forKey: newTreatmentEnddate)
    }
}


