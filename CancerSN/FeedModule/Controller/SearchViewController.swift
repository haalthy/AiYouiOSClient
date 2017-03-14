//
//  SearchViewController.swift
//  CancerSN
//
//  Created by lay on 16/1/23.
//  Copyright © 2016年 lily. All rights reserved.
//

import UIKit

let cellSearchUserIdentifier: String = "UserCell"
let cellSearchTreatmentIdentifier = "TreatmentCell"
let cellSearchClinicTrailIdentifier = "ClinicTrailCell"


class SearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchControllerDelegate, UISearchResultsUpdating, UISearchBarDelegate, UserVCDelegate {
    
    @IBOutlet weak var typeView: UIView!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var userBtn: UIButton!
    
    @IBOutlet weak var methodBtn: UIButton!
    
    @IBOutlet weak var patientBtn: UIButton!
    
    let getAccessToken = GetAccessToken()
    let keychainAccess = KeychainAccess()
    
    var searchDataArr: NSMutableArray?
    
    var curSelectedBtn: UIButton?
    
    var searchViewController: UISearchController!
    
    var searchType: Int! // 1为用户，2为治疗方案，3为临床数据
    
    var count: Int = 10
    
    var page: Int = 0
    
    var showSuggestedUser: Bool = true
    
    var followingList = NSArray()
    
    var heightForCinicInfo = NSMutableDictionary()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.initVaribles()
        self.registerCell()
        self.initContentView()
    }

    
//    override func viewWillAppear(animated: Bool) {
//        super.viewWillAppear(animated)
//        self.searchBar.becomeFirstResponder()
//    }
//    
//    override func viewDidAppear(animated: Bool) {
//        
//        super.viewDidAppear(animated)
//        self.searchBar.becomeFirstResponder()
//        
//    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        initRefresh()
        getSuggestedUser()
    }
    
    func initRefresh() {
        self.tableView.mj_footer = MJRefreshAutoNormalFooter.init(refreshingBlock: { () -> Void in
            if self.showSuggestedUser{
                self.getSuggestedUser()
            }else{
                self.getResult(self.searchViewController.searchBar.text!)
            }
        })
    }
    
    // MARK: - 初始化相关变量
    
    func initVaribles() {
//        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillAppear:", name: UIKeyboardWillShowNotification, object: nil)
//        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillDisappear:", name:UIKeyboardWillHideNotification, object: nil)
        self.searchDataArr = NSMutableArray()
        
        self.searchType = 1
        
    }
    
    // MARK: - 初始化相关View
    
    func initContentView() {
        self.typeView.isHidden = true

        self.searchViewController = UISearchController(searchResultsController: nil)
        self.searchViewController.searchResultsUpdater = self
        self.searchViewController.delegate = self
        self.searchViewController.searchBar.delegate = self
        self.searchViewController.dimsBackgroundDuringPresentation = false
        self.searchViewController.searchBar.sizeToFit()
        self.tableView.tableHeaderView = self.searchViewController.searchBar
    
        //self.searchBar.becomeFirstResponder()
        
        self.userBtn.setImage(UIImage(named: "btn_user_selected"), for: .selected)
        self.userBtn.setImage(UIImage(named: "btn_user"), for: UIControlState())

        self.methodBtn.setImage(UIImage(named: "btn_manage"), for: UIControlState())
        self.methodBtn.setImage(UIImage(named: "btn_manage_selected"), for: .selected)
        
        self.patientBtn.setImage(UIImage(named: "btn_patientData"), for: UIControlState())
        self.patientBtn.setImage(UIImage(named: "btn_patientData_selected"), for: .selected)
        
        self.userBtn.isSelected = true
        
        self.curSelectedBtn = self.userBtn
        
        self.searchViewController.searchBar.placeholder = "搜索用户，治疗方案，或者临床信息"
    }
    
    // MARK: 注册cell
    
    func registerCell() {
    
        self.tableView.register(TreatmentCell.self, forCellReuseIdentifier: cellSearchTreatmentIdentifier)
        
        self.tableView.register(UINib(nibName: cellSearchUserIdentifier, bundle: nil), forCellReuseIdentifier: cellSearchUserIdentifier)
        
        self.tableView.register(ClinicCell.self, forCellReuseIdentifier: cellSearchClinicTrailIdentifier)
    }
    
    // MARK: - 功能方法
    
    // MARK: 搜索用户
    
    @IBAction func searchUserAction(_ sender: UIButton) {
        
        if self.curSelectedBtn == self.userBtn {
        
            return
        }
        else
        {
            self.searchViewController.searchBar.placeholder = "用户"
            self.curSelectedBtn?.isSelected = false
            self.userBtn.isSelected = true
            self.curSelectedBtn = self.userBtn
            self.searchType = 1
        }
    }
    
    // MARK: 搜索治疗方案
    
    @IBAction func searchMethodAction(_ sender: UIButton) {
        
        if self.curSelectedBtn == self.methodBtn {
        
            return
        }
        else {
            self.searchViewController.searchBar.placeholder = "治疗方案"
            self.curSelectedBtn?.isSelected = false
            self.methodBtn.isSelected = true
            self.curSelectedBtn = self.methodBtn
            self.searchType = 2
        }
    }
    
    // MARK: 搜索临床数据
    
    @IBAction func searchPatientAction(_ sender: UIButton) {
        
        if self.curSelectedBtn == self.patientBtn {
        
            return
        }
        else {
        
            self.searchViewController.searchBar.placeholder = "临床数据"
            self.curSelectedBtn?.isSelected = false
            self.patientBtn.isSelected = true
            self.curSelectedBtn = self.patientBtn
            self.searchType = 3
        }
    }
    
    
    // MARK: - 网络请求
    //获得following用户列表
