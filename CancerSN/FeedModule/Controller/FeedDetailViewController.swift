//
//  FeedDetailViewController.swift
//  CancerSN
//
//  Created by lay on 16/1/7.
//  Copyright © 2016年 lily. All rights reserved.
//

import UIKit

let kFeedDetailKeyBoardHeight: CGFloat = 50
let cellFeedDetailIdentifier = "FeedCell"
let cellFeedDetailCommentIdentifier = "FeedCommentIdentifer"


class FeedDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, KeyBoardDelegate, FeedTableCellDelegate {

    // 控件关联
    
    @IBOutlet weak var tableView: UITableView!
    
    // 自定义变量
    
    var feedId: Int!
    var feedDetailFrame: PostFeedFrame!
    var commentListData: NSMutableArray!
    var keyBoardView: KeyBoardView!
    
    var sinceId: Int!
    var count: Int!
    var page: Int!
    var maxId: Int!
    
    var defaultMaxID: Int = 999999
    
    override func viewDidLoad() {
        
        
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.initVariables()
        self.initContentView()
        self.getFeedDetailContentFromServer()
//        self.getFeedCommentListFromServer()
        initRefresh()
        self.tableView.mj_header.beginRefreshing()
    }

    override func viewDidAppear(animated: Bool) {
        self.initContentView()

    }
    
    // MARK: - init Variables 
    
    func initVariables() {
    
        commentListData = NSMutableArray.init(capacity: 0)
        sinceId = 0
        maxId = defaultMaxID
        page = 0
        count = 5
    }
    
    // MARK: - init ContentView
    
