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
    var haalthyService = HaalthyService()
    var patientStatusFormatList = NSArray()
    
    //date section
    var dateSection = UIView()
    var symptomsSection = UIView()
    var symptomDesp = UITextView()
    var dateInserted: NSDate?
    
    override func viewDidLoad() {
        initVariables()
        initContentView()
    }
    
    func initVariables(){
        headerHeight = UIApplication.sharedApplication().statusBarFrame.height + (self.navigationController?.navigationBar.frame.height)!
        dateInserted = NSDate()
        getPatientStatusFormat()
    }
    
    func initContentView(){
        dateSection = UIView(frame: CGRect(x: 0, y: headerHeight, width: screenWidth, height: patientStatusDateSectionHeight))
        let dateLabel = UILabel(frame: CGRect(x: patientStatusDateLabelLeftSpace, y: 0, width: 39, height: patientStatusDateSectionHeight))
        dateLabel.text = "日期："
        dateLabel.textColor = patientStatusDataLabelColor
        dateLabel.font = patientStatusDateLabelFont
        dateSection.addSubview(dateLabel)
        
        // add date button
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "YYYY/MM/dd" // superset of OP's format
        let dateStr = dateFormatter.stringFromDate(dateInserted!)
        let dateBtnTextSize = dateStr.sizeWithFont(patientStatusDateBtnFont, maxSize: CGSize(width: screenWidth, height: CGFloat.max))
        let dateBtn = UIButton(frame: CGRect(x: patientStatusDateLabelLeftSpace + 39, y: 0, width: dateBtnTextSize.width + patientStatusDropdownLeftSpace + patientStatusDropdownW, height: patientStatusDateSectionHeight))
        dateBtn.setTitle(dateStr, forState: UIControlState.Normal)
        dateBtn.setTitleColor(headerColor, forState: UIControlState.Normal)
        dateBtn.titleLabel?.font = patientStatusDateBtnFont
        dateBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Left
        let dropdownImageView: UIImageView = UIImageView(frame: CGRECT(dateBtnTextSize.width + patientStatusDropdownLeftSpace, 0, patientStatusDropdownW, patientStatusDateSectionHeight))
        dropdownImageView.image = UIImage(named: "btn_datedropdown")
        dropdownImageView.contentMode = UIViewContentMode.ScaleAspectFit
        dateBtn.addSubview(dropdownImageView)
        dateSection.addSubview(dateBtn)
        let dateSeperateLine = UIView(frame: CGRECT(0, patientStatusDateSectionHeight - 0.5, screenWidth, 0.5))
        dateSeperateLine.backgroundColor = seperateLineColor
        dateSection.addSubview(dateSeperateLine)
        self.view.addSubview(dateSection)
        
        //symptoms section
        var symptomsSectionW: CGFloat = screenWidth - 2 * symptomsSectionLeftSpace
        //symptons title
        let symptomsTitleSize = symptomsTitleStr.sizeWithFont(symptomsFont, maxSize: CGSize(width: symptomsSectionW, height: CGFloat.max))
        let symptomsTitleLbl = UILabel(frame: CGRECT(0, symptomsTitleTopSpace, symptomsTitleSize.width, symptomsTitleSize.height))
        symptomsTitleLbl.text = symptomsTitleStr
        symptomsTitleLbl.textColor = symptomsTitleColor
        symptomsTitleLbl.font = symptomsFont
        symptomsSection.addSubview(symptomsTitleLbl)
        
        //symptons buttons
        var symptomBtnsX: CGFloat = 0
        var symptomBtnsY: CGFloat = symptomsBtnsTopSpace + symptomsTitleLbl.frame.height + symptomsTitleTopSpace
        for patientStatus in patientStatusFormatList {
            let symptomBtnText = (patientStatus as! NSDictionary).objectForKey("statusName") as! String
            let symptomBtnTextSize = symptomBtnText.sizeWithFont(symptomsFont, maxSize: CGSize(width: symptomsSectionW - symptomBtnsX, height: symptomsBtnHeight))
            if symptomBtnsX + symptomBtnTextSize.width > symptomsSectionW {
                symptomBtnsX = 0
                symptomBtnsY += symptomsBtnHeight + 11
            }
            let symptomBtn = UIButton(frame: CGRECT(symptomBtnsX, symptomBtnsY, symptomBtnTextSize.width + 20, symptomsBtnHeight))
            symptomBtn.setTitle(symptomBtnText, forState: UIControlState.Normal)
            symptomBtn.setTitleColor(headerColor, forState: UIControlState.Normal)
            symptomBtn.titleLabel?.font = symptomsFont
            symptomBtn.layer.borderColor = headerColor.CGColor
            symptomBtn.layer.borderWidth = 1
            symptomBtn.layer.cornerRadius = 2
            symptomBtn.layer.masksToBounds = true
            symptomsSection.addSubview(symptomBtn)
            symptomBtnsX += symptomBtn.frame.width + 11
        }
        
        symptomsSection.frame = CGRECT(symptomsSectionLeftSpace, headerHeight + dateSection.frame.height, symptomsSectionW, symptomBtnsY + symptomsBtnHeight + 13.0)
        let symptomSeperateLine = UIView(frame: CGRECT(0, symptomsSection.frame.height - 0.5, screenWidth, 0.5))
        symptomSeperateLine.backgroundColor = seperateLineColor
        symptomsSection.addSubview(symptomSeperateLine)
        self.view.addSubview(symptomsSection)
        //add text view input
        symptomDesp.frame = CGRECT(symptomDespTextHorizonSpace, symptomDespTextTopSpace + headerHeight + dateSection.frame.height + symptomsSection.frame.height, screenWidth - 2 * symptomDespTextHorizonSpace, symptomDespTextHeight)
        symptomDesp.text
        
        self.view.addSubview(symptomDesp)
    }
    
    func getPatientStatusFormat(){
//        let getClinicReportFormatData = haalthyService.getClinicReportFormat()
//        var jsonResult = try? NSJSONSerialization.JSONObjectWithData(getClinicReportFormatData, options: NSJSONReadingOptions.MutableContainers)
//                clinicReportFormatList = jsonResult as! NSArray
        let getPatientStatusFormatData = haalthyService.getPatientStatusFormat()
        var jsonResult = try? NSJSONSerialization.JSONObjectWithData(getPatientStatusFormatData, options: NSJSONReadingOptions.MutableContainers)
        if jsonResult is NSDictionary {
            patientStatusFormatList = (jsonResult as! NSDictionary).objectForKey("content") as! NSArray
        }
    }
    
    @IBAction func loadPreviousView(){
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
    
}
