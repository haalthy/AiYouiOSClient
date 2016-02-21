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
    var tableView = UITableView()
    
    var userProfileHeaderView: UIView!

    // 自定义变量 old
    //显示他人的profile
    var profileOwnername: NSString?
    var username: NSString?
    var password: NSString?
    var keychainAccess = KeychainAccess()
    var getAccessToken = GetAccessToken()
    var publicService = PublicService()
    
    var treatmentList = NSMutableArray()
    var patientStatusList = NSArray()
    var treatmentSections = NSMutableArray()
    var sectionHeaderHeightList = NSMutableArray()
    var clinicReportList = NSArray()
    var ceaList = NSArray()
    var userProfile = NSDictionary()
    var userProfileObj: UserProfile?
    var broadcastList = NSArray()
    var heightForQuestionRow = NSMutableDictionary()
    var usedToBeInLoginView = false
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
    let relatedToMe: NSArray = ["我的信息列表", "@我的", "关注", "基本资料"]
    var relatedToOther:NSArray?
    
    //“治疗与方案” ”与我相关“
    var treatmentHeaderBtn = UIButton()
    var postHeaderBtn = UIButton()
    var treatmentBtnLine = UIView()
    var postBtnLine = UIView()
    var segmentSectionBtnHeight = CGFloat()
    
    let followBtn = UIButton()
    
    //
    override func viewDidLoad() {
        super.viewDidLoad()
        HudProgressManager.sharedInstance.showHudProgress(self, title: "加载中...")
    }
    
    override func viewDidAppear(animated: Bool) {
        username = keychainAccess.getPasscode(usernameKeyChain)
        password = keychainAccess.getPasscode(passwordKeyChain)
        getAccessToken.getAccessToken()
        let access_token = NSUserDefaults.standardUserDefaults().objectForKey(accessNSUserData)
        if access_token != nil {
            if self.profileOwnername == nil{
                profileOwnername = self.username
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

                self.tableView.registerClass(ChartSummaryTableViewCell.self, forCellReuseIdentifier: "ChartSummaryIdentifier")
                self.tableView.registerClass(PatientStatusTableViewCell.self, forCellReuseIdentifier: "patientstatusIdentifier")
                self.tableView.delegate = self
                self.tableView.dataSource = self
                self.tableView.reloadData()
            }
        }else{
            let storyboard = UIStoryboard(name: "Registeration", bundle: nil)
            let loginController = storyboard.instantiateViewControllerWithIdentifier("LoginEntry") as! UINavigationController
            self.presentViewController(loginController, animated: true, completion: nil)
        }
        HudProgressManager.sharedInstance.dismissHud()
    }
    // MARK: - Init Variables
    func initVariables() {
        print((self.navigationController?.navigationBar.frame.height))
        headerHeight = UIApplication.sharedApplication().statusBarFrame.height + (self.navigationController?.navigationBar.frame.height)!
        screenWidth = UIScreen.mainScreen().bounds.width
        segmentSectionBtnHeight = 43
        isSelectedTreatment = true
        if ((self.userProfileObj?.gender)!) == "F"{
            relatedToOther = NSArray(array: [herProfileStr])
        }else{
            relatedToOther = NSArray(array: [hisProfileStr])
        }
    }
    
    // MARK: - Init Related ContentView
    
    func initContentView() {
        let profileHeaderH: CGFloat = 125
        self.userProfileHeaderView = UIView(frame: CGRect(x: 0, y: headerHeight, width: screenWidth, height: profileHeaderH))
        self.tableView.frame = CGRECT(0, headerHeight + profileHeaderH, screenWidth, screenHeight - headerHeight - profileHeaderH )
        self.view.addSubview(userProfileHeaderView)
        self.view.addSubview(self.tableView)
        //初始化“治疗和方案”
        self.treatmentHeaderBtn.frame = CGRectMake(0, 1, screenWidth/2 , segmentSectionBtnHeight)

        self.treatmentHeaderBtn.setTitle(processHeaderStr, forState: UIControlState.Normal)
        self.treatmentBtnLine.frame = CGRectMake(0, segmentSectionBtnHeight - 2, screenWidth/2, 2)
        self.treatmentHeaderBtn.addSubview(treatmentBtnLine)
        self.treatmentHeaderBtn.addTarget(self, action: "selectSegment:", forControlEvents: UIControlEvents.TouchUpInside)
        self.userProfileHeaderView.addSubview(treatmentHeaderBtn)
        headerBtnFormatBeSelected(self.treatmentHeaderBtn)
        
        //初始化“与我相关”
        self.postHeaderBtn.frame = CGRectMake(screenWidth/2, 1, screenWidth/2, segmentSectionBtnHeight)
        if (self.username == self.profileOwnername) {
            self.postHeaderBtn.setTitle(myProfileStr, forState: UIControlState.Normal)
        }else{
            if ((self.userProfileObj?.gender)!) == "F"{
                self.postHeaderBtn.setTitle(herProfileStr, forState: UIControlState.Normal)
            }else{
                self.postHeaderBtn.setTitle(hisProfileStr, forState: UIControlState.Normal)
            }
        }
        self.postBtnLine.frame = CGRectMake(0, segmentSectionBtnHeight - 2, screenWidth/2, 2)
        self.postHeaderBtn.addSubview(postBtnLine)
        self.postHeaderBtn.addTarget(self, action: "selectSegment:", forControlEvents: UIControlEvents.TouchUpInside)
        self.userProfileHeaderView.addSubview(postHeaderBtn)
        headerBtnFormatBeDeselected(self.postHeaderBtn)
        
        //初始化分割线
        let seperateLine = UIView(frame: CGRectMake(0, 1+segmentSectionBtnHeight, screenWidth, 0.5))
        seperateLine.backgroundColor = seperateLineColor
        self.userProfileHeaderView.addSubview(seperateLine)
        
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
        addFollowingBtnDisplay()
        
        //昵称 和 profile描述 标签
        let profileLabelWidth: CGFloat = screenWidth - 25 - 40 - 15 - followBtnWidth
        let nicknameLabel = UILabel(frame: CGRectMake(65, 45 + 23, profileLabelWidth, 14))
        nicknameLabel.textColor = nicknameColor
        nicknameLabel.font = nicknameFont
        nicknameLabel.text = self.userProfile.valueForKey("displayname") as? String
        self.userProfileHeaderView.addSubview(nicknameLabel)
        
        let profileLabel = UILabel(frame: CGRectMake(65,  90, profileLabelWidth, 12))
        profileLabel.textColor = UIColor.lightGrayColor()
        profileLabel.font = UIFont(name: fontStr, size: 12.0)
        let profileStr = publicService.getProfileStrByDictionary(self.userProfile)
        profileLabel.text = profileStr
        self.userProfileHeaderView.addSubview(profileLabel)
        //
    }
    
    
    func addFollowingBtnDisplay(){
        if username != self.profileOwnername {
            getAccessToken.getAccessToken()
            let accessToken = NSUserDefaults.standardUserDefaults().objectForKey(accessNSUserData)
            let urlPath:String = (isFollowingUserURL as String) + "?access_token=" + (accessToken as! String);
            
            let requestBody = NSMutableDictionary()
            requestBody.setObject(self.profileOwnername!, forKey: "followingUser")
            requestBody.setObject(keychainAccess.getPasscode(usernameKeyChain)!, forKey: "username")
            
            NetRequest.sharedInstance.POST(urlPath, parameters: (requestBody as NSDictionary) as! Dictionary<String, AnyObject>,
                success: { (content , message) -> Void in
                    if (content is NSDictionary) && ((content as! NSDictionary).objectForKey("count") as! Int) == 0 {
                        self.followBtn.frame = CGRectMake(self.screenWidth - followBtnRightSpace - followBtnWidth , followBtnTopSpace, followBtnWidth, followBtnHeight)
                        let addFollowingImage = UIImageView(image: UIImage(named: "btn_addFollowing"))
                        self.followBtn.addSubview(addFollowingImage)
                        self.followBtn.layer.borderColor = followBtnBorderColor.CGColor
                        self.followBtn.layer.borderWidth = followBtnBorderWidth
                        self.followBtn.layer.cornerRadius = cornerRadius
                        self.followBtn.addTarget(self, action: "addFollowing:", forControlEvents: UIControlEvents.TouchUpInside)
                        self.userProfileHeaderView.addSubview(self.followBtn)
                    }
                }) { (content, message) -> Void in
                    
            }
        }
    }
    
    func addFollowing(sender: UIButton){
        getAccessToken.getAccessToken()
        let accessToken = NSUserDefaults.standardUserDefaults().objectForKey(accessNSUserData)
        let urlPath:String = (addFollowingURL as String) + "?access_token=" + (accessToken as! String);
        
        let requestBody = NSMutableDictionary()
        requestBody.setObject(self.profileOwnername!, forKey: "followingUser")
        requestBody.setObject(keychainAccess.getPasscode(usernameKeyChain)!, forKey: "username")
        
        NetRequest.sharedInstance.POST(urlPath, parameters: (requestBody as NSDictionary) as! Dictionary<String, AnyObject>,
            success: { (content , message) -> Void in
                HudProgressManager.sharedInstance.showHudProgress(self, title: "已关注")
                self.followBtn.enabled = false
                let followedImageView = UIImageView(frame: CGRECT(0, 0, self.addFollowingBtn.frame.width, self.addFollowingBtn.frame.height))
                followedImageView.image = UIImage(named: "btn_Followed")
                self.addFollowingBtn.removeAllSubviews()
                self.addFollowingBtn.addSubview(followedImageView)
                HudProgressManager.sharedInstance.dismissHud()
            }) { (content, message) -> Void in
                HudProgressManager.sharedInstance.showHudProgress(self, title: "Oops，失败了，稍后再试:(")
                HudProgressManager.sharedInstance.dismissHud()
        }
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
                
                if (patientStatus is NSArray) == false {
                    numberOfRows = 0
                }else{
                    numberOfRows = (patientStatus as! NSArray).count
                }
            }
        }else{
            if (self.username == self.profileOwnername) {
                numberOfRows = relatedToMe.count + 1
            }else{
                numberOfRows = relatedToOther!.count
            }
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
            if (self.username == self.profileOwnername) {
                if indexPath.row < relatedToMe.count {
                    rowHeight = cellHeight
                }else{
                    rowHeight = logoutCellHeight
                }
            }else{
                rowHeight = cellHeight
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
            if (self.username == self.profileOwnername) {
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
                    logoutBtn.addTarget(self, action: "logout:", forControlEvents: UIControlEvents.TouchUpInside)
                    cell.addSubview(logoutBtn)
                }
            }else{
                cell.textLabel?.text = relatedToOther![indexPath.row] as! String
                cell.textLabel?.textColor = cellTextColor
                cell.textLabel?.font = cellTextFont
                cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
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
            
            getAccessToken.getAccessToken()
            if NSUserDefaults.standardUserDefaults().objectForKey(accessNSUserData) != nil{
                let accessToken = NSUserDefaults.standardUserDefaults().objectForKey(accessNSUserData) as! String
                let urlPath:String = getUserDetailURL + "?access_token=" + accessToken
                let requestBody = NSDictionary(object: self.profileOwnername!, forKey: "username")
                jsonResult = NetRequest.sharedInstance.POST_A(urlPath, parameters: requestBody as! Dictionary<String, AnyObject>)
            }

            
            if jsonResult != nil{
                let userDetail = (jsonResult as! NSDictionary).objectForKey("content")
                treatmentList = userDetail!.objectForKey("treatments") as! NSMutableArray

                self.patientStatusList = userDetail!.objectForKey("patientStatus") as! NSArray
                self.clinicReportList = userDetail!.objectForKey("clinicReport") as! NSArray
                self.userProfile = userDetail!.objectForKey("userProfile") as! NSDictionary
                self.userProfileObj = UserProfile()
                self.userProfileObj?.initVariables(self.userProfile)
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
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if isSelectedTreatment == false {
            switch indexPath.row {
            case 0:
                self.performSegueWithIdentifier("showPostsSegue", sender: self)
                break
            case 1:
                self.performSegueWithIdentifier("showMentionSegue", sender: self)
                break
            case 2:
                self.performSegueWithIdentifier("showFollowSegue", sender: self)
                break
            case 3:
                self.performSegueWithIdentifier("showUserBasicInfoSeuge", sender: self)
                break
            default:
                break
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showUserBasicInfoSeuge" {
            let userBasicViewController = segue.destinationViewController as! UserBasicInfoTableViewController
            userBasicViewController.userProfile = self.userProfileObj
        }
    }
    
    func logout(sender: UIButton){
        publicService.logOutAccount()
        let storyboard = UIStoryboard(name: "Registeration", bundle: nil)
        let controller = storyboard.instantiateViewControllerWithIdentifier("LoginEntry") as UIViewController
        self.presentViewController(controller, animated: true, completion: nil)
    }
}
