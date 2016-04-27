//
//  UpdateTreatmentTableViewController.swift
//  CancerSN
//
//  Created by lily on 10/11/15.
//  Copyright (c) 2015 lily. All rights reserved.
//

import UIKit
import CoreData

class UpdateTreatmentTableViewController: UITableViewController, UIPopoverPresentationControllerDelegate, UITextViewDelegate, UITextFieldDelegate {
    //context For LocalDB
    var context:NSManagedObjectContext?
    var setUserProfileTimeStamp = "setUserProfileTimeStamp"
    
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
    
    var isSelectedDate: Bool = false
    
    let transparentView = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let appDel:AppDelegate = (UIApplication.sharedApplication().delegate as! AppDelegate)
        context = appDel.managedObjectContext!
        if treatmentList.count == 0 {
            HudProgressManager.sharedInstance.showOnlyTextHudProgress(self, title: "您目前没有添加任何治疗方案")
        }
        else{
            for treatment in treatmentList{
                let treatmentLabel = UILabel(frame: CGRectMake(marginWidth, marginWidth + dateLabelHeight + marginWidth, UIScreen.mainScreen().bounds.width - marginWidth * 2, 60))
                treatmentLabel.text = (treatment as! TreatmentObj).treatmentName
                treatmentLabel.font = UIFont(name: fontStr, size: 13.0)
                treatmentLabel.sizeToFit()
                let dosageLabel = UILabel(frame: CGRectMake(marginWidth, marginWidth*3 + dateLabelHeight + treatmentLabel.frame.height, UIScreen.mainScreen().bounds.width - marginWidth * 2, 100))
                dosageLabel.text = (treatment as! TreatmentObj).dosage
                dosageLabel.font = UIFont(name: fontStr, size: 12.0)
                dosageLabel.sizeToFit()
                heightForRowForTreatmentList.addObject(treatmentLabel.frame.height + dosageLabel.frame.height)
                isEditForRow.addObject(0)
            }
        }
        //设置透明层
        transparentView.frame = CGRECT(0, 0, UIScreen.mainScreen().bounds.width, UIScreen.mainScreen().bounds.height)
        transparentView.backgroundColor = UIColor.lightGrayColor()
        transparentView.alpha = 0.6
        
