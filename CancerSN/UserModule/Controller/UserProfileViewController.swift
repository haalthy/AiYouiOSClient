//
//  UserProfileViewController.swift
//  CancerSN
//
//  Created by lily on 9/1/15.
//  Copyright (c) 2015 lily. All rights reserved.
//

import UIKit

let kProfileTimeInterval = 0.5

class UserProfileViewController: UIViewController , UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate {
    // 控件关联
    var tableView = UITableView()
    var relatedTableView = UITableView()
    
    var userProfileHeaderView = UIView()

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
    var isSelectedTreatment:Bool = true
    let relatedToMe: NSArray = ["我的信息列表", "@我的", "关注", "基本资料"]
    var relatedToOther:NSArray?
    
    var otherPeoplesPosts: NSArray?
    
    //“治疗与方案” ”与我相关“
    var treatmentHeaderBtn = UIButton()
    var postHeaderBtn = UIButton()
    var selectedBtnLine = UIView()
    var segmentSectionBtnHeight = CGFloat()
    let portraitView = UIImageView()
    let followBtn = UIButton()
    
    // 当前选中的button
    var curSelectedBtn = UIButton()
    // 初始化标识
    var firstInit: Bool = true
    
    // @我的红点显示view
    var mentionedBadgeView: UIView = UIView()
    
    // 关注红点显示view
    var followBadgeView: UIView = UIView()
    
    // 消息红点显示view
    var messageBadgeView: UIView = UIView()
    
    // 我的奇迹红点提示view
    var headerBadgeView: UIView = UIView()
    
    //scrollView
    let scrollView = UIScrollView()
    
    // 开始时，偏移量（判断scrollview的滑动方向）
    var startContentOffsetX: CGFloat = 0.0
    
    // 结束时，偏移量
    var endContentOffsetX: CGFloat = 0.0
    
