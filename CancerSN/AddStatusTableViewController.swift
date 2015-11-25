//
//  AddStatusTableViewController.swift
//  CancerSN
//
//  Created by lily on 9/22/15.
//  Copyright (c) 2015 lily. All rights reserved.
//

import UIKit

class AddStatusTableViewController: UITableViewController, UITextViewDelegate {
    var patientStatusFormatList = NSArray()
    var clinicReportFormatList = NSArray()
    var haalthyService = HaalthyService()
    var publicService = PublicService()
    var textView = UITextView()
    var symptonContainerView = UIView()
    var patientStatusDetail = String()
    var clinicReportDetail = String()
    var datePickerContainerView = UIView()
    var datePicker = UIDatePicker()
    var dateInserted:NSDate?

    @IBAction func selectDate(sender: UIButton) {
        let datePickerHeight:CGFloat = 200
        let confirmButtonWidth:CGFloat = 100
        let confirmButtonHeight:CGFloat = 30
        datePickerContainerView = UIView(frame: CGRectMake(0, UIScreen.mainScreen().bounds.height - datePickerHeight - 30 - 80, UIScreen.mainScreen().bounds.width, datePickerHeight + 30))
        datePickerContainerView.backgroundColor = UIColor.whiteColor()
        self.datePicker = UIDatePicker(frame: CGRectMake(0 , 30, UIScreen.mainScreen().bounds.width, datePickerHeight))
        self.datePicker.datePickerMode = UIDatePickerMode.Date
        let confirmButton = UIButton(frame: CGRectMake(UIScreen.mainScreen().bounds.width - confirmButtonWidth, 0, confirmButtonWidth, confirmButtonHeight))
        confirmButton.setTitle("确定", forState: UIControlState.Normal)
        confirmButton.setTitleColor(mainColor, forState: UIControlState.Normal)
        confirmButton.addTarget(self, action: "dateChanged", forControlEvents: UIControlEvents.TouchUpInside)
        datePickerContainerView.addSubview(self.datePicker)
        datePickerContainerView.addSubview(confirmButton)
        self.view.addSubview(datePickerContainerView)
    }
    
    func dateChanged(){
        dateInserted = datePicker.date
        self.tableView.reloadData()
        self.datePickerContainerView.removeFromSuperview()
    }
    