        self.transparentView.userInteractionEnabled = true
        let tapTransparentView = UITapGestureRecognizer(target: self, action: #selector(self.dateCancel))
        self.transparentView.addGestureRecognizer(tapTransparentView)
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
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return treatmentList.count
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("treatmentIdentifier", forIndexPath: indexPath)
        let beginDateLabel = UILabel(frame: CGRectMake(marginWidth, marginWidth, dateLabelWidth, dateLabelHeight))
        let beginDateButton = UIButton(frame: CGRectMake(marginWidth*2+dateLabelWidth, marginWidth, dateButtonWidth, dateLabelHeight))
        beginDateButton.addTarget(self, action: #selector(UpdateTreatmentTableViewController.selectDate(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        let endDateLabel = UILabel(frame: CGRectMake(cell.frame.width - marginWidth*2 - dateLabelWidth - dateButtonWidth, marginWidth, dateLabelWidth, dateLabelHeight))
        let endDateButton = UIButton(frame: CGRectMake(cell.frame.width - marginWidth - dateButtonWidth, marginWidth, dateButtonWidth, dateLabelHeight))
        endDateButton.addTarget(self, action: #selector(UpdateTreatmentTableViewController.selectDate(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        beginDateLabel.text = "开始时间"
        beginDateLabel.textColor = UIColor.grayColor()
        beginDateLabel.font = UIFont(name: fontStr, size: 12.0)
        endDateLabel.text = "结束时间"
        endDateLabel.textColor = UIColor.grayColor()
        endDateLabel.font = UIFont(name: fontStr, size: 12.0)
        
        let dateFormatter = NSDateFormatter()
        let beginDate = NSDate(timeIntervalSince1970: ((treatmentList[indexPath.row] as! TreatmentObj).beginDate)/1000 as NSTimeInterval)
        let endDate = NSDate(timeIntervalSince1970: ((treatmentList[indexPath.row] as! TreatmentObj).endDate)/1000 as NSTimeInterval)
        dateFormatter.dateFormat = "yyyy-MM-dd" // superset of OP's format
        let beginDateStr = dateFormatter.stringFromDate(beginDate)
        var endDateStr = String()
        endDateStr = dateFormatter.stringFromDate(endDate)
        formatUpdateDateButton(beginDateButton, title: beginDateStr)
        formatUpdateDateButton(endDateButton, title: endDateStr)
        let treatmentNameTextField = UITextField(frame: CGRectMake(marginWidth, marginWidth + dateLabelHeight + marginWidth, cell.frame.width - marginWidth * 2, treatmentNameTextFieldHeight))
        treatmentNameTextField.text = (treatmentList[indexPath.row] as! TreatmentObj).treatmentName
        let dosageTextView = UITextView(frame: CGRectMake(marginWidth, marginWidth + dateLabelHeight + marginWidth + treatmentNameTextFieldHeight + marginWidth, cell.frame.width - marginWidth * 2, dosageTextViewHeight))
        dosageTextView.text = (treatmentList[indexPath.row] as! TreatmentObj).dosage
        treatmentNameTextField.layer.borderColor = UIColor.lightGrayColor().CGColor
        treatmentNameTextField.layer.borderWidth = 1.5
        treatmentNameTextField.layer.cornerRadius = 2
        treatmentNameTextField.font = UIFont(name: fontStr, size: 14.0)
        treatmentNameTextField.delegate = self
        treatmentNameTextField.returnKeyType = UIReturnKeyType.Done
        
        dosageTextView.font = UIFont(name: fontStr, size: 12.0)
        dosageTextView.layer.borderColor = UIColor.lightGrayColor().CGColor
        dosageTextView.layer.borderWidth = 1.5
        dosageTextView.layer.cornerRadius = 2
        dosageTextView.delegate = self
        dosageTextView.returnKeyType = UIReturnKeyType.Done
        
        let treatmentLabel = UILabel(frame: CGRectMake(marginWidth, marginWidth + dateLabelHeight + marginWidth, cell.frame.width - marginWidth * 2, 60))
        treatmentLabel.textColor = headerColor
        treatmentLabel.text = (treatmentList[indexPath.row] as! TreatmentObj).treatmentName
        treatmentLabel.font = UIFont(name: fontStr, size: 13.0)
        treatmentLabel.sizeToFit()
        let dosageLabel = UILabel(frame: CGRectMake(marginWidth, marginWidth*3 + dateLabelHeight + treatmentLabel.frame.height, cell.frame.width - marginWidth * 2, 100))
        dosageLabel.textColor = headerColor
        dosageLabel.text = (treatmentList[indexPath.row] as! TreatmentObj).dosage
        dosageLabel.font = UIFont(name: fontStr, size: 12.0)
        dosageLabel.sizeToFit()
        
        let editButton = UIButton(frame: CGRectMake(cell.frame.width - marginWidth - editButtonWidth, marginWidth * 3 + treatmentLabel.frame.height + dosageLabel.frame.height + dateLabelHeight, editButtonWidth, 25))
        let deleteButton = UIButton(frame: CGRectMake(cell.frame.width - marginWidth*2 - editButtonWidth*2, marginWidth * 3 + treatmentLabel.frame.height + dosageLabel.frame.height + dateLabelHeight, editButtonWidth, 25))
        
        formatButton(editButton, title: "编辑")
        formatButton(deleteButton, title: "删除")
        editButton.addTarget(self, action: #selector(UpdateTreatmentTableViewController.editItem(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        deleteButton.addTarget(self, action: #selector(UpdateTreatmentTableViewController.deleteItem(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        
        let saveButton = UIButton(frame: CGRectMake(cell.frame.width - marginWidth - editButtonWidth, marginWidth * 4 + treatmentNameTextFieldHeight + dosageTextViewHeight + dateLabelHeight, editButtonWidth, 25))
        saveButton.layer.borderColor = headerColor.CGColor
        saveButton.layer.borderWidth = 1.0
        saveButton.layer.cornerRadius = 2
        saveButton.layer.masksToBounds = true
        saveButton.setTitle("保存", forState: UIControlState.Normal)
        saveButton.setTitleColor(headerColor, forState: UIControlState.Normal)
        saveButton.titleLabel?.font = UIFont(name: fontStr, size: 13.0)
        saveButton.addTarget(self, action: #selector(UpdateTreatmentTableViewController.saveItem(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        let seperateLine = UIView()
        if (isEditForRow[indexPath.row] as! Int) == 1{
            cell.removeAllSubviews()
            cell.addSubview(treatmentNameTextField)
            cell.addSubview(dosageTextView)
            cell.addSubview(saveButton)
            heightForRowForTreatmentList[indexPath.row] = 110
            seperateLine.frame = CGRect(x: 0, y: 110 + 70 - 1, width: cell.frame.width, height: 1)

        }else{
            cell.removeAllSubviews()
            cell.addSubview(treatmentLabel)
            cell.addSubview(dosageLabel)
            cell.addSubview(editButton)
            cell.addSubview(deleteButton)
            heightForRowForTreatmentList[indexPath.row] = treatmentLabel.frame.height + dosageLabel.frame.height
            seperateLine.frame = CGRect(x: 0, y: treatmentLabel.frame.height + dosageLabel.frame.height + 70 - 1, width: cell.frame.width, height: 1)

        }
        cell.addSubview(beginDateButton)
        cell.addSubview(endDateButton)
        cell.addSubview(beginDateLabel)
        cell.addSubview(endDateLabel)
        
        seperateLine.backgroundColor = seperateLineColor
        cell.addSubview(seperateLine)
        return cell
    }
    
    func formatButton(sender:UIButton, title:String){
        sender.layer.borderColor = headerColor.CGColor
        sender.layer.borderWidth = 1.0
        sender.layer.cornerRadius = 2
        sender.layer.masksToBounds = true
        sender.setTitle(title, forState: UIControlState.Normal)
        sender.setTitleColor(headerColor, forState: UIControlState.Normal)
        sender.titleLabel?.font = UIFont(name: fontStr, size: 13.0)
    }
    
    func editItem(sender:UIButton){
        //        CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tableView];
        //        NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonPosition];
        let buttonPositon = sender.convertPoint(CGPointZero, toView: self.tableView)
        let indexPath: NSIndexPath = self.tableView.indexPathForRowAtPoint(buttonPositon)!
        isEditForRow[indexPath.row] = 1
        self.tableView.reloadData()
    }
    
    func deleteTreatmentFromLocalDB(treamentID: Int) {
        let predicate = NSPredicate(format: "treatmentID == %d", treamentID)
        
        let fetchRequest = NSFetchRequest(entityName: tableTreatment)
        fetchRequest.predicate = predicate
        
        do {
            let fetchedEntities: NSArray = try self.context!.executeFetchRequest(fetchRequest) as NSArray
            if fetchedEntities.count > 0{
                let entityToDelete = fetchedEntities[0]
                self.context!.deleteObject(entityToDelete as! NSManagedObject)
            }
        } catch {
            // Do something in response to error condition
        }
        
        do {
            try self.context!.save()
        } catch {
            // Do something in response to error condition
        }
    }
    
    func updateTreatmentInLocalDB(treatmentDic: NSDictionary) {
        let predicate = NSPredicate(format: "treatmentID == %d", treatmentDic.objectForKey("treatmentID") as! Int)
        
        let fetchRequest = NSFetchRequest(entityName: tableTreatment)
        fetchRequest.predicate = predicate
        
        do {
            let fetchedEntities: NSArray = try self.context!.executeFetchRequest(fetchRequest) as NSArray
            if fetchedEntities.count > 0{
                let entityToUpdated = fetchedEntities[0]
                entityToUpdated.setValue(treatmentDic.objectForKey("beginDate") as! Double, forKey: "beginDate")
                entityToUpdated.setValue(treatmentDic.objectForKey("endDate") as! Double, forKey: "endDate")
                entityToUpdated.setValue(treatmentDic.objectForKey("treatmentName") as! String, forKey: "treatmentName")
                entityToUpdated.setValue(treatmentDic.objectForKey("dosage") as! String, forKey: "dosage")
            }
        } catch {
            // Do something in response to error condition
        }
        
        do {
            try self.context!.save()
        } catch {
            // Do something in response to error condition
        }
    }
    
    func deleteItem(sender: UIButton){
        let buttonPositon = sender.convertPoint(CGPointZero, toView: self.tableView)
        let indexPath: NSIndexPath = self.tableView.indexPathForRowAtPoint(buttonPositon)!
        let deletedTreatmentObj = treatmentList.objectAtIndex(indexPath.row) as! TreatmentObj
        let deletedTreatment: NSDictionary = NSDictionary(objects: [deletedTreatmentObj.treatmentID, deletedTreatmentObj.username], forKeys: ["treatmentID", "username"])
        haalthyService.deleteTreatment(deletedTreatment)
        treatmentList.removeObjectAtIndex(indexPath.row)
        deleteTreatmentFromLocalDB(deletedTreatmentObj.treatmentID)
        self.tableView.reloadData()
    }
    
    func saveItem(sender:UIButton){
        let buttonPositon = sender.convertPoint(CGPointZero, toView: self.tableView)
        let indexPath: NSIndexPath = self.tableView.indexPathForRowAtPoint(buttonPositon)!
        isEditForRow[indexPath.row] = 0
        let updateTreatmentObj = treatmentList[indexPath.row] as! TreatmentObj
        let updateTreatment = NSMutableDictionary()
        updateTreatment.setObject(updateTreatmentObj.treatmentID, forKey: "treatmentID")
        updateTreatment.setObject(updateTreatmentObj.username, forKey: "username")
        updateTreatment.setObject(updateTreatmentObj.beginDate, forKey: "beginDate")
        updateTreatment.setObject(updateTreatmentObj.endDate, forKey: "endDate")

        let cell = self.tableView.cellForRowAtIndexPath(indexPath)
        let views = cell?.subviews as! NSArray
        for view in views{
            if view is UITextField{
                updateTreatmentObj.treatmentName = (view as! UITextField).text!
                updateTreatment.setObject((view as! UITextField).text!, forKey: "treatmentName")
            }
            if view is UITextView{
                updateTreatmentObj.dosage = (view as! UITextView).text
                updateTreatment.setObject((view as! UITextView).text, forKey: "dosage")
            }
        }
        haalthyService.updateTreatment(updateTreatment)
        updateTreatmentInLocalDB(updateTreatment)
        self.tableView.reloadData()
    }
    
    func selectDate(sender:UIButton){
        if isSelectedDate == false {
            self.view.addSubview(transparentView)
            let datePickerHeight:CGFloat = 200
            let confirmButtonWidth:CGFloat = 100
            let confirmButtonHeight:CGFloat = 30
            datePickerContainerView = UIView(frame: CGRectMake(0, UIScreen.mainScreen().bounds.height - datePickerHeight - 30 - 80, UIScreen.mainScreen().bounds.width, datePickerHeight + 30))
            datePickerContainerView!.backgroundColor = UIColor.whiteColor()
            self.datePicker = UIDatePicker(frame: CGRectMake(0 , 30, UIScreen.mainScreen().bounds.width, datePickerHeight))
            self.datePicker.datePickerMode = UIDatePickerMode.Date
            let confirmButton = UIButton(frame: CGRectMake(UIScreen.mainScreen().bounds.width - confirmButtonWidth, 0, confirmButtonWidth, confirmButtonHeight))
            confirmButton.setTitle("确定", forState: UIControlState.Normal)
            confirmButton.setTitleColor(headerColor, forState: UIControlState.Normal)
            confirmButton.addTarget(self, action: #selector(UpdateTreatmentTableViewController.dateChanged), forControlEvents: UIControlEvents.TouchUpInside)
            let cancelButton = UIButton(frame: CGRect(x: 0, y: 0, width: confirmButtonWidth, height: confirmButtonHeight))
            cancelButton.setTitleColor(headerColor, forState: UIControlState.Normal)
            cancelButton.addTarget(self, action: #selector(UpdateTreatmentTableViewController.dateCancel), forControlEvents: UIControlEvents.TouchUpInside)
            datePickerContainerView!.addSubview(self.datePicker)
            datePickerContainerView?.addSubview(confirmButton)
            self.view.addSubview(datePickerContainerView!)
            editDateButton = sender
            isSelectedDate = true
        }else{
            isSelectedDate = false
            self.datePickerContainerView?.removeFromSuperview()
        }
    }
    
    func dateCancel(){
        transparentView.removeFromSuperview()
        isSelectedDate = false
        self.datePickerContainerView?.removeFromSuperview()
    }
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return .None
    }
    func dateChanged(){
        transparentView.removeFromSuperview()
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd" // superset of OP's format
        let selectDateStr = dateFormatter.stringFromDate(self.datePicker.date)
        let buttonPositon = editDateButton!.convertPoint(CGPointZero, toView: self.tableView)
        let indexPath: NSIndexPath = self.tableView.indexPathForRowAtPoint(buttonPositon)!
        if buttonPositon.x < 100 {
            (treatmentList[indexPath.row] as! TreatmentObj).beginDate = self.datePicker.date.timeIntervalSince1970 * 1000
        }else{
            (treatmentList[indexPath.row] as! TreatmentObj).beginDate = self.datePicker.date.timeIntervalSince1970 * 1000
            
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
        sender.setAttributedTitle(underlineAttributedString, forState: UIControlState.Normal)
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return (heightForRowForTreatmentList[indexPath.row] as! CGFloat) + 70
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool{
        textField.resignFirstResponder()
        return true
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if text == "\n"{
            textView.resignFirstResponder()
            return false
        }
        return true
    }
}
