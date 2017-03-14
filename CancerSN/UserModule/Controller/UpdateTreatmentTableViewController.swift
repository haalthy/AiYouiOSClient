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
        let appDel:AppDelegate = (UIApplication.shared.delegate as! AppDelegate)
        context = appDel.managedObjectContext!
        if treatmentList.count == 0 {
            HudProgressManager.sharedInstance.showOnlyTextHudProgress(self, title: "您目前没有添加任何治疗方案")
        }
        else{
            for treatment in treatmentList{
                let treatmentLabel = UILabel(frame: CGRect(x: marginWidth, y: marginWidth + dateLabelHeight + marginWidth, width: UIScreen.main.bounds.width - marginWidth * 2, height: 60))
                treatmentLabel.text = (treatment as! TreatmentObj).treatmentName
                treatmentLabel.font = UIFont(name: fontStr, size: 13.0)
                treatmentLabel.sizeToFit()
                let dosageLabel = UILabel(frame: CGRect(x: marginWidth, y: marginWidth*3 + dateLabelHeight + treatmentLabel.frame.height, width: UIScreen.main.bounds.width - marginWidth * 2, height: 100))
                dosageLabel.text = (treatment as! TreatmentObj).dosage
                dosageLabel.font = UIFont(name: fontStr, size: 12.0)
                dosageLabel.sizeToFit()
                heightForRowForTreatmentList.add(treatmentLabel.frame.height + dosageLabel.frame.height)
                isEditForRow.add(0)
            }
        }
        //设置透明层
        transparentView.frame = CGRECT(0, 0, UIScreen.main.bounds.width, UIScreen.main.bounds.height)
        transparentView.backgroundColor = UIColor.lightGray
        transparentView.alpha = 0.6
        
        self.transparentView.isUserInteractionEnabled = true
        let tapTransparentView = UITapGestureRecognizer(target: self, action: #selector(self.dateCancel))
        self.transparentView.addGestureRecognizer(tapTransparentView)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = true
    }
    override func viewWillDisappear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
        
    }
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return treatmentList.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "treatmentIdentifier", for: indexPath)
        let beginDateLabel = UILabel(frame: CGRect(x: marginWidth, y: marginWidth, width: dateLabelWidth, height: dateLabelHeight))
        let beginDateButton = UIButton(frame: CGRect(x: marginWidth*2+dateLabelWidth, y: marginWidth, width: dateButtonWidth, height: dateLabelHeight))
        beginDateButton.addTarget(self, action: #selector(UpdateTreatmentTableViewController.selectDate(_:)), for: UIControlEvents.touchUpInside)
        let endDateLabel = UILabel(frame: CGRect(x: cell.frame.width - marginWidth*2 - dateLabelWidth - dateButtonWidth, y: marginWidth, width: dateLabelWidth, height: dateLabelHeight))
        let endDateButton = UIButton(frame: CGRect(x: cell.frame.width - marginWidth - dateButtonWidth, y: marginWidth, width: dateButtonWidth, height: dateLabelHeight))
        endDateButton.addTarget(self, action: #selector(UpdateTreatmentTableViewController.selectDate(_:)), for: UIControlEvents.touchUpInside)
        beginDateLabel.text = "开始时间"
        beginDateLabel.textColor = UIColor.gray
        beginDateLabel.font = UIFont(name: fontStr, size: 12.0)
        endDateLabel.text = "结束时间"
        endDateLabel.textColor = UIColor.gray
        endDateLabel.font = UIFont(name: fontStr, size: 12.0)
        
        let dateFormatter = DateFormatter()
        let beginDate = Foundation.Date(timeIntervalSince1970: ((treatmentList[indexPath.row] as! TreatmentObj).beginDate)/1000 as TimeInterval)
        let endDate = Foundation.Date(timeIntervalSince1970: ((treatmentList[indexPath.row] as! TreatmentObj).endDate)/1000 as TimeInterval)
        dateFormatter.dateFormat = "yyyy-MM-dd" // superset of OP's format
        let beginDateStr = dateFormatter.string(from: beginDate)
        var endDateStr = String()
        endDateStr = dateFormatter.string(from: endDate)
        formatUpdateDateButton(beginDateButton, title: beginDateStr)
        formatUpdateDateButton(endDateButton, title: endDateStr)
        let treatmentNameTextField = UITextField(frame: CGRect(x: marginWidth, y: marginWidth + dateLabelHeight + marginWidth, width: cell.frame.width - marginWidth * 2, height: treatmentNameTextFieldHeight))
        treatmentNameTextField.text = (treatmentList[indexPath.row] as! TreatmentObj).treatmentName
        let dosageTextView = UITextView(frame: CGRect(x: marginWidth, y: marginWidth + dateLabelHeight + marginWidth + treatmentNameTextFieldHeight + marginWidth, width: cell.frame.width - marginWidth * 2, height: dosageTextViewHeight))
        dosageTextView.text = (treatmentList[indexPath.row] as! TreatmentObj).dosage
        treatmentNameTextField.layer.borderColor = UIColor.lightGray.cgColor
        treatmentNameTextField.layer.borderWidth = 1.5
        treatmentNameTextField.layer.cornerRadius = 2
        treatmentNameTextField.font = UIFont(name: fontStr, size: 14.0)
        treatmentNameTextField.delegate = self
        treatmentNameTextField.returnKeyType = UIReturnKeyType.done
        
        dosageTextView.font = UIFont(name: fontStr, size: 12.0)
        dosageTextView.layer.borderColor = UIColor.lightGray.cgColor
        dosageTextView.layer.borderWidth = 1.5
        dosageTextView.layer.cornerRadius = 2
        dosageTextView.delegate = self
        dosageTextView.returnKeyType = UIReturnKeyType.done
        
        let treatmentLabel = UILabel(frame: CGRect(x: marginWidth, y: marginWidth + dateLabelHeight + marginWidth, width: cell.frame.width - marginWidth * 2, height: 60))
        treatmentLabel.textColor = headerColor
        treatmentLabel.text = (treatmentList[indexPath.row] as! TreatmentObj).treatmentName
        treatmentLabel.font = UIFont(name: fontStr, size: 13.0)
        treatmentLabel.sizeToFit()
        let dosageLabel = UILabel(frame: CGRect(x: marginWidth, y: marginWidth*3 + dateLabelHeight + treatmentLabel.frame.height, width: cell.frame.width - marginWidth * 2, height: 100))
        dosageLabel.textColor = headerColor
        dosageLabel.text = (treatmentList[indexPath.row] as! TreatmentObj).dosage
        dosageLabel.font = UIFont(name: fontStr, size: 12.0)
        dosageLabel.sizeToFit()
        
        let editButton = UIButton(frame: CGRect(x: cell.frame.width - marginWidth - editButtonWidth, y: marginWidth * 3 + treatmentLabel.frame.height + dosageLabel.frame.height + dateLabelHeight, width: editButtonWidth, height: 25))
        let deleteButton = UIButton(frame: CGRect(x: cell.frame.width - marginWidth*2 - editButtonWidth*2, y: marginWidth * 3 + treatmentLabel.frame.height + dosageLabel.frame.height + dateLabelHeight, width: editButtonWidth, height: 25))
        
        formatButton(editButton, title: "编辑")
        formatButton(deleteButton, title: "删除")
        editButton.addTarget(self, action: #selector(UpdateTreatmentTableViewController.editItem(_:)), for: UIControlEvents.touchUpInside)
        deleteButton.addTarget(self, action: #selector(UpdateTreatmentTableViewController.deleteItem(_:)), for: UIControlEvents.touchUpInside)
        
        let saveButton = UIButton(frame: CGRect(x: cell.frame.width - marginWidth - editButtonWidth, y: marginWidth * 4 + treatmentNameTextFieldHeight + dosageTextViewHeight + dateLabelHeight, width: editButtonWidth, height: 25))
        saveButton.layer.borderColor = headerColor.cgColor
        saveButton.layer.borderWidth = 1.0
        saveButton.layer.cornerRadius = 2
        saveButton.layer.masksToBounds = true
        saveButton.setTitle("保存", for: UIControlState())
        saveButton.setTitleColor(headerColor, for: UIControlState())
        saveButton.titleLabel?.font = UIFont(name: fontStr, size: 13.0)
        saveButton.addTarget(self, action: #selector(UpdateTreatmentTableViewController.saveItem(_:)), for: UIControlEvents.touchUpInside)
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
    
    func formatButton(_ sender:UIButton, title:String){
        sender.layer.borderColor = headerColor.cgColor
        sender.layer.borderWidth = 1.0
        sender.layer.cornerRadius = 2
        sender.layer.masksToBounds = true
        sender.setTitle(title, for: UIControlState())
        sender.setTitleColor(headerColor, for: UIControlState())
        sender.titleLabel?.font = UIFont(name: fontStr, size: 13.0)
    }
    
    func editItem(_ sender:UIButton){
        //        CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tableView];
        //        NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonPosition];
        let buttonPositon = sender.convert(CGPoint.zero, to: self.tableView)
        let indexPath: IndexPath = self.tableView.indexPathForRow(at: buttonPositon)!
        isEditForRow[indexPath.row] = 1
        self.tableView.reloadData()
    }
    
    func deleteTreatmentFromLocalDB(_ treamentID: Int) {
        let predicate = NSPredicate(format: "treatmentID == %d", treamentID)
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: tableTreatment)
        fetchRequest.predicate = predicate
        
        do {
            let fetchedEntities: NSArray = try self.context!.fetch(fetchRequest) as NSArray
            if fetchedEntities.count > 0{
                let entityToDelete = fetchedEntities[0]
                self.context!.delete(entityToDelete as! NSManagedObject)
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
    
    func updateTreatmentInLocalDB(_ treatmentDic: NSDictionary) {
        let predicate = NSPredicate(format: "treatmentID == %d", treatmentDic.object(forKey: "treatmentID") as! Int)
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: tableTreatment)
        fetchRequest.predicate = predicate
        
        do {
            let fetchedEntities: NSArray = try self.context!.fetch(fetchRequest) as NSArray
            if fetchedEntities.count > 0{
                let entityToUpdated = fetchedEntities[0]
                (entityToUpdated as AnyObject).setValue(treatmentDic.object(forKey: "beginDate") as! Double, forKey: "beginDate")
                (entityToUpdated as AnyObject).setValue(treatmentDic.object(forKey: "endDate") as! Double, forKey: "endDate")
                (entityToUpdated as AnyObject).setValue(treatmentDic.object(forKey: "treatmentName") as! String, forKey: "treatmentName")
                (entityToUpdated as AnyObject).setValue(treatmentDic.object(forKey: "dosage") as! String, forKey: "dosage")
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
    
    func deleteItem(_ sender: UIButton){
        let buttonPositon = sender.convert(CGPoint.zero, to: self.tableView)
        let indexPath: IndexPath = self.tableView.indexPathForRow(at: buttonPositon)!
        let deletedTreatmentObj = treatmentList.object(at: indexPath.row) as! TreatmentObj
        let deletedTreatment: NSDictionary = NSDictionary(objects: [deletedTreatmentObj.treatmentID, deletedTreatmentObj.username], forKeys: ["treatmentID" as NSCopying, "username" as NSCopying])
        haalthyService.deleteTreatment(deletedTreatment)
        treatmentList.removeObject(at: indexPath.row)
        deleteTreatmentFromLocalDB(deletedTreatmentObj.treatmentID)
        self.tableView.reloadData()
    }
    
    func saveItem(_ sender:UIButton){
        let buttonPositon = sender.convert(CGPoint.zero, to: self.tableView)
        let indexPath: IndexPath = self.tableView.indexPathForRow(at: buttonPositon)!
        isEditForRow[indexPath.row] = 0
        let updateTreatmentObj = treatmentList[indexPath.row] as! TreatmentObj
        let updateTreatment = NSMutableDictionary()
        updateTreatment.setObject(updateTreatmentObj.treatmentID, forKey: "treatmentID" as NSCopying)
        updateTreatment.setObject(updateTreatmentObj.username, forKey: "username" as NSCopying)
        updateTreatment.setObject(updateTreatmentObj.beginDate, forKey: "beginDate" as NSCopying)
        updateTreatment.setObject(updateTreatmentObj.endDate, forKey: "endDate" as NSCopying)

        let cell = self.tableView.cellForRow(at: indexPath)
        let views = cell?.subviews as! NSArray
        for view in views{
            if view is UITextField{
                updateTreatmentObj.treatmentName = (view as! UITextField).text!
                updateTreatment.setObject((view as! UITextField).text!, forKey: "treatmentName" as NSCopying)
            }
            if view is UITextView{
                updateTreatmentObj.dosage = (view as! UITextView).text
                updateTreatment.setObject((view as! UITextView).text, forKey: "dosage" as NSCopying)
            }
        }
        haalthyService.updateTreatment(updateTreatment)
        updateTreatmentInLocalDB(updateTreatment)
        self.tableView.reloadData()
    }
    
    func selectDate(_ sender:UIButton){
        if isSelectedDate == false {
            self.view.addSubview(transparentView)
            let datePickerHeight:CGFloat = 200
            let confirmButtonWidth:CGFloat = 100
            let confirmButtonHeight:CGFloat = 30
            datePickerContainerView = UIView(frame: CGRect(x: 0, y: UIScreen.main.bounds.height - datePickerHeight - 30 - 80, width: UIScreen.main.bounds.width, height: datePickerHeight + 30))
            datePickerContainerView!.backgroundColor = UIColor.white
            self.datePicker = UIDatePicker(frame: CGRect(x: 0 , y: 30, width: UIScreen.main.bounds.width, height: datePickerHeight))
            self.datePicker.datePickerMode = UIDatePickerMode.date
            let confirmButton = UIButton(frame: CGRect(x: UIScreen.main.bounds.width - confirmButtonWidth, y: 0, width: confirmButtonWidth, height: confirmButtonHeight))
            confirmButton.setTitle("确定", for: UIControlState())
            confirmButton.setTitleColor(headerColor, for: UIControlState())
            confirmButton.addTarget(self, action: #selector(UpdateTreatmentTableViewController.dateChanged), for: UIControlEvents.touchUpInside)
            let cancelButton = UIButton(frame: CGRect(x: 0, y: 0, width: confirmButtonWidth, height: confirmButtonHeight))
            cancelButton.setTitleColor(headerColor, for: UIControlState())
            cancelButton.addTarget(self, action: #selector(UpdateTreatmentTableViewController.dateCancel), for: UIControlEvents.touchUpInside)
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
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    func dateChanged(){
        transparentView.removeFromSuperview()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd" // superset of OP's format
        let selectDateStr = dateFormatter.string(from: self.datePicker.date)
        let buttonPositon = editDateButton!.convert(CGPoint.zero, to: self.tableView)
        let indexPath: IndexPath = self.tableView.indexPathForRow(at: buttonPositon)!
        if buttonPositon.x < 100 {
            (treatmentList[indexPath.row] as! TreatmentObj).beginDate = self.datePicker.date.timeIntervalSince1970 * 1000
        }else{
            (treatmentList[indexPath.row] as! TreatmentObj).beginDate = self.datePicker.date.timeIntervalSince1970 * 1000
            
        }
        editDateButton?.titleLabel?.text = selectDateStr
        self.datePickerContainerView?.removeFromSuperview()
    }
    
    func formatUpdateDateButton(_ sender: UIButton, title: String){
        sender.titleLabel?.font = UIFont(name: fontStr, size: 12.0)
        sender.setTitleColor(UIColor.gray, for: UIControlState())
        sender.titleLabel?.textAlignment = NSTextAlignment.center
        let underlineAttribute = [NSUnderlineStyleAttributeName: NSUnderlineStyle.styleSingle.rawValue]
        let underlineAttributedString = NSAttributedString(string: title, attributes: underlineAttribute)
        sender.setAttributedTitle(underlineAttributedString, for: UIControlState())
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return (heightForRowForTreatmentList[indexPath.row] as! CGFloat) + 70
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        textField.resignFirstResponder()
        return true
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n"{
            textView.resignFirstResponder()
            return false
        }
        return true
    }
}
