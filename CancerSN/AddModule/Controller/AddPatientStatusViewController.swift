//
//  AddPatientStatusViewController.swift
//  CancerSN
//
//  Created by hui luo on 22/1/2016.
//  Copyright © 2016 lily. All rights reserved.
//

import UIKit

class AddPatientStatusViewController: UIViewController, UITextViewDelegate, UITextFieldDelegate {
    
    //global variable
    var headerHeight: CGFloat = CGFloat()
    var screenWidth = UIScreen.mainScreen().bounds.width
    var haalthyService = HaalthyService()
    var patientStatusFormatList = NSArray()
    var clinicReportFormatList = NSArray()
    var keyboardheight:CGFloat = 0
    
    //date section
    var dateSection = UIView()
    var scrollView = UIScrollView()
    var symptomsSection = UIView()
    var symptomDesp = UITextView()
    var reportView = UIView()
    var checkedView = UIView()
    var dateInserted: NSDate?
    var isPosted: Int = 1
    
    override func viewDidLoad() {
        initVariables()
        initContentView()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillAppear:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillDisappear:", name:UIKeyboardWillHideNotification, object: nil)
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
        
        symptomsSection.frame = CGRECT(symptomsSectionLeftSpace, 0, symptomsSectionW, symptomBtnsY + symptomsBtnHeight + 13.0)
        let symptomSeperateLine = UIView(frame: CGRECT(0, symptomsSection.frame.height - 0.5, screenWidth, 0.5))
        symptomSeperateLine.backgroundColor = seperateLineColor
        symptomsSection.addSubview(symptomSeperateLine)
        self.scrollView.addSubview(symptomsSection)
        //add text view input
        symptomDesp.frame = CGRECT(symptomDespTextHorizonSpace, symptomDespTextTopSpace + symptomsSection.frame.height, screenWidth - 2 * symptomDespTextHorizonSpace, symptomDespTextHeight)
        symptomDesp.text = symptomDespText
        symptomDesp.textColor = textInputViewPlaceholderColor
        symptomDesp.font = symptomDespFont
        symptomDesp.delegate = self
        self.scrollView.addSubview(symptomDesp)
        
        //add "more" button
        let addReportBtnW = screenWidth - 2 * addReportButtonLeftSpace
        let addReportBtnH = addReportBtnW * 90 / 690
        let addReportBtn = UIButton(frame: CGRect(x: addReportButtonLeftSpace, y: symptomDespTextTopSpace + symptomsSection.frame.height + symptomDesp.frame.height, width: addReportBtnW, height: addReportBtnH))
        let addReportImgView = UIImageView(frame: CGRECT(0, 0, addReportBtnW, addReportBtnH))
        addReportImgView.image = UIImage(named: "btn_addReport")
        addReportBtn.addSubview(addReportImgView)
        addReportBtn.setTitle(addReportButtonText, forState: UIControlState.Normal)
        addReportBtn.setTitleColor(addReportButtonTextColor, forState: UIControlState.Normal)
        addReportBtn.titleLabel?.font = addReportButtonFont
        addReportBtn.addTarget(self, action: "addReport:", forControlEvents: UIControlEvents.TouchUpInside)
        self.scrollView.addSubview(addReportBtn)
        
        scrollView.frame = CGRECT(0, headerHeight + dateSection.frame.height, screenWidth, UIScreen.mainScreen().bounds.height)
        self.view.addSubview(self.scrollView)
        
        //add footer
        let privateCheckUIView = PrivateCheckUIView()
        checkedView = privateCheckUIView.createCheckedSection()
        self.view.addSubview(checkedView)
        privateCheckUIView.checkbox.addTarget(self, action: "checkedPrivate:", forControlEvents: UIControlEvents.TouchUpInside)
    }
    
