//
//  UserProfileViewController.swift
//  CancerSN
//
//  Created by lily on 9/1/15.
//  Copyright (c) 2015 lily. All rights reserved.
//

import UIKit
import CoreData

let kProfileTimeInterval = 0.25

class UserProfileViewController: UIViewController , UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate {
    //context For LocalDB
    var context:NSManagedObjectContext?
    var setUserProfileTimeStamp = "setUserProfileTimeStamp"
    
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
    
    var treatmentList = NSArray()
    var treatmentObjList = NSMutableArray()
    
    var patientStatusList = NSArray()
    var patientStatusObjList = NSMutableArray()
    
    var clinicReportList = NSArray()
    var clinicReportObjList = NSMutableArray()
    
    var treatmentSections = NSMutableArray()
    var sectionHeaderHeightList = NSMutableArray()
    var ceaList = NSArray()
    var userProfile = NSDictionary()
    var userProfileObj = UserProfile()
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
    let relatedToMe: NSArray = ["我发布的", "@我的", "关注", "基本资料"]
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
    
    var commentCount: Int = 0
    
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
        let access_token = UserDefaults.standard.object(forKey: accessNSUserData)
        if access_token != nil {
            initRefresh()
            if self.profileOwnername == nil{
                profileOwnername = self.username
            }
            initVariables()
            initContentView()
            
            self.tableView.register(ChartSummaryTableViewCell.self, forCellReuseIdentifier: "ChartSummaryIdentifier")
            self.tableView.register(PatientStatusTableViewCell.self, forCellReuseIdentifier: "patientstatusIdentifier")
            self.tableView.delegate = self
            self.tableView.dataSource = self
            self.relatedTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
            self.relatedTableView.delegate = self
            self.relatedTableView.dataSource = self
        }else{
            let alertController = UIAlertController(title: "需要登录才能更新您的信息", message: nil, preferredStyle: .alert)
            
            let cancelAction = UIAlertAction(title: "取消", style: .default) { (action) in
                
            }
            
            alertController.addAction(cancelAction)
            let loginAction = UIAlertAction(title: "登陆", style: .cancel) { (action) in
                let storyboard = UIStoryboard(name: "Registeration", bundle: nil)
                let controller = storyboard.instantiateViewController(withIdentifier: "LoginEntry") as UIViewController
                self.present(controller, animated: true, completion: nil)
            }
            alertController.addAction(loginAction)
            
            
            self.present(alertController, animated: true) {
                // ...
            }
        }
        let appDel:AppDelegate = (UIApplication.shared.delegate as! AppDelegate)
        context = appDel.managedObjectContext!
    }
    
    
    
    func initRefresh(){
        self.tableView.mj_header = MJRefreshNormalHeader.init(refreshingBlock: { () -> Void in
            self.userProfileObj.username = ""
            self.getTreatmentsData()
            self.tableView.mj_header.endRefreshing()
            if self.userProfileObj.username == "" {
                let alert = UIAlertController(title: "提示", message: "oops....网络不给力", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "确定", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                self.tabBarController?.selectedIndex = 0
                
            }else{
                self.reloadHeader()
                self.tableView.reloadData()
            }
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        let access_token = UserDefaults.standard.object(forKey: accessNSUserData)
        if access_token != nil {
            
            if keychainAccess.getPasscode(accessNSUserData) != nil {
                
                // 展示未读@我的红点
                self.getUnreadMentionedCountFromServer()
                
                // 展示未读关注的红点
                self.getUnreadFollowCountFromServer()
                
                // 展示未读消息的红点
                self.getUnreadCommentCountFromServer()
                
            }
            
            self.getTreatmentsData()
            self.reloadHeader()
            self.tableView.reloadData()
            self.view.addSubview(userProfileHeaderView)
            self.view.addSubview(scrollView)
            //        HudProgressManager.sharedInstance.dismissHud()
            let titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: view.frame.size.width - 120, height: 44))
            titleLabel.textAlignment = NSTextAlignment.center
            if username != profileOwnername {
                titleLabel.text = "他的奇迹"
            }else{
                titleLabel.text = "我的奇迹"
            }
            titleLabel.textColor = UIColor.white
            self.navigationItem.titleView = titleLabel
        }
    }
    
    // MARK: - Init Variables
    func initVariables() {
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        headerHeight = UIApplication.shared.statusBarFrame.height + (self.navigationController?.navigationBar.frame.height)!
        screenWidth = UIScreen.main.bounds.width
        segmentSectionBtnHeight = 43
        
    }
    
    func reloadHeader(){
        if (self.userProfileObj.gender != nil) && (((self.userProfileObj.gender)!) == "F") {
            relatedToOther = NSArray(array: [herProfileStr])
        }else{
            relatedToOther = NSArray(array: [hisProfileStr])
        }
        
        self.treatmentHeaderBtn.setTitle(processHeaderStr, for: UIControlState())
        
        if (self.username == self.profileOwnername) {
            self.postHeaderBtn.setTitle(myProfileStr, for: UIControlState())
        }else{
            if (self.userProfileObj.gender != nil) && (((self.userProfileObj.gender)!) == "F"){
                self.postHeaderBtn.setTitle(herProfileStr, for: UIControlState())
            }else{
                self.postHeaderBtn.setTitle(hisProfileStr, for: UIControlState())
            }
        }
        
        var imageURL = ""
        
        if self.userProfileObj.portraitUrl != nil {
            imageURL = (self.userProfileObj.portraitUrl)! + "@80h_80w_1e"
        }
        
        self.portraitView.addImageCache(imageURL, placeHolder: placeHolderStr)
        if self.userProfileObj.nick != nil {
            nicknameLabel.text = (self.userProfileObj.nick)!
        }
        
        let profileStr = publicService.getProfileStrByDictionary(self.userProfileObj)
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
        
        self.relatedTableView.tableFooterView = UIView(frame: CGRect.zero)
        
        scrollView.addSubview(self.tableView)
        self.relatedTableView.separatorStyle = .none
        scrollView.addSubview(self.relatedTableView)
        
        scrollView.isUserInteractionEnabled = true
        scrollView.isPagingEnabled = true
        scrollView.delegate = self
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.bounces = false
        scrollView.alwaysBounceHorizontal = false
        
        //初始化“治疗和方案”
        self.treatmentHeaderBtn.frame = CGRect(x: 0, y: 1, width: screenWidth/2 , height: segmentSectionBtnHeight)
        
        self.selectedBtnLine.frame = CGRect(x: 0, y: segmentSectionBtnHeight - 2, width: screenWidth/2, height: 2)
        self.treatmentHeaderBtn.addSubview(self.selectedBtnLine)
        self.treatmentHeaderBtn.addTarget(self, action: #selector(UserProfileViewController.selectSegment(_:)), for: UIControlEvents.touchUpInside)
        self.userProfileHeaderView.addSubview(treatmentHeaderBtn)
        
        
        //初始化“与我相关”
        self.postHeaderBtn.frame = CGRect(x: screenWidth/2, y: 1, width: screenWidth/2, height: segmentSectionBtnHeight)
        
        self.headerBadgeView.frame = CGRECT(3 * (SCREEN_WIDTH / 4) + 10, 5, 20, 20)
        self.userProfileHeaderView.addSubview(self.headerBadgeView)
        
        if (self.username == self.profileOwnername) {
            self.postHeaderBtn.setTitle(myProfileStr, for: UIControlState())
        }else{
            if (self.userProfileObj.gender != nil) && (((self.userProfileObj.gender)!) == "F"){
                self.postHeaderBtn.setTitle(herProfileStr, for: UIControlState())
            }else{
                self.postHeaderBtn.setTitle(hisProfileStr, for: UIControlState())
            }
        }
        self.postHeaderBtn.addTarget(self, action: #selector(UserProfileViewController.selectSegment(_:)), for: UIControlEvents.touchUpInside)
        self.userProfileHeaderView.addSubview(postHeaderBtn)
        if isSelectedTreatment{
            selectSegment(self.treatmentHeaderBtn)
        }else{
            selectSegment(self.postHeaderBtn)
        }
        
        //初始化分割线
        let seperateLine = UIView(frame: CGRect(x: 0, y: 1+segmentSectionBtnHeight, width: screenWidth, height: 0.5))
        seperateLine.backgroundColor = seperateLineColor
        self.userProfileHeaderView.addSubview(seperateLine)
        
        //头像
        portraitView.frame = CGRect(x: 15, y: 20 + self.segmentSectionBtnHeight + 2, width: 40, height: 40)
        portraitView.layer.cornerRadius = 20
        portraitView.layer.masksToBounds = true
        
        self.userProfileHeaderView.addSubview(portraitView)
        
        //关注
        addFollowingBtnDisplay()
        
        //昵称 和 profile描述 标签
        let profileLabelWidth: CGFloat = screenWidth - 25 - 40 - 15 - followBtnWidth
        nicknameLabel.frame = CGRect(x: 65, y: 45 + 23, width: profileLabelWidth, height: 14)
        nicknameLabel.textColor = nicknameColor
        nicknameLabel.font = nicknameFont
        self.userProfileHeaderView.addSubview(nicknameLabel)
        
        profileLabel.frame = CGRect(x: 65,  y: 90, width: profileLabelWidth, height: 12)
        profileLabel.textColor = UIColor.lightGray
        profileLabel.font = UIFont(name: fontStr, size: 12.0)
        
        self.userProfileHeaderView.addSubview(profileLabel)
        
    }
    
    // MARK: - 网络请求
    
    // MARK: 获取未读@我的数量
    
    func getUnreadMentionedCountFromServer() {
        
        NetRequest.sharedInstance.POST(getNewMentionedCountURL , isToken: false, parameters: [ "username" : keychainAccess.getPasscode(usernameKeyChain)!], success: { (content, message) -> Void in
            
            let dict: NSDictionary = content as! NSDictionary
            
            if dict["count"] as! Int > 0 {
                
                self.mentionedBadgeView.showBadge(withShowType: WBadgeShowStyle.middle)
                self.headerBadgeView.showBadge(withShowType: WBadgeShowStyle.middle)
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
        
        NetRequest.sharedInstance.POST(getNewFollowCountURL , isToken: false, parameters: [ "username" : keychainAccess.getPasscode(usernameKeyChain)!], success: { (content, message) -> Void in
            
            let dict: NSDictionary = content as! NSDictionary
            
            if dict["count"] as! Int > 0 {
                
                self.followBadgeView.showBadge(withShowType: WBadgeShowStyle.middle)
                self.headerBadgeView.showBadge(withShowType: WBadgeShowStyle.middle)
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
        
        NetRequest.sharedInstance.POST(getNewCommentCountURL , isToken: false, parameters: [ "username" : keychainAccess.getPasscode(usernameKeyChain)!], success: { (content, message) -> Void in
            
            let dict: NSDictionary = content as! NSDictionary
            
            if dict["count"] as! Int > 0 {
                
                self.commentCount = dict["count"] as! Int
                self.messageBadgeView.showBadge(withShowType: WBadgeShowStyle.middle)
                self.headerBadgeView.showBadge(withShowType: WBadgeShowStyle.middle)
                judgeIsAddCount(0)
            }
            else {
                
                self.commentCount = 0
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
            let accessToken = UserDefaults.standard.object(forKey: accessNSUserData)
            let urlPath:String = (isFollowingUserURL as String) + "?access_token=" + (accessToken as! String);
            
            let requestBody = NSMutableDictionary()
            requestBody.setObject(self.profileOwnername!, forKey: "followingUser" as NSCopying)
            requestBody.setObject(keychainAccess.getPasscode(usernameKeyChain)!, forKey: "username" as NSCopying)
            
            NetRequest.sharedInstance.POST(urlPath, parameters: (requestBody as NSDictionary) as! Dictionary<String, AnyObject>,
                success: { (content , message) -> Void in
                    if (content is NSDictionary) && ((content as! NSDictionary).object(forKey: "count") as! Int) == 0 {
                        self.followBtn.frame = CGRect(x: self.screenWidth - followBtnRightSpace - followBtnWidth , y: followBtnTopSpace, width: followBtnWidth, height: followBtnHeight)
                        let addFollowingImage = UIImageView(image: UIImage(named: "btn_addFollowing"))
                        self.followBtn.addSubview(addFollowingImage)
                        self.followBtn.layer.borderColor = followBtnBorderColor.cgColor
                        self.followBtn.layer.borderWidth = followBtnBorderWidth
                        self.followBtn.layer.cornerRadius = cornerRadius
                        self.followBtn.addTarget(self, action: "addFollowing:", for: UIControlEvents.touchUpInside)
                        self.userProfileHeaderView.addSubview(self.followBtn)
                    }
                }) { (content, message) -> Void in
                    
            }
        }
    }
    
    func addFollowing(_ sender: UIButton){
        getAccessToken.getAccessToken()
        let accessToken = UserDefaults.standard.object(forKey: accessNSUserData)
        let urlPath:String = (addFollowingURL as String) + "?access_token=" + (accessToken as! String);
        
        let requestBody = NSMutableDictionary()
        requestBody.setObject(self.profileOwnername!, forKey: "followingUser" as NSCopying)
        requestBody.setObject(keychainAccess.getPasscode(usernameKeyChain)!, forKey: "username" as NSCopying)
        
        NetRequest.sharedInstance.POST(urlPath, parameters: (requestBody as NSDictionary) as! Dictionary<String, AnyObject>,
            success: { (content , message) -> Void in
                HudProgressManager.sharedInstance.showHudProgress(self, title: "已关注")
                self.followBtn.isEnabled = false
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
    func selectSegment(_ sender: UIButton){
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
                let postTableVC = PostsListTableViewController()
                postTableVC.username = profileOwnername as! String
                self.addChildViewController(postTableVC)
                self.relatedTableView.removeFromSuperview()
                postTableVC.tableView.frame = CGRect(x: screenWidth, y: 0, width: screenWidth, height: self.scrollView.frame.height)
                scrollView.addSubview(postTableVC.tableView)
            }
        }
    }
    
    func headerBtnFormatBeSelected(_ sender: UIButton){
        sender.setTitleColor(headerColor, for: UIControlState())
        sender.titleLabel?.font = UIFont(name: fontBoldStr, size: 13.0)
        
        self.curSelectedBtn = sender
        
        if firstInit {
            
            firstInit = false
            return
        }
        
        if sender == treatmentHeaderBtn {
            
            // 添加动画
            UIView.animate(withDuration: kProfileTimeInterval, animations: { () -> Void in
                let frame: CGRect = self.selectedBtnLine.frame
                self.selectedBtnLine.frame = CGRECT(0, frame.origin.y, frame.size.width, frame.size.height)
            })
            
        }
        if sender == postHeaderBtn {
            
            // 添加动画
            UIView.animate(withDuration: kProfileTimeInterval, animations: { () -> Void in
                let x: CGFloat = SCREEN_WIDTH / 2
                
                let frame: CGRect = self.selectedBtnLine.frame
                self.selectedBtnLine.frame = CGRECT(x, frame.origin.y, frame.size.width, frame.size.height)
            })
            
        }
    }
    
    func headerBtnFormatBeDeselected(_ sender: UIButton){
        sender.setTitleColor(UIColor.lightGray, for: UIControlState())
        sender.titleLabel?.font = UIFont(name: fontBoldStr, size: 13.0)
        
    }
    
    // 判断是否删除我的奇迹红点
    
    func judgeIsDeleteRedBadge() {
        
        let isComment: Bool = UserDefaults.standard.bool(forKey: unreadCommentBadgeCount)
        
        let isFollow: Bool = UserDefaults.standard.bool(forKey: unreadFollowBadgeCount)
        
        let isMentioned: Bool = UserDefaults.standard.bool(forKey: unreadMentionedBadgeCount)
        
        if isComment || isFollow || isMentioned {
            
            self.headerBadgeView.showBadge(withShowType: WBadgeShowStyle.middle)
        }
        else {
            self.headerBadgeView.clearBadge()
        }
        
    }
    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if tableView == self.tableView{
            return self.treatmentSections.count + 2
        }else{
            return 1
        }
    }
    
    // MARK: - scrollView Delegate
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        
        startContentOffsetX = scrollView.contentOffset.x
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
        endContentOffsetX = scrollView.contentOffset.x
        
        if abs(endContentOffsetX - startContentOffsetX) > 40 && scrollView == self.scrollView {
            
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var numberOfRows: Int = 0
        if tableView == self.tableView{
            if section == 0 {
                if self.clinicReportObjList.count > 0 {
                    numberOfRows = 1
                }else{
                    numberOfRows = 0
                }
            }else if section == 1{
                numberOfRows = 1
            }else{
                let patientStatus = (treatmentSections[section-2] as! NSDictionary)["patientStatus"]
                
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
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var rowHeight: CGFloat = 0.0
        if isSelectedTreatment {
            if indexPath.section == 0{
                if indexPath.row == 0{
                    rowHeight = self.clinicReportObjList.count > 0 ? 234 : 0
                }
            }
            if indexPath.section > 1{
                let patientStatusListInSection = (treatmentSections[indexPath.section - 2] as! NSDictionary).object(forKey: "patientStatus") as! NSArray
                let patientStatusFrame = PatientStatusFrame()
                patientStatusFrame.cellWidth = screenWidth
                patientStatusFrame.patientStatus = patientStatusListInSection[indexPath.row] as! PatientStatusObj
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
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier:String = "cell"
        let cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: cellIdentifier)
        if tableView == self.tableView {
            if indexPath.section == 0 {
                if indexPath.row == 0{
                    let treatmentSummaryCell = tableView.dequeueReusableCell(withIdentifier: "ChartSummaryIdentifier", for: indexPath) as! ChartSummaryTableViewCell
                    if clinicReportObjList.count > 0{
                        treatmentSummaryCell.treatmentList = treatmentObjList as! Array<TreatmentObj>
                        treatmentSummaryCell.clinicReportList = clinicReportObjList as! Array<ClinicDataObj>
                    }
                    return treatmentSummaryCell
                }
            }else if indexPath.section > 1 {
                let patientstatusCell = tableView.dequeueReusableCell(withIdentifier: "patientstatusIdentifier", for: indexPath) as! PatientStatusTableViewCell
                patientstatusCell.selectionStyle = UITableViewCellSelectionStyle.none
                let patientStatusListInSection = (treatmentSections[indexPath.section - 2] as! NSDictionary).object(forKey: "patientStatus") as! NSArray
                patientstatusCell.indexPath = indexPath
                patientstatusCell.patientStatus = patientStatusListInSection[indexPath.row] as! PatientStatusObj
                return patientstatusCell
            }
            
        }else{
            if (self.username == self.profileOwnername) {
                if indexPath.row < relatedToMe.count{
                    cell.textLabel?.text = relatedToMe[indexPath.row] as? String
                    cell.textLabel?.textColor = cellTextColor
                    cell.textLabel?.font = cellTextFont
                    cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
                    
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
                    logoutBtn.setTitle("退出登录", for: UIControlState())
                    logoutBtn.setTitleColor(UIColor.white, for: UIControlState())
                    logoutBtn.titleLabel?.font = logoutBtnTextFont
                    logoutBtn.layer.cornerRadius = cornerRadius
                    logoutBtn.layer.masksToBounds = true
                    logoutBtn.addTarget(self, action: #selector(UserProfileViewController.logout(_:)), for: UIControlEvents.touchUpInside)
                    cell.addSubview(logoutBtn)
                }
            }else{
                cell.textLabel?.text = relatedToOther![indexPath.row] as? String
                cell.textLabel?.textColor = cellTextColor
                cell.textLabel?.font = cellTextFont
                cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
                
            }
            let seperatorLine:UIView = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: seperatorLineH))
            seperatorLine.backgroundColor = seperateLineColor
            cell.addSubview(seperatorLine)
        }
        return cell
    }
    
    func getUserFromLocalDB(){
        let userRequest = NSFetchRequest<NSFetchRequestResult>(entityName: tableUser)
        userRequest.returnsDistinctResults = true
        userRequest.returnsObjectsAsFaults = false
        userRequest.resultType = NSFetchRequestResultType.dictionaryResultType
        let users = (try! context!.fetch(userRequest)) as NSArray
        if users.count > 0{
            let user = users.object(at: 0)
            self.userProfileObj.initVariables(user as! NSDictionary)
        }
    }
    
    func getTreatmentListFromLocalDB(){
        let treatmentRequest = NSFetchRequest<NSFetchRequestResult>(entityName: tableTreatment)
        treatmentRequest.returnsDistinctResults = true
        treatmentRequest.returnsObjectsAsFaults = false
        treatmentRequest.resultType = NSFetchRequestResultType.dictionaryResultType
        treatmentRequest.sortDescriptors = [NSSortDescriptor(key: propertyBeginDate, ascending: false)]
        let treatmentList = try! context!.fetch(treatmentRequest)
        let homeData = TreatmentObj.jsonToModelList(treatmentList as AnyObject?) as! Array<TreatmentObj>
        self.treatmentObjList.removeAllObjects()
        self.treatmentObjList.addObjects(from: homeData)
    }
    
    func getPatientStatusFromLocalDB(){
        let patientStatusRequest = NSFetchRequest<NSFetchRequestResult>(entityName: tablePatientStatus)
        patientStatusRequest.returnsDistinctResults = true
        patientStatusRequest.returnsObjectsAsFaults = false
        patientStatusRequest.resultType = NSFetchRequestResultType.dictionaryResultType
        patientStatusRequest.sortDescriptors = [NSSortDescriptor(key: propertyInsertedDate, ascending: false)]
        let patientStatusList = try! context!.fetch(patientStatusRequest)
        let homeData = PatientStatusObj.jsonToModelList(patientStatusList as AnyObject?) as! Array<PatientStatusObj>
        self.patientStatusObjList.removeAllObjects()
        self.patientStatusObjList.addObjects(from: homeData)
    }
    
    func getClinicDataFromLocalDB(){
        let clinicDataRequest = NSFetchRequest<NSFetchRequestResult>(entityName: tableClinicData)
        clinicDataRequest.propertiesToFetch = [propertyClinicItemName]
        clinicDataRequest.returnsDistinctResults = true
        clinicDataRequest.returnsObjectsAsFaults = false
        clinicDataRequest.sortDescriptors = [NSSortDescriptor(key: propertyClinicItemName, ascending: true)]
        
        clinicDataRequest.resultType = NSFetchRequestResultType.dictionaryResultType
        let clinicTypeResult = try! context!.fetch(clinicDataRequest)
        let clinicTypeList = ClinicDataObj.jsonToModelList(clinicTypeResult as AnyObject?) as! Array<ClinicDataObj>
        
        clinicDataRequest.propertiesToFetch = [propertyClinicDataID, propertyClinicItemName, propertyClinicItemValue, propertyClinicDataStatusID, propertyClinicDataInsertDate, propertyClinicDataUsername]
        clinicDataRequest.sortDescriptors = [NSSortDescriptor(key: propertyClinicDataInsertDate, ascending: false)]
        
        let fullClinicDataList = try! context!.fetch(clinicDataRequest)
        let fullClinicDataArr = SubClinicDataObj.jsonToModelList(fullClinicDataList as AnyObject?) as! Array<SubClinicDataObj>
        for clinicData in clinicTypeList {
            let clinicDataInType = NSMutableArray()
            for subClinicData in fullClinicDataArr {
                if (subClinicData.clinicItemName == clinicData.clinicItemName){
                    clinicDataInType.add(subClinicData)
                }
            }
            clinicData.clinicDataList = (clinicDataInType as NSArray) as! Array
        }
        
        self.clinicReportObjList = NSMutableArray(array: clinicTypeList as NSArray)
    }
    
    //save userProfile to Local database
    func saveUserToLocalDB(){
        let userLocalDBItem = NSEntityDescription.insertNewObject(forEntityName: tableUser, into: context!)
        userLocalDBItem.setValue(userProfileObj.username, forKey: propertyUsername)
        userLocalDBItem.setValue(userProfileObj.email, forKey: propertyEmail)
        userLocalDBItem.setValue(userProfileObj.nick, forKey: propertyDisplayname)
        userLocalDBItem.setValue(userProfileObj.gender, forKey: propertyGender)
        userLocalDBItem.setValue(userProfileObj.pathological, forKey: propertyPathological)
        userLocalDBItem.setValue(userProfileObj.stage, forKey: propertyStage)
        userLocalDBItem.setValue(userProfileObj.age, forKey: propertyAge)
        userLocalDBItem.setValue(userProfileObj.cancerType, forKey: propertyCancerType)
        userLocalDBItem.setValue(userProfileObj.metastics, forKey: propertyMetastasis)
        userLocalDBItem.setValue(userProfileObj.geneticMutation, forKey: propertyGeneticMutation)
        userLocalDBItem.setValue(userProfileObj.portraitUrl, forKey: propertyImageURL)
        userLocalDBItem.setValue(userProfileObj.phone, forKey: propertyPhone)
        do {
            try context!.save()
        } catch _ {
        }
    }
    
    func saveTreatmentListToLocalDB(){
        for treatment in treatmentObjList {
            let treatmentLocalDBItem = NSEntityDescription.insertNewObject(forEntityName: tableTreatment, into: context!)
            let treatmentObj = treatment as! TreatmentObj
            treatmentLocalDBItem.setValue(treatmentObj.treatmentName , forKey: propertyTreatmentName)
            treatmentLocalDBItem.setValue(treatmentObj.username , forKey: propertyTreatmentUsername)
            treatmentLocalDBItem.setValue(treatmentObj.dosage , forKey: propertyDosage)
            treatmentLocalDBItem.setValue(treatmentObj.beginDate , forKey: propertyBeginDate)
            treatmentLocalDBItem.setValue(treatmentObj.endDate , forKey: propertyEndDate)
            treatmentLocalDBItem.setValue(treatmentObj.treatmentID, forKey: propertyTreatmentID)
        }
        do {
            try context!.save()
        } catch _ {
        }
    }
    
    func savePatientStatusToLocalDB(){
        for patientStatus in patientStatusObjList {
            let patientstatusLocalDBItem = NSEntityDescription.insertNewObject(forEntityName: tablePatientStatus, into: context!)
            let patientStatusObj = patientStatus as! PatientStatusObj
            patientstatusLocalDBItem.setValue(patientStatusObj.statusID , forKey: propertyStatusID)
            patientstatusLocalDBItem.setValue(patientStatusObj.username , forKey: propertyPatientStatusUsername)
            patientstatusLocalDBItem.setValue(patientStatusObj.statusDesc , forKey: propertyStatusDesc)
            patientstatusLocalDBItem.setValue(patientStatusObj.insertedDate , forKey: propertyInsertedDate)
            patientstatusLocalDBItem.setValue(patientStatusObj.imageURL , forKey: propertyPatientStatusImageURL)
            patientstatusLocalDBItem.setValue(patientStatusObj.scanData , forKey: propertyScanData)
            patientstatusLocalDBItem.setValue(patientStatusObj.hasImage , forKey: propertyHasImage)
        }
        do {
            try context!.save()
        } catch _ {
        }
    }
    
    func saveClinicDataToLocalDB(){
        for clinicReport in self.clinicReportObjList {
            let clinicDataList = (clinicReport as! ClinicDataObj).clinicDataList
            for clinicData in clinicDataList! {
                let clinicDataLocalDBItem = NSEntityDescription.insertNewObject(forEntityName: tableClinicData, into: context!)
                clinicDataLocalDBItem.setValue(clinicData.clinicItemName, forKey: propertyClinicItemName)
                clinicDataLocalDBItem.setValue(clinicData.clinicItemValue, forKey: propertyClinicItemValue)
                clinicDataLocalDBItem.setValue(clinicData.statusID, forKey: propertyClinicDataStatusID)
                clinicDataLocalDBItem.setValue(clinicData.insertDate, forKey: propertyClinicDataInsertDate)
                clinicDataLocalDBItem.setValue(clinicData.insertUsername, forKey: propertyClinicDataUsername)
            }
        }
        do {
            try context!.save()
        } catch _ {
        }
    }
    
    func clearUserFromLocalDB() {
        let deleteUserRequet = NSFetchRequest<NSFetchRequestResult>(entityName: tableUser)
        if let results = try? context!.fetch(deleteUserRequet) {
            for param in results {
                context!.delete(param as! NSManagedObject);
            }
        }
        do {
            try context!.save()
        } catch _ {
        }
    }
    
    func clearTreatmentFromLocalDB() {
        let deleteTreatmentRequet = NSFetchRequest<NSFetchRequestResult>(entityName: tableTreatment)
        if let results = try? context!.fetch(deleteTreatmentRequet) {
            for param in results {
                context!.delete(param as! NSManagedObject);
            }
        }
        do {
            try context!.save()
        } catch _ {
        }
    }
    
    func clearPatientStatusFromLocalDB() {
        let deletePatientStatusRequet = NSFetchRequest<NSFetchRequestResult>(entityName: tablePatientStatus)
        if let results = try? context!.fetch(deletePatientStatusRequet) {
            for param in results {
                context!.delete(param as! NSManagedObject);
            }
        }
        do {
            try context!.save()
        } catch _ {
        }
    }
    
    func clearClinicDataFromLocalDB() {
        let deleteClinicDataRequet = NSFetchRequest<NSFetchRequestResult>(entityName: tableClinicData)
        if let results = try? context!.fetch(deleteClinicDataRequet) {
            for param in results {
                context!.delete(param as! NSManagedObject);
            }
        }
        do {
            try context!.save()
        } catch _ {
        }
    }
    
    func getTreatmentsData(){
        self.treatmentSections.removeAllObjects()
        if self.username == self.profileOwnername {
            
            let currentTimeStamp: Double = Foundation.Date().timeIntervalSince1970
            var previousStoreTimestamp: Double = 0
            if  UserDefaults.standard.object(forKey: setUserProfileTimeStamp) != nil {
                previousStoreTimestamp = UserDefaults.standard.object(forKey: setUserProfileTimeStamp) as! Double
                
            }
            if (currentTimeStamp - previousStoreTimestamp) > 86400 * 15 {
                clearUserFromLocalDB()
                clearTreatmentFromLocalDB()
                clearPatientStatusFromLocalDB()
                clearClinicDataFromLocalDB()
            }else{
                getUserFromLocalDB()
                getTreatmentListFromLocalDB()
                getPatientStatusFromLocalDB()
                getClinicDataFromLocalDB()
            }
        }
        
        if (self.userProfileObj.username == "") || (self.userProfileObj.username == nil) {
            if (username != nil) && (password != nil){
                var jsonResult:AnyObject? = nil
                
                getAccessToken.getAccessToken()
                if UserDefaults.standard.object(forKey: accessNSUserData) != nil{
                    let accessToken = UserDefaults.standard.object(forKey: accessNSUserData) as! String
                    let urlPath:String = getUserDetailURL + "?access_token=" + accessToken
                    let requestBody = NSDictionary(object: self.profileOwnername!, forKey: "username" as NSCopying)
                    jsonResult = NetRequest.sharedInstance.POST_A(urlPath, parameters: requestBody as! Dictionary<String, AnyObject>)
                }
                
                if (jsonResult != nil) && (jsonResult is NSDictionary) && ((jsonResult as! NSDictionary).object(forKey: "content") != nil){
                    UserDefaults.standard.set(Foundation.Date().timeIntervalSince1970, forKey: setTagListTimeStamp)
                    let userDetail = (jsonResult as! NSDictionary).object(forKey: "content")
                    self.treatmentList = (userDetail! as AnyObject).object(forKey: "treatments") as! NSArray
                    let treatmentObjectList = TreatmentObj.jsonToModelList(treatmentList) as! Array<TreatmentObj>
                    self.treatmentObjList.removeAllObjects()
                    self.treatmentObjList.addObjects(from: treatmentObjectList)
                    
                    self.patientStatusList = (userDetail! as AnyObject).object(forKey: "patientStatus") as! NSArray
                    self.patientStatusObjList.removeAllObjects()
                    self.patientStatusObjList.addObjects(from: PatientStatusObj.jsonToModelList(patientStatusList) as! Array<PatientStatusObj>)
                    
                    let clinicReportList = (userDetail! as AnyObject).object(forKey: "clinicReport") as! NSArray
                    self.clinicReportObjList.removeAllObjects()
                    let dataList: Array = ClinicDataObj.jsonToModelList((userDetail as! NSDictionary).object(forKey: "clinicReport") as AnyObject?) as! Array<ClinicDataObj>
                    var index = 0
                    for data in dataList {
                        data.clinicDataList = SubClinicDataObj.jsonToModelList((clinicReportList[index] as! NSDictionary).object(forKey: "clinicDataList") as! AnyObject) as! Array<SubClinicDataObj>
                        index += 1
                    }
                    self.clinicReportObjList.addObjects(from: dataList)

                    self.userProfile = (userDetail! as AnyObject).object(forKey: "userProfile") as! NSDictionary
                    self.userProfileObj.initVariables(self.userProfile)
                    saveUserToLocalDB()
                    saveTreatmentListToLocalDB()
                    savePatientStatusToLocalDB()
                    saveClinicDataToLocalDB()
                    UserDefaults.standard.set(Foundation.Date().timeIntervalSince1970, forKey: setUserProfileTimeStamp)
                }
            }
        }
        var timeList = [Double]()
        let timeSet = NSMutableSet()
        for i in 0 ..< treatmentObjList.count {
            (treatmentObjList.object(at: i) as! TreatmentObj).beginDate = getNSDateMod((treatmentObjList.object(at: i) as! TreatmentObj).beginDate )
            (treatmentObjList.object(at: i) as! TreatmentObj).endDate = getNSDateMod((treatmentObjList.object(at: i) as! TreatmentObj).endDate)
            let defaultEndDateMod: Double = getNSDateMod(defaultTreatmentEndDate * 1000)
            
            let treatment = treatmentObjList.object(at: i) as! TreatmentObj
            
            if treatment.endDate == defaultEndDateMod{
                treatment.endDate = Foundation.Date().timeIntervalSince1970 * 1000
            }
            
            if timeSet.contains(treatment.endDate) == false {
                timeSet.add(treatment.endDate)
            }
            if timeSet.contains(treatment.beginDate) == false {
                timeSet.add(treatment.beginDate)
            }
        }
        
        for timeSt in timeSet {
            timeList.append(timeSt as! Double)
        }
        timeList.sort(by: >)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yy/MM/dd" // superset of OP's format
        var index = 0
        var patientStatusIndex = 0
        if (patientStatusIndex < patientStatusObjList.count) && (timeList.count>0){
            let treatmentSection = NSMutableDictionary()
            let patientStatusInTreatmentSection = NSMutableArray()
            treatmentSection.setObject((Foundation.Date().timeIntervalSince1970)*1000, forKey: "endDate" as NSCopying)
            treatmentSection.setObject((timeList[index] as AnyObject), forKey: "beginDate" as NSCopying)
            treatmentSection.setObject(patientStatusInTreatmentSection, forKey: "patientStatus" as NSCopying)
            while ((patientStatusIndex < patientStatusObjList.count) && ((patientStatusObjList[patientStatusIndex] as! PatientStatusObj).insertedDate) >= (timeList[index] as Double)) {
                patientStatusInTreatmentSection.add(patientStatusObjList[patientStatusIndex])
                patientStatusIndex += 1
            }
            if patientStatusInTreatmentSection.count > 0{
                treatmentSections.add(treatmentSection)
            }
        }
        
        while index < timeList.count-1 {
            let treatmentSection = NSMutableDictionary()
            let patientStatusInTreatmentSection = NSMutableArray()
            treatmentSection.setObject(timeList[index+1] as AnyObject, forKey: "beginDate" as NSCopying)
            treatmentSection.setObject(timeList[index] as AnyObject, forKey: "endDate" as NSCopying)
            var onedayInterval: Double = 0
            if MemoryLayout<Int>.stride == MemoryLayout<Int32>.stride {
                onedayInterval = 86500
            }else if MemoryLayout<Int>.stride == MemoryLayout<Int64>.stride {
                onedayInterval = 86500000
            }
            if (treatmentSection.object(forKey: "beginDate") as! Double) + onedayInterval < (treatmentSection.object(forKey: "endDate") as! Double){
                var treatmentStr = ""
                var dosageStr = ""
                
                for treatmentIndex in 0 ..< treatmentObjList.count {
                    let treatment = treatmentObjList.object(at: treatmentIndex) as! TreatmentObj
                    
                    if ((treatment.endDate) >= (timeList[index] as Double)) && ((treatment.beginDate) <= (timeList[index+1] as Double)) {
                        treatmentStr += (treatment.treatmentName) + " "
                        if treatment.dosage != "" {
                            dosageStr += treatment.dosage
                        }
                    }
                }
                if treatmentStr == "" {
                    treatmentStr = "空窗期"
                }
                treatmentSection.setObject(treatmentStr, forKey: "treatmentTitle" as NSCopying)
                treatmentSection.setObject(dosageStr, forKey: "dosage" as NSCopying)
                
                while ((patientStatusIndex < patientStatusObjList.count) && (((patientStatusObjList[patientStatusIndex] as! PatientStatusObj).insertedDate) >= (timeList[index+1] as Double)) && (((patientStatusObjList[patientStatusIndex] as! PatientStatusObj).insertedDate) < (timeList[index] as Double))) {
                    patientStatusInTreatmentSection.add(patientStatusObjList[patientStatusIndex])
                    patientStatusIndex += 1
                }
                treatmentSection.setObject(patientStatusInTreatmentSection, forKey: "patientStatus" as NSCopying)
            }
            treatmentSections.add(treatmentSection)
            index += 1
        }
        
        if patientStatusIndex < patientStatusObjList.count{
            let treatmentSection = NSMutableDictionary()
            let patientStatusInTreatmentSection = NSMutableArray()
            treatmentSection.setObject(((patientStatusObjList[patientStatusIndex] as! PatientStatusObj).insertedDate), forKey: "endDate" as NSCopying)
            treatmentSection.setObject(((patientStatusObjList[patientStatusObjList.count - 1] as! PatientStatusObj).insertedDate), forKey: "beginDate" as NSCopying)
            treatmentSection.setObject(noTreatmentTimeStr, forKey: "treatmentTitle" as NSCopying)
            for i in patientStatusIndex ..< patientStatusObjList.count {
                patientStatusInTreatmentSection.add(patientStatusObjList[i])
            }
            treatmentSection.setObject(patientStatusInTreatmentSection, forKey: "patientStatus" as NSCopying)
            treatmentSections.add(treatmentSection)
        }
    }
    
    func getNSDateMod(_ date: Double)->Double{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YY-MM-dd" // superset of OP's format
        let dateInserted = Foundation.Date(timeIntervalSince1970: date/1000 as TimeInterval)
        let dateStr = dateFormatter.string(from: dateInserted)
        let timeInterval = dateFormatter.date(from: dateStr)?.timeIntervalSince1970
        return timeInterval! * 1000
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        var heightForHeader:CGFloat = 0
        if tableView == self.tableView{
            if section == 1 {
                heightForHeader = 44
            }
            if (section != 0) && (section != 1) {
                if ((self.treatmentSections[section-2] as AnyObject).object(forKey: "treatmentTitle") != nil) &&  ((self.treatmentSections[section-2] as AnyObject).object(forKey: "treatmentTitle") is NSNull) == false  && (((self.treatmentSections[section-2] as AnyObject).object(forKey: "treatmentTitle") as! String) != "") {
                    let treatmentTitle: String = (self.treatmentSections[section-2] as AnyObject).object(forKey: "treatmentTitle") as! String
                    let treatmentTitleSize: CGSize = treatmentTitle.sizeWithFont(treatmentTitleFont, maxSize: CGSize(width: screenWidth - treatmentTitleLeftSpace - treatmentTitleRightSpace - treatmentDateW, height: CGFloat.greatestFiniteMagnitude))
                    heightForHeader += treatmentTitleSize.height + treatmentTitleTopSpace + dosageButtomSpace
                }
                if ((self.treatmentSections[section-2] as AnyObject).object(forKey: "dosage") != nil)  && ((self.treatmentSections[section-2] as AnyObject).object(forKey: "dosage") is NSNull) == false && (((self.treatmentSections[section-2] as AnyObject).object(forKey: "dosage") as! String) != ""){
                    let dosageStr: String = (self.treatmentSections[section-2] as AnyObject).object(forKey: "dosage") as! String
                    let dosageSize:CGSize = dosageStr.sizeWithFont(dosageFont, maxSize: CGSize(width: screenWidth - dosageLeftSpace - dosageRightSpace, height: CGFloat.greatestFiniteMagnitude))
                    heightForHeader += dosageSize.height + dosageTopSpace
                }
            }
        }
        return heightForHeader
    }
    
    func editTreatment(_ sender: UIButton){
        //updateTreatment
        
        self.performSegue(withIdentifier: "updateTreatment", sender: self)
    }
    
    
    func tableView (_ tableView:UITableView,  viewForHeaderInSection section:Int)->UIView? {
        let headerView = UIView()
        if tableView == self.tableView{
            var headerViewHeight: CGFloat = 0
            if section == 1 {
                let treatmentTitleW: CGFloat = treatmentHeaderStr.sizeWithFont(treatmentHeaderFont, maxSize: CGSize(width: CGFloat.greatestFiniteMagnitude, height: 13)).width
                let treatmentTitleLable = UILabel(frame: CGRect(x: treatmentHeaderLeftSpace, y: treatmentHeaderTopSpace, width: treatmentTitleW, height: 13))
                treatmentTitleLable.font = treatmentHeaderFont
                treatmentTitleLable.text = treatmentHeaderStr
                treatmentTitleLable.textColor = UIColor.lightGray
                headerView.addSubview(treatmentTitleLable)
                headerViewHeight += treatmentTitleLable.frame.height
                
                if username == self.profileOwnername {
                    //编辑治疗方案
                    let editTreatmentBtn = UIButton(frame: CGRect(x: screenWidth - 65, y: 10, width: 50, height: 23))
                    editTreatmentBtn.setTitle("编辑", for: UIControlState())
                    editTreatmentBtn.setTitleColor(headerColor, for: UIControlState())
                    editTreatmentBtn.titleLabel?.font = UIFont.systemFont(ofSize: 13)
                    editTreatmentBtn.layer.borderColor = headerColor.cgColor
                    editTreatmentBtn.layer.borderWidth = 1
                    editTreatmentBtn.layer.cornerRadius = 2
                    editTreatmentBtn.layer.masksToBounds = true
                    editTreatmentBtn.addTarget(self, action: #selector(UserProfileViewController.editTreatment(_:)), for: UIControlEvents.touchUpInside)
                    headerView.addSubview(editTreatmentBtn)
                }
            }
            
            
            if (section != 0) && (section != 1){
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yy/MM/dd" // superset of OP's format
                //Foundation.Date(timeIntervalSince1970: <#T##TimeInterval#>)
                let beginDate = Foundation.Date(timeIntervalSince1970: ((treatmentSections[section-2] as! Dictionary)["beginDate"])!/1000 as TimeInterval)
                let endDate = Foundation.Date(timeIntervalSince1970: ((treatmentSections[section-2] as! Dictionary)["endDate"])!/1000 as TimeInterval)
                let beginDateStr = dateFormatter.string(from: beginDate)
                let endDateStr = dateFormatter.string(from: endDate)
                let dateLabel = UILabel(frame: CGRect(x: screenWidth - treatmentDateW, y: treatmentDateTopSpace, width: treatmentDateW, height: treatmentDateH))
                dateLabel.text = beginDateStr + "-" + endDateStr
                dateLabel.textColor = UIColor.gray
                dateLabel.font = dateFont
                dateLabel.textColor = dateColor
                headerView.addSubview(dateLabel)
                
                let treatmentTitleLabel: UILabel = UILabel()
                if ((self.treatmentSections[section-2] as AnyObject).object(forKey: "treatmentTitle") != nil) &&  ((self.treatmentSections[section-2] as AnyObject).object(forKey: "treatmentTitle") is NSNull) == false  && (((self.treatmentSections[section-2] as AnyObject).object(forKey: "treatmentTitle") as! String) != "") {
                    let treatmentTitle: String = (self.treatmentSections[section-2] as AnyObject).object(forKey: "treatmentTitle") as! String
                    let treatmentTitleSize: CGSize = treatmentTitle.sizeWithFont(treatmentTitleFont, maxSize: CGSize(width: screenWidth - treatmentDateW - treatmentTitleLeftSpace - treatmentTitleRightSpace, height: CGFloat.greatestFiniteMagnitude))
                    treatmentTitleLabel.frame = CGRect(x: treatmentTitleLeftSpace, y: treatmentTitleTopSpace, width: treatmentTitleSize.width, height: treatmentTitleSize.height)
                    treatmentTitleLabel.numberOfLines = 0
                    treatmentTitleLabel.text = (self.treatmentSections[section-2] as AnyObject).object(forKey: "treatmentTitle") as? String
                    treatmentTitleLabel.font = treatmentTitleFont
                    treatmentTitleLabel.textColor = treatmentTitleColor
                    headerView.addSubview(treatmentTitleLabel)
                    headerViewHeight += treatmentTitleLabel.frame.height + treatmentTitleTopSpace + dosageButtomSpace
                }
                
                if ((self.treatmentSections[section-2] as AnyObject).object(forKey: "dosage") != nil)  && ((self.treatmentSections[section-2] as AnyObject).object(forKey: "dosage") is NSNull) == false && (((self.treatmentSections[section-2] as AnyObject).object(forKey: "dosage") as! String) != ""){
                    let dosageStr: String = (self.treatmentSections[section-2] as AnyObject).object(forKey: "dosage") as! String
                    let dosageSize:CGSize = dosageStr.sizeWithFont(dosageFont, maxSize: CGSize(width: screenWidth - dosageLeftSpace - dosageRightSpace, height: CGFloat.greatestFiniteMagnitude))
                    let dosageLabel: UILabel = UILabel(frame: CGRect(x: treatmentTitleLeftSpace, y: treatmentTitleTopSpace + dosageTopSpace + treatmentTitleLabel.frame.height, width: dosageSize.width, height: dosageSize.height))
                    dosageLabel.numberOfLines = 0
                    dosageLabel.text = (self.treatmentSections[section-2] as AnyObject).object(forKey: "dosage") as? String
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
        headerView.backgroundColor = UIColor.white
        return headerView
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        if tableView == self.relatedTableView {
            switch indexPath.row {
            case 0:
                self.performSegue(withIdentifier: "showPostsSegue", sender: self)
                break
            case 1:
                self.performSegue(withIdentifier: "showMentionSegue", sender: self)
                break
            case 2:
                self.performSegue(withIdentifier: "showFollowSegue", sender: self)
                break
            case 3:
                self.performSegue(withIdentifier: "showUserBasicInfoSeuge", sender: self)
                break
            default:
                break
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showUserBasicInfoSeuge" {
            let userBasicViewController = segue.destination as! UserBasicInfoTableViewController
            userBasicViewController.userProfile = self.userProfileObj
        }
        
        if segue.identifier == "updateTreatment" {
            let viewController = segue.destination as! UpdateTreatmentTableViewController
            viewController.treatmentList.removeAllObjects()
            viewController.treatmentList.addObjects(from: self.treatmentObjList as [AnyObject])
        }
        
        if segue.identifier == "showPostsSegue" {
            let viewController = segue.destination as! PostsViewController
            viewController.username = self.profileOwnername as! String
            viewController.commentCount = self.commentCount
        }
    }
    
    func logout(_ sender: UIButton){
        publicService.logOutAccount()
        let storyboard = UIStoryboard(name: "Registeration", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "LoginEntry") as UIViewController
        self.present(controller, animated: true, completion: nil)
    }
    
}
