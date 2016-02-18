//
//  FeedTableViewController.swift
//  CancerSN
//
//  Created by lay on 15/12/15.
//  Copyright © 2015年 lily. All rights reserved.
//

import UIKit

let cellFeedIdentifier = "FeedCell"

class FeedTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, FeedTableCellDelegate  {

    // 控件关联
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var headerView: UIView!
    
    let keychainAccess = KeychainAccess()
    let getAccessToken = GetAccessToken()
    let profileSet = NSUserDefaults.standardUserDefaults()
    
    // 自定义变量
    
    var dataArr: NSMutableArray!
    
    let defaultMaxID: Int = 99999999
    var pageIndex: Int = 0
    var countPerPage: Int  = 5
    var maxID: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initVariables()
        initRefresh()
        initContentView()
       // self .getFeedListFromServer()
        }

    // MARK: - Init Variables
    
    func initVariables() {

        dataArr = NSMutableArray()
        getAccessToken.getAccessToken()

    }
    
    func getFeedListURL()->String{
        var feedListURL: String = ""
        let accessToken = profileSet.objectForKey(accessNSUserData)
        if accessToken != nil{
            feedListURL = getFeedsURL + "?access_token=" + (accessToken as! String)
        }else{
            feedListURL = getBroadcastsByTagsURL
        }
        return feedListURL
    }
    
    func getFeedListParameter(since_id: Int, max_id: Int, pageIndex: Int)-> NSDictionary{
        let parameter = NSMutableDictionary()
        let accessToken = profileSet.objectForKey(accessNSUserData)
        if accessToken != nil{
            parameter.setObject(since_id, forKey: "since_id")
            parameter.setObject(max_id, forKey: "max_id")
            parameter.setObject(countPerPage, forKey: "count")
            parameter.setObject(pageIndex, forKey: "page")
            parameter.setObject(keychainAccess.getPasscode(usernameKeyChain)!, forKey: "username")
        }else{
            parameter.setObject(since_id, forKey: "since_id")
            parameter.setObject(max_id, forKey: "max_id")
            parameter.setObject(countPerPage, forKey: "count")
            parameter.setObject(pageIndex, forKey: "page")
        }
        return parameter
    }
    
    // MARK: - Init Related ContentView
    
    func initContentView() {
    
        // headerView样式
        headerView.layer.borderWidth = 0.7
        headerView.layer.borderColor = UIColor.init(red: 236/255.0, green: 239/255.0, blue: 237/255.0, alpha: 1).CGColor
        
        // tableView 注册
        self.tableView.registerClass(FeedCell.self, forCellReuseIdentifier: cellFeedIdentifier)
        
        self.tableView.mj_header.beginRefreshing()
    }
    
    // MARK: - Init Refresh
    
    func initRefresh() {
    
        self.tableView.mj_header = MJRefreshNormalHeader.init(refreshingBlock: { () -> Void in
            
            self.getFeedListFromServer()
            
        })
        
        self.tableView.mj_footer = MJRefreshAutoNormalFooter.init(refreshingBlock: { () -> Void in
            self.getMoreFeedListFromServer()
        })
        
    }
    
    // MARK: - Net Request
    
    func getFeedListFromServer() {
        maxID = defaultMaxID
        self.pageIndex = 0
        NetRequest.sharedInstance.POST(getFeedListURL(), parameters:getFeedListParameter(0, max_id: maxID, pageIndex: self.pageIndex) as! Dictionary<String, AnyObject>,
            
            success: { (content , message) -> Void in
                self.pageIndex = 1
                self.tableView.mj_header.endRefreshing()
                self.dataArr.removeAllObjects()
                let dict: NSArray = content as! NSArray
                let homeData = PostFeedStatus.jsonToModelList(dict as Array) as! Array<PostFeedStatus>
                if homeData.count > 0 {
                    self.maxID = homeData[0].postID
                    for dataItem in homeData {
                        self.maxID = self.maxID > dataItem.postID ? self.maxID: dataItem.postID
                    }
                }
                self.changeDataToFrame(homeData)
                self.tableView.reloadData()

                
            }) { (content, message) -> Void in
                
                self.tableView.mj_header.endRefreshing()
                
                HudProgressManager.sharedInstance.showOnlyTextHudProgress(self, title: message)
        }
        
    }
    
    func getMoreFeedListFromServer() {
        NetRequest.sharedInstance.POST(getFeedListURL(), parameters:getFeedListParameter(0, max_id: maxID, pageIndex: self.pageIndex) as! Dictionary<String, AnyObject>,
            
            success: { (content , message) -> Void in
                self.pageIndex++
                
                self.tableView.mj_footer.endRefreshing()
                
                let dict: NSArray = content as! NSArray
                let homeData = PostFeedStatus.jsonToModelList(dict as Array) as! Array<PostFeedStatus>
                
                self.changeDataToFrame(homeData)
                self.tableView.reloadData()
                
            }) { (content, message) -> Void in
                
                self.tableView.mj_footer.endRefreshing()
                
        }
    }

    
    // MARK: - Function
    
    // 处理数据
    
    func changeDataToFrame(dataArr: Array<PostFeedStatus>)  {
    
        for feedData in dataArr {
        
            let feedFrame: PostFeedFrame = PostFeedFrame(feedModel: feedData)
            self.dataArr.addObject(feedFrame)
        }
    }
    
    // 进入到查看临床数据
    
    @IBAction func pushClinicalDataAction(sender: AnyObject) {
        
        performSegueWithIdentifier("EnterClinicTVC", sender: self)
    }
    
    // 进入到选择标签页

    @IBAction func pushTagAction(sender: AnyObject) {
        
        performSegueWithIdentifier("EnterTagView", sender: self)
    }
    
    // MARK: - Table view data source

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArr.count
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        let feedFrame: PostFeedFrame = dataArr[indexPath.row] as! PostFeedFrame
        
        return feedFrame.cellHeight
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier(cellFeedIdentifier, forIndexPath: indexPath) as! FeedCell
        cell.feedTableCellDelegate = self
        
        let feedFrame: PostFeedFrame = dataArr[indexPath.row] as! PostFeedFrame

        cell.feedOriginFrame = feedFrame.feedOriginalFrame
        
        
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        self.performSegueWithIdentifier("EnterDetailView", sender: self)
    }
    
    func checkUserProfile(username: String) {

        let storyboard = UIStoryboard(name: "User", bundle: nil)
        let userProfileController = storyboard.instantiateViewControllerWithIdentifier("UserContent") as! UserProfileViewController
        userProfileController.profileOwnername = username
        self.navigationController?.pushViewController(userProfileController, animated: true)
    }
    
    func checkPostComment(postID: Int) {
        print(postID)
    }
}
