//
//  CommentViewController.swift
//  CancerSN
//
//  Created by lay on 16/3/15.
//  Copyright © 2016年 lily. All rights reserved.
//

import UIKit

let cellCommentIdentifier = "MentionedCell"

class CommentViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    
    
    let keychainAccess = KeychainAccess()
    let getAccessToken = GetAccessToken()
    let profileSet = UserDefaults.standard
    
    // 自定义变量
    
    var commentData: NSMutableArray!
    
    let defaultMaxID: Int = 99999999
    var pageIndex: Int = 0
    var countPerPage: Int  = 5
    var maxID: Int = 0

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        getAccessToken.getAccessToken()
        if profileSet.object(forKey: accessNSUserData) == nil{
            let storyboard = UIStoryboard(name: "Registeration", bundle: nil)
            let rootController = storyboard.instantiateViewController(withIdentifier: "LoginEntry") as! UINavigationController
            self.present(rootController, animated: true, completion: nil)
        }else{
            initVariables()
            initRefresh()
            initContentView()
            self.resetUnreadMentionedCountFromServer()
        }
    }
    
    
    // MARK: - 初始化变量
    
    func initVariables() {
    
        self.commentData = NSMutableArray(capacity: 0)
    }
    
    // MARK: - 初始化视图
    
    func initContentView() {
    
        self.tableView.register(UINib(nibName: cellCommentIdentifier, bundle: nil), forCellReuseIdentifier: cellCommentIdentifier)
        self.tableView.mj_header.beginRefreshing()
    }

    func getFeedListParameter(_ since_id: Int, max_id: Int, pageIndex: Int)-> NSDictionary{
        let parameter = NSMutableDictionary()
        let accessToken = profileSet.object(forKey: accessNSUserData)
        if accessToken != nil{
            parameter.setObject(since_id, forKey: "since_id" as NSCopying)
            parameter.setObject(max_id, forKey: "max_id" as NSCopying)
            parameter.setObject(countPerPage, forKey: "count" as NSCopying)
            parameter.setObject(pageIndex, forKey: "page" as NSCopying)
            parameter.setObject(keychainAccess.getPasscode(usernameKeyChain)!, forKey: "username" as NSCopying)

        }
        return parameter
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
        NetRequest.sharedInstance.POST(getCommentsByUsernameURL, isToken: true, parameters:getFeedListParameter(0, max_id: maxID, pageIndex: self.pageIndex) as! Dictionary<String, AnyObject>,
            
            success: { (content , message) -> Void in
                self.pageIndex = 1
                self.tableView.mj_header.endRefreshing()
                self.commentData.removeAllObjects()
                let dict: NSArray = content as! NSArray
                let homeData = UserCommentModel.jsonToModelList(dict) as! Array<UserCommentModel>
                if homeData.count > 0 {
                    self.maxID = homeData[0].postID
                    for dataItem in homeData {
                        self.maxID = self.maxID > dataItem.postID ? self.maxID: dataItem.postID
                    }
                }
                self.commentData.addObjects(from: homeData)
                self.tableView.reloadData()
                
                
            }) { (content, message) -> Void in
                
                self.tableView.mj_header.endRefreshing()
                
                HudProgressManager.sharedInstance.showOnlyTextHudProgress(self, title: message)
        }
        
    }
    
    func getMoreFeedListFromServer() {
        
        NetRequest.sharedInstance.POST(getCommentsByUsernameURL, isToken: true,  parameters:getFeedListParameter(0, max_id: maxID, pageIndex: self.pageIndex) as! Dictionary<String, AnyObject>,
            
            success: { (content , message) -> Void in
                self.pageIndex += 1
                
                self.tableView.mj_footer.endRefreshing()
                
                
                let dict: NSArray = content as! NSArray
                let homeData = PostFeedStatus.jsonToModelList(dict) as! Array<PostFeedStatus>
                self.commentData.addObjects(from: homeData)
                self.tableView.reloadData()
                
            }) { (content, message) -> Void in
                
                self.tableView.mj_footer.endRefreshing()
        }
    }

    // MARK: - 功能方法
    
    // MARK: 重置未读评论的数量为0
    
    func resetUnreadMentionedCountFromServer() {
        
        NetRequest.sharedInstance.POST(refreshNewCommentURL , isToken: true, parameters: [ "username" : keychainAccess.getPasscode(usernameKeyChain)!], success: { (content, message) -> Void in
            
            let notification: Notification = Notification(name: Notification.Name(rawValue: "refreshCommentNoti"), object: nil)
            NotificationCenter.default.post(notification)
            
            }) { (content, message) -> Void in
                
        }
    }

    
    
    // MARK: - Table view data source
    
    func numberOfSectionsInTableView(_ tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.commentData.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellCommentIdentifier, for: indexPath) as! MentionedCell
        
        cell.setContentViewForUserComment(commentData[indexPath.row] as! UserCommentModel)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAtIndexPath indexPath: IndexPath) -> CGFloat {

        return 70
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAtIndexPath indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        let feedStatus: UserCommentModel = commentData[indexPath.row] as! UserCommentModel
        
        let storyBoard: UIStoryboard = UIStoryboard(name: "Feed", bundle: nil)
        let feedDetailVC: FeedDetailViewController = storyBoard.instantiateViewController(withIdentifier: "FeedDetailView") as! FeedDetailViewController
        feedDetailVC.feedId = feedStatus.postID
        self.navigationController?.pushViewController(feedDetailVC, animated: true)
        
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
