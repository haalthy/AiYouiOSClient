//
//  SearchViewController.swift
//  CancerSN
//
//  Created by lay on 16/1/23.
//  Copyright © 2016年 lily. All rights reserved.
//

import UIKit

let cellSearchUserIdentifier: String = "UserCell"
let cellSearchTreatmentIdentifier = "FeedCell"


class SearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchControllerDelegate, UISearchResultsUpdating, UISearchBarDelegate {

    
    
    @IBOutlet weak var typeView: UIView!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var userBtn: UIButton!
    
    @IBOutlet weak var methodBtn: UIButton!
    
    @IBOutlet weak var patientBtn: UIButton!
    
    var searchDataArr: NSMutableArray?
    
    var curSelectedBtn: UIButton?
    
    var searchViewController: UISearchController!
    
    var searchType: Int! // 1为用户，2为治疗方案，3为临床数据
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.initVaribles()
        self.registerCell()
        self.initContentView()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    // MARK: - 初始化相关变量
    
    func initVaribles() {
    
        self.searchDataArr = NSMutableArray()
        self.searchType = 1
    }
    
    // MARK: - 初始化相关View
    
    func initContentView() {
        
        
        self.searchViewController = UISearchController(searchResultsController: nil)
        self.searchViewController.searchResultsUpdater = self
        self.searchViewController.delegate = self
        self.searchViewController.searchBar.delegate = self
        self.searchViewController.dimsBackgroundDuringPresentation = false
        self.searchViewController.searchBar.sizeToFit()
        self.tableView.tableHeaderView = self.searchViewController.searchBar
    
        self.userBtn.setImage(UIImage(named: "btn_user_selected"), forState: .Selected)
        self.userBtn.setImage(UIImage(named: "btn_user"), forState: .Normal)

        self.methodBtn.setImage(UIImage(named: "btn_manage"), forState: .Normal)
        self.methodBtn.setImage(UIImage(named: "btn_manage_selected"), forState: .Selected)
        
        self.patientBtn.setImage(UIImage(named: "btn_patientData"), forState: .Normal)
        self.patientBtn.setImage(UIImage(named: "btn_patientData_selected"), forState: .Selected)
        
        self.userBtn.selected = true
        
        self.curSelectedBtn = self.userBtn
        
        self.searchViewController.searchBar.placeholder = "用户"
    }
    
    // MARK: 注册cell
    
    func registerCell() {
    
        self.tableView.registerClass(FeedCell.self, forCellReuseIdentifier: cellSearchTreatmentIdentifier)
        
        self.tableView.registerNib(UINib(nibName: cellSearchUserIdentifier, bundle: nil), forCellReuseIdentifier: cellSearchUserIdentifier)
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
    
    // MARK: 搜索用户
    
    func getUserDataFromServer(parameters: Dictionary<String, AnyObject>) {
        
        
        HudProgressManager.sharedInstance.showHudProgress(self, title: "")
        NetRequest.sharedInstance.POST(searchUserURL, parameters: parameters, success: { (content, message) -> Void in
        
            self.searchDataArr?.removeAllObjects()
            let dict: NSArray = content as! NSArray
            let userData = UserModel.jsonToModelList(dict as Array) as! Array<UserModel>
            self.searchDataArr = NSMutableArray(array: userData as NSArray)
            self.tableView.reloadData()
            HudProgressManager.sharedInstance.dismissHud()
            HudProgressManager.sharedInstance.showSuccessHudProgress(self, title: "搜索成功")
            

        }) { (content, message) -> Void in
            
            
            HudProgressManager.sharedInstance.dismissHud()
            HudProgressManager.sharedInstance.showOnlyTextHudProgress(self, title: message)
        }
    }
    
    // MARK: 搜索治疗方案
    
    func getCureFuncDataFromServer(parameters: Dictionary<String, AnyObject>) {
    
        HudProgressManager.sharedInstance.showHudProgress(self, title: "")

        NetRequest.sharedInstance.POST(searchTreatmentURL, parameters: parameters, success: { (content, message) -> Void in
            
            HudProgressManager.sharedInstance.dismissHud()
            HudProgressManager.sharedInstance.showSuccessHudProgress(self, title: "搜索成功")
            self.searchDataArr?.removeAllObjects()
            let dict: NSArray = content as! NSArray
            let homeData = PostFeedStatus.jsonToModelList(dict as Array) as! Array<PostFeedStatus>
            
            self.changeDataToFrame(homeData)

            }) { (content, message) -> Void in
              
                
                HudProgressManager.sharedInstance.dismissHud()
                HudProgressManager.sharedInstance.showOnlyTextHudProgress(self, title: message)
        }

    }
    
    // MARK: 搜索临床数据
    
    func getPatientDataFromServer(parameters: Dictionary<String, AnyObject>) {
    
        HudProgressManager.sharedInstance.showHudProgress(self, title: "")

        NetRequest.sharedInstance.POST(searchClinicURL, parameters: parameters, success: { (content, message) -> Void in
            
            HudProgressManager.sharedInstance.dismissHud()
            HudProgressManager.sharedInstance.showSuccessHudProgress(self, title: "搜索成功")
            }) { (content, message) -> Void in
                
                HudProgressManager.sharedInstance.dismissHud()
                HudProgressManager.sharedInstance.showOnlyTextHudProgress(self, title: message)
        }

    }
    
    // MARK: - Function
    
    // 处理数据
    
    func changeDataToFrame(dataArr: Array<PostFeedStatus>)  {
        
        for feedData in dataArr {
            
            let feedFrame: PostFeedFrame = PostFeedFrame(feedModel: feedData)
            self.searchDataArr!.addObject(feedFrame)
        }
    }

    // MARK: - UISearchResultsUpdating
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        
        
    }
    
