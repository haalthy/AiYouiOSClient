//
//  AddPatientStatusViewController.swift
//  CancerSN
//
//  Created by hui luo on 22/1/2016.
//  Copyright © 2016 lily. All rights reserved.
//

import UIKit

class AddPatientStatusViewController: UIViewController, UITextViewDelegate, UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate{
    
    //global variable
    let getAccessToken = GetAccessToken()
    let keychainAccess = KeychainAccess()
    
    var headerHeight: CGFloat = CGFloat()
    var screenWidth = UIScreen.mainScreen().bounds.width
    var patientStatusFormatList = NSArray()
    var clinicReportFormatList = NSArray()
    var keyboardheight:CGFloat = 0
    var patientStatusDetail: String = String()
    var clinicRowsCount:Int = 0
    var defaultClinicRowsName = NSMutableArray()
    var selfDefinedCilnicRowName = NSMutableArray()
    var clinicDataList = NSMutableArray()

    //date section
    var dateSection = UIView()
    var scrollView = UIScrollView()
    var symptomsSection = UIView()
    var symptomDesp = UITextView()
    var reportView = UIView()
    var checkedView = UIView()
    var clinicReportViewList = UIView()
    let reportTextInput = UITextField()
    let scanReportText = UITextView()
    var clinicTableView = UITableView()
    let dateBtn = UIButton()
    var isSelectedDate: Bool = false
    
    var datePickerContainerView = UIView()
    var datePicker = UIDatePicker()
    
    var dateInserted: NSDate?
    var isPosted: Int = 1
    
    var scrollViewOffset: CGFloat = 0
    