    @IBAction func cancel(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        dateInserted = NSDate()

        textView.delegate = self
        let getClinicReportFormatData = haalthyService.getClinicReportFormat()
        var jsonResult = try? NSJSONSerialization.JSONObjectWithData(getClinicReportFormatData, options: NSJSONReadingOptions.MutableContainers)
        clinicReportFormatList = jsonResult as! NSArray
        let getPatientStatusFormatData = haalthyService.getPatientStatusFormat()
        jsonResult = try? NSJSONSerialization.JSONObjectWithData(getPatientStatusFormatData, options: NSJSONReadingOptions.MutableContainers)
        patientStatusFormatList = jsonResult as! NSArray
        textView.text = "请在这里输入其他信息，如对副作用的处理方法"
        textView.textColor = UIColor.lightGrayColor()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 6
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var numberOfRowsInSection = 0
        switch section{
        case 3: numberOfRowsInSection = clinicReportFormatList.count
            break
        default: numberOfRowsInSection = 1
            break
        }
        return numberOfRowsInSection
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("titleCell", forIndexPath: indexPath) as! AddPatientStatusHeaderTableViewCell
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "YYYY/MM/dd" // superset of OP's format
            let dateStr = dateFormatter.stringFromDate(dateInserted!)
            cell.selectDateBtn.setTitle(dateStr, forState: UIControlState.Normal)
            cell.selectDateBtn.setTitleColor(UIColor.blueColor(), forState: UIControlState.Normal)
            return cell
        }
        if indexPath.section == 3 {
            let cell = tableView.dequeueReusableCellWithIdentifier("clinicReportCell", forIndexPath: indexPath) 
            let reportNameLabel = UILabel(frame: CGRectMake(20, 10, 60, 30))
            let textField = UITextField(frame: CGRectMake(reportNameLabel.bounds.origin.x + reportNameLabel.bounds.width + 15, 10, UIScreen.mainScreen().bounds.width - reportNameLabel.bounds.width - 30, reportNameLabel.bounds.height))
            reportNameLabel.text = (clinicReportFormatList[indexPath.row] as! NSDictionary).objectForKey("clinicItem") as! String
            reportNameLabel.textColor = mainColor
            textField.layer.borderColor = mainColor.CGColor
            textField.layer.borderWidth = 1.0
            textField.layer.cornerRadius = 5.0
            cell.addSubview(reportNameLabel)
            cell.addSubview(textField)
            return cell
        }
        if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCellWithIdentifier("symptonCell", forIndexPath: indexPath) 
            symptonContainerView = UIView(frame: CGRectMake(10, 30, UIScreen.mainScreen().bounds.width - 20, 70))
            symptonContainerView.backgroundColor = sectionHeaderColor
            let symptonTitleLabel = UILabel(frame: CGRectMake(20, 5, UIScreen.mainScreen().bounds.width - 40, 20))
            symptonTitleLabel.text = "请选择出现的副作用"
            symptonTitleLabel.font = UIFont(name: fontStr, size: 12.0)
            symptonTitleLabel.textColor = UIColor.grayColor()
            cell.addSubview(symptonTitleLabel)
            var index = 0
            for index = 0; index < patientStatusFormatList.count; index++ {
                let labelWidth: CGFloat = CGFloat(symptonContainerView.frame.width - 5)/5 - 5
                let labelHeight: CGFloat = 30
                let coordinateX:CGFloat = 5.0 + (labelWidth+4)*CGFloat(index%5)
                var coordinateY = CGFloat()
                if index<5{
                    coordinateY = 5
                }else{
                    coordinateY = 38
                }
                let statusBtn = UIButton(frame: CGRectMake(coordinateX, coordinateY, labelWidth, labelHeight))
                statusBtn.titleLabel!.font = UIFont(name: fontStr, size: 13.0)
                statusBtn.addTarget(self, action: "selectSymptom:", forControlEvents: UIControlEvents.TouchUpInside)
                publicService.formatButton(statusBtn, title: (patientStatusFormatList[index] as! NSDictionary).objectForKey("statusName") as! String)
                symptonContainerView.addSubview(statusBtn)
            }
            cell.addSubview(symptonContainerView)
            return cell
        }
        if indexPath.section == 2 {
            let cell = tableView.dequeueReusableCellWithIdentifier("textInputCell", forIndexPath: indexPath) 
            textView.frame = CGRectMake(10, 5, cell.frame.width - 20, cell.frame.height - 15)
            textView.layer.borderWidth = 1.0
            textView.layer.borderColor = mainColor.CGColor
            textView.layer.cornerRadius = 5
            cell.addSubview(textView)
            return cell
        }
