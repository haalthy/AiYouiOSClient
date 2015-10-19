//
//  UpdateTreatmentTableViewController.swift
//  CancerSN
//
//  Created by lily on 10/11/15.
//  Copyright (c) 2015 lily. All rights reserved.
//

import UIKit

class UpdateTreatmentTableViewController: UITableViewController, UIPopoverPresentationControllerDelegate {
    
    var treatmentList = NSMutableArray()
    let dateLabelWidth:CGFloat = 50.0
    let dateButtonWidth: CGFloat = 70.0
    let dateLabelHeight:CGFloat = 25.0
    let marginWidth:CGFloat = 5.0
    let treatmentNameTextFieldHeight: CGFloat = 30.0
    let dosageTextViewHeight: CGFloat = 70
    var heightForRowForTreatmentList = NSMutableArray()
    var editButtonWidth:CGFloat = 60
    var isEditForRow = NSMutableArray()
    var haalthyService = HaalthyService()
    var datePicker = UIDatePicker()
    var datePickerContainerView:UIView?
    var editDateItem = NSMutableDictionary()
    var editDateButton:UIButton?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        for treatment in treatmentList{
            var treatmentLabel = UILabel(frame: CGRectMake(marginWidth, marginWidth + dateLabelHeight + marginWidth, UIScreen.mainScreen().bounds.width - marginWidth * 2, 60))
            treatmentLabel.text = (treatment as! NSDictionary).objectForKey("treatmentName") as! String
            treatmentLabel.font = UIFont(name: fontStr, size: 13.0)
            treatmentLabel.sizeToFit()
            var dosageLabel = UILabel(frame: CGRectMake(marginWidth, marginWidth*3 + dateLabelHeight + treatmentLabel.frame.height, UIScreen.mainScreen().bounds.width - marginWidth * 2, 100))
            dosageLabel.text = (treatment as! NSDictionary).objectForKey("dosage") as! String
            dosageLabel.font = UIFont(name: fontStr, size: 12.0)
            dosageLabel.sizeToFit()
            heightForRowForTreatmentList.addObject(treatmentLabel.frame.height + dosageLabel.frame.height)
            isEditForRow.addObject(0)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
    
    override func viewWillAppear(animated: Bool) {
        self.tabBarController?.tabBar.hidden = true
    }
    override func viewWillDisappear(animated: Bool) {
        self.tabBarController?.tabBar.hidden = false

    }
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 2
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        if section == 0{
            return 1
        }else{
            return treatmentList.count
        }
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0{
            let cell = tableView.dequeueReusableCellWithIdentifier("headerIdentifier", forIndexPath: indexPath) as! UITableViewCell
            return cell

        }else{
            let cell = tableView.dequeueReusableCellWithIdentifier("treatmentIdentifier", forIndexPath: indexPath) as! UITableViewCell
            var beginDateLabel = UILabel(frame: CGRectMake(marginWidth, marginWidth, dateLabelWidth, dateLabelHeight))
            var beginDateButton = UIButton(frame: CGRectMake(marginWidth*2+dateLabelWidth, marginWidth, dateButtonWidth, dateLabelHeight))
            beginDateButton.addTarget(self, action: "selectDate:", forControlEvents: UIControlEvents.TouchUpInside)
            var endDateLabel = UILabel(frame: CGRectMake(cell.frame.width - marginWidth*2 - dateLabelWidth - dateButtonWidth, marginWidth, dateLabelWidth, dateLabelHeight))
            var endDateButton = UIButton(frame: CGRectMake(cell.frame.width - marginWidth - dateButtonWidth, marginWidth, dateButtonWidth, dateLabelHeight))
            endDateButton.addTarget(self, action: "selectDate:", forControlEvents: UIControlEvents.TouchUpInside)
            beginDateLabel.text = "开始时间"
            beginDateLabel.textColor = UIColor.grayColor()
            beginDateLabel.font = UIFont(name: fontStr, size: 12.0)
            endDateLabel.text = "结束时间"
            endDateLabel.textColor = UIColor.grayColor()
            endDateLabel.font = UIFont(name: fontStr, size: 12.0)
            
            var dateFormatter = NSDateFormatter()
            var beginDate = NSDate(timeIntervalSince1970: ((treatmentList[indexPath.row] as! NSDictionary).objectForKey("beginDate") as! Double)/1000 as NSTimeInterval)
            var endDate = NSDate(timeIntervalSince1970: ((treatmentList[indexPath.row] as! NSDictionary).objectForKey("endDate") as! Double)/1000 as NSTimeInterval)
            dateFormatter.dateFormat = "yyyy-MM-dd" // superset of OP's format
            var beginDateStr = dateFormatter.stringFromDate(beginDate)
            var endDateStr = String()
            endDateStr = dateFormatter.stringFromDate(endDate)
            formatUpdateDateButton(beginDateButton, title: beginDateStr)
            formatUpdateDateButton(endDateButton, title: endDateStr)
            var treatmentNameTextField = UITextField(frame: CGRectMake(marginWidth, marginWidth + dateLabelHeight + marginWidth, cell.frame.width - marginWidth * 2, treatmentNameTextFieldHeight))
            treatmentNameTextField.text = (treatmentList[indexPath.row] as! NSDictionary).objectForKey("treatmentName") as! String
            var dosageTextView = UITextView(frame: CGRectMake(marginWidth, marginWidth + dateLabelHeight + marginWidth + treatmentNameTextFieldHeight + marginWidth, cell.frame.width - marginWidth * 2, dosageTextViewHeight))
            dosageTextView.text = (treatmentList[indexPath.row] as! NSDictionary).objectForKey("dosage") as! String
            treatmentNameTextField.layer.borderColor = UIColor.lightGrayColor().CGColor
            treatmentNameTextField.layer.borderWidth = 1.5
            treatmentNameTextField.layer.cornerRadius = 5
            treatmentNameTextField.font = UIFont(name: fontStr, size: 14.0)
            dosageTextView.font = UIFont(name: fontStr, size: 12.0)
            dosageTextView.layer.borderColor = UIColor.lightGrayColor().CGColor
            dosageTextView.layer.borderWidth = 1.5
            dosageTextView.layer.cornerRadius = 5
            
            var treatmentLabel = UILabel(frame: CGRectMake(marginWidth, marginWidth + dateLabelHeight + marginWidth, cell.frame.width - marginWidth * 2, 60))
            treatmentLabel.textColor = mainColor
            treatmentLabel.text = (treatmentList[indexPath.row] as! NSDictionary).objectForKey("treatmentName") as! String
            treatmentLabel.font = UIFont(name: fontStr, size: 13.0)
            treatmentLabel.sizeToFit()
            var dosageLabel = UILabel(frame: CGRectMake(marginWidth, marginWidth*3 + dateLabelHeight + treatmentLabel.frame.height, cell.frame.width - marginWidth * 2, 100))
            dosageLabel.textColor = mainColor
            dosageLabel.text = (treatmentList[indexPath.row] as! NSDictionary).objectForKey("dosage") as! String
            dosageLabel.font = UIFont(name: fontStr, size: 12.0)
            dosageLabel.sizeToFit()
            
            var editButton = UIButton(frame: CGRectMake(cell.frame.width - marginWidth - editButtonWidth, marginWidth * 3 + treatmentLabel.frame.height + dosageLabel.frame.height + dateLabelHeight, editButtonWidth, 25))
            var deleteButton = UIButton(frame: CGRectMake(cell.frame.width - marginWidth*2 - editButtonWidth*2, marginWidth * 3 + treatmentLabel.frame.height + dosageLabel.frame.height + dateLabelHeight, editButtonWidth, 25))

//            editButton.layer.borderColor = mainColor.CGColor
//            editButton.layer.borderWidth = 1.0
//            editButton.layer.cornerRadius = 5
//            editButton.layer.masksToBounds = true
//            editButton.setTitle("编辑", forState: UIControlState.Normal)
//            editButton.setTitleColor(mainColor, forState: UIControlState.Normal)
//            editButton.titleLabel?.font = UIFont(name: fontStr, size: 13.0)
            formatButton(editButton, title: "编辑")
            formatButton(deleteButton, title: "删除")
            editButton.addTarget(self, action: "editItem:", forControlEvents: UIControlEvents.TouchUpInside)
            deleteButton.addTarget(self, action: "deleteItem:", forControlEvents: UIControlEvents.TouchUpInside)

            var saveButton = UIButton(frame: CGRectMake(cell.frame.width - marginWidth - editButtonWidth, marginWidth * 4 + treatmentNameTextFieldHeight + dosageTextViewHeight + dateLabelHeight, editButtonWidth, 25))
            saveButton.layer.borderColor = mainColor.CGColor
            saveButton.layer.borderWidth = 1.0
            saveButton.layer.cornerRadius = 5
            saveButton.layer.masksToBounds = true
            saveButton.setTitle("保存", forState: UIControlState.Normal)
            saveButton.setTitleColor(mainColor, forState: UIControlState.Normal)
            saveButton.titleLabel?.font = UIFont(name: fontStr, size: 13.0)
            saveButton.addTarget(self, action: "saveItem:", forControlEvents: UIControlEvents.TouchUpInside)
            
            if (isEditForRow[indexPath.row] as! Int) == 1{
                cell.removeAllSubviews()
                cell.addSubview(treatmentNameTextField)
                cell.addSubview(dosageTextView)
                cell.addSubview(saveButton)
                heightForRowForTreatmentList[indexPath.row] = 100
            }else{
                cell.removeAllSubviews()
                cell.addSubview(treatmentLabel)
                cell.addSubview(dosageLabel)
                cell.addSubview(editButton)
                cell.addSubview(deleteButton)
                heightForRowForTreatmentList[indexPath.row] = treatmentLabel.frame.height + dosageLabel.frame.height
            }
            cell.addSubview(beginDateButton)
            cell.addSubview(endDateButton)
            cell.addSubview(beginDateLabel)
            cell.addSubview(endDateLabel)
            return cell
        }
    }
    
