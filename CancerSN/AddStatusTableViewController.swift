//
//  AddStatusTableViewController.swift
//  CancerSN
//
//  Created by lily on 9/22/15.
//  Copyright (c) 2015 lily. All rights reserved.
//

import UIKit

class AddStatusTableViewController: UITableViewController {
    var patientStatusFormatList = NSArray()
    var clinicReportFormatList = NSArray()
    var haalthyService = HaalthyService()
    var publicService = PublicService()
    var textView = UITextView()
    var symptonContainerView = UIView()
    var patientStatusDetail = String()
    var clinicReportDetail = String()
    
    @IBAction func cancel(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        var getClinicReportFormatData = haalthyService.getClinicReportFormat()
        var jsonResult = NSJSONSerialization.JSONObjectWithData(getClinicReportFormatData, options: NSJSONReadingOptions.MutableContainers, error: nil)
        clinicReportFormatList = jsonResult as! NSArray
        var getPatientStatusFormatData = haalthyService.getPatientStatusFormat()
        jsonResult = NSJSONSerialization.JSONObjectWithData(getPatientStatusFormatData, options: NSJSONReadingOptions.MutableContainers, error: nil)
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
        var cell = UITableViewCell()
        if indexPath.section == 0 {
            cell = tableView.dequeueReusableCellWithIdentifier("titleCell", forIndexPath: indexPath) as! UITableViewCell
        }
        if indexPath.section == 3 {
            cell = tableView.dequeueReusableCellWithIdentifier("clinicReportCell", forIndexPath: indexPath) as! UITableViewCell
            var reportNameLabel = UILabel(frame: CGRectMake(20, 10, 60, 30))
            var textField = UITextField(frame: CGRectMake(reportNameLabel.bounds.origin.x + reportNameLabel.bounds.width + 15, 10, UIScreen.mainScreen().bounds.width - reportNameLabel.bounds.width - 30, reportNameLabel.bounds.height))
            reportNameLabel.text = (clinicReportFormatList[indexPath.row] as! NSDictionary).objectForKey("clinicItem") as! String
            reportNameLabel.textColor = mainColor
            textField.layer.borderColor = mainColor.CGColor
            textField.layer.borderWidth = 1.0
            textField.layer.cornerRadius = 5.0
            cell.addSubview(reportNameLabel)
            cell.addSubview(textField)
        }
        if indexPath.section == 1 {
            cell = tableView.dequeueReusableCellWithIdentifier("symptonCell", forIndexPath: indexPath) as! UITableViewCell
            symptonContainerView = UIView(frame: CGRectMake(10, 30, UIScreen.mainScreen().bounds.width - 20, 70))
            symptonContainerView.backgroundColor = sectionHeaderColor
            var symptonTitleLabel = UILabel(frame: CGRectMake(20, 5, UIScreen.mainScreen().bounds.width - 40, 20))
            symptonTitleLabel.text = "请选择出现的副作用"
            symptonTitleLabel.font = UIFont(name: fontStr, size: 12.0)
            symptonTitleLabel.textColor = UIColor.grayColor()
            cell.addSubview(symptonTitleLabel)
            var index = 0
            for index = 0; index < patientStatusFormatList.count; index++ {
                var labelWidth: CGFloat = CGFloat(symptonContainerView.frame.width - 5)/5 - 5
                var labelHeight: CGFloat = 30
                var coordinateX:CGFloat = 5.0 + (labelWidth+4)*CGFloat(index%5)
                var coordinateY = CGFloat()
                if index<5{
                    coordinateY = 5
                }else{
                    coordinateY = 38
                }
                var statusBtn = UIButton(frame: CGRectMake(coordinateX, coordinateY, labelWidth, labelHeight))
                statusBtn.titleLabel!.font = UIFont(name: fontStr, size: 13.0)
                statusBtn.addTarget(self, action: "selectSymptom:", forControlEvents: UIControlEvents.TouchUpInside)
                publicService.formatButton(statusBtn, title: (patientStatusFormatList[index] as! NSDictionary).objectForKey("statusName") as! String)
                symptonContainerView.addSubview(statusBtn)
            }
            cell.addSubview(symptonContainerView)
        }
        if indexPath.section == 2 {
            cell = tableView.dequeueReusableCellWithIdentifier("textInputCell", forIndexPath: indexPath) as! UITableViewCell
            textView.frame = CGRectMake(10, 5, cell.frame.width - 20, cell.frame.height - 15)
            textView.layer.borderWidth = 1.0
            textView.layer.borderColor = mainColor.CGColor
            textView.layer.cornerRadius = 5
            cell.addSubview(textView)
        }
        if indexPath.section == 4 {
            cell = tableView.dequeueReusableCellWithIdentifier("imageCell", forIndexPath: indexPath) as! UITableViewCell
            var addImageButton = UIButton(frame: CGRectMake(10, 4, 30, 30))
            publicService.formatButton(addImageButton, title: "img")
            cell.addSubview(addImageButton)
        }
        if indexPath.section == 5 {
            cell = tableView.dequeueReusableCellWithIdentifier("submitButtonCell", forIndexPath: indexPath) as! UITableViewCell
            var submitButtonWidth = (cell.frame.width - 90)/2
            var shareToFriendButton = UIButton(frame: CGRectMake(20, 10, UIScreen.mainScreen().bounds.width/2 - 30, 30))
            var saveToMyselfButton = UIButton(frame: CGRectMake(shareToFriendButton.frame.width + 40, 10, shareToFriendButton.frame.width, 30))
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
        }
        return cell
    }
    
    func submitStatus(isPublic: Int){
        
        for symptonButton in symptonContainerView.subviews {
            if symptonButton is UIButton && symptonButton.backgroundColor == mainColor{
                patientStatusDetail += ((symptonButton as! UIButton).titleLabel!).text! + "*"
            }
        }
        patientStatusDetail += "**" + textView.text
        var patientStatus = NSMutableDictionary()
        patientStatus.setValue(patientStatusDetail, forKey: "statusDesc")
        patientStatus.setValue(isPublic, forKey: "isPosted")
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
                if clinicItemView is UITextField {
                    clinicItem.setObject((clinicItemView as! UITextField).text, forKey: "clinicItemDesc")
                }
            }
            clinicItemList.addObject(clinicItem)
        }
        
        for clinicItem in clinicItemList{
            if ((clinicItem as! NSDictionary).objectForKey("clinicItemDesc") as! NSString).length > 0{
                clinicReportDetail += ((clinicItem as! NSDictionary).objectForKey("clinicItemName") as! String) + "*" + ((clinicItem as! NSDictionary).objectForKey("clinicItemDesc") as! String) + "**"
            }
        }
        
        var clinicReport = NSMutableDictionary()
        clinicReport.setValue(clinicReportDetail, forKey: "clinicReport")
        clinicReport.setValue(isPublic, forKey: "isPosted")
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
        case 0: rowHeight = 70
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

}