    func initContentView() {
    
        // 评论
        self.keyBoardView = KeyBoardView(frame: CGRECT(0, SCREEN_HEIGHT - kFeedDetailKeyBoardHeight, SCREEN_WIDTH, kFeedDetailKeyBoardHeight))
        self.keyBoardView.delegate = self
        self.keyBoardView.setPlaceHolderTextColor(RGB(204, 204, 204))
        self.keyBoardView.setPlaceHolderText("在此输入您要发送的评论")

        self.view.addSubview(keyBoardView)
        self.view.bringSubviewToFront(keyBoardView)
        
        // tableView 注册
        self.tableView.registerClass(FeedCell.self, forCellReuseIdentifier: cellFeedDetailIdentifier)
//        self.tableView.registerClass(FeedCommentCell.self, forCellReuseIdentifier: cellFeedDetailCommentIdentifier)
        
        self.view.userInteractionEnabled = true
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "tapDismiss")
        self.view.addGestureRecognizer(tapGesture)
    }
    
    // MARK: - Init Refresh
    
    func initRefresh() {
        self.tableView.mj_header = MJRefreshNormalHeader.init(refreshingBlock: { () -> Void in
            self.getFeedCommentListFromServer()
            
        })
        
        self.tableView.mj_footer = MJRefreshAutoNormalFooter.init(refreshingBlock: { () -> Void in
            self.getMoreFeedCommentListFromServer()
        })

    }

    
    // MARK: - 功能方法
    
    func tapDismiss() {
    
        self.keyBoardView.tapDismiss()
    }
    
    // MARK: - 网络请求
    
    func getFeedDetailContentFromServer() {
    
        NetRequest.sharedInstance.POST(getPostDetailURL, parameters:["id":self.feedId],
            
            success: { (content , message) -> Void in
                
               
                let postFeedModel = PostFeedStatus.jsonToModel(content) as PostFeedStatus
                self.feedDetailFrame = PostFeedFrame(feedModel: postFeedModel, isShowFullText: true)
                self.tableView.reloadData()
                
                
            }) { (content, message) -> Void in
                
                
                HudProgressManager.sharedInstance.showOnlyTextHudProgress(self, title: message)
        }

    }
    
    // MARK: 获取评论列表
    
    func getFeedCommentListFromServer() {
        self.maxId = self.defaultMaxID
        self.page = 0
        NetRequest.sharedInstance.POST(getCommentListByPostURL, parameters: ["id" : self.feedId,
            "since_id" : self.sinceId,
            "max_id" : self.maxId,
            "page" : self.page,
            "count" : self.count
            ], success: { (content, message) -> Void in
                self.page = 1
                self.tableView.mj_header.endRefreshing()
                self.commentListData.removeAllObjects()
                
                let dict: NSArray = content as! NSArray
                let commentArr = CommentModel.jsonToModelList(dict as Array) as! Array<CommentModel>
                self.commentListData = NSMutableArray(array: commentArr as NSArray)
                //重新设置 maxID
                if self.commentListData.count > 0 {
                    self.maxId = commentArr[0].commentID
                    for comment in commentArr {
                        self.maxId = self.maxId > comment.commentID ? self.maxId: comment.commentID
                    }
                }
                self.tableView.mj_footer.endEditing(false)
                if self.commentListData.count < 5 {
                
                    self.tableView.mj_footer.endRefreshingWithNoMoreData()
                }
                self.tableView.reloadData()
            
            }) { (content, message) -> Void in
                self.tableView.mj_header.endRefreshing()
                HudProgressManager.sharedInstance.showOnlyTextHudProgress(self, title: message)
        }
    }
    
    // MARK: 获取更多评论列表
    
    func getMoreFeedCommentListFromServer() {
    
        NetRequest.sharedInstance.POST(getCommentListByPostURL, parameters: ["id" : self.feedId,
            "since_id" : self.sinceId,
            "max_id" : self.maxId,
            "page" : self.page,
            "count" : self.count
            ], success: { (content, message) -> Void in
                self.page = self.page + 1
                let dict: NSArray = content as! NSArray
                let commentArr = CommentModel.jsonToModelList(dict as Array) as! Array<CommentModel>
                let comment: NSMutableArray = NSMutableArray(array: commentArr as NSArray)
                if comment.count < 5 {
                
                    self.tableView.mj_footer.endRefreshingWithNoMoreData()
                }
                
                self.commentListData.addObjectsFromArray(comment as [AnyObject])
                self.tableView.reloadData()
                
            }) { (content, message) -> Void in
                
                self.tableView.mj_footer.endRefreshing()
                HudProgressManager.sharedInstance.showOnlyTextHudProgress(self, title: message)
        }

    }
    
    func commentToFeedDetail(commentStr: String) {
        let keychainAccess = KeychainAccess()
        let getAccessToken = GetAccessToken()
        let insertUsername: String = keychainAccess.getPasscode(usernameKeyChain) as! String
        getAccessToken.getAccessToken()
        if NSUserDefaults.standardUserDefaults().objectForKey(accessNSUserData) != nil {
            let accessToken = NSUserDefaults.standardUserDefaults().objectForKey(accessNSUserData) as! String
            
            NetRequest.sharedInstance.POST(addCommentsURL + "?access_token=" + accessToken, parameters:[
                "body":commentStr,
                "postID":self.feedId,
                "insertUsername":insertUsername
                ],
                
                success: { (content , message) -> Void in
                    
                    
                    HudProgressManager.sharedInstance.showSuccessHudProgress(self, title: "评论成功")
                    self.tapDismiss()
                    self.getFeedCommentListFromServer()
                }) { (content, message) -> Void in
                    
                    self.tapDismiss()
                    HudProgressManager.sharedInstance.showOnlyTextHudProgress(self, title: message)
            }
        }else{
            let alertController = UIAlertController(title: "请登录后再评论", message: nil, preferredStyle: .Alert)
            let ContinueAction = UIAlertAction(title: "返回", style: .Default){ (action)in
            }
            let LoginAction = UIAlertAction(title: "登录", style: .Default){ (action)in
                let storyboard = UIStoryboard(name: "Registeration", bundle: nil)
                let rootController = storyboard.instantiateViewControllerWithIdentifier("LoginEntry") as! UINavigationController
                self.presentViewController(rootController, animated: true, completion: nil)
            }
            alertController.addAction(ContinueAction)
            alertController.addAction(LoginAction)
            //
            self.presentViewController(alertController, animated: true) {
                // ...
            }
        }
    }
    
    // MARK: - Table view data source
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return commentListData.count + 1
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        if indexPath.row == 0 {
        
            if self.feedDetailFrame != nil {
                return self.feedDetailFrame.cellHeight + 1
            }
            else {
            
                return 0
            }
        }
        else {
        
            let commentModel: CommentModel = self.commentListData[indexPath.row - 1] as! CommentModel
            let cellHeight = commentModel.body.sizeWithFont(UIFont.systemFontOfSize(16), maxSize: CGSize(width: SCREEN_WIDTH - 85, height: CGFloat.max)).height
            return cellHeight + 80
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        
        if indexPath.row == 0 {
        
            let cell: FeedCell = tableView.dequeueReusableCellWithIdentifier(cellFeedDetailIdentifier, forIndexPath: indexPath) as! FeedCell
            cell.isShowFullText = true
            cell.feedTableCellDelegate = self
            if self.feedDetailFrame != nil {
                cell.feedOriginFrame?.isShowFullText = true
                cell.feedOriginFrame = self.feedDetailFrame.feedOriginalFrame
            }
            return cell
        }
        else {
        
            let cell: FeedCommentCell = tableView.dequeueReusableCellWithIdentifier(cellFeedDetailCommentIdentifier, forIndexPath: indexPath) as! FeedCommentCell
            
            let commentModel: CommentModel = self.commentListData[indexPath.row - 1] as! CommentModel
            
            cell.showFeedInfo(commentModel)
            return cell

        }
      
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
    }

    // MARK: - 发送评论代理
    
    func sendCommentAction(commentStr: String) {

        // 判断用户是否登录
        
        self.commentToFeedDetail(commentStr)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
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
