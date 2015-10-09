//
//  UserProfileViewController.swift
//  CancerSN
//
//  Created by lily on 9/1/15.
//  Copyright (c) 2015 lily. All rights reserved.
//

import UIKit

class UserProfileViewController: UIViewController , UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var patientProfile: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    
    @IBOutlet weak var profileSegment: UISegmentedControl!
    var profileOwnername: NSString?
    var username: NSString?
    var password: NSString?
    var haalthyService = HaalthyService()
    var keychainAccess = KeychainAccess()
    var getAccessToken = GetAccessToken()
    var treatmentList = NSMutableArray()
    var patientStatusList = NSArray()
    var treatmentSections = NSMutableArray()
    var sectionHeaderHeightList = NSMutableArray()
    var clinicReportList = NSArray()
    var userProfile = NSDictionary()
    var broadcastList = NSArray()
    var heightForQuestionRow = NSMutableDictionary()
    var usedToBeInLoginView = false
    var publicService = PublicService()
    var viewContainer = UIView()
    var accessToken :AnyObject? = nil
    var userList = NSArray()
    
    @IBAction func segmentIndexChanged(sender: UISegmentedControl) {
        if username != nil {
            if sender.selectedSegmentIndex == 1 {
                var broadcastData = haalthyService.getPostsByUsername(profileOwnername as! String)
                var jsonResult = NSJSONSerialization.JSONObjectWithData(broadcastData, options: NSJSONReadingOptions.MutableContainers, error: nil)
                if jsonResult is NSArray {
                    broadcastList = jsonResult as! NSArray
                }
            }
            self.tableview.reloadData()
        }
    }
    @IBOutlet weak var tableview: UITableView!
    
    func getTreatmentsData(){
        if (username != nil) && (password != nil){
            var jsonResult:AnyObject? = nil
            var userDetailData = haalthyService.getUserDetail(profileOwnername! as String)
            if userDetailData != nil{
                jsonResult = NSJSONSerialization.JSONObjectWithData(userDetailData!, options: NSJSONReadingOptions.MutableContainers, error: nil)
                            let str: NSString = NSString(data: userDetailData!, encoding: NSUTF8StringEncoding)!
                            println(str)
            }

            if jsonResult != nil{
                if profileSegment.numberOfSegments < 3 && profileOwnername == username {
                    profileSegment.insertSegmentWithTitle("我", atIndex: 2, animated: false)
                }
                if profileSegment.numberOfSegments > 2 && profileOwnername != username{
                    profileSegment.removeSegmentAtIndex(2, animated: false)
                }
                var userDetail = jsonResult as! NSDictionary
                treatmentList = jsonResult!.objectForKey("treatments") as! NSMutableArray
                
                patientStatusList = jsonResult!.objectForKey("patientStatus") as! NSArray
                clinicReportList = jsonResult!.objectForKey("clinicReport") as! NSArray
                userProfile = jsonResult!.objectForKey("userProfile") as! NSDictionary
                var timeList = [Int]()
                var timeSet = NSMutableSet()
                for var i = 0; i < treatmentList.count; i++ {
                    treatmentList[i] = treatmentList[i] as! NSMutableDictionary
                    treatmentList[i].setObject(getNSDateMod(treatmentList[i].objectForKey("beginDate") as! Double), forKey:"beginDate")
                    treatmentList[i].setObject(getNSDateMod(treatmentList[i].objectForKey("endDate") as! Double), forKey:"endDate")

                    var treatment = treatmentList[i] as! NSMutableDictionary
                    
                    if (treatment.objectForKey("endDate") as! Double) > (NSDate().timeIntervalSince1970 * 1000){
                        treatment.setObject(((NSDate().timeIntervalSince1970 as! NSNumber).integerValue * 1000) as AnyObject, forKey:"endDate")
                    }
                    
                    if timeSet.containsObject(treatment.objectForKey("endDate")!) == false {
                        timeSet.addObject((treatment.objectForKey("endDate") as! NSNumber).integerValue)
                    }
                    if timeSet.containsObject(treatment.objectForKey("beginDate")!) == false {
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
                    var sectionHeight: CGFloat = 0.0
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
                            var dosageLabel = UILabel()
                            dosageLabel = UILabel(frame: CGRectMake(0, 0, 170.0, CGFloat.max))
                            dosageLabel.text = treatment["dosage"] as! String
                            dosageLabel.font = UIFont(name: "Helvetica-Bold", size: 13.0)
                            dosageLabel.numberOfLines = 0
                            dosageLabel.sizeToFit()
                            var height:CGFloat = dosageLabel.frame.height > 30 ? dosageLabel.frame.height : 30
                            sectionHeight += height + 5
                        }
                    }
                    treatmentSection.setObject(sectionHeight, forKey: "sectionHeight")
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
    
    func getNSDateMod(date: Double)->Double{
        var dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "YY-MM-dd" // superset of OP's format
        var dateInserted = NSDate(timeIntervalSince1970: date/1000 as NSTimeInterval)
        let dateStr = dateFormatter.stringFromDate(dateInserted)
//        var newDataStr = dateStr + " 00:00:00"
        let timeInterval = dateFormatter.dateFromString(dateStr)?.timeIntervalSince1970
        return timeInterval! * 1000
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var dummyViewHeight : CGFloat = 40
        var dummyView: UIView = UIView(frame:CGRectMake(0, 0, self.tableview.frame.width, dummyViewHeight))
        self.tableview.tableHeaderView = dummyView;
        self.tableview.contentInset = UIEdgeInsetsMake(-dummyViewHeight, 0, 0, 0);
    }
    
    override func viewWillDisappear(animated: Bool) {
        viewContainer.removeFromSuperview()
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        profileOwnername = nil
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        username = keychainAccess.getPasscode(usernameKeyChain)
        password = keychainAccess.getPasscode(passwordKeyChain)
        getAccessToken.getAccessToken()
        accessToken = NSUserDefaults.standardUserDefaults().objectForKey(accessNSUserData)
        if accessToken == nil{
            if usedToBeInLoginView == false{
                self.performSegueWithIdentifier("loginSegue", sender: self)
                usedToBeInLoginView = true
            }else{
                self.tabBarController?.selectedIndex = 0
                usedToBeInLoginView = false
            }
        }else{
            if profileOwnername == nil {
                profileOwnername  = username
            }
            tableview.delegate = self
            tableview.dataSource = self
            self.treatmentSections = NSMutableArray()
            getTreatmentsData()

            var imageView = UIImageView(frame: CGRectMake(4, 4, 88, 88))
            viewContainer = UIView(frame: CGRectMake(28, 16, 96, 96))
//            imageView.image = UIImage(named: "Mario.jpg")
            if self.userProfile.valueForKey("image") != nil{
                let dataString = self.userProfile.valueForKey("image") as! String
                let imageData: NSData = NSData(base64EncodedString: dataString, options: NSDataBase64DecodingOptions(0))!
                imageView.image = UIImage(data: imageData)
            }else{
                imageView.image = UIImage(named: "Mario.jpg")
            }
            viewContainer.addSubview(imageView)
            viewContainer.backgroundColor = UIColor.whiteColor()
            self.navigationController?.navigationBar.addSubview(viewContainer)

            //            self.tableview.allowsSelection = false
            let publicService = PublicService()
            let profileStr = publicService.getProfileStrByDictionary(userProfile)
            self.patientProfile.text = profileStr
            self.patientProfile.font = UIFont(name: "Helvetica", size: 12)
            self.usernameLabel.text = self.userProfile.objectForKey("username") as! String
        }
    }
    
//    func formatButton(sender: UIButton){
//        sender.layer.borderWidth = 1.0
//        sender.layer.borderColor = mainColor.CGColor
//        sender.titleLabel?.textAlignment = NSTextAlignment.Center
//        sender.backgroundColor = UIColor.whiteColor()
//        sender.setTitleColor(mainColor, forState: UIControlState.allZeros)
//        sender.titleLabel?.font = UIFont(name: "Helvetica", size: 13.0)
//        sender.layer.cornerRadius = 5
//        sender.layer.masksToBounds = true
//    }
    
//    func login(){
//        self.performSegueWithIdentifier("loginSegue", sender: self)
//    }
//    
//    func signup(){
//    
//    }
    
    func sortFunc(num1: Int, num2: Int) -> Bool {
        return num1 > num2
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // Return the number of sections.
        var numberOfSections = 0
        switch profileSegment.selectedSegmentIndex {
        case 0:
            numberOfSections = treatmentSections.count + 1
            break
        case 1:
            numberOfSections = 1
            break
        case 2:
//            if username != nil{
                numberOfSections = 3
//            } else{
//                numberOfSections = 1
//            }
            break
        default:
            numberOfSections = 0
            break
        }
        return numberOfSections
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
        }else if profileSegment.selectedSegmentIndex == 1{
            numberOfRows = self.broadcastList.count
        }else if profileSegment.selectedSegmentIndex == 2{
//            if username != nil{
                switch section{
                case 0: numberOfRows = 3
                    break
                case 1: numberOfRows = 1
                    break
                case 2: numberOfRows = 1
                    break
                default: numberOfRows = 0
                    break
                }
//            }else{
//                numberOfRows = 1
//            }
        }
        return numberOfRows
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if profileSegment.selectedSegmentIndex == 0{
            if indexPath.section == 0{
                let cell = tableView.dequeueReusableCellWithIdentifier("treatmentSummaryCell", forIndexPath: indexPath) as! TreatmentSummaryTableViewCell
                cell.selectionStyle = UITableViewCellSelectionStyle.None
                if clinicReportList.count > 0{
                    cell.treatmentList = treatmentList
                    cell.clinicReportList = clinicReportList
                }
                return cell
            }else{
                let cell = tableView.dequeueReusableCellWithIdentifier("patientStatusListCell", forIndexPath: indexPath) as! PatientStatusTableViewCell
                cell.selectionStyle = UITableViewCellSelectionStyle.None
                var patientStatusListInSection = (treatmentSections[indexPath.section - 1] as! NSDictionary).objectForKey("patientStatus") as! NSArray
                cell.patientStatus = patientStatusListInSection[indexPath.row] as! NSDictionary
                return cell
            }
        }else if profileSegment.selectedSegmentIndex == 1{
            let cell = tableView.dequeueReusableCellWithIdentifier("questionListCell", forIndexPath: indexPath) as! QuestionListTableViewCell
//            cell.selectionStyle = UITableViewCellSelectionStyle.None
            var broadcast = broadcastList[indexPath.row] as! NSDictionary
            
            var dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "MM/dd" // superset of OP's format
            var dateInserted = NSDate(timeIntervalSince1970: (broadcast["dateInserted"] as! Double)/1000 as NSTimeInterval)
            let dateStr = dateFormatter.stringFromDate(dateInserted)
            
            var questionLabel = UILabel(frame: CGRectMake(15, 150, UIScreen.mainScreen().bounds.width - 30, CGFloat.max))
            questionLabel.numberOfLines = 0
            questionLabel.lineBreakMode = NSLineBreakMode.ByCharWrapping
            questionLabel.font = UIFont(name: "Helvetica", size: 13.0)
            questionLabel.text = broadcast.objectForKey("body") as! String
            questionLabel.textColor = UIColor.blackColor()
            questionLabel.sizeToFit()

            var dateInsertedLabel = UILabel(frame: CGRectMake(10, questionLabel.frame.height + 5, 60, 20))
            dateInsertedLabel.textColor = UIColor.darkGrayColor()
            dateInsertedLabel.text = dateStr
            dateInsertedLabel.font = UIFont(name: "Helvetica", size: 12.0)

            var reviewsLabel = UILabel(frame: CGRectMake(UIScreen.mainScreen().bounds.width - 15 - 80, questionLabel.frame.height + 5, 80, 20))
            reviewsLabel.textColor = UIColor.darkGrayColor()
            reviewsLabel.font = UIFont(name: "Helvetica", size: 12.0)
            reviewsLabel.text = (broadcast["countComments"] as! NSNumber).stringValue + "评论"
            reviewsLabel.textAlignment = NSTextAlignment.Right
            
            cell.addSubview(questionLabel)
            cell.addSubview(dateInsertedLabel)
            cell.addSubview(reviewsLabel)
            self.heightForQuestionRow.setObject(questionLabel.frame.height, forKey: indexPath)
            return cell
        }else{
            if indexPath.section == 0 {
                let cell = tableView.dequeueReusableCellWithIdentifier("personalSettingCell", forIndexPath: indexPath) as! UITableViewCell
                cell.selectionStyle = UITableViewCellSelectionStyle.None
                //            if username != nil{
                switch indexPath.row{
                case 0: cell.textLabel?.text = "我关注的病友"
                    break
                case 1: cell.textLabel?.text = "关注我的病友"
                    break
                case 2: cell.textLabel?.text = "我的评论"
                    break
                default: break
                }
                return cell
            }else if indexPath.section == 1{
                let cell = tableView.dequeueReusableCellWithIdentifier("accountSettingCell", forIndexPath: indexPath) as! UITableViewCell
                cell.selectionStyle = UITableViewCellSelectionStyle.None
                cell.textLabel?.text = "更改个人信息"
                return cell
            } else {
                let cell = tableView.dequeueReusableCellWithIdentifier("logoutCell", forIndexPath: indexPath) as! UITableViewCell
                cell.selectionStyle = UITableViewCellSelectionStyle.None
                cell.textLabel?.text = "退出登录"
                return cell
            }
        }
    }
    
    func tableView(_tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat{
        var rowHeight: CGFloat = 0.0
        if profileSegment.selectedSegmentIndex == 0{
            if indexPath.section == 0{
                rowHeight = clinicReportList.count > 0 ? 150 : 0
            }else{
                rowHeight = UITableViewAutomaticDimension
            }
        }else if profileSegment.selectedSegmentIndex == 1{
            var questionLabelHeight = self.heightForQuestionRow.objectForKey(indexPath)
            if questionLabelHeight != nil{
                rowHeight = (self.heightForQuestionRow.objectForKey(indexPath) as! CGFloat) + 35
            }
//            rowHeight = self.heightForQuestionRow.objectForKey(indexPath) as! CGFloat
//            rowHeight = 80
        }else if profileSegment.selectedSegmentIndex == 2{
            rowHeight = 50
        }
        
        return rowHeight
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        var heightForHeader:CGFloat = 0
        if profileSegment.selectedSegmentIndex == 0{
            if section == 0 {
                heightForHeader = 40
            }else{
                var treatmentLineCount:AnyObject? = self.treatmentSections[section-1]["treatmentLineCount"]
                if treatmentLineCount == nil{
                    heightForHeader = 0
                }else{
//                    var treatmentStr = self.treatmentSections[section-1]["treatmentLineCount"] as! Int
//                    heightForHeader = CGFloat(35 * treatmentStr + 4)
                    heightForHeader = (self.treatmentSections[section-1]["sectionHeight"] as! CGFloat) + 5
                    if UIScreen.mainScreen().bounds.width < 375 {
                        heightForHeader += 35
                    }
                }
            }
        }
        if profileSegment.selectedSegmentIndex == 1 {
            heightForHeader = 40
        }
        if profileSegment.selectedSegmentIndex == 2 {
            heightForHeader = 10
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
                var treatmentList: NSMutableArray = NSMutableArray(array: treatmentStr.componentsSeparatedByString("**"))
                for treatment in treatmentList {
                    var treatmentItemStr:String = treatment as! String
                    
                    treatmentItemStr = treatmentItemStr.stringByReplacingOccurrencesOfString("*", withString: "", options:  NSStringCompareOptions.LiteralSearch, range: nil)
                    if (treatmentItemStr as NSString).length == 0{
                        treatmentList.removeObject(treatment)
                    }
                }
                
                for treatment in treatmentList {
                    var treatmentStr = treatment as! String
                    if (treatmentStr as! NSString).length == 0{
                        break
                    }
                    if treatmentStr.substringWithRange(Range(start: treatmentStr.startIndex, end: advance(treatmentStr.startIndex, 1))) == "*" {
                        treatmentStr = treatmentStr.substringFromIndex(advance(treatmentStr.startIndex, 1))
                    }
                    var treatmentNameAndDosage:NSArray = treatmentStr.componentsSeparatedByString("*")
                    var treatmentName = treatmentNameAndDosage[0] as! String
                    var treatmentDosage = String()
                    var treatmentNameLabel = UILabel()
                    var dosageLabel = UILabel()
                    if treatmentNameAndDosage.count > 1{
                        treatmentDosage = treatmentNameAndDosage[1] as! String
//                        var dosageLableLine = (treatmentDosage as NSString).length/14 + 1
//                        var height = CGFloat(30 * dosageLableLine)
                        treatmentNameLabel = UILabel(frame: CGRectMake(10.0, treatmentY, 90.0, 30.0))
                        treatmentNameLabel.text = treatmentName
                        dosageLabel.frame = CGRectMake(110.0, treatmentY, 170.0, 0)
                        dosageLabel.text = treatmentDosage
                        dosageLabel.font = UIFont(name: "Helvetica-Bold", size: 13.0)
                        dosageLabel.numberOfLines = 0
//                        dosageLable.backgroundColor = UIColor.lightGrayColor()
                        dosageLabel.sizeToFit()
                        var height:CGFloat = dosageLabel.frame.height > treatmentNameLabel.frame.height ? dosageLabel.frame.height : treatmentNameLabel.frame.height
                        treatmentY += height + 5
                        treatmentNameLabel.font = UIFont(name: "Helvetica-Bold", size: 14.0)
                        treatmentNameLabel.layer.cornerRadius = 5
                        treatmentNameLabel.backgroundColor = tabBarColor
                        treatmentNameLabel.textColor = mainColor
                        treatmentNameLabel.layer.masksToBounds = true
                        treatmentNameLabel.layer.borderColor = mainColor.CGColor
                        treatmentNameLabel.layer.borderWidth = 1.0
                        treatmentNameLabel.textAlignment = NSTextAlignment.Center
                        dosageLabel.textColor = mainColor
                    }else{
                        var treatmentLine = (treatmentName as NSString).length/20 + 1
                        var height = CGFloat(30 * treatmentLine)
                        treatmentNameLabel = UILabel(frame: CGRectMake(10.0, treatmentY, 90.0, height))
                        treatmentNameLabel.text = treatmentName
                        treatmentY += height + 5
                        treatmentNameLabel.font = UIFont(name: "Helvetica-Bold", size: 13.0)
                        treatmentNameLabel.textColor = mainColor
                        treatmentNameLabel.backgroundColor = tabBarColor
                        treatmentNameLabel.layer.borderColor = mainColor.CGColor
                        treatmentNameLabel.layer.borderWidth = 1.0
                        treatmentNameLabel.layer.masksToBounds = true
                        treatmentNameLabel.layer.cornerRadius = 5
                        treatmentNameLabel.textAlignment = NSTextAlignment.Center
                    }
                    headerView.addSubview(treatmentNameLabel)
                    headerView.addSubview(dosageLabel)
                    
                    var separatorLine:UIImageView = UIImageView(frame: CGRectMake(5, 0, tableView.frame.size.width-10.0, 1.0))
                    separatorLine.image = UIImage(named: "grayline.png")?.stretchableImageWithLeftCapWidth(1, topCapHeight: 0)
                    
                    headerView.addSubview(separatorLine)
                }
            }
        }
        if profileSegment.selectedSegmentIndex == 1{
            var addBroadcastBtnWidth = 200
            var coordinateX:CGFloat = CGFloat((Int(UIScreen.mainScreen().bounds.width) - addBroadcastBtnWidth)/2)
            var addBroadcastBtn = UIButton(frame: CGRectMake(coordinateX, 5.0, CGFloat(addBroadcastBtnWidth), 30.0))
            addBroadcastBtn.backgroundColor = mainColor
            addBroadcastBtn.layer.cornerRadius = 5
            addBroadcastBtn.titleLabel?.textAlignment = NSTextAlignment.Center
            addBroadcastBtn.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
            addBroadcastBtn.setTitle("有新问题？点击发送广播", forState: UIControlState.Normal)
            addBroadcastBtn.titleLabel?.font = UIFont(name: "Helvetica-Bold", size: 14)
            addBroadcastBtn.addTarget(self, action: "addPost", forControlEvents: UIControlEvents.TouchUpInside)
            headerView.addSubview(addBroadcastBtn)
            
        }
        if profileSegment.selectedSegmentIndex == 2 {
            headerView = UIView(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.width, 10))
            headerView.backgroundColor = sectionHeaderColor
        }
        return headerView
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if profileSegment.selectedSegmentIndex == 2 {
            if indexPath.section == 2 {
                self.performSegueWithIdentifier("loginSegue", sender: self)
                publicService.logOutAccount()
                usedToBeInLoginView = true
            }
            if indexPath.section == 1 {
                self.performSegueWithIdentifier("setProfileSegue", sender: self)
            }
            if indexPath.section == 0 {
                if indexPath == 2{
                    self.performSegueWithIdentifier("commentListSegue", sender: self)
                }else{
                    var userListData = NSData()
                    if indexPath.row == 0{
                        userListData = haalthyService.getFollowingUsers(username! as String)!
                    }
                    if indexPath.row == 1{
                        userListData = haalthyService.getFollowerUsers(username! as String)!
                    }
                    var jsonResult = NSJSONSerialization.JSONObjectWithData(userListData, options: NSJSONReadingOptions.MutableContainers, error: nil)
                    if jsonResult is NSArray {
                        userList = jsonResult as! NSArray
                    }
                    self.performSegueWithIdentifier("userListSegue", sender: self)
                }
            }
        }
    }
    
    func addPost(){
        self.performSegueWithIdentifier("addPostSegue", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "addPostSegue" {
            (segue.destinationViewController as! AddPostViewController).isBroadcast = 1
        }
        if segue.identifier == "setPasswordSegue" {
            (segue.destinationViewController as! SettingPasswordViewController).username = userProfile.objectForKey("username") as! String
        }
        if segue.identifier == "userListSegue" {
            (segue.destinationViewController as! UserListTableViewController).userList = userList
        }
        if segue.identifier == "commentListSegue" {
            var commentList = NSArray()
            var commentListData = haalthyService.getCommentsByUsername(username as! String)
            var jsonResult = NSJSONSerialization.JSONObjectWithData(commentListData!, options: NSJSONReadingOptions.MutableContainers, error: nil)
            if jsonResult is NSArray {
                commentList = jsonResult as! NSArray
            }
            (segue.destinationViewController as! CommentListTableViewController).commentList = commentList
        }
        if segue.identifier == "setProfileSegue"{
            (segue.destinationViewController as! PatientProfileTableViewController).userProfile = userProfile.mutableCopy() as! NSMutableDictionary
        }
    }
}

//extension UserProfileViewController: SettingPasswordDelegate{
//    func getPassword(password: String){
//        
//    }
//}