    let nicknameLabel = UILabel()
    let profileLabel = UILabel()
    //
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.removeAllSubviews()
//        HudProgressManager.sharedInstance.showHudProgress(self, title: "")
        username = keychainAccess.getPasscode(usernameKeyChain)
        password = keychainAccess.getPasscode(passwordKeyChain)
        getAccessToken.getAccessToken()
        let access_token = NSUserDefaults.standardUserDefaults().objectForKey(accessNSUserData)
        if access_token != nil {
            initRefresh()
            if self.profileOwnername == nil{
                profileOwnername = self.username
            }
//            getTreatmentsData()

                initVariables()
                initContentView()
            
                self.tableView.registerClass(ChartSummaryTableViewCell.self, forCellReuseIdentifier: "ChartSummaryIdentifier")
                self.tableView.registerClass(PatientStatusTableViewCell.self, forCellReuseIdentifier: "patientstatusIdentifier")
                self.tableView.delegate = self
                self.tableView.dataSource = self
                self.relatedTableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
                self.relatedTableView.delegate = self
                self.relatedTableView.dataSource = self
//            }
        }else{
            let alertController = UIAlertController(title: "需要登录才能更新您的信息", message: nil, preferredStyle: .Alert)
            
            let cancelAction = UIAlertAction(title: "取消", style: .Default) { (action) in
                
            }
            
            alertController.addAction(cancelAction)
            let loginAction = UIAlertAction(title: "登陆", style: .Cancel) { (action) in
                let storyboard = UIStoryboard(name: "Registeration", bundle: nil)
                let controller = storyboard.instantiateViewControllerWithIdentifier("LoginEntry") as UIViewController
                self.presentViewController(controller, animated: true, completion: nil)
            }
            alertController.addAction(loginAction)
            
            
            self.presentViewController(alertController, animated: true) {
                // ...
            }
        }

    }
    
    
    
    func initRefresh(){
        self.tableView.mj_header = MJRefreshNormalHeader.init(refreshingBlock: { () -> Void in
            self.getTreatmentsData()
            if self.userProfile.count == 0 {
                let alert = UIAlertController(title: "提示", message: "oops....网络不给力", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "确定", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
                self.tabBarController?.selectedIndex = 0
                
            }else{
                self.reloadHeader()
                self.tableView.reloadData()
            }
        })
    }
    
    override func viewWillAppear(animated: Bool) {
        let access_token = NSUserDefaults.standardUserDefaults().objectForKey(accessNSUserData)
        if access_token != nil {
            super.viewWillAppear(animated)
            if keychainAccess.getPasscode(accessNSUserData) != nil {
                
                // 展示未读@我的红点
                self.getUnreadMentionedCountFromServer()
                
                // 展示未读关注的红点
                self.getUnreadFollowCountFromServer()
                
                // 展示未读消息的红点
                self.getUnreadCommentCountFromServer()
            }
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        let access_token = NSUserDefaults.standardUserDefaults().objectForKey(accessNSUserData)
        if access_token != nil {
            self.getTreatmentsData()
            self.reloadHeader()
            self.tableView.reloadData()
            self.view.addSubview(userProfileHeaderView)
            self.view.addSubview(scrollView)
            //        HudProgressManager.sharedInstance.dismissHud()
            let titleLabel = UILabel(frame: CGRectMake(0, 0, view.frame.size.width - 120, 44))
            titleLabel.textAlignment = NSTextAlignment.Center
            if username != profileOwnername {
                titleLabel.text = "他的奇迹"
            }else{
                titleLabel.text = "我的奇迹"
            }
            titleLabel.textColor = UIColor.whiteColor()
            self.navigationItem.titleView = titleLabel
        }
    }
    
    // MARK: - Init Variables
    func initVariables() {
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        headerHeight = UIApplication.sharedApplication().statusBarFrame.height + (self.navigationController?.navigationBar.frame.height)!
        screenWidth = UIScreen.mainScreen().bounds.width
        segmentSectionBtnHeight = 43

    }
    
    func reloadHeader(){
        if (self.userProfileObj?.gender != nil) && (((self.userProfileObj?.gender)!) == "F") {
            relatedToOther = NSArray(array: [herProfileStr])
        }else{
            relatedToOther = NSArray(array: [hisProfileStr])
        }
        
        self.treatmentHeaderBtn.setTitle(processHeaderStr, forState: UIControlState.Normal)
        
        if (self.username == self.profileOwnername) {
            self.postHeaderBtn.setTitle(myProfileStr, forState: UIControlState.Normal)
        }else{
            if (self.userProfileObj?.gender != nil) && (((self.userProfileObj?.gender)!) == "F"){
                self.postHeaderBtn.setTitle(herProfileStr, forState: UIControlState.Normal)
            }else{
                self.postHeaderBtn.setTitle(hisProfileStr, forState: UIControlState.Normal)
            }
        }
        
        var imageURL = ""
        
        if self.userProfileObj?.portraitUrl != nil {
            imageURL = (self.userProfileObj?.portraitUrl)! + "@80h_80w_1e"
        }
        
        self.portraitView.addImageCache(imageURL, placeHolder: placeHolderStr)
        if self.userProfileObj?.nick != nil {
            nicknameLabel.text = (self.userProfileObj?.nick)!
        }
        
        let profileStr = publicService.getProfileStrByDictionary(self.userProfile)
        profileLabel.text = profileStr

    }
    
    // MARK: - Init Related ContentView
    
    func initContentView() {
        let profileHeaderH: CGFloat = 125
        
        // 选中提示线颜色
        self.selectedBtnLine.backgroundColor = headerColor
        
        self.userProfileHeaderView = UIView(frame: CGRect(x: 0, y: headerHeight, width: screenWidth, height: profileHeaderH))

        scrollView.frame = CGRECT(0, headerHeight + profileHeaderH, screenWidth, screenHeight - headerHeight - profileHeaderH - (self.tabBarController?.tabBar.frame.height)! )
        scrollView.contentSize = CGSize(width: screenWidth * 2, height: scrollView.frame.height)
        
        
        self.tableView.frame = CGRECT(0, 0, screenWidth, screenHeight - headerHeight - profileHeaderH - (self.tabBarController?.tabBar.frame.height)! )
        self.relatedTableView.frame = CGRECT(screenWidth, 0, screenWidth, screenHeight - headerHeight - profileHeaderH - (self.tabBarController?.tabBar.frame.height)! )
        
        self.relatedTableView.tableFooterView = UIView(frame: CGRectZero)
        
        scrollView.addSubview(self.tableView)
        scrollView.addSubview(self.relatedTableView)

        scrollView.userInteractionEnabled = true
        scrollView.pagingEnabled = true
        scrollView.delegate = self
        scrollView.showsHorizontalScrollIndicator = false
        
        //初始化“治疗和方案”
        self.treatmentHeaderBtn.frame = CGRectMake(0, 1, screenWidth/2 , segmentSectionBtnHeight)

        self.selectedBtnLine.frame = CGRectMake(0, segmentSectionBtnHeight - 2, screenWidth/2, 2)
        self.treatmentHeaderBtn.addSubview(self.selectedBtnLine)
        self.treatmentHeaderBtn.addTarget(self, action: "selectSegment:", forControlEvents: UIControlEvents.TouchUpInside)
        self.userProfileHeaderView.addSubview(treatmentHeaderBtn)
        

        //初始化“与我相关”
        self.postHeaderBtn.frame = CGRectMake(screenWidth/2, 1, screenWidth/2, segmentSectionBtnHeight)
        
        self.headerBadgeView.frame = CGRECT(3 * (SCREEN_WIDTH / 4) + 10, 5, 20, 20)
        self.userProfileHeaderView.addSubview(self.headerBadgeView)
        
        if (self.username == self.profileOwnername) {
            self.postHeaderBtn.setTitle(myProfileStr, forState: UIControlState.Normal)
        }else{
            if (self.userProfileObj?.gender != nil) && (((self.userProfileObj?.gender)!) == "F"){
                self.postHeaderBtn.setTitle(herProfileStr, forState: UIControlState.Normal)
            }else{
                self.postHeaderBtn.setTitle(hisProfileStr, forState: UIControlState.Normal)
            }
        }
        self.postHeaderBtn.addTarget(self, action: "selectSegment:", forControlEvents: UIControlEvents.TouchUpInside)
        self.userProfileHeaderView.addSubview(postHeaderBtn)
        if isSelectedTreatment{
            selectSegment(self.treatmentHeaderBtn)
        }else{
            selectSegment(self.postHeaderBtn)
        }
        
        //初始化分割线
        let seperateLine = UIView(frame: CGRectMake(0, 1+segmentSectionBtnHeight, screenWidth, 0.5))
        seperateLine.backgroundColor = seperateLineColor
        self.userProfileHeaderView.addSubview(seperateLine)
        
        //头像
        portraitView.frame = CGRectMake(15, 20 + self.segmentSectionBtnHeight + 2, 40, 40)
        portraitView.layer.cornerRadius = 20
        portraitView.layer.masksToBounds = true

        self.userProfileHeaderView.addSubview(portraitView)
        
        //关注
        addFollowingBtnDisplay()
        
        //昵称 和 profile描述 标签
        let profileLabelWidth: CGFloat = screenWidth - 25 - 40 - 15 - followBtnWidth
        nicknameLabel.frame = CGRectMake(65, 45 + 23, profileLabelWidth, 14)
        nicknameLabel.textColor = nicknameColor
        nicknameLabel.font = nicknameFont
        self.userProfileHeaderView.addSubview(nicknameLabel)
        
        profileLabel.frame = CGRectMake(65,  90, profileLabelWidth, 12)
        profileLabel.textColor = UIColor.lightGrayColor()
        profileLabel.font = UIFont(name: fontStr, size: 12.0)

        self.userProfileHeaderView.addSubview(profileLabel)
        //

    }
    
    // MARK: - 网络请求
    
    // MARK: 获取未读@我的数量
    
    func getUnreadMentionedCountFromServer() {
    
        NetRequest.sharedInstance.POST(getNewMentionedCountURL , isToken: true, parameters: [ "username" : keychainAccess.getPasscode(usernameKeyChain)!], success: { (content, message) -> Void in
            
            let dict: NSDictionary = content as! NSDictionary
            
            if dict["count"] as! Int > 0 {
            
                self.mentionedBadgeView.showBadgeWithShowType(WBadgeShowStyle.Middle)
                self.headerBadgeView.showBadgeWithShowType(WBadgeShowStyle.Middle)
                judgeIsAddCount(1)
            }
            else {
            
                self.mentionedBadgeView.clearBadge()
                judgeIsDecCount(1)
                self.judgeIsDeleteRedBadge()
            }
            
            }) { (content, message) -> Void in
                
        }
    }
    
        
    // MARK: 获取未读关注的数量
    
    func getUnreadFollowCountFromServer() {
        
        NetRequest.sharedInstance.POST(getNewFollowCountURL , isToken: true, parameters: [ "username" : keychainAccess.getPasscode(usernameKeyChain)!], success: { (content, message) -> Void in
            
            let dict: NSDictionary = content as! NSDictionary
            
            if dict["count"] as! Int > 0 {
                
                self.followBadgeView.showBadgeWithShowType(WBadgeShowStyle.Middle)
                self.headerBadgeView.showBadgeWithShowType(WBadgeShowStyle.Middle)
                judgeIsAddCount(2)
            }
            else {
            
                self.followBadgeView.clearBadge()
                judgeIsDecCount(2)
                self.judgeIsDeleteRedBadge()
            }

            
            }) { (content, message) -> Void in
                
        }
    }
    
    // 获取未读评论的数量
    
    func getUnreadCommentCountFromServer() {
    
        NetRequest.sharedInstance.POST(getNewCommentCountURL , isToken: true, parameters: [ "username" : keychainAccess.getPasscode(usernameKeyChain)!], success: { (content, message) -> Void in
            
            let dict: NSDictionary = content as! NSDictionary
            
            if dict["count"] as! Int > 0 {
                
                self.messageBadgeView.showBadgeWithShowType(WBadgeShowStyle.Middle)
                self.headerBadgeView.showBadgeWithShowType(WBadgeShowStyle.Middle)
                judgeIsAddCount(0)
            }
            else {
                
                self.messageBadgeView.clearBadge()
                judgeIsDecCount(0)
                self.judgeIsDeleteRedBadge()
            }
            
            
            }) { (content, message) -> Void in
                
        }
        
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
                let followedImageView = UIImageView(frame: CGRECT(0, 0, self.followBtn.frame.width, self.followBtn.frame.height))
                followedImageView.image = UIImage(named: "btn_Followed")
                self.followBtn.removeAllSubviews()
                self.followBtn.addSubview(followedImageView)
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
            self.tableView.reloadData()
            scrollView.contentOffset = CGPoint(x: 0, y: 0)
        }
        if sender == postHeaderBtn {
            headerBtnFormatBeSelected(postHeaderBtn)
            headerBtnFormatBeDeselected(treatmentHeaderBtn)
            isSelectedTreatment = false
            self.relatedTableView.reloadData()
            scrollView.contentOffset = CGPoint(x: screenWidth, y: 0)
            if profileOwnername != username{
                let postTableVC = PostsTableViewController()
                postTableVC.username = profileOwnername as! String
                self.addChildViewController(postTableVC)
                self.relatedTableView.removeFromSuperview()
                postTableVC.tableView.frame = CGRect(x: screenWidth, y: 0, width: screenWidth, height: self.scrollView.frame.height)
                scrollView.addSubview(postTableVC.tableView)
            }
        }
    }
    
    func headerBtnFormatBeSelected(sender: UIButton){
        sender.setTitleColor(headerColor, forState: UIControlState.Normal)
        sender.titleLabel?.font = UIFont(name: fontBoldStr, size: 13.0)
        
        self.curSelectedBtn = sender

        if firstInit {
            
            firstInit = false
            return
        }
        
        if sender == treatmentHeaderBtn {
            
            // 添加动画
            UIView.animateWithDuration(kProfileTimeInterval, animations: { () -> Void in
                let frame: CGRect = self.selectedBtnLine.frame
                self.selectedBtnLine.frame = CGRECT(0, frame.origin.y, frame.size.width, frame.size.height)
            })

        }
        if sender == postHeaderBtn {
            
            // 添加动画
            UIView.animateWithDuration(kProfileTimeInterval, animations: { () -> Void in
                let x: CGFloat = SCREEN_WIDTH / 2
                
                let frame: CGRect = self.selectedBtnLine.frame
                self.selectedBtnLine.frame = CGRECT(x, frame.origin.y, frame.size.width, frame.size.height)
            })

        }
    }
    
    func headerBtnFormatBeDeselected(sender: UIButton){
        sender.setTitleColor(UIColor.lightGrayColor(), forState: UIControlState.Normal)
        sender.titleLabel?.font = UIFont(name: fontBoldStr, size: 13.0)

    }
    
    // 判断是否删除我的奇迹红点
    
    func judgeIsDeleteRedBadge() {
    
        let isComment: Bool = NSUserDefaults.standardUserDefaults().boolForKey(unreadCommentBadgeCount)
        
        let isFollow: Bool = NSUserDefaults.standardUserDefaults().boolForKey(unreadFollowBadgeCount)
        
        let isMentioned: Bool = NSUserDefaults.standardUserDefaults().boolForKey(unreadMentionedBadgeCount)
        
        if isComment || isFollow || isMentioned {
            
            self.headerBadgeView.showBadgeWithShowType(WBadgeShowStyle.Middle)
        }
        else {
            self.headerBadgeView.clearBadge()
        }

    }
    
    // MARK: - Table view data source
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if tableView == self.tableView{
            return self.treatmentSections.count + 2
        }else{
            return 1
        }
    }
    
    // MARK: - scrollView Delegate
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        
        startContentOffsetX = scrollView.contentOffset.x
    }

    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
        endContentOffsetX = scrollView.contentOffset.x
        
        if abs(endContentOffsetX - startContentOffsetX) > SCREEN_WIDTH / 2 - 60 && scrollView == self.scrollView  {
        
            if self.curSelectedBtn == treatmentHeaderBtn {
                
                headerBtnFormatBeSelected(postHeaderBtn)
                headerBtnFormatBeDeselected(treatmentHeaderBtn)
                isSelectedTreatment = false
                self.relatedTableView.reloadData()
            }
            else {
                
                headerBtnFormatBeSelected(treatmentHeaderBtn)
                headerBtnFormatBeDeselected(postHeaderBtn)
                isSelectedTreatment = true
                self.tableView.reloadData()
            }
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var numberOfRows: Int = 0
        if tableView == self.tableView{
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
        }else if tableView == self.relatedTableView{
            if (self.username == self.profileOwnername) {
                numberOfRows = relatedToMe.count + 1
            }else{
                numberOfRows = 1
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
        if tableView == self.tableView {
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
                    cell.textLabel?.text = relatedToMe[indexPath.row] as? String
                    cell.textLabel?.textColor = cellTextColor
                    cell.textLabel?.font = cellTextFont
                    cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
                    
                    if indexPath.row == 0 {
                        
                        self.messageBadgeView.frame = CGRECT(SCREEN_WIDTH - 70, cell.frame.size.height / 2 - 7, 20, 20)
                        cell.addSubview(self.messageBadgeView)
                    }
                    else if indexPath.row == 1 {
                    
                        self.mentionedBadgeView.frame = CGRECT(SCREEN_WIDTH - 70, cell.frame.size.height / 2 - 7, 20, 20)
                        cell.addSubview(self.mentionedBadgeView)
                    }
                    else if indexPath.row == 2 {
                    
                        self.followBadgeView.frame = CGRECT(SCREEN_WIDTH - 70, cell.frame.size.height / 2 - 7, 20, 20)
                        cell.addSubview(self.followBadgeView)

                    }
                    else {
                    
                    }

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
                cell.textLabel?.text = relatedToOther![indexPath.row] as? String
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
        treatmentSections.removeAllObjects()
        if (username != nil) && (password != nil){
            var jsonResult:AnyObject? = nil
            
            getAccessToken.getAccessToken()
            if NSUserDefaults.standardUserDefaults().objectForKey(accessNSUserData) != nil{
                let accessToken = NSUserDefaults.standardUserDefaults().objectForKey(accessNSUserData) as! String
                let urlPath:String = getUserDetailURL + "?access_token=" + accessToken
                let requestBody = NSDictionary(object: self.profileOwnername!, forKey: "username")
                jsonResult = NetRequest.sharedInstance.POST_A(urlPath, parameters: requestBody as! Dictionary<String, AnyObject>)
            }

            
            if (jsonResult != nil) && (jsonResult is NSDictionary) && ((jsonResult as! NSDictionary).objectForKey("content") != nil){
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
        self.tableView.mj_header.endRefreshing()

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
        if tableView == self.tableView{
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
    
    func editTreatment(sender: UIButton){
        //updateTreatment
        
        self.performSegueWithIdentifier("updateTreatment", sender: self)
    }
    
    
    func tableView (tableView:UITableView,  viewForHeaderInSection section:Int)->UIView? {
        let headerView = UIView()
        if tableView == self.tableView{
            var headerViewHeight: CGFloat = 0
            if section == 1 {
                let treatmentTitleW: CGFloat = treatmentHeaderStr.sizeWithFont(treatmentHeaderFont, maxSize: CGSize(width: CGFloat.max, height: 13)).width
                let treatmentTitleLable = UILabel(frame: CGRect(x: treatmentHeaderLeftSpace, y: treatmentHeaderTopSpace, width: treatmentTitleW, height: 13))
                treatmentTitleLable.font = treatmentHeaderFont
                treatmentTitleLable.text = treatmentHeaderStr
                treatmentTitleLable.textColor = UIColor.lightGrayColor()
                headerView.addSubview(treatmentTitleLable)
                headerViewHeight += treatmentTitleLable.frame.height
                
                if username == self.profileOwnername {
                    //编辑治疗方案
                    let editTreatmentBtn = UIButton(frame: CGRect(x: screenWidth - 65, y: 10, width: 50, height: 23))
                    editTreatmentBtn.setTitle("编辑", forState: UIControlState.Normal)
                    editTreatmentBtn.setTitleColor(headerColor, forState: UIControlState.Normal)
                    editTreatmentBtn.titleLabel?.font = UIFont.systemFontOfSize(13)
                    editTreatmentBtn.layer.borderColor = headerColor.CGColor
                    editTreatmentBtn.layer.borderWidth = 1
                    editTreatmentBtn.layer.cornerRadius = 2
                    editTreatmentBtn.layer.masksToBounds = true
                    editTreatmentBtn.addTarget(self, action: "editTreatment:", forControlEvents: UIControlEvents.TouchUpInside)
                    headerView.addSubview(editTreatmentBtn)
                }
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
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        if tableView == self.relatedTableView {
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

        if segue.identifier == "updateTreatment" {
            let viewController = segue.destinationViewController as! UpdateTreatmentTableViewController
            viewController.treatmentList = self.treatmentList
        }
        
        if segue.identifier == "showPostsSegue" {
            let viewController = segue.destinationViewController as! PostsTableViewController
            viewController.username = self.profileOwnername as! String
        }
    }
    
    func logout(sender: UIButton){
        publicService.logOutAccount()
        let storyboard = UIStoryboard(name: "Registeration", bundle: nil)
        let controller = storyboard.instantiateViewControllerWithIdentifier("LoginEntry") as UIViewController
        self.presentViewController(controller, animated: true, completion: nil)
    }
    
}
