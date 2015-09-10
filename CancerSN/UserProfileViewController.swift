//
//  UserProfileViewController.swift
//  CancerSN
//
//  Created by lily on 9/1/15.
//  Copyright (c) 2015 lily. All rights reserved.
//

import UIKit

class UserProfileViewController: UIViewController , UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var profileSegment: UISegmentedControl!
    var username: NSString?
    var password: NSString?
    var haalthyService = HaalthyService()
    var keychainAccess = KeychainAccess()
    var treatmentList = NSArray()
    var patientStatusList = NSArray()
    var treatmentSections = NSMutableArray()
    var sectionHeaderHeightList = NSMutableArray()
    var clinicReportList = NSArray()
    
    @IBOutlet weak var tableview: UITableView!
    
    func gettTreatmentsData(){
        username = keychainAccess.getPasscode(usernameKeyChain)
        password = keychainAccess.getPasscode(passwordKeyChain)
        if (username != nil) && (password != nil){
            var getUserDetail = haalthyService.getUserDetail(username! as String)
            var jsonResult = NSJSONSerialization.JSONObjectWithData(getUserDetail, options: NSJSONReadingOptions.MutableContainers, error: nil)
            
            let str: NSString = NSString(data: getUserDetail, encoding: NSUTF8StringEncoding)!
            println(str)
            if jsonResult != nil{
                profileSegment.insertSegmentWithTitle("我的设置", atIndex: 2, animated: false)
                var userDetail = jsonResult as! NSDictionary
                treatmentList = jsonResult!.objectForKey("treatments") as! NSArray
                patientStatusList = jsonResult!.objectForKey("patientStatus") as! NSArray
                clinicReportList = jsonResult!.objectForKey("clinicReport") as! NSArray
                var timeList = [Int]()
//                var timeList = NSArray()
                var timeSet = NSMutableSet()
                for var i = 0; i < treatmentList.count; i++ {
                    var treatment = treatmentList[i] as! NSMutableDictionary
                    if (treatment.objectForKey("endDate") as! Double) > (NSDate().timeIntervalSince1970 * 1000){
                        treatment.setObject(((NSDate().timeIntervalSince1970 as! NSNumber).integerValue * 1000) as AnyObject, forKey:"endDate")
                    }
                    
                    if timeSet.containsObject(treatment.objectForKey("endDate")!) == false {
                        //                        timeList.addObject(treatment.objectForKey("endDate")!)
//                        timeList.append((treatment.objectForKey("endDate") as! NSNumber).integerValue)
                        timeSet.addObject((treatment.objectForKey("endDate") as! NSNumber).integerValue)
                    }
                    if timeSet.containsObject(treatment.objectForKey("beginDate")!) == false {
                        //                        timeList.addObject(treatment.objectForKey("beginDate")!)
//                        timeList.append((treatment.objectForKey("beginDate") as! NSNumber).integerValue)
                        timeSet.addObject((treatment.objectForKey("beginDate") as! NSNumber).integerValue)
                    }
                }
                
                for timeSt in timeSet {
                    timeList.append(timeSt as! Int)
                }

                timeList.sort(>)
                var index = 0
                var patientStatusIndex = 0
                while index < timeList.count-1 {
                    var treatmentSection = NSMutableDictionary()
                    var patientStatusInTreatmentSection = NSMutableArray()
                    treatmentSection.setObject((timeList[index] as AnyObject), forKey: "endDate")
                    treatmentSection.setObject(timeList[index+1] as AnyObject, forKey: "beginDate")
                    var treatmentStr = ""
                    var treatmentCountInSection = 0
                    var treatmentSectionLineCount = 0
                    for var treatmentIndex = 0; treatmentIndex < treatmentList.count; treatmentIndex++ {
                        var treatment = treatmentList[treatmentIndex] as! NSDictionary
                        if ((treatment.objectForKey("endDate") as? Int) >= (timeList[index] as Int)) && ((treatment.objectForKey("beginDate") as? Int) <= (timeList[index+1] as Int)) {
                            treatmentStr += (treatment["treatmentName"] as! String) + "*"
                            if treatment["dosage"] != nil{
                                treatmentStr += treatment["dosage"] as! String
                                var dosageStr = treatment["dosage"] as! String
                                treatmentSectionLineCount += (dosageStr as NSString).length/14 + 1
                            }else{
                                treatmentSectionLineCount += (treatmentStr as NSString).length/20 + 1
                            }
                            treatmentStr += "**"
                            treatmentCountInSection++
                        }
                    }
                    treatmentSection.setObject(treatmentCountInSection, forKey: "treatmentCount")
                    treatmentSection.setObject(treatmentSectionLineCount, forKey: "treatmentLineCount")
                    treatmentSection.setObject(treatmentStr, forKey: "treatmentDetails")
                    if patientStatusIndex < patientStatusList.count{
                        while ((patientStatusIndex < patientStatusList.count) && (patientStatusList[patientStatusIndex]["insertedDate"] as! Int) > (timeList[index+1] as Int)) {
                            patientStatusInTreatmentSection.addObject(patientStatusList[patientStatusIndex])
                            patientStatusIndex++
                        }
                        treatmentSection.setObject(patientStatusInTreatmentSection, forKey: "patientStatus")
                    }
                    index++
                    treatmentSections.addObject(treatmentSection)
                }
                if patientStatusIndex < patientStatusList.count{
                    var treatmentSection = NSMutableDictionary()
                    var patientStatusInTreatmentSection = NSMutableArray()
                    treatmentSection.setObject((patientStatusList[patientStatusIndex]["insertedDate"] as! Int), forKey: "endDate")
                    treatmentSection.setObject((patientStatusList[patientStatusList.count - 1]["insertedDate"] as! Int), forKey: "beginDate")
                    for var i = patientStatusIndex; i < patientStatusList.count; i++ {
                        patientStatusInTreatmentSection.addObject(patientStatusList[i])
                    }
                    treatmentSection.setObject(patientStatusInTreatmentSection, forKey: "patientStatus")
                    treatmentSections.addObject(treatmentSection)
                }
            }
        }

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var imageView = UIImageView(frame: CGRectMake(4, 4, 88, 88))
        var viewContainer = UIView(frame: CGRectMake(28, 16, 96, 96))
        imageView.image = UIImage(named: "Mario.jpg")
        viewContainer.addSubview(imageView)
        viewContainer.backgroundColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.addSubview(viewContainer)
        tableview.delegate = self
        tableview.dataSource = self
        gettTreatmentsData()
        self.tableview.allowsSelection = false
        
    }
    
    func sortFunc(num1: Int, num2: Int) -> Bool {
        return num1 > num2
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // Return the number of sections.
        if profileSegment.selectedSegmentIndex == 0 {
            return treatmentSections.count+1
        }
        return 0
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var numberOfRows = 0
        if profileSegment.selectedSegmentIndex == 0 {
            if section == 0{
                numberOfRows = 1
            }else{
                var patientStatus = treatmentSections[section-1]["patientStatus"]
                if (patientStatus!) != nil {
                    numberOfRows = (patientStatus as! NSArray).count
                }else{
                    numberOfRows = 0
                }
            }
        }else{
            numberOfRows = 0
        }
        return numberOfRows
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if profileSegment.selectedSegmentIndex == 0{
            if indexPath.section == 0{
                let cell = tableView.dequeueReusableCellWithIdentifier("treatmentSummaryCell", forIndexPath: indexPath) as! TreatmentSummaryTableViewCell
                if clinicReportList.count > 0{
                    cell.treatmentList = treatmentList
                    cell.clinicReportList = clinicReportList
                }
                return cell
            }else{
                let cell = tableView.dequeueReusableCellWithIdentifier("patientStatusListCell", forIndexPath: indexPath) as! PatientStatusTableViewCell
                cell.patientStatus = patientStatusList[indexPath.row] as! NSDictionary
                return cell
            }
        }else if profileSegment.selectedSegmentIndex == 1{
            let cell = tableView.dequeueReusableCellWithIdentifier("questionListCell", forIndexPath: indexPath) as! UITableViewCell
            return cell
        }else{
            let cell = tableView.dequeueReusableCellWithIdentifier("settingListCell", forIndexPath: indexPath) as! UITableViewCell
            return cell
        }
    }
    
    func tableView(_tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat{
        var rowHeight: CGFloat
        if profileSegment.selectedSegmentIndex == 0{
            if indexPath.section == 0{
                rowHeight = clinicReportList.count > 0 ? 150 : 0
            }else{
                rowHeight = UITableViewAutomaticDimension
            }
        }else{
            rowHeight = 80
        }
        return rowHeight
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        var heightForHeader:CGFloat = 0
        if profileSegment.selectedSegmentIndex == 0{
            if section == 0 {
                heightForHeader = 40
            }else{
                var treatmentStr = self.treatmentSections[section-1]["treatmentLineCount"] as! Int
                heightForHeader = CGFloat(35 * treatmentStr + 4)
                if UIScreen.mainScreen().bounds.width < 375 {
                    heightForHeader += 35
                }
            }
        }
        return heightForHeader
    }
    
    func tableView (tableView:UITableView,  viewForHeaderInSection section:Int)->UIView {
        var headerView = UIView()
        if profileSegment.selectedSegmentIndex == 0{
            if section == 0 {
                headerView =  UIView(frame: CGRectMake(0, 0,tableView.bounds.size.width, 40))
                var summaryLabel = UILabel(frame: CGRectMake(15,5,tableView.bounds.size.width - 40, 30))
                summaryLabel.text = "CEA指标变化"
                summaryLabel.textColor = mainColor
                summaryLabel.font = UIFont(name: "Helvetica-Bold", size: 15)
                headerView.addSubview(summaryLabel)
            }else{
                var heightForHeader:CGFloat = 0
                var treatmentY:CGFloat = 5.0
                
                var treatmentLineCount = self.treatmentSections[section-1]["treatmentLineCount"] as! Int
                heightForHeader += CGFloat(35 * treatmentLineCount + 4)
                if UIScreen.mainScreen().bounds.width < 375 {
                    heightForHeader += 35
                }
                headerView =  UIView(frame: CGRectMake(0, 0,tableView.bounds.size.width, heightForHeader))

                var dateLabel = UILabel()
                if UIScreen.mainScreen().bounds.width >= 375 {
                    dateLabel = UILabel(frame: CGRectMake(285, treatmentY, 80, 30))
                }else{
                    dateLabel = UILabel(frame: CGRectMake(285, treatmentY, 80, 30))
                    treatmentY += 35
                    heightForHeader += 35
                }
                
                var dateFormatter = NSDateFormatter()
                dateFormatter.dateFormat = "MM/dd" // superset of OP's format
                
                var beginDate = NSDate(timeIntervalSince1970: (treatmentSections[section-1]["beginDate"] as! Double)/1000 as NSTimeInterval)
                var endDate = NSDate(timeIntervalSince1970: (treatmentSections[section-1]["endDate"] as! Double)/1000 as NSTimeInterval)
                let beginDateStr = dateFormatter.stringFromDate(beginDate)
                let endDateStr = dateFormatter.stringFromDate(endDate)
                dateLabel.text = beginDateStr + " - " + endDateStr
                dateLabel.textColor = UIColor.grayColor()
                dateLabel.font = UIFont(name: "Helvetica", size: 12.0)
                dateLabel.textAlignment = NSTextAlignment.Right
                headerView.addSubview(dateLabel)

                var treatmentStr = self.treatmentSections[section-1]["treatmentDetails"] as! String
                println(treatmentStr)
                var treatmentList: NSArray = treatmentStr.componentsSeparatedByString("**")
                
                for treatment in treatmentList{
                    var treatmentNameAndDosage:NSArray = (treatment as! String).componentsSeparatedByString("*")
                    var treatmentName = treatmentNameAndDosage[0] as! String
                    var treatmentDosage = String()
                    var treatmentNameLabel = UILabel()
                    var dosageLable = UILabel()
                    if treatmentNameAndDosage.count > 1{
                        var dosageLableLine = (treatmentDosage as NSString).length/14 + 1
                        var height = CGFloat(30 * dosageLableLine)
                        treatmentDosage = treatmentNameAndDosage[1] as! String
                        treatmentNameLabel = UILabel(frame: CGRectMake(10.0, treatmentY, 90.0, 30.0))
                        treatmentNameLabel.text = treatmentName
                        dosageLable = UILabel(frame: CGRectMake(110.0, treatmentY, 170.0, height))
                        dosageLable.text = treatmentDosage
                        treatmentY += height + 5
                        dosageLable.font = UIFont(name: "Helvetica-Bold", size: 13.0)
                        treatmentNameLabel.font = UIFont(name: "Helvetica-Bold", size: 14.0)
                        treatmentNameLabel.layer.cornerRadius = 5
                        treatmentNameLabel.backgroundColor = tabBarColor
                        treatmentNameLabel.textColor = mainColor
                        treatmentNameLabel.layer.masksToBounds = true
                        treatmentNameLabel.layer.borderColor = mainColor.CGColor
                        treatmentNameLabel.layer.borderWidth = 1.0
                        treatmentNameLabel.textAlignment = NSTextAlignment.Center
                        dosageLable.textColor = mainColor
                    }else{
                        var treatmentLine = (treatmentName as NSString).length/20 + 1
                        var height = CGFloat(30 * treatmentLine)
                        treatmentNameLabel = UILabel(frame: CGRectMake(10.0, treatmentY, 265.0, height))
                        treatmentNameLabel.text = treatmentName
                        treatmentY += height + 5
                        treatmentNameLabel.font = UIFont(name: "Helvetica-Bold", size: 13.0)
                        treatmentNameLabel.textColor = mainColor
                    }
                    headerView.addSubview(treatmentNameLabel)
                    headerView.addSubview(dosageLable)
                    
                    var separatorLine:UIImageView = UIImageView(frame: CGRectMake(5, 0, tableView.frame.size.width-10.0, 1.0))
                    separatorLine.image = UIImage(named: "grayline.png")?.stretchableImageWithLeftCapWidth(1, topCapHeight: 0)
                    
                    headerView.addSubview(separatorLine)
                }
            }
        }
        return headerView;

    }
    

}
