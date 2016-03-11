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


class SearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchControllerDelegate, UISearchResultsUpdating, UISearchBarDelegate {
    
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
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(animated: Bool) {
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
        self.typeView.hidden = true

        self.searchViewController = UISearchController(searchResultsController: nil)
        self.searchViewController.searchResultsUpdater = self
        self.searchViewController.delegate = self
        self.searchViewController.searchBar.delegate = self
        self.searchViewController.dimsBackgroundDuringPresentation = false
        self.searchViewController.searchBar.sizeToFit()
        self.tableView.tableHeaderView = self.searchViewController.searchBar
    
        //self.searchBar.becomeFirstResponder()
        
        self.userBtn.setImage(UIImage(named: "btn_user_selected"), forState: .Selected)
        self.userBtn.setImage(UIImage(named: "btn_user"), forState: .Normal)

        self.methodBtn.setImage(UIImage(named: "btn_manage"), forState: .Normal)
        self.methodBtn.setImage(UIImage(named: "btn_manage_selected"), forState: .Selected)
        
        self.patientBtn.setImage(UIImage(named: "btn_patientData"), forState: .Normal)
        self.patientBtn.setImage(UIImage(named: "btn_patientData_selected"), forState: .Selected)
        
        self.userBtn.selected = true
        
        self.curSelectedBtn = self.userBtn
        
        self.searchViewController.searchBar.placeholder = "搜索用户，治疗方案，或者临床信息"
    }
    
    // MARK: 注册cell
    
    func registerCell() {
    
        self.tableView.registerClass(TreatmentCell.self, forCellReuseIdentifier: cellSearchTreatmentIdentifier)
        
        self.tableView.registerNib(UINib(nibName: cellSearchUserIdentifier, bundle: nil), forCellReuseIdentifier: cellSearchUserIdentifier)
        
        self.tableView.registerClass(ClinicCell.self, forCellReuseIdentifier: cellSearchClinicTrailIdentifier)
    }
    
    // MARK: - 功能方法
    
    // MARK: 搜索用户
    
    @IBAction func searchUserAction(sender: UIButton) {
        
        if self.curSelectedBtn == self.userBtn {
        
            return
        }
        else
        {
            self.searchViewController.searchBar.placeholder = "用户"
            self.curSelectedBtn?.selected = false
            self.userBtn.selected = true
            self.curSelectedBtn = self.userBtn
            self.searchType = 1
        }
    }
    
    // MARK: 搜索治疗方案
    
    @IBAction func searchMethodAction(sender: UIButton) {
        
        if self.curSelectedBtn == self.methodBtn {
        
            return
        }
        else {
            self.searchViewController.searchBar.placeholder = "治疗方案"
            self.curSelectedBtn?.selected = false
            self.methodBtn.selected = true
            self.curSelectedBtn = self.methodBtn
            self.searchType = 2
        }
    }
    
    // MARK: 搜索临床数据
    
    @IBAction func searchPatientAction(sender: UIButton) {
        
        if self.curSelectedBtn == self.patientBtn {
        
            return
        }
        else {
        
            self.searchViewController.searchBar.placeholder = "临床数据"
            self.curSelectedBtn?.selected = false
            self.patientBtn.selected = true
            self.curSelectedBtn = self.patientBtn
            self.searchType = 3
        }
    }
    
    
    // MARK: - 网络请求
    //获得following用户列表
    func getFollowingUser(){
        getAccessToken.getAccessToken()
        let accessToken = NSUserDefaults.standardUserDefaults().objectForKey(accessNSUserData)
        let urlStr: String = getFollowingUserURL + "?access_token=" + (accessToken as! String)
        let json = NetRequest.sharedInstance.POST_A(urlStr, parameters: ["username" : keychainAccess.getPasscode(usernameKeyChain)!])
        if  json.objectForKey("content") != nil {
            let userList: NSArray = json.objectForKey("content") as! NSArray
            self.followingList = UserModel.jsonToModelList(userList as Array) as! Array<UserModel>
        }
    }
    
