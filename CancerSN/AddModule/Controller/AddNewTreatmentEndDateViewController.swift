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
    let profileSet = UserDefaults.standard
    
    @IBOutlet weak var currentmonthLabel: UIButton!
    @IBOutlet weak var currentmenuView: CVCalendarMenuView!
    @IBOutlet weak var currentcalendarView: CVCalendarView!
    
    @IBAction func loadPreviousView(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func loadPrevious(_ sender: AnyObject) {
        calendarView.loadPreviousView()
    }
    
    
    @IBAction func loadNext(_ sender: AnyObject) {
        calendarView.loadNextView()
    }
    
    override func viewDidLoad() {
        super.calendarView = self.currentcalendarView
        super.menuView = self.currentmenuView
        super.monthLabel = self.currentmonthLabel
        super.viewDidLoad()
        profileSet.removeObject(forKey: newTreatmentEnddate)
        monthLabel.setTitle(CVDate(date: Foundation.Date()).globalDescription, for: UIControlState())
    }
    
    @IBAction func submitTreatmentEndDate(_ sender: UIButton) {
        if profileSet.object(forKey: newTreatmentEnddate) == nil{
            profileSet.set(Foundation.Date().timeIntervalSince1970, forKey: newTreatmentEnddate)
        }
        if (profileSet.object(forKey: newTreatmentEnddate) as! Int) <= ((profileSet.object(forKey: newTreatmentBegindate) as! Int) + 60) {
            let alertController = UIAlertController(title: "结束时间必须大于开始时间", message: nil, preferredStyle: .alert)
            let ContinueAction = UIAlertAction(title: "返回", style: .default){ (action)in
            }
            alertController.addAction(ContinueAction)
//            
            self.present(alertController, animated: true) {
                // ...
            }

        }else{
            self.performSegue(withIdentifier: "treatmentDetailSegue", sender: self)
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
    
    override func didSelectDayView(_ dayView: CVCalendarDayView) {
        let date = dayView.date
        super.didSelectDayView(dayView)
        profileSet.set(calendarView.presentedDate.convertedDate()?.timeIntervalSince1970, forKey: newTreatmentEnddate)
    }
}