//    func getFollowingUser(){
//        getAccessToken.getAccessToken()
//        let accessToken = NSUserDefaults.standardUserDefaults().objectForKey(accessNSUserData)
//        let urlStr: String = getFollowingUserURL + "?access_token=" + (accessToken as! String)
//        let json = NetRequest.sharedInstance.POST_A(urlStr, parameters: ["username" : keychainAccess.getPasscode(usernameKeyChain)!])
//        if  json.objectForKey("content") != nil {
//            let userList: NSArray = json.objectForKey("content") as! NSArray
//            self.followingList = UserModel.jsonToModelList(userList as Array) as! Array<UserModel>
//        }
//    }
    
    //获得推荐用户列表
    func getSuggestedUser() {
        getAccessToken.getAccessToken()
        let accessToken = UserDefaults.standard.object(forKey: accessNSUserData)
        var urlStr: String = ""
        var parameters = Dictionary<String, Any>()
        if accessToken != nil {
            urlStr = getSuggestUserByProfileURL + "?access_token=" + (accessToken as! String)
            parameters = ["page" : page, "count" : count, "username" : keychainAccess.getPasscode(usernameKeyChain)!]
        }else{
            urlStr = getSuggestUserByTagsURL
            let tags = UserDefaults.standard.object(forKey: favTagsNSUserData) as! NSArray
//            let tagIDs = NSMutableArray()
//            for tag in tags {
//                tagIDs.addObject(((tag as! NSDictionary).objectForKey("tagId")!) as! Int)
//            }
            parameters = ["page" : page, "count" : count, "tags": tags]
        }
//        HudProgressManager.sharedInstance.showHudProgress(self, title: "")
        NetRequest.sharedInstance.POST(urlStr, parameters: parameters as! Dictionary<String, AnyObject>, success: { (content, message) -> Void in
            self.tableView.mj_footer.endRefreshing()
//            self.searchDataArr?.removeAllObjects()
            let dict = content as! Array<Any>
            let userData = UserModel.jsonToModelList(dict as AnyObject?) as! Array<UserModel>
            let appendDataArr = NSMutableArray(array: userData as NSArray)
            self.searchDataArr?.addObjects(from: appendDataArr as [AnyObject])
            self.tableView.reloadData()
//            HudProgressManager.sharedInstance.dismissHud()
//            HudProgressManager.sharedInstance.showSuccessHudProgress(self, title: "搜索成功")
            self.typeView.isHidden = true
            self.page += 1
            }) { (content, message) -> Void in
                self.tableView.mj_footer.endRefreshing()
//                HudProgressManager.sharedInstance.dismissHud()
//                HudProgressManager.sharedInstance.showOnlyTextHudProgress(self, title: message)
        }
    }
    
    // MARK: 搜索用户
    
    func getUserDataFromServer(_ parameters: Dictionary<String, AnyObject>) {
//        HudProgressManager.sharedInstance.showHudProgress(self, title: "")
        NetRequest.sharedInstance.POST(searchUserURL, parameters: parameters, success: { (content, message) -> Void in
//            self.searchDataArr?.removeAllObjects()
            let dict: NSArray = content as! NSArray
            let userData = UserModel.jsonToModelList(dict as NSObject) as! Array<UserModel>
            let searchResult = NSMutableArray(array: userData as NSArray)
            self.searchDataArr?.addObjects(from: searchResult as [AnyObject])
            self.tableView.reloadData()
//            HudProgressManager.sharedInstance.dismissHud()
//            HudProgressManager.sharedInstance.showSuccessHudProgress(self, title: "搜索成功")
            self.typeView.isHidden = true
            self.page += 1
            self.tableView.mj_footer.endRefreshing()

        }) { (content, message) -> Void in
            self.tableView.mj_footer.endRefreshing()

//            HudProgressManager.sharedInstance.dismissHud()
//            HudProgressManager.sharedInstance.showOnlyTextHudProgress(self, title: message)
        }
    }
    
    // MARK: 搜索治疗方案
    
    func getCureFuncDataFromServer(_ parameters: Dictionary<String, AnyObject>) {

//        HudProgressManager.sharedInstance.showHudProgress(self, title: "")

        NetRequest.sharedInstance.POST(searchTreatmentURL, parameters: parameters, success: { (content, message) -> Void in
            self.tableView.mj_footer.endRefreshing()

//            HudProgressManager.sharedInstance.dismissHud()
//            HudProgressManager.sharedInstance.showSuccessHudProgress(self, title: "搜索成功")
//            self.searchDataArr?.removeAllObjects()
            let dict: NSArray = content as! NSArray
            let homeData = TreatmentModel.jsonToModelList(dict as NSObject) as! Array<TreatmentModel>
            self.searchDataArr?.addObjects(from: homeData)
            //            self.changeDataToFrame(homeData)
            self.tableView.reloadData()
            self.typeView.isHidden = true
            self.page += 1
            }) { (content, message) -> Void in
                self.tableView.mj_footer.endRefreshing()

//                HudProgressManager.sharedInstance.dismissHud()
//                HudProgressManager.sharedInstance.showOnlyTextHudProgress(self, title: message)
        }
    }
    
    // MARK: 搜索临床数据
    
    func getPatientDataFromServer(_ parameters: Dictionary<String, AnyObject>) {

//        HudProgressManager.sharedInstance.showHudProgress(self, title: "")

        NetRequest.sharedInstance.POST(searchClinicURL, parameters: parameters, success: { (content, message) -> Void in
//            self.searchDataArr?.removeAllObjects()
            self.tableView.mj_footer.endRefreshing()

            let dict: NSArray = content as! NSArray
            let homeData = ClinicTrailObj.jsonToModelList(dict as NSObject) as! Array<ClinicTrailObj>
            
            self.searchDataArr?.addObjects(from: homeData)
            self.heightForCinicInfo.removeAllObjects()
            var index = 0
            for data in self.searchDataArr! {
                let clinicTrial = data as! ClinicTrailObj
                let clinicStr: String = clinicTrial.subGroup + " " + clinicTrial.stage + "\n" + clinicTrial.effect + "\n" + clinicTrial.sideEffect + "\n" + clinicTrial.researchInfo
                let clinicInfoHeight: CGFloat = clinicStr.sizeWithFont(UIFont.systemFont(ofSize: 13), maxSize: CGSize(width: screenWidth - 30, height: CGFloat.greatestFiniteMagnitude)).height
                self.heightForCinicInfo.setObject(clinicInfoHeight, forKey: index as NSCopying)
                index += 1
            }
            self.tableView.reloadData()
//            HudProgressManager.sharedInstance.dismissHud()
//            HudProgressManager.sharedInstance.showSuccessHudProgress(self, title: "搜索成功")
            self.typeView.isHidden = true
            self.page += 1
            }) { (content, message) -> Void in
                self.tableView.mj_footer.endRefreshing()

//                HudProgressManager.sharedInstance.dismissHud()
//                HudProgressManager.sharedInstance.showOnlyTextHudProgress(self, title: message)
        }

    }

    // MARK: - UISearchResultsUpdating
    func updateSearchResults(for searchController: UISearchController) {
        
        
    }
    
    func willDismissSearchController(_ searchController: UISearchController) {
        
        self.searchViewController.searchBar.resignFirstResponder()
        
        self.typeView.isHidden = true
    }
    
    func willPresentSearchController(_ searchController: UISearchController) {
        
        self.typeView.isHidden = false
    }
    
    // MARK: - searchBar Delegate
    
    
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
//        self.typeView.hidden = false
        //self.navigationController?.popViewControllerAnimated(true)
    }
    
    func searchBar(_ searchBar: UISearchBar, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        return true
    }
    
    func getResult(_ searchStr: String){
        var username: String = ""
        
        if keychainAccess.getPasscode(usernameKeyChain) != nil {
            username = keychainAccess.getPasscode(usernameKeyChain) as! String
        }
        let parameters: Dictionary<String, AnyObject> = [
            "searchString" : searchStr as AnyObject,
            "page" : page as AnyObject,
            "count" : count as AnyObject,
            "username": username as AnyObject
        ]
        
        switch self.searchType {
            
        case 1:
            self.getUserDataFromServer(parameters)
            break
        case 2:
            self.getCureFuncDataFromServer(parameters)
            break
        case 3:
            self.getPatientDataFromServer(parameters)
            break
        default:
            break
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.searchDataArr?.removeAllObjects()
        self.heightForCinicInfo.removeAllObjects()
        page = 0
        self.showSuggestedUser = false
        if self.searchViewController.searchBar.text == nil {
            
            HudProgressManager.sharedInstance.showOnlyTextHudProgress(self, title: "请输入搜索内容")
            return
        }
        
//        if self.searchType == 1 {
//            getFollowingUser()
//        }
        
        getResult(self.searchViewController.searchBar.text!)
    }
    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.searchDataArr!.count
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        var height: CGFloat = 70
        switch self.searchType {
            
        case 1:
            height = 70
            break
        case 2:
//            let feedFrame: PostFeedFrame = self.searchDataArr![indexPath.row] as! PostFeedFrame
//            height = feedFrame.cellHeight
            height = 120
            break
        case 3:
            height = (self.heightForCinicInfo.object(forKey: indexPath.row) as! CGFloat) + 70
            break
            
        default:
            break
        }

        return height
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if self.searchType == 2 {
        
            let cell = tableView.dequeueReusableCell(withIdentifier: cellSearchTreatmentIdentifier, for: indexPath) as! TreatmentCell
            
//            
//            let feedFrame: PostFeedFrame = self.searchDataArr![indexPath.row] as! PostFeedFrame
//            cell.feedOriginFrame = feedFrame.feedOriginalFrame
            cell.treatmentObj = self.searchDataArr![indexPath.row] as! TreatmentModel
            
            return cell

        }
        else if self.searchType == 3 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: cellSearchClinicTrailIdentifier, for: indexPath) as! ClinicCell

            cell.clinicTrial = self.searchDataArr![indexPath.row] as! ClinicTrailObj
