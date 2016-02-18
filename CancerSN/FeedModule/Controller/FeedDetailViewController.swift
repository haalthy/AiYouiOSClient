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


class FeedDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, KeyBoardDelegate {

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
    
    override func viewDidLoad() {
        
        
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.initVariables()
        self.initContentView()
        self.getFeedDetailContentFromServer()
    }

    override func viewDidAppear(animated: Bool) {
        self.initContentView()

    }
    
    // MARK: - init Variables 
    
    func initVariables() {
    
        commentListData = NSMutableArray.init(capacity: 0)
        sinceId = 0
        maxId = 1000
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
        
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "tapDismiss")
        self.view.addGestureRecognizer(tapGesture)
    }
    
    // MARK: - Init Refresh
    
    func initRefresh() {
        
        
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
    
        NetRequest.sharedInstance.POST(getPostDetailURL, parameters:["id":329],
            
            success: { (content , message) -> Void in
                
               
                let postFeedModel = PostFeedStatus.jsonToModel(content) as PostFeedStatus
                self.feedDetailFrame = PostFeedFrame(feedModel: postFeedModel)
                self.tableView.reloadData()
                
                
            }) { (content, message) -> Void in
                
                
                HudProgressManager.sharedInstance.showOnlyTextHudProgress(self, title: message)
        }

    }
    
    // MARK: 获取评论列表
    
    func getFeedCommentListFromServer() {
        
        NetRequest.sharedInstance.POST(getCommentListByPostURL, parameters: ["id" : self.feedId,
            "since_id" : self.sinceId,
            "max_id" : self.maxId,
            "page" : self.page,
            "count" : self.count
            ], success: { (content, message) -> Void in
            
                self.commentListData.removeAllObjects()
                
                let dict: NSArray = content as! NSArray
                let commentArr = CommentModel.jsonToModelList(dict as Array) as! Array<CommentModel>
                self.commentListData = NSMutableArray(array: commentArr as NSArray)
                
                if self.commentListData.count < 5 {
                
                    self.tableView.mj_footer.endRefreshingWithNoMoreData()
                }
                self.tableView.reloadData()
            
            }) { (content, message) -> Void in
                
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
    
        NetRequest.sharedInstance.POST(getCommentListByPostURL, parameters:[
            "body":commentStr,
            "postID":self.feedId,
            "insertUsername":"AY1449549912985.679"
            ],
            
            success: { (content , message) -> Void in
                
            
                HudProgressManager.sharedInstance.showSuccessHudProgress(self, title: "评论成功")
            self.tableView.reloadData()
                
                
            }) { (content, message) -> Void in
                
                self.tableView.mj_header.endRefreshing()
                
                HudProgressManager.sharedInstance.showOnlyTextHudProgress(self, title: message)
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
        
            
        }
        
        return 10
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        
        if indexPath.row == 0 {
        
            let cell: FeedCell = tableView.dequeueReusableCellWithIdentifier(cellFeedDetailIdentifier, forIndexPath: indexPath) as! FeedCell
            
            if self.feedDetailFrame != nil {
                cell.feedOriginFrame = self.feedDetailFrame.feedOriginalFrame
            }
            return cell
        }
        
      
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: nil)
        
        return cell
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

}