    //获得推荐用户列表
    func getSuggestedUser() {
        getAccessToken.getAccessToken()
        let accessToken = NSUserDefaults.standardUserDefaults().objectForKey(accessNSUserData)
        var urlStr: String = ""
        var parameters = [:]
        if accessToken != nil {
            urlStr = getSuggestUserByProfileURL + "?access_token=" + (accessToken as! String)
            parameters = ["page" : page, "count" : count, "username" : keychainAccess.getPasscode(usernameKeyChain)!]
        }else{
            urlStr = getSuggestUserByTagsURL
            parameters = ["page" : page, "count" : count]
        }
//        HudProgressManager.sharedInstance.showHudProgress(self, title: "")
        NetRequest.sharedInstance.POST(urlStr, parameters: parameters as! Dictionary<String, AnyObject>, success: { (content, message) -> Void in
            self.tableView.mj_footer.endRefreshing()
//            self.searchDataArr?.removeAllObjects()
            let dict: NSArray = content as! NSArray
            let userData = UserModel.jsonToModelList(dict as Array) as! Array<UserModel>
            let appendDataArr = NSMutableArray(array: userData as NSArray)
            self.searchDataArr?.addObjectsFromArray(appendDataArr as [AnyObject])
            self.tableView.reloadData()
//            HudProgressManager.sharedInstance.dismissHud()
//            HudProgressManager.sharedInstance.showSuccessHudProgress(self, title: "搜索成功")
            self.typeView.hidden = true
            self.page++
            }) { (content, message) -> Void in
                self.tableView.mj_footer.endRefreshing()
//                HudProgressManager.sharedInstance.dismissHud()
//                HudProgressManager.sharedInstance.showOnlyTextHudProgress(self, title: message)
        }
    }
    
    // MARK: 搜索用户
    
    func getUserDataFromServer(parameters: Dictionary<String, AnyObject>) {
//        HudProgressManager.sharedInstance.showHudProgress(self, title: "")
        NetRequest.sharedInstance.POST(searchUserURL, parameters: parameters, success: { (content, message) -> Void in
//            self.searchDataArr?.removeAllObjects()
            let dict: NSArray = content as! NSArray
            let userData = UserModel.jsonToModelList(dict as Array) as! Array<UserModel>
            let searchResult = NSMutableArray(array: userData as NSArray)
            self.searchDataArr?.addObjectsFromArray(searchResult as [AnyObject])
            self.tableView.reloadData()
//            HudProgressManager.sharedInstance.dismissHud()
//            HudProgressManager.sharedInstance.showSuccessHudProgress(self, title: "搜索成功")
            self.typeView.hidden = true
            self.page++
            self.tableView.mj_footer.endRefreshing()

        }) { (content, message) -> Void in
            self.tableView.mj_footer.endRefreshing()

//            HudProgressManager.sharedInstance.dismissHud()
//            HudProgressManager.sharedInstance.showOnlyTextHudProgress(self, title: message)
        }
    }
    
    // MARK: 搜索治疗方案
    
    func getCureFuncDataFromServer(parameters: Dictionary<String, AnyObject>) {

//        HudProgressManager.sharedInstance.showHudProgress(self, title: "")

        NetRequest.sharedInstance.POST(searchTreatmentURL, parameters: parameters, success: { (content, message) -> Void in
            self.tableView.mj_footer.endRefreshing()

//            HudProgressManager.sharedInstance.dismissHud()
//            HudProgressManager.sharedInstance.showSuccessHudProgress(self, title: "搜索成功")
//            self.searchDataArr?.removeAllObjects()
            let dict: NSArray = content as! NSArray
            let homeData = TreatmentModel.jsonToModelList(dict as Array) as! Array<TreatmentModel>
            self.searchDataArr?.addObjectsFromArray(homeData)
            //            self.changeDataToFrame(homeData)
            self.tableView.reloadData()
            self.typeView.hidden = true
            self.page++
            }) { (content, message) -> Void in
                self.tableView.mj_footer.endRefreshing()

//                HudProgressManager.sharedInstance.dismissHud()
//                HudProgressManager.sharedInstance.showOnlyTextHudProgress(self, title: message)
        }
    }
    
    // MARK: 搜索临床数据
    