    func addReport(sender: UIButton){
        sender.removeFromSuperview()
        getClinicReportFormat()
        //seperate Line View
        let seperateTitleLine = UIView(frame: CGRect(x: 0, y: clinicReportTitleListHeight - 0.5, width: screenWidth - clinicReportListLeftSpace, height: 0.5))
        seperateTitleLine.backgroundColor = seperateLineColor
        
        //report table view
        let reportListViewY: CGFloat = symptomDespTextTopSpace + symptomsSection.frame.height + symptomDesp.frame.height + 10
        let reportListViewW: CGFloat = screenWidth - clinicReportListLeftSpace * 2
        let reportListViewH: CGFloat = clinicReportTitleListHeight * CGFloat(clinicReportFormatList.count + 2)
        let reportListView: UIView = UIView(frame: CGRect(x: clinicReportListLeftSpace, y: reportListViewY, width: reportListViewW, height: reportListViewH))
        
        //add report list title
        let reportListTitle: UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: reportListViewW, height: clinicReportTitleListHeight))
        reportListTitle.text = reportListTitleStr
        reportListTitle.textColor = reportListTitleColor
        reportListTitle.font = reportListTitleFont
        reportListView.addSubview(seperateTitleLine)
        reportListView.addSubview(reportListTitle)
        
        //add report list
        var cinicReportIndex = 0
        let clinicReportLblW:CGFloat = 80
        for clinicReportFormat in clinicReportFormatList {
            let clinicReportListView = UIView(frame: CGRect(x: 0, y: CGFloat(cinicReportIndex + 1)*clinicReportTitleListHeight, width: reportListViewW, height: reportListViewH))
            let clinicReportLbl = UILabel(frame: CGRect(x: 0, y: 0, width: clinicReportLblW, height: reportListViewH))
            clinicReportLbl.text = ((clinicReportFormat as! NSDictionary).objectForKey("clinicItem") as! String) + ":"
            clinicReportLbl.font = reportListTitleFont
            clinicReportLbl.textColor = reportListItemColor
            clinicReportListView.addSubview(clinicReportLbl)
            let clinicReportItemTextField: UITextField = UITextField(frame: CGRect(x: clinicReportLblW, y: reportListViewH, width: clinicReportListView.frame.width - clinicReportLblW, height: reportListViewH))
            clinicReportItemTextField.textColor = reportListItemColor
            clinicReportItemTextField.font = reportListTitleFont
            clinicReportListView.addSubview(clinicReportItemTextField)
            let seperateLine = UIView(frame: CGRect(x: 0, y: clinicReportTitleListHeight - 0.5, width: reportListViewW, height: 0.5))
            seperateLine.backgroundColor = seperateLineColor
            clinicReportListView.addSubview(seperateLine)
            reportListView.addSubview(clinicReportListView)
        }
        //add report text
        let reportTextInput: UITextField = UITextField(frame: CGRect(x: 0, y: CGFloat(cinicReportIndex + 1)*clinicReportTitleListHeight, width: reportListViewW, height: clinicReportTitleListHeight))
        reportTextInput.placeholder = reportTextInputStr
        reportTextInput.font = reportListTitleFont
        reportTextInput.delegate = self
        let seperateTextInputLine = UIView(frame: CGRect(x: 0, y: clinicReportTitleListHeight - 0.5, width: reportListViewW, height: 0.5))
        seperateTextInputLine.backgroundColor = seperateLineColor
        reportTextInput.addSubview(seperateTextInputLine)
        reportListView.addSubview(reportTextInput)
        self.scrollView.addSubview(reportListView)
        
        let scanReportText: UITextView = UITextView(frame: CGRECT(10, reportListViewY + reportListView.frame.height, reportListViewW, scanReportHeight))
        scanReportText.text = scanReportDespStr
        scanReportText.textColor = textInputViewPlaceholderColor
        scanReportText.delegate = self
        scanReportText.font = scanReportDespFont
        scrollView.addSubview(scanReportText)
        //add image view
        scrollView.frame = CGRECT(0, headerHeight + dateSection.frame.height, screenWidth, UIScreen.mainScreen().bounds.height - headerHeight - dateSection.frame.height - patientstatusFooterH)
        scrollView.contentSize = CGSize(width: screenWidth, height: scrollView.frame.height + reportListViewY)
        self.scrollView.contentOffset = CGPoint(x: 0, y: symptomDespTextTopSpace + symptomsSection.frame.height + symptomDesp.frame.height)
        self.scrollView.scrollEnabled = true
    }
    
    func checkedPrivate(sender: UIButton){
        if isPosted == 0 {
            isPosted = 1
            sender.backgroundColor = UIColor.whiteColor()
            sender.layer.borderColor = privateLabelColor.CGColor
            sender.removeAllSubviews()
        }else{
            isPosted = 0
            sender.backgroundColor = headerColor
            let checkImgView = UIImageView(image: UIImage(named: "btn_check"))
            checkImgView.frame = CGRECT(0, 0, sender.frame.width, sender.frame.height)
            checkImgView.contentMode = UIViewContentMode.ScaleAspectFit
            sender.layer.borderColor = headerColor.CGColor
            sender.addSubview(checkImgView)
        }
    }
    
    func getClinicReportFormat(){
        let getClinicReportFormatData = haalthyService.getClinicReportFormat()
        var jsonResult = try? NSJSONSerialization.JSONObjectWithData(getClinicReportFormatData, options: NSJSONReadingOptions.MutableContainers)
        if jsonResult is NSDictionary {
            clinicReportFormatList = (jsonResult as! NSDictionary).objectForKey("content") as! NSArray
        }
    }
    
    func getPatientStatusFormat(){
        let getPatientStatusFormatData = haalthyService.getPatientStatusFormat()
        var jsonResult = try? NSJSONSerialization.JSONObjectWithData(getPatientStatusFormatData, options: NSJSONReadingOptions.MutableContainers)
        if jsonResult is NSDictionary {
            patientStatusFormatList = (jsonResult as! NSDictionary).objectForKey("content") as! NSArray
        }
    }
    
    @IBAction func loadPreviousView(){
//        self.navigationController?.popToRootViewControllerAnimated(true)
        self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
//    @IBAction func submitStatus(sender: UIButton){
//        for symptonButton in symptonContainerView.subviews {
//            if symptonButton is UIButton && symptonButton.backgroundColor == mainColor{
//                patientStatusDetail += ((symptonButton as! UIButton).titleLabel!).text! + "*"
//            }
//        }
//        if textView.textColor == UIColor.blackColor(){
//            patientStatusDetail += "**" + textView.text
//        }
//        
//        let clinicItemList = NSMutableArray()
//        var index = 0
//        for index = 0; index < clinicReportFormatList.count; index++ {
//            let indexPath = NSIndexPath(forRow: index, inSection: 3)
//            let clinicItem = NSMutableDictionary()
//            let cell = self.tableView.cellForRowAtIndexPath(indexPath)
//            for clinicItemView in cell!.subviews {
//                if clinicItemView is UILabel{
//                    clinicItem.setObject((clinicItemView as! UILabel).text!, forKey: "clinicItemName")
//                }
//                if (clinicItemView is UITextField) && ((clinicItemView as! UITextField).text != nil) && ((clinicItemView as! UITextField).text != ""){
//                    clinicItem.setObject((clinicItemView as! UITextField).text!, forKey: "clinicItemDesc")
//                }
//            }
//            if (clinicItem.objectForKey("clinicItemDesc") != nil) && ((clinicItem.objectForKey("clinicItemDesc") as! String) != ""){
//                clinicItemList.addObject(clinicItem)
//            }
//        }
//        
//        for clinicItem in clinicItemList{
//            if ((clinicItem as! NSDictionary).objectForKey("clinicItemDesc") as! NSString).length > 0{
//                clinicReportDetail += ((clinicItem as! NSDictionary).objectForKey("clinicItemName") as! String) + "*" + ((clinicItem as! NSDictionary).objectForKey("clinicItemDesc") as! String) + "**"
//            }
//        }
//        
//        let clinicReport = NSMutableDictionary()
//        clinicReport.setValue(clinicReportDetail, forKey: "clinicReport")
//        clinicReport.setValue(isPublic, forKey: "isPosted")
//        clinicReport.setValue(Int(self.datePicker.date.timeIntervalSince1970 * 1000), forKey: "dateInserted")
//        let patientStatus = NSMutableDictionary()
//        patientStatus.setValue(patientStatusDetail, forKey: "statusDesc")
//        patientStatus.setValue(isPublic, forKey: "isPosted")
//        patientStatus.setValue(Int(self.datePicker.date.timeIntervalSince1970 * 1000), forKey: "insertedDate")
//        
//        haalthyService.addPatientStatus(patientStatus as NSDictionary, clinicReport: clinicReport as NSDictionary)
//    }

    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if text == "\n"{
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        if textView.textColor != UIColor.blackColor() {
            textView.text = nil
            textView.textColor = UIColor.blackColor()
        }
    }
    
    
    func textFieldShouldReturn(textField: UITextField) -> Bool{
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func loadPreviousView(sender: UIButton) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func keyboardWillAppear(notification: NSNotification) {
        
        if self.checkedView.center.y > UIScreen.mainScreen().bounds.height - 50{
            // 获取键盘信息
            let keyboardinfo = notification.userInfo![UIKeyboardFrameBeginUserInfoKey]
            
            keyboardheight = (keyboardinfo?.CGRectValue.size.height)!
            
            self.checkedView.center = CGPoint(x: self.checkedView.center.x, y: self.checkedView.center.y - keyboardheight)
        }
    }
    
    func keyboardWillDisappear(notification:NSNotification){
        
        self.checkedView.center = CGPoint(x: self.checkedView.center.x, y: self.checkedView.center.y + keyboardheight)
    }
}

