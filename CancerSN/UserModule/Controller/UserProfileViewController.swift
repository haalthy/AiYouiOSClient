//
//  UserProfileViewController.swift
//  CancerSN
//
//  Created by lily on 9/1/15.
//  Copyright (c) 2015 lily. All rights reserved.
//

import UIKit

class UserProfileViewController: UIViewController , UITableViewDataSource, UITableViewDelegate {
    // 控件关联
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var userProfileHeaderView: UIView!

    // 自定义变量 old
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
    var ceaList = NSArray()
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
    
    // 自定义变量

    var headerHeight = CGFloat()
    var screenWidth = CGFloat()
    var clinicChartItemList = NSMutableDictionary()
    var isSelectedTreatment = Bool()

    //“治疗与方案” ”与我相关“
    var treatmentHeaderBtn = UIButton()
    var postHeaderBtn = UIButton()
    var treatmentBtnLine = UIView()
    var postBtnLine = UIView()
    var segmentSectionBtnHeight = CGFloat()

    //
    override func viewDidLoad() {
        super.viewDidLoad()
//        keychainAccess.setPasscode(usernameKeyChain, passcode: "AY1449535482715.927")
//        keychainAccess.setPasscode(passwordKeyChain, passcode: "password")
        username = keychainAccess.getPasscode(usernameKeyChain)
        password = keychainAccess.getPasscode(passwordKeyChain)
        if self.tabBarController?.selectedIndex == 2{
            profileOwnername = self.username
        }else{
            
        }
        getTreatmentsData()
        if self.userProfile.count == 0 {
            let alert = UIAlertController(title: "提示", message: "oops....网络不给力", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "确定", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
            self.tabBarController?.selectedIndex = 0
            
            print(self.tabBarController?.selectedIndex)
        }else{
            initVariables()
            initContentView()
            self.tableView.delegate = self
            self.tableView.dataSource = self
            self.tableView.reloadData()
        }
    }
    
    // MARK: - Init Variables
    func initVariables() {
        headerHeight = UIApplication.sharedApplication().statusBarFrame.height + (self.navigationController?.navigationBar.frame.height)!
        screenWidth = UIScreen.mainScreen().bounds.width
        segmentSectionBtnHeight = 43
        isSelectedTreatment = true
    }
    
    // MARK: - Init Related ContentView
    
    func initContentView() {
        //初始化“治疗和方案”
//        self.treatmentHeaderBtn.frame = CGRectMake(0, headerHeight+1, screenWidth/2 , segmentSectionBtnHeight)
        self.treatmentHeaderBtn.frame = CGRectMake(0, 1, screenWidth/2 , segmentSectionBtnHeight)

        self.treatmentHeaderBtn.setTitle(processHeaderStr, forState: UIControlState.Normal)
        self.treatmentBtnLine.frame = CGRectMake(0, segmentSectionBtnHeight - 2, screenWidth/2, 2)
        self.treatmentHeaderBtn.addSubview(treatmentBtnLine)
        self.treatmentHeaderBtn.addTarget(self, action: "selectSegment:", forControlEvents: UIControlEvents.TouchUpInside)
//        self.view.addSubview(treatmentHeaderBtn)
        self.userProfileHeaderView.addSubview(treatmentHeaderBtn)
        headerBtnFormatBeSelected(self.treatmentHeaderBtn)
        
        //初始化“与我相关”
        self.postHeaderBtn.frame = CGRectMake(screenWidth/2, 1, screenWidth/2, segmentSectionBtnHeight)
        if (self.username == self.profileOwnername) {
            self.postHeaderBtn.setTitle(myProfileStr, forState: UIControlState.Normal)
        }else{
            if (self.userProfile.valueForKey("gender") as! String) == "F"{
                self.postHeaderBtn.setTitle(hisProfileStr, forState: UIControlState.Normal)
            }else{
                self.postHeaderBtn.setTitle(herProfileStr, forState: UIControlState.Normal)
            }
        }
        self.postBtnLine.frame = CGRectMake(0, segmentSectionBtnHeight - 2, screenWidth/2, 2)
        self.postHeaderBtn.addSubview(postBtnLine)
        self.postHeaderBtn.addTarget(self, action: "selectSegment:", forControlEvents: UIControlEvents.TouchUpInside)
//        self.view.addSubview(postHeaderBtn)
        self.userProfileHeaderView.addSubview(postHeaderBtn)
        headerBtnFormatBeDeselected(self.postHeaderBtn)
        
        //初始化分割线
        let seperateLine = UIView(frame: CGRectMake(0, 1+segmentSectionBtnHeight, screenWidth, 0.5))
        seperateLine.backgroundColor = seperateLineColor
        self.userProfileHeaderView.addSubview(seperateLine)

//        self.view.addSubview(seperateLine)
        
        //头像
        let portraitView = UIImageView(frame: CGRectMake(15, 20 + segmentSectionBtnHeight + 2, 40, 40))
        portraitView.layer.cornerRadius = 20
        portraitView.layer.masksToBounds = true
        if (self.userProfile.valueForKey("imageURL") != nil) && (self.userProfile.valueForKey("imageURL") is NSNull) == false {
            let portraitURL = self.userProfile.valueForKey("imageURL") as! String
//            let imageData: NSData = NSData(base64EncodedString: dataString, options: NSDataBase64DecodingOptions(rawValue: 0))!
            let url : NSURL = NSURL(string: portraitURL)!
            let imageData = NSData(contentsOfURL: url)
            if imageData != nil {
                portraitView.image = UIImage(data: imageData!)
            }else{
                portraitView.backgroundColor = imageViewBackgroundColor
            }
        }else{
            portraitView.image = UIImage(named: "Mario.jpg")
        }
//        self.view.addSubview(portraitView)
        self.userProfileHeaderView.addSubview(portraitView)
        
        //关注

        if (haalthyService.isFollowingUser(self.profileOwnername as! String) != nil) && (self.username != self.profileOwnername){
            let followBtn = UIButton(frame: CGRectMake(screenWidth - followBtnRightSpace - followBtnWidth , followBtnTopSpace, followBtnWidth, followBtnHeight))
            let addFollowingImage = UIImageView(image: UIImage(named: "btn_addFollowing"))
            followBtn.addSubview(addFollowingImage)
            followBtn.layer.borderColor = followBtnBorderColor.CGColor
            followBtn.layer.borderWidth = followBtnBorderWidth
            followBtn.layer.cornerRadius = cornerRadius
            self.userProfileHeaderView.addSubview(followBtn)
        }
        //昵称 和 profile描述 标签
        let profileLabelWidth: CGFloat = screenWidth - 25 - 40 - 15 - followBtnWidth
        let nicknameLabel = UILabel(frame: CGRectMake(65, 45 + 23, profileLabelWidth, 14))
        nicknameLabel.textColor = nicknameColor
        nicknameLabel.font = nicknameFont
        nicknameLabel.text = self.userProfile.valueForKey("displayname") as? String
//        self.view.addSubview(nicknameLabel)
        self.userProfileHeaderView.addSubview(nicknameLabel)
        
        let profileLabel = UILabel(frame: CGRectMake(65,  90, profileLabelWidth, 12))
        profileLabel.textColor = UIColor.lightGrayColor()
        profileLabel.font = UIFont(name: fontStr, size: 12.0)
        let profileStr = publicService.getProfileStrByDictionary(self.userProfile)
        profileLabel.text = profileStr
//        self.view.addSubview(profileLabel)
        self.userProfileHeaderView.addSubview(profileLabel)
        //
    }
    
    
    // MARK: - Function
    func selectSegment(sender: UIButton){
        if sender == treatmentHeaderBtn {
            headerBtnFormatBeSelected(treatmentHeaderBtn)
            headerBtnFormatBeDeselected(postHeaderBtn)
            isSelectedTreatment = true
        }
        if sender == postHeaderBtn {
            headerBtnFormatBeSelected(postHeaderBtn)
            headerBtnFormatBeDeselected(treatmentHeaderBtn)
            isSelectedTreatment = false
        }
        self.tableView.reloadData()
    }
    
    func headerBtnFormatBeSelected(sender: UIButton){
        sender.setTitleColor(headerColor, forState: UIControlState.Normal)
        sender.titleLabel?.font = UIFont(name: fontBoldStr, size: 13.0)
        if sender == treatmentHeaderBtn{
            treatmentBtnLine.backgroundColor = headerColor
            postBtnLine.backgroundColor = UIColor.whiteColor()
        }
        if sender == postHeaderBtn{
            postBtnLine.backgroundColor = headerColor
            treatmentBtnLine.backgroundColor = UIColor.whiteColor()
        }
    }
    
    func headerBtnFormatBeDeselected(sender: UIButton){
        sender.setTitleColor(UIColor.lightGrayColor(), forState: UIControlState.Normal)
        sender.titleLabel?.font = UIFont(name: fontBoldStr, size: 13.0)

    }
    // MARK: - Table view data source
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if isSelectedTreatment {
            return self.treatmentSections.count + 2
        }else{
            return 1
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var numberOfRows: Int = 0
        if isSelectedTreatment {
            if section == 0 {
                if self.clinicReportList.count > 0 {
                    numberOfRows = 1
                }else{
                    numberOfRows = 0
                }
            }else if section == 1{
                numberOfRows = 1
            }else{
                let patientStatus = treatmentSections[section-2]["patientStatus"]
                
                if patientStatus != nil {
                    numberOfRows = (patientStatus as! NSArray).count
                }else{
                    numberOfRows = 0
                }
            }
        }else{
            numberOfRows = relatedToMe.count + 1
        }
        return numberOfRows
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        var rowHeight: CGFloat = 0.0
        if isSelectedTreatment {
            if indexPath.section == 0{
                if indexPath.row == 0{
                    rowHeight = self.clinicReportList.count > 0 ? 234 : 0
                }
            }
            if indexPath.section > 1{
                let patientStatusListInSection = (treatmentSections[indexPath.section - 2] as! NSDictionary).objectForKey("patientStatus") as! NSArray
                let patientStatusFrame = PatientStatusFrame()
                patientStatusFrame.cellWidth = screenWidth
                patientStatusFrame.patientStatus = patientStatusListInSection[indexPath.row] as! NSDictionary
                rowHeight = patientStatusFrame.cellHeight
            }
        }else{
            if indexPath.row < relatedToMe.count {
                rowHeight = cellHeight
            }else{
                rowHeight = logoutCellHeight
            }
        }
        return rowHeight
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier:String = "cell"
        let cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: cellIdentifier)
        if isSelectedTreatment {
            if indexPath.section == 0 {
                if indexPath.row == 0{
                    let treatmentSummaryCell = tableView.dequeueReusableCellWithIdentifier("ChartSummaryIdentifier", forIndexPath: indexPath) as! ChartSummaryTableViewCell
                    if clinicReportList.count > 0{
                        treatmentSummaryCell.treatmentList = treatmentList
                        treatmentSummaryCell.clinicReportList = clinicReportList
                    }
                    return treatmentSummaryCell
                }
            }else if indexPath.section > 1 {
                let patientstatusCell = tableView.dequeueReusableCellWithIdentifier("patientstatusIdentifier", forIndexPath: indexPath) as! PatientStatusTableViewCell
                patientstatusCell.selectionStyle = UITableViewCellSelectionStyle.None
                let patientStatusListInSection = (treatmentSections[indexPath.section - 2] as! NSDictionary).objectForKey("patientStatus") as! NSArray
                patientstatusCell.indexPath = indexPath
                patientstatusCell.patientStatus = patientStatusListInSection[indexPath.row] as! NSDictionary
                return patientstatusCell
            }
        }else{
            if indexPath.row < relatedToMe.count{
                cell.textLabel?.text = relatedToMe[indexPath.row] as! String
                cell.textLabel?.textColor = cellTextColor
                cell.textLabel?.font = cellTextFont
                cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
            }else{
                //退出登录
                let logoutBtn = UIButton(frame: CGRect(x: logoutBtnLeftSpace, y: logoutBtnTopSpace, width: screenWidth - logoutBtnLeftSpace - logoutBtnRightSpce, height: logoutBtnHeight))
                logoutBtn.backgroundColor = headerColor
                logoutBtn.setTitle("退出登录", forState: UIControlState.Normal)
                logoutBtn.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
                logoutBtn.titleLabel?.font = logoutBtnTextFont
                logoutBtn.layer.cornerRadius = cornerRadius
                logoutBtn.layer.masksToBounds = true
                cell.addSubview(logoutBtn)
            }
            let seperatorLine:UIView = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: seperatorLineH))
            seperatorLine.backgroundColor = seperateLineColor
            cell.addSubview(seperatorLine)
        }
        return cell
    }

    func getTreatmentsData(){
        if (username != nil) && (password != nil){
            var jsonResult:AnyObject? = nil
            let userDetailData = haalthyService.getUserDetail(profileOwnername! as String)
            if userDetailData != nil{
                jsonResult = try? NSJSONSerialization.JSONObjectWithData(userDetailData!, options: NSJSONReadingOptions.MutableContainers)
                            let str: NSString = NSString(data: userDetailData!, encoding: NSUTF8StringEncoding)!
                            print(str)
            }

            if jsonResult != nil{
                let userDetail = (jsonResult as! NSDictionary).objectForKey("content")
                treatmentList = userDetail!.objectForKey("treatments") as! NSMutableArray

                self.patientStatusList = userDetail!.objectForKey("patientStatus") as! NSArray
                self.clinicReportList = userDetail!.objectForKey("clinicReport") as! NSArray
                self.userProfile = userDetail!.objectForKey("userProfile") as! NSDictionary
                var timeList = [Int]()
                let timeSet = NSMutableSet()
                for var i = 0; i < treatmentList.count; i++ {
                    treatmentList[i] = treatmentList[i] as! NSMutableDictionary
                    treatmentList[i].setObject(getNSDateMod(treatmentList[i].objectForKey("beginDate") as! Double), forKey:"beginDate")
                    treatmentList[i].setObject(getNSDateMod(treatmentList[i].objectForKey("endDate") as! Double), forKey:"endDate")
                    let defaultEndDateMod: Double = getNSDateMod(defaultTreatmentEndDate * 1000)

                    let treatment = treatmentList[i] as! NSMutableDictionary

                    if (treatment.objectForKey("endDate") as! Double) == (defaultEndDateMod){
                        treatment.setObject(((NSDate().timeIntervalSince1970 as NSNumber).integerValue * 1000) as AnyObject, forKey:"endDate")
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
                timeList.sortInPlace(>)

                let dateFormatter = NSDateFormatter()
                dateFormatter.dateFormat = "yy/MM/dd" // superset of OP's format
                for time in timeList{
                    let dateInserted = NSDate(timeIntervalSince1970: Double(time)/1000 as NSTimeInterval)
                    let dateStr = dateFormatter.stringFromDate(dateInserted)
                }

                var index = 0
                var patientStatusIndex = 0
                if (patientStatusIndex < patientStatusList.count) && (timeList.count>0){
                    let treatmentSection = NSMutableDictionary()
                    let patientStatusInTreatmentSection = NSMutableArray()
                    treatmentSection.setObject((NSDate().timeIntervalSince1970)*1000, forKey: "endDate")
                    treatmentSection.setObject((timeList[index] as AnyObject), forKey: "beginDate")
                    treatmentSection.setObject(patientStatusInTreatmentSection, forKey: "patientStatus")
                    while ((patientStatusIndex < patientStatusList.count) && (patientStatusList[patientStatusIndex]["insertedDate"] as! Int) > (timeList[index] as Int)) {
                        patientStatusInTreatmentSection.addObject(patientStatusList[patientStatusIndex])
                        patientStatusIndex++
                    }
                    if patientStatusInTreatmentSection.count > 0{
                        treatmentSections.addObject(treatmentSection)
                    }
                }

                while index < timeList.count-1 {
                    let treatmentSection = NSMutableDictionary()
                    let patientStatusInTreatmentSection = NSMutableArray()
                    treatmentSection.setObject(timeList[index+1] as AnyObject, forKey: "beginDate")
                    treatmentSection.setObject(timeList[index] as AnyObject, forKey: "endDate")
                    var treatmentStr = ""
                    var dosageStr = ""
                    for var treatmentIndex = 0; treatmentIndex < treatmentList.count; treatmentIndex++ {
                        let treatment = treatmentList[treatmentIndex] as! NSDictionary
                        
                        if ((treatment.objectForKey("endDate") as? Int) >= (timeList[index] as Int)) && ((treatment.objectForKey("beginDate") as? Int) <= (timeList[index+1] as Int)) {
                            treatmentStr += (treatment["treatmentName"] as! String) + " "
                            if treatment["dosage"] != nil{
                                dosageStr += treatment["dosage"] as! String
                            }
                        }
                    }
                    if treatmentStr == "" {
                        treatmentStr = "空窗期"
                    }
                    treatmentSection.setObject(treatmentStr, forKey: "treatmentTitle")
                    treatmentSection.setObject(dosageStr, forKey: "dosage")
                    if patientStatusIndex < patientStatusList.count{
                        while ((patientStatusIndex < patientStatusList.count) && ((patientStatusList[patientStatusIndex]["insertedDate"] as! Int) > (timeList[index+1] as Int)) && ((patientStatusList[patientStatusIndex]["insertedDate"] as! Int) < (timeList[index] as Int))) {
                            patientStatusInTreatmentSection.addObject(patientStatusList[patientStatusIndex])
                            patientStatusIndex++
                        }
                        treatmentSection.setObject(patientStatusInTreatmentSection, forKey: "patientStatus")
                    }
                    index++
                    treatmentSections.addObject(treatmentSection)
                }
                if patientStatusIndex < patientStatusList.count{
                    let treatmentSection = NSMutableDictionary()
                    let patientStatusInTreatmentSection = NSMutableArray()
                    treatmentSection.setObject((patientStatusList[patientStatusIndex]["insertedDate"] as! Int), forKey: "endDate")
                    treatmentSection.setObject((patientStatusList[patientStatusList.count - 1]["insertedDate"] as! Int), forKey: "beginDate")
                    treatmentSection.setObject(noTreatmentTimeStr, forKey: "treatmentTitle")
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
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "YY-MM-dd" // superset of OP's format
        let dateInserted = NSDate(timeIntervalSince1970: date/1000 as NSTimeInterval)
        let dateStr = dateFormatter.stringFromDate(dateInserted)
        let timeInterval = dateFormatter.dateFromString(dateStr)?.timeIntervalSince1970
        return timeInterval! * 1000
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        var heightForHeader:CGFloat = 0
        if isSelectedTreatment {
            if section == 1 {
                heightForHeader = 44
            }
            if (section != 0) && (section != 1) {
                if (self.treatmentSections[section-2].objectForKey("treatmentTitle") != nil) &&  (self.treatmentSections[section-2].objectForKey("treatmentTitle") is NSNull) == false  && ((self.treatmentSections[section-2].objectForKey("treatmentTitle") as! String) != "") {
                    let treatmentTitle: String = self.treatmentSections[section-2].objectForKey("treatmentTitle") as! String
                    let treatmentTitleSize: CGSize = treatmentTitle.sizeWithFont(treatmentTitleFont, maxSize: CGSize(width: screenWidth - treatmentTitleLeftSpace - treatmentTitleRightSpace - treatmentDateW, height: CGFloat.max))
                    heightForHeader += treatmentTitleSize.height + treatmentTitleTopSpace + dosageButtomSpace
                }
                if (self.treatmentSections[section-2].objectForKey("dosage") != nil)  && (self.treatmentSections[section-2].objectForKey("dosage") is NSNull) == false && ((self.treatmentSections[section-2].objectForKey("dosage") as! String) != ""){
                    let dosageStr: String = self.treatmentSections[section-2].objectForKey("dosage") as! String
                    let dosageSize:CGSize = dosageStr.sizeWithFont(dosageFont, maxSize: CGSize(width: screenWidth - dosageLeftSpace - dosageRightSpace, height: CGFloat.max))
                    heightForHeader += dosageSize.height + dosageTopSpace
                }
            }
        }
        return heightForHeader
    }
    
    func tableView (tableView:UITableView,  viewForHeaderInSection section:Int)->UIView? {
        let headerView = UIView()
        if isSelectedTreatment{
            var headerViewHeight: CGFloat = 0
            if section == 1 {
                let treatmentTitleW: CGFloat = treatmentHeaderStr.sizeWithFont(treatmentHeaderFont, maxSize: CGSize(width: CGFloat.max, height: 13)).width
                let treatmentTitleLable = UILabel(frame: CGRect(x: treatmentHeaderLeftSpace, y: treatmentHeaderTopSpace, width: treatmentTitleW, height: 13))
                treatmentTitleLable.font = treatmentHeaderFont
                treatmentTitleLable.text = treatmentHeaderStr
                treatmentTitleLable.textColor = UIColor.lightGrayColor()
                headerView.addSubview(treatmentTitleLable)
                headerViewHeight += treatmentTitleLable.frame.height
            }
            
            if (section != 0) && (section != 1){
                
                let dateFormatter = NSDateFormatter()
                dateFormatter.dateFormat = "yy/MM/dd" // superset of OP's format
                
                let beginDate = NSDate(timeIntervalSince1970: (treatmentSections[section-2]["beginDate"] as! Double)/1000 as NSTimeInterval)
                let endDate = NSDate(timeIntervalSince1970: (treatmentSections[section-2]["endDate"] as! Double)/1000 as NSTimeInterval)
                let beginDateStr = dateFormatter.stringFromDate(beginDate)
                let endDateStr = dateFormatter.stringFromDate(endDate)
                let dateLabel = UILabel(frame: CGRect(x: screenWidth - treatmentDateW, y: treatmentDateTopSpace, width: treatmentDateW, height: treatmentDateH))
                dateLabel.text = beginDateStr + "-" + endDateStr
                dateLabel.textColor = UIColor.grayColor()
                dateLabel.font = dateFont
                dateLabel.textColor = dateColor
                headerView.addSubview(dateLabel)
                
                let treatmentTitleLabel: UILabel = UILabel()
                if (self.treatmentSections[section-2].objectForKey("treatmentTitle") != nil) &&  (self.treatmentSections[section-2].objectForKey("treatmentTitle") is NSNull) == false  && ((self.treatmentSections[section-2].objectForKey("treatmentTitle") as! String) != "") {
                    let treatmentTitle: String = self.treatmentSections[section-2].objectForKey("treatmentTitle") as! String
                    let treatmentTitleSize: CGSize = treatmentTitle.sizeWithFont(treatmentTitleFont, maxSize: CGSize(width: screenWidth - treatmentDateW - treatmentTitleLeftSpace - treatmentTitleRightSpace, height: CGFloat.max))
                    treatmentTitleLabel.frame = CGRect(x: treatmentTitleLeftSpace, y: treatmentTitleTopSpace, width: treatmentTitleSize.width, height: treatmentTitleSize.height)
                    treatmentTitleLabel.numberOfLines = 0
                    treatmentTitleLabel.text = self.treatmentSections[section-2].objectForKey("treatmentTitle") as? String
                    treatmentTitleLabel.font = treatmentTitleFont
                    treatmentTitleLabel.textColor = treatmentTitleColor
                    headerView.addSubview(treatmentTitleLabel)
                    headerViewHeight += treatmentTitleLabel.frame.height + treatmentTitleTopSpace + dosageButtomSpace
                }

                if (self.treatmentSections[section-2].objectForKey("dosage") != nil)  && (self.treatmentSections[section-2].objectForKey("dosage") is NSNull) == false && ((self.treatmentSections[section-2].objectForKey("dosage") as! String) != ""){
                    let dosageStr: String = self.treatmentSections[section-2].objectForKey("dosage") as! String
                    let dosageSize:CGSize = dosageStr.sizeWithFont(dosageFont, maxSize: CGSize(width: screenWidth - dosageLeftSpace - dosageRightSpace, height: CGFloat.max))
                    let dosageLabel: UILabel = UILabel(frame: CGRect(x: treatmentTitleLeftSpace, y: treatmentTitleTopSpace + dosageTopSpace + treatmentTitleLabel.frame.height, width: dosageSize.width, height: dosageSize.height))
                    dosageLabel.numberOfLines = 0
                    dosageLabel.text = self.treatmentSections[section-2].objectForKey("dosage") as? String
                    dosageLabel.font = dosageFont
                    dosageLabel.textColor = dosageColor
                    headerView.addSubview(dosageLabel)
                    headerViewHeight += dosageLabel.frame.height
                }
            }
            let seperatorLine:UIView = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: seperatorLineH))
            seperatorLine.backgroundColor = seperateLineColor
            headerView.addSubview(seperatorLine)
        }
        headerView.backgroundColor = UIColor.whiteColor()
        return headerView
    }
    
}

//class UserProfileViewController: UIViewController , UITableViewDataSource, UITableViewDelegate {
//    @IBOutlet weak var patientProfile: UILabel!
//    @IBOutlet weak var usernameLabel: UILabel!
//
//    @IBOutlet weak var profileSegment: UISegmentedControl!
//    var profileOwnername: NSString?
//    var username: NSString?
//    var password: NSString?
//    var haalthyService = HaalthyService()
//    var keychainAccess = KeychainAccess()
//    var getAccessToken = GetAccessToken()
//    var treatmentList = NSMutableArray()
//    var patientStatusList = NSArray()
//    var treatmentSections = NSMutableArray()
//    var sectionHeaderHeightList = NSMutableArray()
//    var clinicReportList = NSArray()
//    var ceaList = NSArray()
//    var userProfile = NSDictionary()
//    var broadcastList = NSArray()
//    var heightForQuestionRow = NSMutableDictionary()
//    var usedToBeInLoginView = false
//    var publicService = PublicService()
//    var viewContainer = UIView()
//    var accessToken :AnyObject? = nil
//    var userList = NSArray()
//    var addFollowingBtn = UIButton()
//    var newFollowerCount: Int = 0
//    var unreadMentionedPostCount: Int = 0
//    var unreadMentionedPostLabel = UILabel()
//    var selectedPostId = Int()
//    
//    @IBAction func segmentIndexChanged(sender: UISegmentedControl) {
//        if username != nil {
//            if sender.selectedSegmentIndex == 1 {
//                let broadcastData = haalthyService.getPostsByUsername(profileOwnername as! String)
//                let jsonResult = try? NSJSONSerialization.JSONObjectWithData(broadcastData, options: NSJSONReadingOptions.MutableContainers)
//                if jsonResult is NSArray {
//                    broadcastList = jsonResult as! NSArray
//                }
//            }
//            self.tableview.reloadData()
//        }
//    }
//    @IBOutlet weak var tableview: UITableView!
//
//    func getNSDateMod(date: Double)->Double{
//        let dateFormatter = NSDateFormatter()
//        dateFormatter.dateFormat = "YY-MM-dd" // superset of OP's format
//        let dateInserted = NSDate(timeIntervalSince1970: date/1000 as NSTimeInterval)
//        let dateStr = dateFormatter.stringFromDate(dateInserted)
//        let timeInterval = dateFormatter.dateFromString(dateStr)?.timeIntervalSince1970
//        return timeInterval! * 1000
//    }
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        let dummyViewHeight : CGFloat = 40
//        let dummyView: UIView = UIView(frame:CGRectMake(0, 0, self.tableview.frame.width, dummyViewHeight))
//        self.tableview.tableHeaderView = dummyView;
//        self.tableview.contentInset = UIEdgeInsetsMake(-dummyViewHeight, 0, 0, 0)
//        ((self.tabBarController?.tabBar.items as! NSArray).objectAtIndex(1) as! UITabBarItem).title = "我"
//
//    }
//    
//    override func viewWillDisappear(animated: Bool) {
//        viewContainer.removeFromSuperview()
//        if profileOwnername != username{
//            self.tabBarController?.tabBar.hidden = false
//        }
//    }
//    
//    override func viewDidDisappear(animated: Bool) {
//        super.viewDidDisappear(animated)
//        profileOwnername = nil
//    }
//    
//    override func viewDidAppear(animated: Bool) {
//        if self.userProfile.count == 0 {
//            let alert = UIAlertController(title: "提示", message: "oops....网络不给力", preferredStyle: UIAlertControllerStyle.Alert)
//            alert.addAction(UIAlertAction(title: "确定", style: UIAlertActionStyle.Default, handler: nil))
//            self.presentViewController(alert, animated: true, completion: nil)
//            self.tabBarController?.selectedIndex = 0
//            
//            print(self.tabBarController?.selectedIndex)
//        }
//    }
//    
//    override func viewWillAppear(animated: Bool) {
//        super.viewWillAppear(animated)
//
//        
//        username = keychainAccess.getPasscode(usernameKeyChain)
//        password = keychainAccess.getPasscode(passwordKeyChain)
//        getAccessToken.getAccessToken()
//        accessToken = NSUserDefaults.standardUserDefaults().objectForKey(accessNSUserData)
//        if accessToken == nil{
//            if usedToBeInLoginView == false{
////                self.performSegueWithIdentifier("loginSegue", sender: self)
//                let storyboard = UIStoryboard(name: "Main", bundle: nil)
//                let controller = storyboard.instantiateViewControllerWithIdentifier("LoginEntry") as UIViewController
//                
//                self.presentViewController(controller, animated: true, completion: nil)
//                usedToBeInLoginView = true
//            }else{
//                self.tabBarController?.selectedIndex = 0
//                usedToBeInLoginView = false
//            }
//        }else{
//            if profileOwnername == nil {
//                profileOwnername  = username
//            }
//            tableview.delegate = self
//            tableview.dataSource = self
//            self.treatmentSections = NSMutableArray()
//            
//            getTreatmentsData()
//            if self.userProfile.count > 0 {
//                let imageView = UIImageView(frame: CGRectMake(4, 4, 88, 88))
//                viewContainer = UIView(frame: CGRectMake(28, 16, 96, 96))
//                //            imageView.image = UIImage(named: "Mario.jpg")
//                if self.userProfile.valueForKey("image") != nil{
//                    let dataString = self.userProfile.valueForKey("image") as! String
//                    let imageData: NSData = NSData(base64EncodedString: dataString, options: NSDataBase64DecodingOptions(rawValue: 0))!
//                    imageView.image = UIImage(data: imageData)
//                }else{
//                    imageView.image = UIImage(named: "Mario.jpg")
//                }
//                viewContainer.addSubview(imageView)
//                viewContainer.backgroundColor = UIColor.whiteColor()
////                self.navigationController?.navigationBar.addSubview(viewContainer)
//                
//                //            self.tableview.allowsSelection = false
//                let publicService = PublicService()
//                let profileStr = publicService.getProfileStrByDictionary(userProfile)
//                self.patientProfile.text = profileStr
//                self.patientProfile.font = UIFont(name: "Helvetica", size: 12)
//                self.usernameLabel.text = self.userProfile.objectForKey("displayname") as? String
//                if profileOwnername != username{
//                    let isFollowingUserData: NSData? = haalthyService.isFollowingUser(profileOwnername as! String)
//                    if isFollowingUserData != nil {
//                        let isFollowingUserStr = NSString(data: isFollowingUserData!, encoding: NSUTF8StringEncoding)
//                        if isFollowingUserStr == "0"{
//                            self.tabBarController?.tabBar.hidden = true
//                            let addFollowingBtnWidth: CGFloat = 60
//                            let addFollowingBtnOriginY:CGFloat = (self.navigationController?.navigationBar.frame)!.height + 30
//
//                            addFollowingBtn = UIButton(frame: CGRectMake(UIScreen.mainScreen().bounds.width - addFollowingBtnWidth - 15, addFollowingBtnOriginY, addFollowingBtnWidth, 30))
//                            addFollowingBtn.layer.cornerRadius = 5
//                            addFollowingBtn.layer.masksToBounds = true
//                            addFollowingBtn.setTitle("加关注", forState: UIControlState.Normal)
//                            addFollowingBtn.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
//                            addFollowingBtn.backgroundColor = mainColor
//                            self.view.addSubview(addFollowingBtn)
//                            addFollowingBtn.addTarget(self, action: "addFollowing:", forControlEvents: UIControlEvents.TouchUpInside)
//                        }
//                    }
//                }else{
//                    let newFollowerCountData: NSData? = haalthyService.selectNewFollowCount()
//                    if newFollowerCountData != nil{
//                        let jsonResult = try? NSJSONSerialization.JSONObjectWithData(newFollowerCountData!, options: NSJSONReadingOptions.MutableContainers)
//                        if jsonResult is NSDictionary {
//                            newFollowerCount = ((jsonResult as! NSDictionary).objectForKey("count") as! NSNumber).integerValue
//                            if newFollowerCount != 0{
//                                self.profileSegment.selectedSegmentIndex = 2
//                            }else{
//                                let unreadMentionedPostCountData: NSData = haalthyService.getUnreadMentionedPostCount()!
//                                unreadMentionedPostCount =  Int((NSString(data: unreadMentionedPostCountData, encoding: NSUTF8StringEncoding)! as String))!
//                                if unreadMentionedPostCount != 0 {
//                                    self.profileSegment.selectedSegmentIndex = 2
//                                }
//                            }
//                        }
//                    }
//                }
//            }
//        }
//    }
//    
//    func addFollowing(sender: AnyObject) {
//        let profileSet = NSUserDefaults.standardUserDefaults()
//        if profileSet.objectForKey(accessNSUserData) != nil{
//            let addFollowingData = haalthyService.addFollowing(profileOwnername as! String)
//            var jsonResult = try? NSJSONSerialization.JSONObjectWithData(addFollowingData, options: NSJSONReadingOptions.MutableContainers)
////            let deleteResult = haalthyService.deleteFromSuggestedUser(profileOwnername as! String)
////            print(NSString(data: deleteResult, encoding: NSUTF8StringEncoding))
//            addFollowingBtn.enabled = false
//            addFollowingBtn.setTitle("已关注", forState: UIControlState.Normal)
//            addFollowingBtn.setTitleColor(UIColor.lightGrayColor(), forState: UIControlState.Normal)
//            addFollowingBtn.layer.borderColor = UIColor.lightGrayColor().CGColor
////            haalthyService.increaseNewFollowCount(profileOwnername as! String)
//        }
//    }
//    
//    func sortFunc(num1: Int, num2: Int) -> Bool {
//        return num1 > num2
//    }
//
//    override func didReceiveMemoryWarning() {
//        super.didReceiveMemoryWarning()
//    }
//    
//    
//    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
//        // Return the number of sections.
//        var numberOfSections = 0
//        switch profileSegment.selectedSegmentIndex {
//        case 0:
//            numberOfSections = treatmentSections.count + 1
//            break
//        case 1:
//            numberOfSections = 1
//            break
//        case 2:
//            numberOfSections = 3
//            break
//        default:
//            numberOfSections = 0
//            break
//        }
//        return numberOfSections
//    }
//    
//    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        var numberOfRows = 0
//        if profileSegment.selectedSegmentIndex == 0 {
//            if section == 0{
//                numberOfRows = 2
//            }else{
//                let patientStatus = treatmentSections[section-1]["patientStatus"]
//                if (patientStatus!) != nil {
//                    numberOfRows = (patientStatus as! NSArray).count
//                }else{
//                    numberOfRows = 0
//                }
//            }
//        }else if profileSegment.selectedSegmentIndex == 1{
//            numberOfRows = self.broadcastList.count
//        }else if profileSegment.selectedSegmentIndex == 2{
//            switch section{
//            case 0: numberOfRows = 4
//                break
//            case 1: numberOfRows = 1
//                break
//            case 2: numberOfRows = 1
//                break
//            default: numberOfRows = 0
//                break
//            }
//        }
//        return numberOfRows
//    }
//    
//    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
//        if profileSegment.selectedSegmentIndex == 0{
//            if indexPath.section == 0{
//                if indexPath.row == 0{
//                    let cell = tableView.dequeueReusableCellWithIdentifier("treatmentSummaryCell", forIndexPath: indexPath) as! TreatmentSummaryTableViewCell
//                    if clinicReportList.count > 0{
//                        cell.treatmentList = treatmentList
//                        cell.clinicReportList = clinicReportList
//                    }
//                    return cell
//                }else{
//                    let cell = tableView.dequeueReusableCellWithIdentifier("editTreatmentIndentifier", forIndexPath:indexPath) 
//                    if profileOwnername == username{
//                        let editButtonWidth: CGFloat = 60.0
//                        let editButtonHeight: CGFloat = 30.0
//                        let marginWidth: CGFloat = 10.0
//                        let editButton = UIButton(frame: CGRectMake(cell.frame.width - editButtonWidth - marginWidth, marginWidth, editButtonWidth, editButtonHeight))
//                        editButton.titleLabel?.font = UIFont(name: fontStr, size: 12.0)
//                        editButton.setTitleColor(UIColor.grayColor(), forState: UIControlState.Normal)
//                        editButton.titleLabel?.textAlignment = NSTextAlignment.Center
//                        let underlineAttribute = [NSUnderlineStyleAttributeName: NSUnderlineStyle.StyleSingle.rawValue]
//                        let underlineAttributedString = NSAttributedString(string: "编辑", attributes: underlineAttribute)
//                        editButton.setAttributedTitle(underlineAttributedString, forState: UIControlState.Normal)
//                        cell.addSubview(editButton)
//                        editButton.addTarget(self, action: "updateTreatment", forControlEvents: UIControlEvents.TouchUpInside)
//                    }
//                    return cell
//                }
//            }else{
//                let cell = tableView.dequeueReusableCellWithIdentifier("patientStatusListCell", forIndexPath: indexPath) as! PatientStatusTableViewCell
//                cell.selectionStyle = UITableViewCellSelectionStyle.None
//                let patientStatusListInSection = (treatmentSections[indexPath.section - 1] as! NSDictionary).objectForKey("patientStatus") as! NSArray
//                cell.patientStatus = patientStatusListInSection[indexPath.row] as! NSDictionary
//                return cell
//            }
//        }else if profileSegment.selectedSegmentIndex == 1{
//            let cell = tableView.dequeueReusableCellWithIdentifier("questionListCell", forIndexPath: indexPath) 
//            let broadcast = broadcastList[indexPath.row] as! NSDictionary
//            let dateFormatter = NSDateFormatter()
//            dateFormatter.dateFormat = "yy/MM/dd" // superset of OP's format
//            let dateInserted = NSDate(timeIntervalSince1970: (broadcast["dateInserted"] as! Double)/1000 as NSTimeInterval)
//            let dateStr = dateFormatter.stringFromDate(dateInserted)
//            
//            let questionLabel = UILabel(frame: CGRectMake(15, 0, UIScreen.mainScreen().bounds.width - 30, CGFloat.max))
//            questionLabel.numberOfLines = 0
//            questionLabel.lineBreakMode = NSLineBreakMode.ByCharWrapping
//            questionLabel.font = UIFont(name: "Helvetica", size: 13.0)
//            questionLabel.text = broadcast.objectForKey("body") as! String
//            questionLabel.textColor = UIColor.blackColor()
//            questionLabel.sizeToFit()
//
//            let dateInsertedLabel = UILabel(frame: CGRectMake(10, questionLabel.frame.height + 5, 60, 20))
//            dateInsertedLabel.textColor = UIColor.darkGrayColor()
//            dateInsertedLabel.text = dateStr
//            dateInsertedLabel.font = UIFont(name: "Helvetica", size: 12.0)
//
//            let reviewsLabel = UILabel(frame: CGRectMake(UIScreen.mainScreen().bounds.width - 15 - 80, questionLabel.frame.height + 5, 80, 20))
//            reviewsLabel.textColor = UIColor.darkGrayColor()
//            reviewsLabel.font = UIFont(name: "Helvetica", size: 12.0)
//            reviewsLabel.text = (broadcast["countComments"] as! NSNumber).stringValue + "评论"
//            reviewsLabel.textAlignment = NSTextAlignment.Right
//            
//            cell.addSubview(questionLabel)
//            cell.addSubview(dateInsertedLabel)
//            cell.addSubview(reviewsLabel)
//            self.heightForQuestionRow.setObject(questionLabel.frame.height, forKey: indexPath)
//            return cell
//        }else{
//            if indexPath.section == 0 {
//                let cell = tableView.dequeueReusableCellWithIdentifier("personalSettingCell", forIndexPath: indexPath) 
//                cell.textLabel?.font = UIFont(name: fontStr, size: 14.0)
//                cell.selectionStyle = UITableViewCellSelectionStyle.None
//                //            if username != nil{
//                switch indexPath.row{
//                case 0: cell.textLabel?.text = "我关注的病友"
//                    break
//                case 1: cell.textLabel?.text = "关注我的病友"
//                    var textLabelWidth:CGFloat = (cell.textLabel?.frame)!.width
//                    let newFollowerCountLabel = UILabel(frame: CGRectMake(110, 5, 20, 20))
//                    if newFollowerCount != 0{
//                        newFollowerCountLabel.text = (newFollowerCount as NSNumber).stringValue
//                        newFollowerCountLabel.textColor = UIColor.redColor()
//                        cell.addSubview(newFollowerCountLabel)
//                    }
//                    break
//                case 2: cell.textLabel?.text = "我的评论"
//                    break
//                case 3: cell.removeAllSubviews()
//                    let titleLabel = UILabel(frame: CGRectMake(10, 5, 100, 40))
//                    titleLabel.text = "@提到我的"
//                    titleLabel.textColor = UIColor.blackColor()
//                    cell.addSubview(titleLabel)
//                    var textLabelWidth:CGFloat = (cell.textLabel?.frame)!.width
//                    unreadMentionedPostLabel = UILabel(frame: CGRectMake(110, 5, 20, 20))
//                    if unreadMentionedPostCount != 0{
//                        unreadMentionedPostLabel.text = (unreadMentionedPostCount as NSNumber).stringValue
//                        unreadMentionedPostLabel.textColor = UIColor.redColor()
//                        cell.addSubview(unreadMentionedPostLabel)
//                    }
//                    break
//                default: break
//                }
//                return cell
//            }else if indexPath.section == 1{
//                let cell = tableView.dequeueReusableCellWithIdentifier("accountSettingCell", forIndexPath: indexPath) 
//                cell.textLabel?.font = UIFont(name: fontStr, size: 14.0)
//                cell.selectionStyle = UITableViewCellSelectionStyle.None
//                cell.textLabel?.text = "更改个人信息"
//                return cell
//            } else {
//                let cell = tableView.dequeueReusableCellWithIdentifier("logoutCell", forIndexPath: indexPath) 
//                cell.textLabel?.font = UIFont(name: fontStr, size: 14.0)
//                cell.selectionStyle = UITableViewCellSelectionStyle.None
//                cell.textLabel?.text = "退出登录"
//                return cell
//            }
//        }
//    }
//    
//    func updateTreatment(){
//        self.performSegueWithIdentifier("updateTreatment", sender: self)
//    }
//    
//    func tableView(_tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat{
//        var rowHeight: CGFloat = 0.0
//        if profileSegment.selectedSegmentIndex == 0{
//            if indexPath.section == 0{
//                if indexPath.row == 0{
//                    var containCEAValue: Bool = false
//                    for clinicItem in clinicReportList {
//                        if (clinicItem.objectForKey("cea") != nil) && ((clinicItem.objectForKey("cea") as! Float) != 0.0) {
//                            containCEAValue = true
//                        }
//                    }
//                    rowHeight = containCEAValue == true ? 150 : 0
//                }else{
//                    rowHeight = 44
//                }
//            }else{
//                rowHeight = UITableViewAutomaticDimension
//            }
//        }else if profileSegment.selectedSegmentIndex == 1{
//            let questionLabelHeight = self.heightForQuestionRow.objectForKey(indexPath)
//            if questionLabelHeight != nil{
//                rowHeight = (self.heightForQuestionRow.objectForKey(indexPath) as! CGFloat) + 35
//            }
//        }else if profileSegment.selectedSegmentIndex == 2{
//            rowHeight = 50
//        }
//        
//        return rowHeight
//    }
//    
//    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        var heightForHeader:CGFloat = 0
//        if profileSegment.selectedSegmentIndex == 0{
//            if section == 0 {
//                if (self.clinicReportList.count > 0){
//                    heightForHeader = 40
//                }
//            }else{
//                let treatmentLineCount:AnyObject? = self.treatmentSections[section-1]["treatmentLineCount"]
//                if treatmentLineCount == nil{
//                    heightForHeader = 0
//                }else{
//                    if (self.treatmentSections[section-1].objectForKey("treatmentDetails") != nil) && ((self.treatmentSections[section-1].objectForKey("treatmentDetails") is NSNull) == false) && ((self.treatmentSections[section-1].objectForKey("treatmentDetails") as! NSString).length > 0){
//
//                    heightForHeader = (self.treatmentSections[section-1]["sectionHeight"] as! CGFloat) + 5
//                    if UIScreen.mainScreen().bounds.width < 375 {
//                        heightForHeader += 35
//                    }
//                    }else{
//                        heightForHeader = 0
//                    }
//                }
//            }
//        }
//        if profileSegment.selectedSegmentIndex == 2 {
//            heightForHeader = 10
//        }
//        return heightForHeader
//    }
//    
//    func tableView (tableView:UITableView,  viewForHeaderInSection section:Int)->UIView {
//        var headerView = UIView()
//        if profileSegment.selectedSegmentIndex == 0{
//            if section == 0 {
//                headerView =  UIView(frame: CGRectMake(0, 0,tableView.bounds.size.width, 40))
//                let summaryLabel = UILabel(frame: CGRectMake(15,5,tableView.bounds.size.width - 40, 30))
//                summaryLabel.text = "CEA指标变化"
//                summaryLabel.textColor = mainColor
//                summaryLabel.font = UIFont(name: "Helvetica-Bold", size: 15)
//                headerView.addSubview(summaryLabel)
//            }else{
//                var heightForHeader:CGFloat = 0
//                var treatmentY:CGFloat = 5.0
//                
//                let treatmentLineCount = self.treatmentSections[section-1]["treatmentLineCount"] as! Int
//                heightForHeader += CGFloat(35 * treatmentLineCount + 4)
//                if UIScreen.mainScreen().bounds.width < 375 {
//                    heightForHeader += 35
//                }
//                headerView =  UIView(frame: CGRectMake(0, 0,tableView.bounds.size.width, heightForHeader))
//
//                var dateLabel = UILabel()
//                if UIScreen.mainScreen().bounds.width >= 375 {
//                    dateLabel = UILabel(frame: CGRectMake(265, treatmentY, 100, 30))
//                }else{
//                    dateLabel = UILabel(frame: CGRectMake(265, treatmentY, 100, 30))
//                    treatmentY += 35
//                    heightForHeader += 35
//                }
//                
//                let dateFormatter = NSDateFormatter()
//                dateFormatter.dateFormat = "yy/MM/dd" // superset of OP's format
//                
//                let beginDate = NSDate(timeIntervalSince1970: (treatmentSections[section-1]["beginDate"] as! Double)/1000 as NSTimeInterval)
//                let endDate = NSDate(timeIntervalSince1970: (treatmentSections[section-1]["endDate"] as! Double)/1000 as NSTimeInterval)
//                let beginDateStr = dateFormatter.stringFromDate(beginDate)
//                let endDateStr = dateFormatter.stringFromDate(endDate)
//                dateLabel.text = beginDateStr + "-" + endDateStr
//                dateLabel.textColor = UIColor.grayColor()
//                dateLabel.font = UIFont(name: "Helvetica", size: 12.0)
//                dateLabel.textAlignment = NSTextAlignment.Right
//                headerView.addSubview(dateLabel)
//
//                let treatmentStr = self.treatmentSections[section-1]["treatmentDetails"] as! String
//                print(treatmentStr)
//                let treatmentList: NSMutableArray = NSMutableArray(array: treatmentStr.componentsSeparatedByString("**"))
//                for treatment in treatmentList {
//                    var treatmentItemStr:String = treatment as! String
//                    
//                    treatmentItemStr = treatmentItemStr.stringByReplacingOccurrencesOfString("*", withString: "", options:  NSStringCompareOptions.LiteralSearch, range: nil)
//                    if (treatmentItemStr as NSString).length == 0{
//                        treatmentList.removeObject(treatment)
//                    }
//                }
//                
//                for treatment in treatmentList {
//                    var treatmentStr = treatment as! String
//                    if (treatmentStr as NSString).length == 0{
//                        break
//                    }
//                    if treatmentStr.substringWithRange(Range(start: treatmentStr.startIndex, end: treatmentStr.startIndex.advancedBy(1))) == "*" {
//                        treatmentStr = treatmentStr.substringFromIndex(treatmentStr.startIndex.advancedBy(1))
//                    }
//                    let treatmentNameAndDosage:NSArray = treatmentStr.componentsSeparatedByString("*")
//                    let treatmentName = treatmentNameAndDosage[0] as! String
//                    var treatmentDosage = String()
//                    var treatmentNameLabel = UILabel()
//                    let dosageLabel = UILabel()
//                    if treatmentNameAndDosage.count > 1{
//                        treatmentDosage = treatmentNameAndDosage[1] as! String
////                        var dosageLableLine = (treatmentDosage as NSString).length/14 + 1
////                        var height = CGFloat(30 * dosageLableLine)
//                        treatmentNameLabel = UILabel(frame: CGRectMake(10.0, treatmentY, 90.0, 30.0))
//                        treatmentNameLabel.text = treatmentName
//                        dosageLabel.frame = CGRectMake(110.0, treatmentY + 5, 150.0, 0)
//                        dosageLabel.text = treatmentDosage
//                        dosageLabel.font = UIFont(name: "Helvetica-Bold", size: 13.0)
//                        dosageLabel.numberOfLines = 0
////                        dosageLable.backgroundColor = UIColor.lightGrayColor()
//                        dosageLabel.sizeToFit()
//                        print(dosageLabel.frame.height)
//                        let height:CGFloat = dosageLabel.frame.height > treatmentNameLabel.frame.height ? dosageLabel.frame.height : treatmentNameLabel.frame.height
//                        treatmentY += height + 5
//                        treatmentNameLabel.font = UIFont(name: "Helvetica-Bold", size: 14.0)
//                        treatmentNameLabel.layer.cornerRadius = 5
//                        treatmentNameLabel.backgroundColor = tabBarColor
//                        treatmentNameLabel.textColor = mainColor
//                        treatmentNameLabel.layer.masksToBounds = true
//                        treatmentNameLabel.layer.borderColor = mainColor.CGColor
//                        treatmentNameLabel.layer.borderWidth = 1.0
//                        treatmentNameLabel.textAlignment = NSTextAlignment.Center
//                        dosageLabel.textColor = mainColor
//                    }else{
//                        let treatmentLine = (treatmentName as NSString).length/20 + 1
//                        let height = CGFloat(30 * treatmentLine)
//                        treatmentNameLabel = UILabel(frame: CGRectMake(10.0, treatmentY, 90.0, height))
//                        treatmentNameLabel.text = treatmentName
//                        treatmentY += height + 5
//                        treatmentNameLabel.font = UIFont(name: "Helvetica-Bold", size: 13.0)
//                        treatmentNameLabel.textColor = mainColor
//                        treatmentNameLabel.backgroundColor = tabBarColor
//                        treatmentNameLabel.layer.borderColor = mainColor.CGColor
//                        treatmentNameLabel.layer.borderWidth = 1.0
//                        treatmentNameLabel.layer.masksToBounds = true
//                        treatmentNameLabel.layer.cornerRadius = 5
//                        treatmentNameLabel.textAlignment = NSTextAlignment.Center
//                    }
//                    headerView.addSubview(treatmentNameLabel)
//                    headerView.addSubview(dosageLabel)
//                    
//                    let separatorLine:UIImageView = UIImageView(frame: CGRectMake(5, 0, tableView.frame.size.width-10.0, 1.0))
//                    separatorLine.image = UIImage(named: "grayline.png")?.stretchableImageWithLeftCapWidth(1, topCapHeight: 0)
//                    
//                    headerView.addSubview(separatorLine)
//                }
//            }
//        }
//        if profileSegment.selectedSegmentIndex == 2 {
//            headerView = UIView(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.width, 10))
//            headerView.backgroundColor = sectionHeaderColor
//        }
//        return headerView
//    }
//    
//    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
//        if profileSegment.selectedSegmentIndex == 2 {
//            if indexPath.section == 2 {
//                publicService.logOutAccount()
//                let storyboard = UIStoryboard(name: "Main", bundle: nil)
//                let controller = storyboard.instantiateViewControllerWithIdentifier("LoginEntry") as UIViewController
//                
//                self.presentViewController(controller, animated: true, completion: nil)
//                usedToBeInLoginView = true
//            }
//            if indexPath.section == 1 {
//                let storyboard = UIStoryboard(name: "Registeration", bundle: nil)
//                let controller = storyboard.instantiateViewControllerWithIdentifier("ProfileDetail") as UIViewController
//                (controller as! PatientProfileTableViewController).userProfile = userProfile.mutableCopy() as! NSMutableDictionary
//
//                self.navigationController?.pushViewController(controller, animated: true)
//            }
//            if indexPath.section == 0 {
//                if indexPath.row == 2 {
//                    self.performSegueWithIdentifier("commentListSegue", sender: self)
//                }else if indexPath.row == 3 {
//                    unreadMentionedPostCount = 0
//                    haalthyService.markMentionedPostAsRead()
//                    self.performSegueWithIdentifier("mentionedPostSegue", sender: self)
//                }else{
//                    var userListData = NSData()
//                    if indexPath.row == 0{
//                        userListData = haalthyService.getFollowingUsers(username! as String)!
//                    }
//                    if indexPath.row == 1{
//                        newFollowerCount = 0
//                        userListData = haalthyService.getFollowerUsers(username! as String)!
//                        haalthyService.refreshNewFollowCount()
//                    }
//                    let jsonResult = try? NSJSONSerialization.JSONObjectWithData(userListData, options: NSJSONReadingOptions.MutableContainers)
//                    if jsonResult is NSArray {
//                        userList = jsonResult as! NSArray
//                    }
//                    self.performSegueWithIdentifier("userListSegue", sender: self)
//                }
//            }
//        }
//        if profileSegment.selectedSegmentIndex == 1 {
//            selectedPostId = (broadcastList[indexPath.row] as! NSDictionary).objectForKey("postID") as! Int
//            let storyboard = UIStoryboard(name: "Feed", bundle: nil)
//            let controller = storyboard.instantiateViewControllerWithIdentifier("PostDetailEntry") as! ShowPostDetailTableViewController
//            controller.postId = selectedPostId
//            self.navigationController?.pushViewController(controller, animated: true)
//        }
//    }
//    
//    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//        if segue.identifier == "setPasswordSegue" {
//            (segue.destinationViewController as! SettingPasswordViewController).username = userProfile.objectForKey("username") as! String
//        }
//        if segue.identifier == "userListSegue" {
//            (segue.destinationViewController as! UserListTableViewController).userList = userList
//        }
//        if segue.identifier == "commentListSegue" {
//            var commentList = NSArray()
//            let commentListData = haalthyService.getCommentsByUsername(username as! String)
//            let str: NSString = NSString(data: commentListData!, encoding: NSUTF8StringEncoding)!
//            print(str)
//            let jsonResult = try? NSJSONSerialization.JSONObjectWithData(commentListData!, options: NSJSONReadingOptions.MutableContainers)
//            if jsonResult is NSArray {
//                commentList = jsonResult as! NSArray
//            }
//            (segue.destinationViewController as! CommentListTableViewController).commentList = commentList
//        }
//        if segue.identifier == "setProfileSegue" {
//            (segue.destinationViewController as! PatientProfileTableViewController).userProfile = userProfile.mutableCopy() as! NSMutableDictionary
//        }
//        if segue.identifier == "updateTreatment" {
//            (segue.destinationViewController as! UpdateTreatmentTableViewController).treatmentList = self.treatmentList
//        }
//    }
//}