    func formatButton(sender:UIButton, title:String){
        sender.layer.borderColor = mainColor.CGColor
        sender.layer.borderWidth = 1.0
        sender.layer.cornerRadius = 5
        sender.layer.masksToBounds = true
        sender.setTitle(title, forState: UIControlState.Normal)
        sender.setTitleColor(mainColor, forState: UIControlState.Normal)
        sender.titleLabel?.font = UIFont(name: fontStr, size: 13.0)
    }
    
    func editItem(sender:UIButton){
//        CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tableView];
//        NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonPosition];
        var buttonPositon = sender.convertPoint(CGPointZero, toView: self.tableView)
        var indexPath: NSIndexPath = self.tableView.indexPathForRowAtPoint(buttonPositon)!
        isEditForRow[indexPath.row] = 1
        self.tableView.reloadData()
    }
    
    func deleteItem(sender: UIButton){
        var buttonPositon = sender.convertPoint(CGPointZero, toView: self.tableView)
        var indexPath: NSIndexPath = self.tableView.indexPathForRowAtPoint(buttonPositon)!
        haalthyService.deleteTreatment(treatmentList[indexPath.row] as! NSDictionary)
        treatmentList.removeObjectAtIndex(indexPath.row)
        self.tableView.reloadData()
    }
    