    @IBOutlet weak var submitBtn: UIButton!
    override func viewDidLoad() {
        getAccessToken.getAccessToken()
        
        let accessToken = NSUserDefaults.standardUserDefaults().objectForKey(accessNSUserData)
        
        if accessToken != nil {
            initVariables()
            initContentView()
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillAppear:", name: UIKeyboardWillShowNotification, object: nil)
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillDisappear:", name:UIKeyboardWillHideNotification, object: nil)
            clinicTableView.delegate = self
            clinicTableView.dataSource = self
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
    
    func initVariables(){
        headerHeight = UIApplication.sharedApplication().statusBarFrame.height + (self.navigationController?.navigationBar.frame.height)!
        dateInserted = NSDate()
        getPatientStatusFormat()
    }
    
    func initContentView(){
        //
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
        dateBtn.frame = CGRect(x: patientStatusDateLabelLeftSpace + 39, y: 0, width: dateBtnTextSize.width + patientStatusDropdownLeftSpace + patientStatusDropdownW, height: patientStatusDateSectionHeight)
        dateBtn.setTitle(dateStr, forState: UIControlState.Normal)
        dateBtn.setTitleColor(headerColor, forState: UIControlState.Normal)
        dateBtn.titleLabel?.font = patientStatusDateBtnFont
        dateBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Left
        dateBtn.addTarget(self, action: "selectDate:", forControlEvents: UIControlEvents.TouchUpInside)
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
        let symptomsSectionW: CGFloat = screenWidth - 2 * symptomsSectionLeftSpace
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
            symptomBtn.addTarget(self, action: "selectSymptom:", forControlEvents: UIControlEvents.TouchUpInside)
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
        symptomDesp.returnKeyType = UIReturnKeyType.Done
        self.scrollView.addSubview(symptomDesp)
        
        //add "more" button
        let addReportBtnW = screenWidth - 2 * addReportButtonLeftSpace
        let addReportBtnH = addReportBtnW * 90 / 690
        let addReportBtn = UIButton(frame: CGRect(x: addReportButtonLeftSpace, y: symptomDespTextTopSpace + symptomsSection.frame.height + symptomDesp.frame.height + 50, width: addReportBtnW, height: addReportBtnH))
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
    
    func selectSymptom(sender: UIButton){
        print(sender.backgroundColor)
        if (sender.backgroundColor == nil) || (sender.backgroundColor == UIColor.whiteColor()){
            sender.backgroundColor = headerColor
            sender.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        }else{
            sender.backgroundColor = UIColor.whiteColor()
            sender.setTitleColor(headerColor, forState: UIControlState.Normal)
        }
    }
    
    func selectDate(sender: UIButton) {
        if isSelectedDate == false {
            isSelectedDate = true
            let datePickerHeight:CGFloat = 200
            let confirmButtonWidth:CGFloat = 100
            let confirmButtonHeight:CGFloat = 30
            datePickerContainerView = UIView(frame: CGRectMake(0, screenHeight - datePickerHeight - 30 - 40, screenWidth, datePickerHeight + 30))
            datePickerContainerView.backgroundColor = UIColor.whiteColor()
            self.datePicker.frame = CGRectMake(0 , 30, UIScreen.mainScreen().bounds.width, datePickerHeight)
            self.datePicker.datePickerMode = UIDatePickerMode.Date
            let confirmButton = UIButton(frame: CGRectMake(screenWidth - confirmButtonWidth, 0, confirmButtonWidth, confirmButtonHeight))
            confirmButton.setTitle("确定", forState: UIControlState.Normal)
            confirmButton.setTitleColor(headerColor, forState: UIControlState.Normal)
            confirmButton.addTarget(self, action: "dateChanged", forControlEvents: UIControlEvents.TouchUpInside)
            let cancelButton = UIButton(frame: CGRect(x: 0, y: 0, width: confirmButtonWidth, height: confirmButtonHeight))
            cancelButton.setTitle("取消", forState: UIControlState.Normal)
            cancelButton.setTitleColor(headerColor, forState: UIControlState.Normal)
            cancelButton.addTarget(self, action: "dateCancel", forControlEvents: UIControlEvents.TouchUpInside)
            datePickerContainerView.addSubview(self.datePicker)
            datePickerContainerView.addSubview(confirmButton)
            datePickerContainerView.addSubview(cancelButton)
            self.view.addSubview(datePickerContainerView)
        }else {
            isSelectedDate = false
            dateCancel()
        }
    }
    
    func dateCancel(){
        self.datePickerContainerView.removeFromSuperview()
    }
    
    func dateChanged(){
        dateInserted = datePicker.date
        self.datePickerContainerView.removeFromSuperview()
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "YYYY/MM/dd" // superset of OP's format
        let dateStr = dateFormatter.stringFromDate(dateInserted!)
        dateBtn.setTitle(dateStr, forState: UIControlState.Normal)
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
        clinicTableView.scrollEnabled = false
        clinicTableView.frame = CGRECT(0, clinicReportTitleListHeight, screenWidth - 30, CGFloat(clinicReportFormatList.count + 1)*clinicReportTitleListHeight)
        for clinicReportFormat in clinicReportFormatList {
            defaultClinicRowsName.addObject((clinicReportFormat as! NSDictionary).objectForKey("clinicItem") as! String)
        }
        clinicRowsCount = defaultClinicRowsName.count
//        clinicTableView.setEditing(true, animated: true)
        reportListView.addSubview(clinicTableView)
        //add report text
        self.scrollView.addSubview(reportListView)
        
        scanReportText.frame = CGRECT(10, reportListViewY + reportListView.frame.height, reportListViewW, scanReportHeight)
        scanReportText.text = scanReportDespStr
        scanReportText.textColor = textInputViewPlaceholderColor
        scanReportText.delegate = self
        scanReportText.font = scanReportDespFont
        scanReportText.returnKeyType = UIReturnKeyType.Done
        scrollView.addSubview(scanReportText)
        //add image view
        scrollView.frame = CGRECT(0, headerHeight + dateSection.frame.height, screenWidth, UIScreen.mainScreen().bounds.height - headerHeight - dateSection.frame.height - patientstatusFooterH)
        scrollView.contentSize = CGSize(width: screenWidth, height: scrollView.frame.height + reportListViewY)
        self.scrollView.contentOffset = CGPoint(x: 0, y: symptomDespTextTopSpace + symptomsSection.frame.height + symptomDesp.frame.height)
        self.scrollView.scrollEnabled = true
        
        self.scrollView.userInteractionEnabled = true
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "tapDismiss")
        self.scrollView.addGestureRecognizer(tapGesture)
    }
    
    func tapDismiss(){
        self.view.endEditing(true)
    }
    
    func addClinicData(sender: UIButton){
        self.clinicTableView.beginUpdates()
        let indexPath = NSIndexPath(forRow: clinicRowsCount, inSection: 0)
        clinicRowsCount++
        self.clinicTableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
        self.clinicTableView.endUpdates()
        
        self.clinicTableView.frame = CGRECT(clinicTableView.frame.origin.x, clinicTableView.frame.origin.y, clinicTableView.frame.width, clinicTableView.frame.height + clinicReportTitleListHeight)
        let reportListView = clinicTableView.superview!
        reportListView.frame = CGRECT(reportListView.frame.origin.x, reportListView.frame.origin.y, reportListView.frame.width, reportListView.frame.height + clinicReportTitleListHeight)
        scanReportText.center = CGPoint(x: scanReportText.center.x, y: scanReportText.center.y + clinicReportTitleListHeight)
        sender.center = CGPoint(x: sender.center.x, y: sender.center.y + clinicReportTitleListHeight)
        scrollView.contentSize = CGSize(width: scrollView.contentSize.width, height: scrollView.contentSize.height + clinicReportTitleListHeight)
    }
    
    func deleteClinicData(sender: UIButton){
        let indexPath = self.clinicTableView.indexPathForCell(sender.superview as! UITableViewCell)
        clinicRowsCount--
        if indexPath?.row < defaultClinicRowsName.count {
            defaultClinicRowsName.removeObjectAtIndex((indexPath?.row)!)
        }
        self.clinicTableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: UITableViewRowAnimation.Automatic)
        self.clinicTableView.frame = CGRECT(clinicTableView.frame.origin.x, clinicTableView.frame.origin.y, clinicTableView.frame.width, clinicTableView.frame.height - clinicReportTitleListHeight)
        let reportListView = clinicTableView.superview!
        reportListView.frame = CGRECT(reportListView.frame.origin.x, reportListView.frame.origin.y, reportListView.frame.width, reportListView.frame.height - clinicReportTitleListHeight)
        scanReportText.center = CGPoint(x: scanReportText.center.x, y: scanReportText.center.y - clinicReportTitleListHeight)
        scrollView.contentSize = CGSize(width: scrollView.contentSize.width, height: scrollView.contentSize.height - clinicReportTitleListHeight)
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
        let parameters = NSDictionary(object: keychainAccess.getPasscode(usernameKeyChain)!, forKey: "username")
        let jsonResult = NetRequest.sharedInstance.POST_A(getClinicReportFormatURL, parameters: parameters as! Dictionary<String, AnyObject>)
        if (jsonResult.objectForKey("content") != nil) && ((jsonResult ).objectForKey("content") is NSArray){
            self.clinicReportFormatList = (jsonResult ).objectForKey("content") as! NSArray
        }
    }
    
    func getPatientStatusFormat(){
        let parameters = NSDictionary()
        let jsonResult = NetRequest.sharedInstance.GET_A(getPatientStatusFormatURL, parameters: parameters as! Dictionary<String, AnyObject>)
        if (jsonResult.objectForKey("content") != nil){
            patientStatusFormatList = (jsonResult ).objectForKey("content") as! NSArray
        }else{
        }
    }
    
    @IBAction func loadPreviousView(){
//        self.navigationController?.popToRootViewControllerAnimated(true)
        self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func submitStatus(sender: UIButton){
        
        for symptonButton in symptomsSection.subviews {
            if symptonButton is UIButton && symptonButton.backgroundColor == headerColor{
                patientStatusDetail += ((symptonButton as! UIButton).titleLabel!).text! + " "
            }
        }
        patientStatusDetail += "::"
        if symptomDesp.textColor != textInputViewPlaceholderColor{
            patientStatusDetail += symptomDesp.text
        }
        if patientStatusDetail == "::" {
            patientStatusDetail = ""
        }
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd"
        let date:NSDate = dateFormatter.dateFromString((dateBtn.titleLabel?.text)!)!
        
        var scanReportStr: String = ""
        if self.scanReportText.textColor != textInputViewPlaceholderColor {
            scanReportStr = self.scanReportText.text
        }
        let pateintStatusDic  = NSDictionary(objects: [date.timeIntervalSince1970 * 1000, self.isPosted, patientStatusDetail, scanReportStr], forKeys: [ "insertedDate", "isPosted", "statusDesc", "scanData"])
        getClinicDataStr()
        var clinicReportStr: String = ""
        for clinicData in clinicDataList {
            let clinicDataDic = clinicData as! NSDictionary
            clinicReportStr += "[" + ((clinicDataDic.allKeys as NSArray).objectAtIndex(0)as! String) + ":" + ((clinicDataDic.allValues as NSArray).objectAtIndex(0)as! String) + "]"
        }
        let clinicReportDic = NSDictionary(objects: [clinicReportStr, self.isPosted], forKeys: [ "clinicReport", "isPosted"])
        
        var accessToken = NSUserDefaults.standardUserDefaults().objectForKey(accessNSUserData)
        if accessToken == nil {
            getAccessToken.getAccessToken()
            accessToken = NSUserDefaults.standardUserDefaults().objectForKey(accessNSUserData)
        }
        
        let urlPath:String = (addPatientStatusURL as String) + "?access_token=" + (accessToken as! String);

        let requestBody = NSMutableDictionary()
        requestBody.setValue(pateintStatusDic, forKey: "patientStatus")
        requestBody.setValue(clinicReportDic, forKey: "clinicReport")
        requestBody.setValue(keychainAccess.getPasscode(usernameKeyChain), forKey: "insertUsername")
        
        NetRequest.sharedInstance.POST(urlPath, parameters: (requestBody as NSDictionary) as! Dictionary<String, AnyObject>,
            
            success: { (content , message) -> Void in
                print(content)
                
            }) { (content, message) -> Void in
                
                HudProgressManager.sharedInstance.showOnlyTextHudProgress(self, title: message)
            }
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
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
        self.scrollViewOffset = textView.frame.origin.y
        self.scrollView.contentOffset = CGPoint(x: 0, y: scrollViewOffset)
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
        self.scrollView.contentOffset = CGPoint(x: 0, y: 0)
    }
    //UITextField
//    func textFieldDidEndEditing(textField: UITextField) {
//        if textField.superview  is UITableViewCell{
//            let clinicData = NSMutableDictionary()
//            var clinicDataName: String = ""
//            let cell = textField.superview as! UITableViewCell
//            if textField.placeholder == reportListItemPlaceholder {
//                if (cell.textLabel != nil) && (cell.textLabel?.text != nil) && (cell.textLabel?.text != ""){
//                    clinicDataName = (cell.textLabel?.text)!
//                }else{
//                    for subView in cell.subviews {
//                        if (subView is UITextField) && (subView as! UITextField).frame.origin.x < clinicReportLblW {
//                            clinicDataName = (subView as! UITextField).text!
//                        }
//                    }
//                }
//                if (textField.text != "")&&(clinicDataName != "") {
//                    clinicData.setObject(textField.text!, forKey: clinicDataName)
//                    self.clinicDataList.addObject(clinicData)
//                }
//            }else{
//                if (textField.text != "") {
//                    for subView in cell.subviews {
//                        if (subView is UITextField) && (subView as! UITextField).placeholder == reportListItemPlaceholder {
//                            let clinicDataValue = (subView as! UITextField).text!
//                            if clinicDataValue != "" {
//                                clinicData.setObject(clinicDataValue, forKey: textField.text!)
//                                self.clinicDataList.addObject(clinicData)
//                            }
//                        }
//                    }
//                }
//            }
//        }
//    }
    
    func getClinicDataStr(){
        if self.clinicTableView.numberOfRowsInSection(0) > 0{
            for index in 0...(self.clinicTableView.numberOfRowsInSection(0) - 1) {
                var clinicDataName: String = ""
                var clinicDataValue: String = ""
                let indexPath = NSIndexPath(forRow: index, inSection: 0)
                let cell = self.clinicTableView.cellForRowAtIndexPath(indexPath)
                if (cell!.textLabel != nil) && (cell!.textLabel?.text != nil) && (cell!.textLabel?.text != ""){
                    clinicDataName = (cell!.textLabel?.text)!
                }
                
                for subView in cell!.subviews {
                    if (subView is UITextField) && (subView as! UITextField).frame.origin.x < clinicReportLblW {
                        clinicDataName = (subView as! UITextField).text!
                    }else if (subView is UITextField) && (subView as! UITextField).frame.origin.x > (clinicReportLblW - 10){
                        clinicDataValue = (subView as! UITextField).text!
                    }
                }
                
                if (clinicDataName != "") && (clinicDataValue != "") {
                    let clinicData = NSDictionary(object: clinicDataValue, forKey: clinicDataName)
                    self.clinicDataList.addObject(clinicData)
                }
            }
        }
    }
    
    // MARK: - Table view data source
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 2
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            return clinicRowsCount
        }else{
            return 1
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        var heightForRow: CGFloat = 0
        switch indexPath.section {
        case 0:
            heightForRow = clinicReportTitleListHeight
            break
        case 1:
            heightForRow = 90
            break
        default:
            break
        }
        return heightForRow
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier:String = "cell"
        let cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: cellIdentifier)
        if indexPath.section == 0{
            if indexPath.row < defaultClinicRowsName.count {
                cell.textLabel?.text =  defaultClinicRowsName.objectAtIndex(indexPath.row) as! String
                cell.textLabel?.font = reportListTitleFont
                cell.textLabel?.textColor = reportListItemColor

            }else{
                let clinicItemNameTextField = UITextField(frame: CGRect(x: 15, y: 0, width: clinicReportLblW - 10, height: clinicReportTitleListHeight))
                clinicItemNameTextField.placeholder = "其他指标:"
                clinicItemNameTextField.font = reportListTitleFont
                clinicItemNameTextField.delegate = self
                cell.addSubview(clinicItemNameTextField)
            }
            //textField
            let clinicItemValueTextField = UITextField(frame: CGRect(x: clinicReportLblW, y: 0, width: cell.frame.width - clinicReportLblW - clinicReportDelBtnRightSpace - clinicReportDelBtnWidth, height: clinicReportTitleListHeight))
            clinicItemValueTextField.placeholder = reportListItemPlaceholder
            clinicItemValueTextField.font = reportListTitleFont
            clinicItemValueTextField.delegate = self
            cell.addSubview(clinicItemValueTextField)
            //delete button
            print(cell.frame.width)
            let clinicReportDelBtnWidthMargin: CGFloat = 15
            let deleteBtn = UIButton(frame: CGRect(x: cell.frame.width - clinicReportDelBtnWidth - 30 - clinicReportDelBtnWidthMargin * 2, y: 16 - clinicReportDelBtnWidthMargin, width: clinicReportDelBtnWidth + clinicReportDelBtnWidthMargin * 2, height: clinicReportDelBtnWidth + clinicReportDelBtnWidthMargin * 2))
            deleteBtn.backgroundColor = UIColor.clearColor()
            let btnImageView = UIImageView(frame: CGRECT(clinicReportDelBtnWidth, clinicReportDelBtnWidth, clinicReportDelBtnWidth, clinicReportDelBtnWidth))
            btnImageView.image = UIImage(named: "btn_deleteClinicData")
            deleteBtn.addSubview(btnImageView)
            deleteBtn.layer.cornerRadius = clinicReportDelBtnWidth/2
            deleteBtn.layer.masksToBounds = true
            deleteBtn.addTarget(self, action: "deleteClinicData:", forControlEvents: UIControlEvents.TouchUpInside)
            cell.addSubview(deleteBtn)
        }else{
            let addMoreClinicDataBtnW:CGFloat = cell.frame.size.width - 12
            let addMoreClinicDataBtnH:CGFloat = 30
            let addMoreClinicDataBtn = UIButton(frame: CGRect(x: 12, y: 12, width: cell.frame.width - 36, height: addMoreClinicDataBtnH))
            let addReportImgView = UIImageView(frame: CGRECT(0, 0, addMoreClinicDataBtnW, addMoreClinicDataBtnH))
            addReportImgView.image = UIImage(named: "btn_addReport")
            addMoreClinicDataBtn.addSubview(addReportImgView)
            addMoreClinicDataBtn.setTitle("添加更多指标", forState: UIControlState.Normal)
            addMoreClinicDataBtn.setTitleColor(addReportButtonTextColor, forState: UIControlState.Normal)
            addMoreClinicDataBtn.titleLabel?.font = addReportButtonFont
            addMoreClinicDataBtn.addTarget(self, action: "addClinicData:", forControlEvents: UIControlEvents.TouchUpInside)

            cell.addSubview(addMoreClinicDataBtn)
        }
        return cell
    }
    
}

