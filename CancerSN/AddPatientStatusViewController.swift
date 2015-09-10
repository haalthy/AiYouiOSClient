//
//  AddPatientStatusViewController.swift
//  CancerSN
//
//  Created by lily on 8/25/15.
//  Copyright (c) 2015 lily. All rights reserved.
//

import UIKit

class AddPatientStatusViewController: UITableViewController , UITextFieldDelegate, UITextViewDelegate {
    var patientStatusFormatList = NSArray()
    var clinicReportFormatList = NSArray()
    let haalthyService = HaalthyService()
    var expendRow = NSMutableArray()
    var patientStatusDetail = String()
    var clinicReportDetail = String()
    
    var treatmentList = NSArray()
    var patientStatusList = NSMutableArray()
    var clinicReportList = NSMutableArray()
    
    func getPatientStatusDesc(){
        var patientStatusNameSet = NSMutableSet()
        for i in 0..<expendRow.count {
            var indexPath = NSIndexPath(forRow: expendRow[i] as! Int, inSection: 1)
            var cell = self.tableView.cellForRowAtIndexPath(indexPath)
            if cell != nil {
                var selectedCell = cell as! AddPatientStatusTableViewCell
                var isExistInStatusList = false
                for item in patientStatusList {
                    if (item.objectForKey("patientStatusName") as! String) == selectedCell.patientStatusName.text! {
                        item.setObject(selectedCell.patientStatusDesc.text!, forKey: "patientStatusDesc")
                        isExistInStatusList = true
                    }
                }
                if isExistInStatusList == false {
                    var patientStatus = NSMutableDictionary()
                    patientStatus.setObject(selectedCell.patientStatusName.text!, forKey: "patientStatusName")
                    patientStatus.setObject(selectedCell.patientStatusDesc.text!, forKey: "patientStatusDesc")
                    patientStatusList.addObject(patientStatus)
                }
            }
        }
        var clinicReportNameList = NSMutableSet()
        for clinicReportFormat in clinicReportFormatList {
            clinicReportNameList.addObject(clinicReportFormat.objectForKey("clinicItem") as! String)
            println(clinicReportFormat.objectForKey("clinicItem") as! String)
        }
        for patientStatus in patientStatusList {
            if clinicReportNameList.containsObject(patientStatus.objectForKey("patientStatusName") as! String) {
                if patientStatus.objectForKey("patientStatusDesc")  == nil {
                    clinicReportDetail += (patientStatus.objectForKey("patientStatusName") as! String) + "**"
                }else{
                    clinicReportDetail += (patientStatus.objectForKey("patientStatusName") as! String) + "*" + (patientStatus.objectForKey("patientStatusDesc") as! String) + "**"
                }
            }else{
                if patientStatus.objectForKey("patientStatusDesc")  == nil {
                    patientStatusDetail += (patientStatus.objectForKey("patientStatusName") as! String) + "**"
                }else{
                    patientStatusDetail += (patientStatus.objectForKey("patientStatusName") as! String) + "*" + (patientStatus.objectForKey("patientStatusDesc") as! String) + "**"
                }
            }
        }
    }
    