    func saveItem(sender:UIButton){
        var buttonPositon = sender.convertPoint(CGPointZero, toView: self.tableView)
        var indexPath: NSIndexPath = self.tableView.indexPathForRowAtPoint(buttonPositon)!
        isEditForRow[indexPath.row] = 0
        var updateTreatment = treatmentList[indexPath.row] as! NSMutableDictionary
        var cell = self.tableView.cellForRowAtIndexPath(indexPath)
        var views = cell?.subviews as! NSArray
        for view in views{
            if view is UITextField{
                
                println("疗程名称"+(view as! UITextField).text)
                updateTreatment.setObject((view as! UITextField).text, forKey: "treatmentName")
            }
            if view is UITextView{
                println("剂量"+(view as! UITextView).text)
                updateTreatment.setObject((view as! UITextView).text, forKey: "dosage")
            }
//            if (view is UIButton) && (view.frame.origin.x < 100) && (view.frame.origin.y < 10){
//                println("开始时间" + ((view as! UIButton).titleLabel?.text!)!)
//                updateTreatment.setObject(((view as! UIButton).titleLabel?.text!)!, forKey: "beginDate")
//
//            }
//            if (view is UIButton) && (view.frame.origin.x > 100) && (view.frame.origin.y < 10){
//                println("结束时间" + ((view as! UIButton).titleLabel?.text!)!)
//                updateTreatment.setObject(((view as! UIButton).titleLabel?.text!)!, forKey: "endDate")
//            }
        }
        haalthyService.updateTreatment(updateTreatment)
        self.tableView.reloadData()
    }
    
