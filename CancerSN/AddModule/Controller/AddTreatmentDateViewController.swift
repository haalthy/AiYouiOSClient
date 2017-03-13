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
    let profileSet = UserDefaults.standard
    var datePickerContainerView = UIView()
    var datePicker = UIDatePicker()
    var dateInserted:Foundation.Date?
    
    @IBOutlet weak var currentmonthLabel: UIButton!
    @IBOutlet weak var currentmenuView: CVCalendarMenuView!
    @IBOutlet weak var currentcalendarView: CVCalendarView!
    
    override func viewDidLoad() {
        let getAccessToken = GetAccessToken()
        getAccessToken.getAccessToken()
        
        let accessToken = UserDefaults.standard.object(forKey: accessNSUserData)
        
        if accessToken != nil {
            super.calendarView = self.currentcalendarView
            super.menuView = self.currentmenuView
            super.monthLabel = self.currentmonthLabel
            super.viewDidLoad()
            
            username = keychainAccess.getPasscode(usernameKeyChain) as? String
            profileSet.removeObject(forKey: newTreatmentBegindate)
        }else{
            let alertController = UIAlertController(title: "需要登录才能添加信息", message: nil, preferredStyle: .alert)
            
            let cancelAction = UIAlertAction(title: "取消", style: .default) { (action) in
                self.dismiss(animated: true, completion: nil)
            }
            
            alertController.addAction(cancelAction)
            let loginAction = UIAlertAction(title: "登陆", style: .cancel) { (action) in
                let storyboard = UIStoryboard(name: "Registeration", bundle: nil)
                let controller = storyboard.instantiateViewController(withIdentifier: "LoginEntry") as UIViewController
                self.present(controller, animated: true, completion: nil)
            }
            alertController.addAction(loginAction)
            
            
            self.present(alertController, animated: true) {
                // ...
            }
        }
    }
    
    func dateChanged(){
        dateInserted = datePicker.date
        profileSet.set(dateInserted?.timeIntervalSince1970, forKey: newTreatmentBegindate)
        monthLabel.setTitle(CVDate(date: dateInserted!).globalDescription, for: UIControlState())
        self.datePickerContainerView.removeFromSuperview()
    }
    
    @IBAction func loadPrevious(_ sender: AnyObject) {
        calendarView.loadPreviousView()
    }
    
    
    @IBAction func loadNext(_ sender: AnyObject) {
        calendarView.loadNextView()
    }
    
    @IBAction func cancelNewTreatment(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func submitNewTreatmentBeginDate(_ sender: UIButton) {
        if profileSet.object(forKey: newTreatmentBegindate) == nil{
            profileSet.set(Foundation.Date().timeIntervalSince1970, forKey: newTreatmentBegindate)
        }
        self.performSegue(withIdentifier: "selectEndDateSegue", sender: self)
    }
    
    override func didSelectDayView(_ dayView: CVCalendarDayView) {
        super.didSelectDayView(dayView)
        profileSet.set(calendarView.presentedDate.convertedDate()?.timeIntervalSince1970, forKey: newTreatmentBegindate)
    }
}