    @IBAction func addPublicStatus(sender: UIButton) {
        if treatmentList.count > 0 {
            for i in 0..<treatmentList.count {
                treatmentList.setValue(1, forKey: "isPosted")
            }
            haalthyService.addTreatment(treatmentList)
        }
        getPatientStatusDesc()
        var patientStatus = NSMutableDictionary()
        patientStatus.setValue(patientStatusDetail, forKey: "statusDesc")
        patientStatus.setValue(1, forKey: "isPosted")
//        patientStatus.setValue(Int(NSDate().timeIntervalSince1970*1000), forKey: "insertedDate")
        var clinicReport = NSMutableDictionary()
        clinicReport.setValue(clinicReportDetail, forKey: "clinicReport")
        clinicReport.setValue(1, forKey: "isPosted")
        haalthyService.addPatientStatus(patientStatus as NSDictionary, clinicReport: clinicReport as NSDictionary)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func addPrivateStatus(sender:UIButton){
        if treatmentList.count > 0 {
            for i in 0..<treatmentList.count {
                treatmentList.setValue(0, forKey: "isPosted")
            }
            haalthyService.addTreatment(treatmentList)
            self.dismissViewControllerAnimated(true, completion: nil)
        }
        getPatientStatusDesc()
        var patientStatus = NSMutableDictionary()
        patientStatus.setValue(patientStatusDetail, forKey: "statusDesc")
        patientStatus.setValue(0, forKey: "isPosted")
//        patientStatus.setValue(NSDate().timeIntervalSince1970, forKey: "insertedDate")
        var clinicReport = NSMutableDictionary()
        clinicReport.setValue(clinicReport, forKey: "clinicReport")
        clinicReport.setValue(1, forKey: "isPosted")
        haalthyService.addPatientStatus(patientStatus as NSDictionary, clinicReport: clinicReport as NSDictionary)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func cancelEdit(sender: UIButton) {
        var buttonPosition = sender.convertPoint(CGPointZero, toView: self.tableView)
        var indexPath:NSIndexPath = self.tableView.indexPathForRowAtPoint(buttonPosition)!
        var cell = self.tableView.cellForRowAtIndexPath(indexPath) as! AddPatientStatusTableViewCell
        expendRow.removeObject(indexPath.row)
        for patientStatus in patientStatusList{
            if (patientStatus.objectForKey("patientStatusName") as! String) == cell.patientStatusName {
                patientStatusList.removeObject(patientStatus)
            }
        }
        cell.patientStatusDesc.hidden = true
        cell.cancel.hidden = true
        tableView.beginUpdates()
        tableView.endUpdates()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var haalthyService = HaalthyService()
        var getPatientStatusFormatData = haalthyService.getPatientStatusFormat()
        var jsonResult = NSJSONSerialization.JSONObjectWithData(getPatientStatusFormatData, options: NSJSONReadingOptions.MutableContainers, error: nil)
        patientStatusFormatList = jsonResult as! NSArray
        var getClinicReportFormatData = haalthyService.getClinicReportFormat()
        jsonResult = NSJSONSerialization.JSONObjectWithData(getClinicReportFormatData, options: NSJSONReadingOptions.MutableContainers, error: nil)
        clinicReportFormatList = jsonResult as! NSArray
//        self.tableView.allowsSelection = false
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
        case 1: numberOfRows = clinicReportFormatList.count + patientStatusFormatList.count
            break
        case 0, 2, 3: numberOfRows = 1
            break
        default: numberOfRows = 0
            break
        }
        return numberOfRows
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 1{
        let cell = tableView.dequeueReusableCellWithIdentifier("addPatientStatusCellIdentifier", forIndexPath: indexPath) as! AddPatientStatusTableViewCell
//            let cell = self.tableView.cellForRowAtIndexPath(indexPath) as! AddPatientStatusTableViewCell
            if indexPath.row < clinicReportFormatList.count {
                cell.patientStatusName.text = clinicReportFormatList[indexPath.row]["clinicItem"] as? String
            }else{
                cell.patientStatusName.text = patientStatusFormatList[indexPath.row - clinicReportFormatList.count]["statusName"] as? String
            }
            if expendRow.containsObject(indexPath.row) {
                cell.patientStatusDesc.hidden = false
                cell.cancel.hidden = false
            }else{
                cell.patientStatusDesc.hidden = true
                cell.cancel.hidden = true
            }
            cell.patientStatusDesc.delegate = self
        return cell
        }else if indexPath.section == 0{
            let cell = tableView.dequeueReusableCellWithIdentifier("addPatientStatusHeaderIdentifier", forIndexPath: indexPath) as! UITableViewCell
            return cell
        }else if indexPath.section == 2{
            let cell = tableView.dequeueReusableCellWithIdentifier("otherPatientStatusIdentifier", forIndexPath: indexPath) as! UITableViewCell
            return cell
        }
        else{
            let cell = tableView.dequeueReusableCellWithIdentifier("addPatientStatusIdentifier", forIndexPath: indexPath) as! UITableViewCell
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
            var selectedCell = tableView.cellForRowAtIndexPath(indexPath)! as! AddPatientStatusTableViewCell
            selectedCell.patientStatusDesc.hidden = false
            selectedCell.cancel.hidden = false
            selectedCell.patientStatusName.backgroundColor = highlightColor
            expendRow.addObject(indexPath.row)
            var patientStatus = NSMutableDictionary()
            patientStatus.setObject(selectedCell.patientStatusName.text!, forKey: "patientStatusName")
            patientStatusList.addObject(patientStatus)
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
    
    override func tableView(tableView: UITableView, didEndDisplayingCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if(indexPath.section == 1){
            var endDisplayingCell = cell as! AddPatientStatusTableViewCell
            for item in patientStatusList{
                if (item.objectForKey("patientStatusName") as! String) == endDisplayingCell.patientStatusName.text! {
                    item.setObject(endDisplayingCell.patientStatusDesc.text!, forKey: "patientStatusDesc")
                }
            }
        }
    }
}