//        if indexPath.section == 4 {
//            var cell = tableView.dequeueReusableCellWithIdentifier("imageCell", forIndexPath: indexPath) as! UITableViewCell
//            var addImageButton = UIButton(frame: CGRectMake(10, 4, 30, 30))
//            publicService.formatButton(addImageButton, title: "img")
//            cell.addSubview(addImageButton)
//            return cell
//        }
        if indexPath.section == 5 {
            let cell = tableView.dequeueReusableCellWithIdentifier("submitButtonCell", forIndexPath: indexPath) 
            var submitButtonWidth = (cell.frame.width - 90)/2
            let shareToFriendButton = UIButton(frame: CGRectMake(20, 10, UIScreen.mainScreen().bounds.width/2 - 30, 30))
            let saveToMyselfButton = UIButton(frame: CGRectMake(shareToFriendButton.frame.width + 40, 10, shareToFriendButton.frame.width, 30))
            publicService.formatButton(shareToFriendButton, title: "听听病友们的意见？")
            publicService.formatButton(saveToMyselfButton, title: "仅自己可见")
            shareToFriendButton.addTarget(self, action: "shareToFriend", forControlEvents: UIControlEvents.TouchUpInside)
            saveToMyselfButton.addTarget(self, action: "saveToMyself", forControlEvents: UIControlEvents.TouchUpInside)
            shareToFriendButton.titleLabel?.font = UIFont(name: fontStr, size: 13.0)
            saveToMyselfButton.titleLabel?.font = UIFont(name: fontStr, size: 13.0)
            shareToFriendButton.backgroundColor = mainColor
            shareToFriendButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
            saveToMyselfButton.backgroundColor = mainColor
            saveToMyselfButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
            cell.addSubview(shareToFriendButton)
            cell.addSubview(saveToMyselfButton)
            return cell
        }
        let cell = UITableViewCell()
        return cell
    }
    
    func submitStatus(isPublic: Int){
        for symptonButton in symptonContainerView.subviews {
            if symptonButton is UIButton && symptonButton.backgroundColor == mainColor{
                patientStatusDetail += ((symptonButton as! UIButton).titleLabel!).text! + "*"
            }
        }
        if textView.textColor == UIColor.blackColor(){
            patientStatusDetail += "**" + textView.text
        }

        var clinicItemList = NSMutableArray()
        var index = 0
        for index = 0; index < clinicReportFormatList.count; index++ {
            var indexPath = NSIndexPath(forRow: index, inSection: 3)
            var clinicItem = NSMutableDictionary()
            var cell = self.tableView.cellForRowAtIndexPath(indexPath)
            for clinicItemView in cell!.subviews {
                if clinicItemView is UILabel{
                    clinicItem.setObject((clinicItemView as! UILabel).text!, forKey: "clinicItemName")
                }
                if (clinicItemView is UITextField) && ((clinicItemView as! UITextField).text != nil) && ((clinicItemView as! UITextField).text != ""){
                    clinicItem.setObject((clinicItemView as! UITextField).text!, forKey: "clinicItemDesc")
                }
            }
            if (clinicItem.objectForKey("clinicItemDesc") != nil) && ((clinicItem.objectForKey("clinicItemDesc") as! String) != ""){
                clinicItemList.addObject(clinicItem)
            }
        }
        
        for clinicItem in clinicItemList{
            if ((clinicItem as! NSDictionary).objectForKey("clinicItemDesc") as! NSString).length > 0{
                clinicReportDetail += ((clinicItem as! NSDictionary).objectForKey("clinicItemName") as! String) + "*" + ((clinicItem as! NSDictionary).objectForKey("clinicItemDesc") as! String) + "**"
            }
        }
        
        var clinicReport = NSMutableDictionary()
        clinicReport.setValue(clinicReportDetail, forKey: "clinicReport")
        clinicReport.setValue(isPublic, forKey: "isPosted")
        clinicReport.setValue(Int(self.datePicker.date.timeIntervalSince1970 * 1000), forKey: "dateInserted")
        var patientStatus = NSMutableDictionary()
        patientStatus.setValue(patientStatusDetail, forKey: "statusDesc")
        patientStatus.setValue(isPublic, forKey: "isPosted")
        patientStatus.setValue(Int(self.datePicker.date.timeIntervalSince1970 * 1000), forKey: "insertedDate")
        
        haalthyService.addPatientStatus(patientStatus as NSDictionary, clinicReport: clinicReport as NSDictionary)
    }
    
    func shareToFriend(){
        self.submitStatus(1)
        self.dismissViewControllerAnimated(false, completion: nil)
    }
    
    func saveToMyself(){
        self.submitStatus(0)
        self.dismissViewControllerAnimated(false, completion: nil)
    }
    
    func selectSymptom(sender: UIButton){
        if sender.backgroundColor == UIColor.whiteColor(){
            sender.backgroundColor = mainColor
            sender.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        }else{
            sender.backgroundColor = UIColor.whiteColor()
            sender.setTitleColor(mainColor, forState: UIControlState.Normal)
        }
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */
    
    override func tableView(_tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat{
        var rowHeight:CGFloat = 0
        switch indexPath.section{
        case 0: rowHeight = 100
            break
        case 1: rowHeight = 100
            break
        case 5: rowHeight = 44
            break
        case 2: rowHeight = 100
            break
        case 3: rowHeight = 44
            break
        case 4: rowHeight = 40
            break
        default:
            break
        }
        return rowHeight
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        if textView.textColor != UIColor.blackColor() {
            textView.text = nil
            textView.textColor = UIColor.blackColor()
        }
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if text == "\n"{
            textView.resignFirstResponder()
            return false
        }
        return true
    }
}