//            cell.clinicCellDelegate = self
            return cell
        
        }
        else {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: cellSearchUserIdentifier, for: indexPath) as! UserCell
            let userModel: UserModel = self.searchDataArr![indexPath.row] as! UserModel
//            for followingUser in self.followingList {
//                if followingUser.username == userModel.username {
//                    cell.isFollowing = true
//                }
//            }
            if userModel.isFollowedByCurrentUser == 1 {
                cell.isFollowing = true
            }
            cell.userVCDelegate = self
            cell.userObj = userModel
            return cell
            
        }
        
    }
    
//    func updateCellHeight(height: CGFloat) {
//        self.searchDisplayController?.searchResultsTableView.beginUpdates()
//        self.searchDisplayController?.searchResultsTableView.endUpdates()
//    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        getAccessToken.getAccessToken()
        
        let accessToken = UserDefaults.standard.object(forKey: accessNSUserData)
        
        if accessToken != nil {
            
            self.searchViewController.searchBar.resignFirstResponder()
            
            tableView.deselectRow(at: indexPath, animated: true)
            
            let storyboard = UIStoryboard(name: "User", bundle: nil)
            let userProfileController = storyboard.instantiateViewController(withIdentifier: "UserContent") as! UserProfileViewController
            let info = self.searchDataArr![indexPath.row]
            if info is UserModel {
                userProfileController.profileOwnername = (info as! UserModel).username as NSString?
                self.navigationController?.pushViewController(userProfileController, animated: true)
            }
            if info is TreatmentModel{
                userProfileController.profileOwnername = (info as! TreatmentModel).username as NSString?
                self.navigationController?.pushViewController(userProfileController, animated: true)
            }
        }else{
            let alertController = UIAlertController(title: "需要登录才能查看更多用户信息", message: nil, preferredStyle: .alert)
            
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
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
//    func keyboardWillDisappear(notification:NSNotification){
//        self.typeView.hidden = true
//    }
//    func keyboardWillAppear(notification:NSNotification){
//        self.typeView.hidden = false
//    }
    func unlogin(){
        let alertController = UIAlertController(title: "需要登录才能关注该用户", message: nil, preferredStyle: .alert)
        
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
}