    func willDismissSearchController(searchController: UISearchController) {
        
        self.searchViewController.searchBar.resignFirstResponder()
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func willPresentSearchController(searchController: UISearchController) {
        
        self.typeView.hidden = true
    }
    
    // MARK: - searchBar Delegate
    
    
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func searchBar(searchBar: UISearchBar, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        
        return true
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        
        if self.searchViewController.searchBar.text == nil {
            
            HudProgressManager.sharedInstance.showOnlyTextHudProgress(self, title: "请输入搜索内容")
            return
        }
        
        let parameters: Dictionary<String, AnyObject> = [
            
            "searchString" : self.searchViewController.searchBar.text!,
            "page" : 1,
            "count" : 10
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
    
    // MARK: - Table view data source
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.searchDataArr!.count
        
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        var height: CGFloat = 40
        switch self.searchType {
            
        case 1:
            
            height = 70
            break
        case 2:
            
            let feedFrame: PostFeedFrame = self.searchDataArr![indexPath.row] as! PostFeedFrame
            height = feedFrame.cellHeight
            break
            
        case 3:
            
            height = 80
            break
            
        default:
            break
        }

        return height
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if self.searchType == 1 {
            
            let cell = tableView.dequeueReusableCellWithIdentifier(cellSearchUserIdentifier, forIndexPath: indexPath) as! UserCell
            
            
                let userModel: UserModel = self.searchDataArr![indexPath.row] as! UserModel
                cell.portraitImage.addImageCache(userModel.imageURL!, placeHolder: placeHolderStr)
            
            
            
            return cell

        }
        else if self.searchType == 2 {
        
            let cell = tableView.dequeueReusableCellWithIdentifier(cellFeedIdentifier, forIndexPath: indexPath) as! FeedCell
            
            
            let feedFrame: PostFeedFrame = self.searchDataArr![indexPath.row] as! PostFeedFrame
            cell.feedOriginFrame = feedFrame.feedOriginalFrame
            
            return cell

        }
        else {
            
            let cell = tableView.dequeueReusableCellWithIdentifier(cellFeedIdentifier, forIndexPath: indexPath) as! FeedCell
            
            
            let feedFrame: PostFeedFrame = self.searchDataArr![indexPath.row] as! PostFeedFrame
            cell.feedOriginFrame = feedFrame.feedOriginalFrame
            
            return cell

        
        }
        
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        //self.performSegueWithIdentifier("EnterDetailView", sender: self)
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