    func selectDate(sender:UIButton){
//        self.datePicker = [[UIDatePicker alloc] initWithFrame:CGRectZero];
//        [self.datePicker setDatePickerMode:UIDatePickerModeDate];
//        [self.datePicker addTarget:self action:@selector(onDatePickerValueChanged:) forControlEvents:UIControlEventValueChanged];
        let datePickerHeight:CGFloat = 200
        let confirmButtonWidth:CGFloat = 100
        let confirmButtonHeight:CGFloat = 30
        datePickerContainerView = UIView(frame: CGRectMake(0, UIScreen.mainScreen().bounds.height - datePickerHeight - 30 - 80, UIScreen.mainScreen().bounds.width, datePickerHeight + 30))
        datePickerContainerView!.backgroundColor = UIColor.whiteColor()
        self.datePicker = UIDatePicker(frame: CGRectMake(0 , 30, UIScreen.mainScreen().bounds.width, datePickerHeight))
        self.datePicker.datePickerMode = UIDatePickerMode.Date
//        self.datePicker.addTarget(self, action: "dateChanged:", forControlEvents: UIControlEvents.ValueChanged)
        var confirmButton = UIButton(frame: CGRectMake(UIScreen.mainScreen().bounds.width - confirmButtonWidth, 0, confirmButtonWidth, confirmButtonHeight))
        confirmButton.setTitle("确定", forState: UIControlState.Normal)
        confirmButton.setTitleColor(mainColor, forState: UIControlState.Normal)
        confirmButton.addTarget(self, action: "dateChanged", forControlEvents: UIControlEvents.TouchUpInside)
        datePickerContainerView!.addSubview(self.datePicker)
        datePickerContainerView?.addSubview(confirmButton)
        self.view.addSubview(datePickerContainerView!)
//        editDateItem.objectForKey(sender.)
//        self.performSegueWithIdentifier("showDatePickerIdentifier", sender: self)
        editDateButton = sender
    }
    
//    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//        if segue.identifier == "showDatePickerIdentifier"{
//            var vc = segue.destinationViewController as! UIViewController
//            var controller = vc.popoverPresentationController
//            if controller != nil{
//                controller?.delegate = self
//                controller?.permittedArrowDirections = nil
//            }
//        }
//    }
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return .None
    }
    func dateChanged(){
        var dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd" // superset of OP's format
        let selectDateStr = dateFormatter.stringFromDate(self.datePicker.date)
        var buttonPositon = editDateButton!.convertPoint(CGPointZero, toView: self.tableView)
        var indexPath: NSIndexPath = self.tableView.indexPathForRowAtPoint(buttonPositon)!
        if buttonPositon.x < 100 {
            (treatmentList[indexPath.row] as! NSMutableDictionary).setObject(self.datePicker.date.timeIntervalSince1970 * 1000, forKey: "beginDate")
        }else{
            (treatmentList[indexPath.row] as! NSMutableDictionary).setObject(self.datePicker.date.timeIntervalSince1970 * 1000, forKey: "endDate")

        }
        editDateButton?.titleLabel?.text = selectDateStr
        self.datePickerContainerView?.removeFromSuperview()
    }
    
    func formatUpdateDateButton(sender: UIButton, title: String){
        sender.titleLabel?.font = UIFont(name: fontStr, size: 12.0)
        sender.setTitleColor(UIColor.grayColor(), forState: UIControlState.Normal)
        sender.titleLabel?.textAlignment = NSTextAlignment.Center
        let underlineAttribute = [NSUnderlineStyleAttributeName: NSUnderlineStyle.StyleSingle.rawValue]
        let underlineAttributedString = NSAttributedString(string: title, attributes: underlineAttribute)
        //            clinicTrailButton.titleLabel?.attributedText = underlineAttributedString
        sender.setAttributedTitle(underlineAttributedString, forState: UIControlState.Normal)
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 0{
            return 44
        }else{
            return (heightForRowForTreatmentList[indexPath.row] as! CGFloat) + 70
        }
    }
}
