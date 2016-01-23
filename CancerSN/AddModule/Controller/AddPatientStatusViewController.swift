//
//  AddPatientStatusViewController.swift
//  CancerSN
//
//  Created by hui luo on 22/1/2016.
//  Copyright © 2016 lily. All rights reserved.
//

import UIKit

class AddPatientStatusViewController: UIViewController {
    
    //global variable
    var headerHeight: CGFloat = CGFloat()
    var screenWidth = UIScreen.mainScreen().bounds.width
    
    //date section
    var dateSection = UIView()
    
    override func viewDidLoad() {
        initVariables()
        initContentView()
    }
    
    func initVariables(){
        headerHeight = UIApplication.sharedApplication().statusBarFrame.height + (self.navigationController?.navigationBar.frame.height)!
    }
    
    func initContentView(){
        dateSection = UIView(frame: CGRect(x: 0, y: headerHeight, width: screenWidth, height: patientStatusDateSectionHeight))
        let dateLabel = UILabel(frame: CGRect(x: patientStatusDateLabelLeftSpace, y: 0, width: 39, height: patientStatusDateSectionHeight))
        dateLabel.text = "日期："
        dateLabel.textColor = patientStatusDataLabelColor
        dateLabel.font = patientStatusDateLabelFont
        dateSection.addSubview(dateLabel)
        let dateBtn = UIButton(frame: CGRect(x: patientStatusDateLabelLeftSpace + 39, y: 0, width: screenWidth - patientStatusDateLabelLeftSpace - 39, height: patientStatusDateSectionHeight))
        dateSection.addSubview(dateBtn)
        dateBtn.
        self.view.addSubview(dateSection)
    }
}
