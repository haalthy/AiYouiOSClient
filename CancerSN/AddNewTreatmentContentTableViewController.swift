//
//  AddNewTreatmentContentTableViewController.swift
//  CancerSN
//
//  Created by lily on 8/23/15.
//  Copyright (c) 2015 lily. All rights reserved.
//

import UIKit

class AddNewTreatmentContentTableViewController: UITableViewController, UITextFieldDelegate, UITextViewDelegate {

    var treatmentList = NSMutableArray()
    var treatmentFormatList = NSArray()
    var expendRow = NSMutableArray()
    let profileSet = NSUserDefaults.standardUserDefaults()
    
    func getTreatmentList(){
        for i in 0..<expendRow.count {
            
            var indexPath = NSIndexPath(forRow: expendRow[i] as! Int, inSection: 1)
            var cell = self.tableView.cellForRowAtIndexPath(indexPath)
            if cell != nil {
                var selectedCell = cell as! AddNewTreatmentListTableViewCell
                var isExistInTreatmentList = false
                for item in treatmentList {
                    if (item.objectForKey("treatmentName") as! String) == selectedCell.treatmentName.text! {
                        item.setObject(selectedCell.dosageDescription.text!, forKey: "dosage")
                        isExistInTreatmentList = true
                    }
                }
                if isExistInTreatmentList == false {
                    var treatment = NSMutableDictionary()
                    treatment.setObject(selectedCell.treatmentName.text!, forKey: "treatmentName")
                    var dosage : String = ""
                    if selectedCell.dosageDescription.text != nil {
                        dosage += selectedCell.dosageDescription.text
                    }
                    treatment.setObject(dosage, forKey: "dosage")
                    treatmentList.addObject(treatment)
                }
            }
        }
        for treatment in treatmentList{
            treatment.setObject((profileSet.objectForKey(newTreatmentBegindate) as! Int)*1000, forKey: "beginDate")
            if profileSet.objectForKey(newTreatmentEnddate) != nil {
                treatment.setObject((profileSet.objectForKey(newTreatmentEnddate) as! Int)*1000, forKey: "endDate")
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "addPatientStatusSegue"{
            var vc = segue.destinationViewController as! AddPatientStatusViewController
            vc.treatmentList = self.treatmentList
        }
    }
    
    @IBAction func addTreatment(sender: UIButton) {
        getTreatmentList()
        self.performSegueWithIdentifier("addPatientStatusSegue", sender: self)
    }

    @IBAction func cancelEdit(sender: UIButton) {
        
        var buttonPosition = sender.convertPoint(CGPointZero, toView: self.tableView)
        var indexPath:NSIndexPath = self.tableView.indexPathForRowAtPoint(buttonPosition)!
        var cell = self.tableView.cellForRowAtIndexPath(indexPath) as! AddNewTreatmentListTableViewCell
        expendRow.removeObject(indexPath.row)
        for treatment in treatmentList {
            if treatment.objectForKey("treatmentName") as! String == cell.treatmentName.text! {
                treatmentList.removeObject(treatment)
            }
        }
        cell.dosageDescription.hidden = true
        cell.cancel.hidden = true
        tableView.beginUpdates()
        tableView.endUpdates()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        var haalthyService = HaalthyService()
        var getTreatmentFormatData = haalthyService.getTreatmentFormat()
        var jsonResult = NSJSONSerialization.JSONObjectWithData(getTreatmentFormatData, options: NSJSONReadingOptions.MutableContainers, error: nil)
        treatmentFormatList = jsonResult as! NSArray
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 4
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        
        var numberOfRows:Int = 0
        switch section{
        case 1: numberOfRows = treatmentFormatList.count
            break
        case 0, 2, 3: numberOfRows = 1
            break
        default: numberOfRows = 0
            break
        }
        return numberOfRows
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if(indexPath.section == 1){
//            var reuseCellStr:String?
            let cell = tableView.dequeueReusableCellWithIdentifier("treatmentFormatCellIdentifier", forIndexPath: indexPath) as! AddNewTreatmentListTableViewCell
            cell.treatmentName.text = (treatmentFormatList[indexPath.row] as! NSDictionary).objectForKey("treatmentName") as? String
            if expendRow.containsObject(indexPath.row) {
                cell.dosageDescription.hidden = false
                cell.cancel.hidden = false
            }else{
                cell.dosageDescription.hidden = true
                cell.cancel.hidden = true
            }
            cell.dosageDescription.delegate = self
            return cell
        }else if(indexPath.section == 0){
            var cell = tableView.dequeueReusableCellWithIdentifier("addTreatmentHeaderCell", forIndexPath: indexPath) as!UITableViewCell
            return cell
        }else if(indexPath.section == 2){
            var cell = tableView.dequeueReusableCellWithIdentifier("otherTreatmentCellIdentifier", forIndexPath: indexPath) as!AddOtherTreatmentTableViewCell
            cell.addOtherTreatmentText.delegate = self
            return cell
        }else {
            var cell = tableView.dequeueReusableCellWithIdentifier("addTreatmentIdentifier", forIndexPath: indexPath) as!UITableViewCell
            return cell
        }
    }
    
    override func tableView(_tableView: UITableView,
        heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat{
            var rowHeight:CGFloat
            switch indexPath.section{
            case 0: rowHeight = 70
                break
            case 1: rowHeight = expendRow.containsObject(indexPath.row) ? 145 : 65
                break
            case 2:rowHeight = 100
                break
            case 3:rowHeight = 80
                break
            default:rowHeight = 0
                break
            }
            return rowHeight
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var generalSselectedCell:UITableViewCell = tableView.cellForRowAtIndexPath(indexPath)! as UITableViewCell
        generalSselectedCell.contentView.backgroundColor = UIColor.whiteColor()
        if(indexPath.section == 1){
            var selectedCell = tableView.cellForRowAtIndexPath(indexPath)! as! AddNewTreatmentListTableViewCell
            selectedCell.dosageDescription.hidden = false
            selectedCell.cancel.hidden = false
            selectedCell.treatmentName.backgroundColor = highlightColor
            expendRow.addObject(indexPath.row)
            var treatment = NSMutableDictionary()
            treatment.setObject(selectedCell.treatmentName.text!, forKey: "treatmentName")
            treatmentList.addObject(treatment)
            tableView.beginUpdates()
            tableView.endUpdates()
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool{
        textField.resignFirstResponder()
        return true
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        if textView.textColor != UIColor.blackColor() {
            textView.text = nil
            textView.textColor = UIColor.blackColor()
        }
    }
    
    func textFieldShouldEndEditing(textField: UITextField) -> Bool {
        return true
    }
    
//    func textFieldDidEndEditing(textField: UITextField) {
//        var textFieldPosition = textField.convertPoint(CGPointZero, toView: self.tableView)
//        var indexPath:NSIndexPath = self.tableView.indexPathForRowAtPoint(textFieldPosition)!
//        var cell = self.tableView.cellForRowAtIndexPath(indexPath) as! AddNewTreatmentListTableViewCell
//        for treatment in treatmentList{
//            if (treatment.objectForKey("treatmentName") as! String) == cell.treatmentName.text {
//                treatment.setObject(textField.text, forKey: "dosage")
//            }
//        }
//    }
    
    override func tableView(tableView: UITableView, didEndDisplayingCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if(indexPath.section == 1){
            var endDisplayingCell = cell as! AddNewTreatmentListTableViewCell
            for treatment in treatmentList{
                if (treatment.objectForKey("treatmentName") as! String) == endDisplayingCell.treatmentName.text! {
                    treatment.setObject(endDisplayingCell.dosageDescription.text!, forKey: "dosage")
                }
            }
        }
    }
}
