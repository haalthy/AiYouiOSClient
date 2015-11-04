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
    var addFollowingBtn = UIButton()
    var newFollowerCount: Int = 0
    var unreadMentionedPostCount: Int = 0
    var unreadMentionedPostLabel = UILabel()
    var selectedPostId = Int()
    
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
                    var defaultEndDateMod: Double = getNSDateMod(defaultTreatmentEndDate * 1000)

                    var treatment = treatmentList[i] as! NSMutableDictionary
                    
//                    if (treatment.objectForKey("endDate") as! Double) > (NSDate().timeIntervalSince1970 * 1000){
                    println(treatment.objectForKey("treatmentName"))
                    println(treatment.objectForKey("endDate") as! Double)
                    println(defaultTreatmentEndDate * 1000)
                    if (treatment.objectForKey("endDate") as! Double) == (defaultEndDateMod){
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
                
                var dateFormatter = NSDateFormatter()
                dateFormatter.dateFormat = "yy/MM/dd" // superset of OP's format
                for time in timeList{
                    var dateInserted = NSDate(timeIntervalSince1970: Double(time)/1000 as NSTimeInterval)
                    let dateStr = dateFormatter.stringFromDate(dateInserted)
                    println(dateStr)
                }
                
                var index = 0
                var patientStatusIndex = 0
                if patientStatusIndex < patientStatusList.count{
                    var treatmentSection = NSMutableDictionary()
                    var patientStatusInTreatmentSection = NSMutableArray()
                    treatmentSection.setObject((NSDate().timeIntervalSince1970)*1000, forKey: "endDate")
                    treatmentSection.setObject((timeList[index] as AnyObject), forKey: "beginDate")
                    treatmentSection.setObject(patientStatusInTreatmentSection, forKey: "patientStatus")
                    while ((patientStatusList[patientStatusIndex]["insertedDate"] as! Int) > (timeList[index] as Int)) {
                        patientStatusInTreatmentSection.addObject(patientStatusList[patientStatusIndex])
                        patientStatusIndex++
                    }
                    if patientStatusInTreatmentSection.count > 0{
                        treatmentSections.addObject(treatmentSection)
                    }
                }
                
                while index < timeList.count-1 {
                    var treatmentSection = NSMutableDictionary()
                    var patientStatusInTreatmentSection = NSMutableArray()
                    treatmentSection.setObject(timeList[index+1] as AnyObject, forKey: "beginDate")
                    treatmentSection.setObject(timeList[index] as AnyObject, forKey: "endDate")
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
                        println(patientStatusList[patientStatusIndex]["insertedDate"])
                        println(timeList[index+1])
                        println(timeList[index])
                        while ((patientStatusIndex < patientStatusList.count) && ((patientStatusList[patientStatusIndex]["insertedDate"] as! Int) > (timeList[index+1] as Int)) && ((patientStatusList[patientStatusIndex]["insertedDate"] as! Int) < (timeList[index] as Int))) {
                            patientStatusInTreatmentSection.addObject(patientStatusList[patientStatusIndex])
                            patientStatusIndex++
                        }
                        treatmentSection.setObject(patientStatusInTreatmentSection, forKey: "patientStatus")
                    }
                    index++
//                    if (treatmentSection.objectForKey("treatmentDetails") != nil) && ((treatmentSection.objectForKey("treatmentDetails") is NSNull) == false) && ((treatmentSection.objectForKey("treatmentDetails") as! NSString).length > 0){
                        treatmentSections.addObject(treatmentSection)
//                    }
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
        self.tableview.contentInset = UIEdgeInsetsMake(-dummyViewHeight, 0, 0, 0)
        ((self.tabBarController?.tabBar.items as! NSArray).objectAtIndex(1) as! UITabBarItem).title = "我"
    }
    
    override func viewWillDisappear(animated: Bool) {
        viewContainer.removeFromSuperview()
        if profileOwnername != username{
            self.tabBarController?.tabBar.hidden = false
        }
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
            self.usernameLabel.text = self.userProfile.objectForKey("displayname") as! String
        }
        if profileOwnername != username{
            var isFollowingUserData: NSData? = haalthyService.isFollowingUser(profileOwnername as! String)
            if isFollowingUserData != nil {
                var isFollowingUserStr = NSString(data: isFollowingUserData!, encoding: NSUTF8StringEncoding)
                if isFollowingUserStr == "0"{
                    self.tabBarController?.tabBar.hidden = true
                    var addFollowingBtnWidth: CGFloat = 60
                    var addFollowingBtnOriginY:CGFloat = (self.navigationController?.navigationBar.frame)!.height + 30
                    addFollowingBtn = UIButton(frame: CGRectMake(UIScreen.mainScreen().bounds.width - addFollowingBtnWidth - 15, addFollowingBtnOriginY, addFollowingBtnWidth, 30))
                    addFollowingBtn.layer.cornerRadius = 5
                    addFollowingBtn.layer.masksToBounds = true
                    addFollowingBtn.setTitle("加关注", forState: UIControlState.Normal)
                    addFollowingBtn.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
                    addFollowingBtn.backgroundColor = mainColor
                    self.view.addSubview(addFollowingBtn)
                    addFollowingBtn.addTarget(self, action: "addFollowing:", forControlEvents: UIControlEvents.TouchUpInside)
                }
            }
        }else{
            var newFollowerCountData: NSData? = haalthyService.selectNewFollowCount()
            if newFollowerCountData != nil{
                var jsonResult = NSJSONSerialization.JSONObjectWithData(newFollowerCountData!, options: NSJSONReadingOptions.MutableContainers, error: nil)
                if jsonResult is NSDictionary {
                    newFollowerCount = ((jsonResult as! NSDictionary).objectForKey("count") as! NSNumber).integerValue
                    if newFollowerCount != 0{
                        self.profileSegment.selectedSegmentIndex = 2
                    }else{
                        var unreadMentionedPostCountData: NSData = haalthyService.getUnreadMentionedPostCount()!
                        unreadMentionedPostCount =  (NSString(data: unreadMentionedPostCountData, encoding: NSUTF8StringEncoding)! as String).toInt()!
                        if unreadMentionedPostCount != 0 {
                            self.profileSegment.selectedSegmentIndex = 2
                        }
                    }
                }
            }
        }
    }
    
    func addFollowing(sender: AnyObject) {
        let profileSet = NSUserDefaults.standardUserDefaults()
        if profileSet.objectForKey(accessNSUserData) != nil{
            var addFollowingData = haalthyService.addFollowing(profileOwnername as! String)
            var jsonResult = NSJSONSerialization.JSONObjectWithData(addFollowingData, options: NSJSONReadingOptions.MutableContainers, error: nil)
            var deleteResult = haalthyService.deleteFromSuggestedUser(profileOwnername as! String)
            println(NSString(data: deleteResult, encoding: NSUTF8StringEncoding))
        }
        addFollowingBtn.enabled = false
        addFollowingBtn.setTitle("已关注", forState: UIControlState.Normal)
        addFollowingBtn.setTitleColor(UIColor.lightGrayColor(), forState: UIControlState.Normal)
        addFollowingBtn.layer.borderColor = UIColor.lightGrayColor().CGColor
        haalthyService.increaseNewFollowCount(profileOwnername as! String)
    }
    
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
            numberOfSections = 3
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
                numberOfRows = 2
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
            switch section{
            case 0: numberOfRows = 4
                break
            case 1: numberOfRows = 1
                break
            case 2: numberOfRows = 1
                break
            default: numberOfRows = 0
                break
            }
        }
        return numberOfRows
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if profileSegment.selectedSegmentIndex == 0{
            if indexPath.section == 0{
                if indexPath.row == 0{
                    let cell = tableView.dequeueReusableCellWithIdentifier("treatmentSummaryCell", forIndexPath: indexPath) as! TreatmentSummaryTableViewCell
                    cell.selectionStyle = UITableViewCellSelectionStyle.None
                    if clinicReportList.count > 0{
                        cell.treatmentList = treatmentList
                        cell.clinicReportList = clinicReportList
                    }
                    return cell
                }else{
                    let cell = tableView.dequeueReusableCellWithIdentifier("editTreatmentIndentifier", forIndexPath:indexPath) as! UITableViewCell
                    if profileOwnername == username{
                        let editButtonWidth: CGFloat = 60.0
                        let editButtonHeight: CGFloat = 30.0
                        let marginWidth: CGFloat = 10.0
                        var editButton = UIButton(frame: CGRectMake(cell.frame.width - editButtonWidth - marginWidth, marginWidth, editButtonWidth, editButtonHeight))
                        editButton.titleLabel?.font = UIFont(name: fontStr, size: 12.0)
                        editButton.setTitleColor(UIColor.grayColor(), forState: UIControlState.Normal)
                        editButton.titleLabel?.textAlignment = NSTextAlignment.Center
                        let underlineAttribute = [NSUnderlineStyleAttributeName: NSUnderlineStyle.StyleSingle.rawValue]
                        let underlineAttributedString = NSAttributedString(string: "编辑", attributes: underlineAttribute)
                        editButton.setAttributedTitle(underlineAttributedString, forState: UIControlState.Normal)
                        cell.addSubview(editButton)
                        editButton.addTarget(self, action: "updateTreatment", forControlEvents: UIControlEvents.TouchUpInside)
                    }
                    return cell
                }
            }else{
                let cell = tableView.dequeueReusableCellWithIdentifier("patientStatusListCell", forIndexPath: indexPath) as! PatientStatusTableViewCell
                cell.selectionStyle = UITableViewCellSelectionStyle.None
                var patientStatusListInSection = (treatmentSections[indexPath.section - 1] as! NSDictionary).objectForKey("patientStatus") as! NSArray
                cell.patientStatus = patientStatusListInSection[indexPath.row] as! NSDictionary
                return cell
            }
        }else if profileSegment.selectedSegmentIndex == 1{
            let cell = tableView.dequeueReusableCellWithIdentifier("questionListCell", forIndexPath: indexPath) as! UITableViewCell
//            cell.selectionStyle = UITableViewCellSelectionStyle.None
            var broadcast = broadcastList[indexPath.row] as! NSDictionary
            
//            cell.feedBodyDelegate = self
//            cell.width = cell.frame.width
//            cell.indexPath = indexPath
//            cell.feed = broadcast
            var dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "yy/MM/dd" // superset of OP's format
            var dateInserted = NSDate(timeIntervalSince1970: (broadcast["dateInserted"] as! Double)/1000 as NSTimeInterval)
            let dateStr = dateFormatter.stringFromDate(dateInserted)
            
            var questionLabel = UILabel(frame: CGRectMake(15, 0, UIScreen.mainScreen().bounds.width - 30, CGFloat.max))
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
                cell.textLabel?.font = UIFont(name: fontStr, size: 14.0)
                cell.selectionStyle = UITableViewCellSelectionStyle.None
                //            if username != nil{
                switch indexPath.row{
                case 0: cell.textLabel?.text = "我关注的病友"
                    break
                case 1: cell.textLabel?.text = "关注我的病友"
                    var textLabelWidth:CGFloat = (cell.textLabel?.frame)!.width
                    var newFollowerCountLabel = UILabel(frame: CGRectMake(110, 5, 20, 20))
                    if newFollowerCount != 0{
                        newFollowerCountLabel.text = (newFollowerCount as! NSNumber).stringValue
                        newFollowerCountLabel.textColor = UIColor.redColor()
                        cell.addSubview(newFollowerCountLabel)
                    }
                    break
                case 2: cell.textLabel?.text = "我的评论"
                    break
                case 3: cell.removeAllSubviews()
                    var titleLabel = UILabel(frame: CGRectMake(10, 5, 100, 40))
                    titleLabel.text = "@提到我的"
                    titleLabel.textColor = UIColor.blackColor()
                    cell.addSubview(titleLabel)
                    var textLabelWidth:CGFloat = (cell.textLabel?.frame)!.width
                    unreadMentionedPostLabel = UILabel(frame: CGRectMake(110, 5, 20, 20))
                    if unreadMentionedPostCount != 0{
                        unreadMentionedPostLabel.text = (unreadMentionedPostCount as! NSNumber).stringValue
                        unreadMentionedPostLabel.textColor = UIColor.redColor()
                        cell.addSubview(unreadMentionedPostLabel)
                    }
                    break
                default: break
                }
                return cell
            }else if indexPath.section == 1{
                let cell = tableView.dequeueReusableCellWithIdentifier("accountSettingCell", forIndexPath: indexPath) as! UITableViewCell
                cell.textLabel?.font = UIFont(name: fontStr, size: 14.0)
                cell.selectionStyle = UITableViewCellSelectionStyle.None
                cell.textLabel?.text = "更改个人信息"
                return cell
            } else {
                let cell = tableView.dequeueReusableCellWithIdentifier("logoutCell", forIndexPath: indexPath) as! UITableViewCell
                cell.textLabel?.font = UIFont(name: fontStr, size: 14.0)
                cell.selectionStyle = UITableViewCellSelectionStyle.None
                cell.textLabel?.text = "退出登录"
                return cell
            }
        }
    }
    
    func updateTreatment(){
        self.performSegueWithIdentifier("updateTreatment", sender: self)
    }
    
    func tableView(_tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat{
        var rowHeight: CGFloat = 0.0
        if profileSegment.selectedSegmentIndex == 0{
            if indexPath.section == 0{
                if indexPath.row == 0{
                    rowHeight = clinicReportList.count > 0 ? 150 : 0
                }else{
                    rowHeight = 44
                }
            }else{
                rowHeight = UITableViewAutomaticDimension
            }
        }else if profileSegment.selectedSegmentIndex == 1{
            var questionLabelHeight = self.heightForQuestionRow.objectForKey(indexPath)
            if questionLabelHeight != nil{
                rowHeight = (self.heightForQuestionRow.objectForKey(indexPath) as! CGFloat) + 35
            }
        }else if profileSegment.selectedSegmentIndex == 2{
            rowHeight = 50
        }
        
        return rowHeight
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        var heightForHeader:CGFloat = 0
        if profileSegment.selectedSegmentIndex == 0{
            if section == 0 {
                if (self.clinicReportList.count > 0){
                    heightForHeader = 40
                }
            }else{
                var treatmentLineCount:AnyObject? = self.treatmentSections[section-1]["treatmentLineCount"]
                if treatmentLineCount == nil{
                    heightForHeader = 0
                }else{
                    if (self.treatmentSections[section-1].objectForKey("treatmentDetails") != nil) && ((self.treatmentSections[section-1].objectForKey("treatmentDetails") is NSNull) == false) && ((self.treatmentSections[section-1].objectForKey("treatmentDetails") as! NSString).length > 0){

                    heightForHeader = (self.treatmentSections[section-1]["sectionHeight"] as! CGFloat) + 5
                    if UIScreen.mainScreen().bounds.width < 375 {
                        heightForHeader += 35
                    }
                    }else{
                        heightForHeader = 0
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
                    dateLabel = UILabel(frame: CGRectMake(265, treatmentY, 100, 30))
                }else{
                    dateLabel = UILabel(frame: CGRectMake(265, treatmentY, 100, 30))
                    treatmentY += 35
                    heightForHeader += 35
                }
                
                var dateFormatter = NSDateFormatter()
                dateFormatter.dateFormat = "yy/MM/dd" // superset of OP's format
                
                var beginDate = NSDate(timeIntervalSince1970: (treatmentSections[section-1]["beginDate"] as! Double)/1000 as NSTimeInterval)
                var endDate = NSDate(timeIntervalSince1970: (treatmentSections[section-1]["endDate"] as! Double)/1000 as NSTimeInterval)
                let beginDateStr = dateFormatter.stringFromDate(beginDate)
                let endDateStr = dateFormatter.stringFromDate(endDate)
                dateLabel.text = beginDateStr + "-" + endDateStr
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
                        dosageLabel.frame = CGRectMake(110.0, treatmentY + 5, 170.0, 0)
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
                publicService.logOutAccount()
                println("logout")
                self.performSegueWithIdentifier("loginSegue", sender: self)
                usedToBeInLoginView = true
            }
            if indexPath.section == 1 {
                self.performSegueWithIdentifier("setProfileSegue", sender: self)
            }
            if indexPath.section == 0 {
                if indexPath.row == 2 {
                    self.performSegueWithIdentifier("commentListSegue", sender: self)
                }else if indexPath.row == 3 {
                    unreadMentionedPostCount = 0
                    haalthyService.markMentionedPostAsRead()
                    self.performSegueWithIdentifier("mentionedPostSegue", sender: self)
                }else{
                    var userListData = NSData()
                    if indexPath.row == 0{
                        userListData = haalthyService.getFollowingUsers(username! as String)!
                    }
                    if indexPath.row == 1{
                        newFollowerCount = 0
                        userListData = haalthyService.getFollowerUsers(username! as String)!
                        haalthyService.refreshNewFollowCount()
                    }
                    var jsonResult = NSJSONSerialization.JSONObjectWithData(userListData, options: NSJSONReadingOptions.MutableContainers, error: nil)
                    if jsonResult is NSArray {
                        userList = jsonResult as! NSArray
                    }
                    self.performSegueWithIdentifier("userListSegue", sender: self)
                }
            }
        }
        if profileSegment.selectedSegmentIndex == 1 {
            selectedPostId = (broadcastList[indexPath.row] as! NSDictionary).objectForKey("postID") as! Int
            self.performSegueWithIdentifier("postDetailSegue", sender: self)
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
        if segue.identifier == "setProfileSegue" {
            (segue.destinationViewController as! PatientProfileTableViewController).userProfile = userProfile.mutableCopy() as! NSMutableDictionary
        }
        if segue.identifier == "updateTreatment" {
            (segue.destinationViewController as! UpdateTreatmentTableViewController).treatmentList = self.treatmentList
        }
        if segue.identifier == "postDetailSegue" {
            (segue.destinationViewController as! ShowPostDetailTableViewController).postId = selectedPostId
        }
    }
}
