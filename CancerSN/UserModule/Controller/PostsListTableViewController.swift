//
//  PostsListTableViewController.swift
//  CancerSN
//
//  Created by lay on 16/3/15.
//  Copyright © 2016年 lily. All rights reserved.
//

import UIKit

class PostsListTableViewController: UITableViewController {

    
    let cellPostIdentifier = "PostCell"
    
    var username: String = ""
    // 控件关联
    
    let keychainAccess = KeychainAccess()
    let getAccessToken = GetAccessToken()
    let profileSet = NSUserDefaults.standardUserDefaults()
    
    // 自定义变量
    
    var postList: NSMutableArray!
    
    let defaultMaxID: Int = 99999999
    var pageIndex: Int = 0
    var countPerPage: Int  = 5
    var maxID: Int = 0
    
    var postTableView: UITableView?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        getAccessToken.getAccessToken()
        if profileSet.objectForKey(accessNSUserData) == nil{
            let storyboard = UIStoryboard(name: "Registeration", bundle: nil)
            let rootController = storyboard.instantiateViewControllerWithIdentifier("LoginEntry") as! UINavigationController
            self.presentViewController(rootController, animated: true, completion: nil)
        }else{
            initVariables()
            initRefresh()
            initContentView()
        }
    }
    
    
    // MARK: - Init Variables
    
    func initVariables() {
        
        postList = NSMutableArray()
        postTableView = self.tableView
        
        self.tableView.registerClass(PostTableViewCell.self, forCellReuseIdentifier: cellPostIdentifier)
        
    }
    
    func getFeedListURL()->String{
        var feedListURL: String = ""
        let accessToken = profileSet.objectForKey(accessNSUserData)
        if accessToken != nil{
            feedListURL = getPostsByUsername + "?access_token=" + (accessToken as! String)
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
            parameter.setObject(username, forKey: "username")
        }
        return parameter
    }
    
    // MARK: - Init Related ContentView
    
    func initContentView() {
        
        // headerView样式
        //        headerView.layer.borderWidth = 0.7
        //        headerView.layer.borderColor = UIColor.init(red: 236/255.0, green: 239/255.0, blue: 237/255.0, alpha: 1).CGColor
        
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
                self.postList.removeAllObjects()
                let dict: NSArray = content as! NSArray
                let homeData = PostFeedStatus.jsonToModelList(dict as Array) as! Array<PostFeedStatus>
                if homeData.count > 0 {
                    self.maxID = homeData[0].postID
                    for dataItem in homeData {
                        self.maxID = self.maxID > dataItem.postID ? self.maxID: dataItem.postID
                    }
                }
                self.postList.addObjectsFromArray(homeData)
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
                self.postList.addObjectsFromArray(homeData)
                self.tableView.reloadData()
                
            }) { (content, message) -> Void in
                
                self.tableView.mj_footer.endRefreshing()
        }
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.postList.count
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellPostIdentifier, forIndexPath: indexPath) as! PostTableViewCell
        
        cell.post = postList[indexPath.row] as! PostFeedStatus
        return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let postCellFrame: PostCellFrame = PostCellFrame()
        postCellFrame.post = postList[indexPath.row] as! PostFeedStatus
        return postCellFrame.cellHeight + 30
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let feedStatus: PostFeedStatus = postList[indexPath.row] as! PostFeedStatus
        
        let storyBoard: UIStoryboard = UIStoryboard(name: "Feed", bundle: nil)
        let feedDetailVC: FeedDetailViewController = storyBoard.instantiateViewControllerWithIdentifier("FeedDetailView") as! FeedDetailViewController
        feedDetailVC.feedId = feedStatus.postID
        self.navigationController?.pushViewController(feedDetailVC, animated: true)
        
    }

    
    /*
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