    func getPatientDataFromServer(parameters: Dictionary<String, AnyObject>) {

//        HudProgressManager.sharedInstance.showHudProgress(self, title: "")

        NetRequest.sharedInstance.POST(searchClinicURL, parameters: parameters, success: { (content, message) -> Void in
//            self.searchDataArr?.removeAllObjects()
            self.tableView.mj_footer.endRefreshing()

            let dict: NSArray = content as! NSArray
            let homeData = ClinicTrailObj.jsonToModelList(dict as Array) as! Array<ClinicTrailObj>
            
            self.searchDataArr?.addObjectsFromArray(homeData)
            self.tableView.reloadData()
//            HudProgressManager.sharedInstance.dismissHud()
//            HudProgressManager.sharedInstance.showSuccessHudProgress(self, title: "搜索成功")
            self.typeView.hidden = true
            self.page++
            }) { (content, message) -> Void in
                self.tableView.mj_footer.endRefreshing()

//                HudProgressManager.sharedInstance.dismissHud()
//                HudProgressManager.sharedInstance.showOnlyTextHudProgress(self, title: message)
        }

    }

    // MARK: - UISearchResultsUpdating
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        
        
    }
    
    func willDismissSearchController(searchController: UISearchController) {
        
        self.searchViewController.searchBar.resignFirstResponder()
        
        self.typeView.hidden = true
    }
    
    func willPresentSearchController(searchController: UISearchController) {
        
        self.typeView.hidden = false
    }
    
    // MARK: - searchBar Delegate
    
    
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
//        self.typeView.hidden = false
        //self.navigationController?.popViewControllerAnimated(true)
    }
    
    func searchBar(searchBar: UISearchBar, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        
        return true
    }
    
    func getResult(searchStr: String){
        let parameters: Dictionary<String, AnyObject> = [
            "searchString" : searchStr,
            "page" : page,
            "count" : count
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
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        self.searchDataArr?.removeAllObjects()
        page = 0
        self.showSuggestedUser = false
        if self.searchViewController.searchBar.text == nil {
            
            HudProgressManager.sharedInstance.showOnlyTextHudProgress(self, title: "请输入搜索内容")
            return
        }
        
        if self.searchType == 1 {
            getFollowingUser()
        }
        
        getResult(self.searchViewController.searchBar.text!)
    }
    
    // MARK: - Table view data source
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.searchDataArr!.count
        
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
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
            height = 140
            break
            
        default:
            break
        }

        return height
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        if self.searchType == 2 {
        
            let cell = tableView.dequeueReusableCellWithIdentifier(cellSearchTreatmentIdentifier, forIndexPath: indexPath) as! TreatmentCell
            
//            
//            let feedFrame: PostFeedFrame = self.searchDataArr![indexPath.row] as! PostFeedFrame
//            cell.feedOriginFrame = feedFrame.feedOriginalFrame
            cell.treatmentObj = self.searchDataArr![indexPath.row] as! TreatmentModel
            
            return cell

        }
        else if self.searchType == 3 {
            
            let cell = tableView.dequeueReusableCellWithIdentifier(cellSearchClinicTrailIdentifier, forIndexPath: indexPath) as! ClinicCell

            cell.clinicTrial = self.searchDataArr![indexPath.row] as! ClinicTrailObj
//            cell.clinicCellDelegate = self
            return cell
        
        }
        else {
            
            let cell = tableView.dequeueReusableCellWithIdentifier(cellSearchUserIdentifier, forIndexPath: indexPath) as! UserCell
            let userModel: UserModel = self.searchDataArr![indexPath.row] as! UserModel
            for followingUser in self.followingList {
                if followingUser.username == userModel.username {
                    cell.isFollowing = true
                }
            }
            cell.userObj = userModel
            return cell
            
        }
        
    }
    
//    func updateCellHeight(height: CGFloat) {
//        self.searchDisplayController?.searchResultsTableView.beginUpdates()
//        self.searchDisplayController?.searchResultsTableView.endUpdates()
//    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        self.searchViewController.searchBar.resignFirstResponder()
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let storyboard = UIStoryboard(name: "User", bundle: nil)
        let userProfileController = storyboard.instantiateViewControllerWithIdentifier("UserContent") as! UserProfileViewController
        let info = self.searchDataArr![indexPath.row]
        if info is UserModel {
            userProfileController.profileOwnername = (info as! UserModel).username
                self.navigationController?.pushViewController(userProfileController, animated: true)
        }
        if info is TreatmentModel{
            userProfileController.profileOwnername = (info as! TreatmentModel).username
            self.navigationController?.pushViewController(userProfileController, animated: true)
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
}
