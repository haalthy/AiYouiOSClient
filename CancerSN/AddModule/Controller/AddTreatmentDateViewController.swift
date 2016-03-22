//
//  AddTreatmentDateViewController.swift
//  CancerSN
//
//  Created by hui luo on 18/1/2016.
//  Copyright © 2016 lily. All rights reserved.
//

import UIKit

class AddTreatmentDateViewController: CalenderViewController {
    
//    var haalthyService = HaalthyService()
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
        let getAccessToken = GetAccessToken()
        getAccessToken.getAccessToken()
        
        let accessToken = NSUserDefaults.standardUserDefaults().objectForKey(accessNSUserData)
        
        if accessToken != nil {
            super.calendarView = self.currentcalendarView
            super.menuView = self.currentmenuView
            super.monthLabel = self.currentmonthLabel
            super.viewDidLoad()
            
            username = keychainAccess.getPasscode(usernameKeyChain) as? String
            profileSet.removeObjectForKey(newTreatmentBegindate)
        }else{
            let alertController = UIAlertController(title: "需要登录才能添加信息", message: nil, preferredStyle: .Alert)
            
            let cancelAction = UIAlertAction(title: "取消", style: .Default) { (action) in
                self.dismissViewControllerAnimated(true, completion: nil)
            }
            
            alertController.addAction(cancelAction)
            let loginAction = UIAlertAction(title: "登陆", style: .Cancel) { (action) in
                let storyboard = UIStoryboard(name: "Registeration", bundle: nil)
                let controller = storyboard.instantiateViewControllerWithIdentifier("LoginEntry") as UIViewController
                self.presentViewController(controller, animated: true, completion: nil)
            }
            alertController.addAction(loginAction)
            
            
            self.presentViewController(alertController, animated: true) {
                // ...
            }
        }
    }
    
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
