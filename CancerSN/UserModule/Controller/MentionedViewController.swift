//
//  MentionedViewController.swift
//  CancerSN
//
//  Created by lay on 16/3/1.
//  Copyright © 2016年 lily. All rights reserved.
//

import UIKit

let cellMentionedIdentifier = "MentionedCell"

class MentionedViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    var mentionedData: NSMutableArray!
    
    let defaultMaxID: Int = 99999999
    var pageIndex: Int = 0
    var countPerPage: Int  = 5
    var maxID: Int = 0
    
    var keychainAccess = KeychainAccess()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.initVariables()
        self.registerCell()
        self.addRefresh()
        self.initContentView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // 重置未读个数为0
        self.resetUnreadMentionedCountFromServer()
    }

    // MARK: - 初始化数据
    
    func initVariables() {
        
        self.mentionedData = NSMutableArray(capacity: 0)
    }
    
    // MARK: - 初始化相关view
    
    func initContentView() {
        
        self.tableView.tableFooterView = UIView(frame: CGRECT(0, 0, 0, 0))
        
        self.tableView.mj_header.beginRefreshing()
    }
    
    // MARK: - 注册cell
    
    func registerCell() {
        
        self.tableView.register(UINib(nibName: cellMentionedIdentifier, bundle: nil), forCellReuseIdentifier: cellMentionedIdentifier)
    }
    
    // MARK: - 初始化刷新
    
    func addRefresh() {
        
        self.tableView.mj_header = MJRefreshNormalHeader.init(refreshingBlock: { () -> Void in
            
            self.getMentionedDataFromServer()
        })
        
        self.tableView.mj_footer = MJRefreshAutoNormalFooter.init(refreshingBlock: { () -> Void in
            
            self.getMoreMentionedDataFromServer()
        })
        
    }
    
    // MARK: - 功能方法
    func getParamters(_ since_id: Int, max_id: Int, pageIndex: Int) -> Dictionary<String, AnyObject> {
    
        let keychainAccess = KeychainAccess()
        
        let parameters: Dictionary<String, AnyObject> = [
            "since_id" : since_id as AnyObject,
            "max_id" : max_id as AnyObject,
            "count" : self.countPerPage as AnyObject,
            "page" : pageIndex as AnyObject,
            "username" : keychainAccess.getPasscode(usernameKeyChain)!]
        return parameters
    }
    
    // MARK: - 网络请求
    
    func getMentionedDataFromServer() {
        
        self.pageIndex = 0
        NetRequest.sharedInstance.POST(userMentionedURL, isToken: true, parameters: self.getParamters(0, max_id: self.maxID, pageIndex: self.pageIndex), success: { (content, message) -> Void in
            
            
            self.tableView.mj_header.endRefreshing()
            self.mentionedData.removeAllObjects()
            
            
            let mentioned: NSArray = content as! NSArray
            
            let mentionedArr = PostFeedStatus.jsonToModelList(mentioned) as! Array<PostFeedStatus>
            if mentionedArr.count > 0 {
                self.maxID = mentionedArr[0].postID
                for dataItem in mentionedArr {
                    self.maxID = self.maxID > dataItem.postID ? self.maxID: dataItem.postID
                }
            }
            self.mentionedData =  NSMutableArray(array: mentionedArr as NSArray)

            self.tableView.reloadData()
            
            
            }) { (content, message) -> Void in
                
                self.tableView.mj_header.endRefreshing()
                HudProgressManager.sharedInstance.showOnlyTextHudProgress(self, title: message)
        }
    }
    
    // MARK: 获取更多提及我的数据
    
    func getMoreMentionedDataFromServer() {
    
        self.pageIndex += 1

        NetRequest.sharedInstance.POST(userMentionedURL, isToken: true, parameters: self.getParamters(0, max_id: self.maxID, pageIndex: self.pageIndex), success: { (content, message) -> Void in
            
            
            let mentioned: NSArray = content as! NSArray
            
            let mentionedArr = PostFeedStatus.jsonToModelList(mentioned) as! Array<PostFeedStatus>
            
            if mentionedArr.count == 0   {
            
                self.tableView.mj_footer.endRefreshingWithNoMoreData()
            }
            else {
            
                self.tableView.mj_footer.endRefreshing()
                self.mentionedData.addObjects(from: mentionedArr)
                
                self.tableView.reloadData()

            }
            
            
            }) { (content, message) -> Void in
                
                self.tableView.mj_footer.endRefreshing()

                HudProgressManager.sharedInstance.showOnlyTextHudProgress(self, title: message)
        }

    }
    
    // MARK: 重置未读@我的数量为0
    
    func resetUnreadMentionedCountFromServer() {
        
        NetRequest.sharedInstance.POST(refreshNewMentionedCountURL , isToken: true, parameters: [ "username" : keychainAccess.getPasscode(usernameKeyChain)!], success: { (content, message) -> Void in
            
            }) { (content, message) -> Void in
                
        }
    }

    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.mentionedData.count
    
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 70
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellMentionedIdentifier)! as! MentionedCell
        
        let feedModel: PostFeedStatus = self.mentionedData[indexPath.row] as! PostFeedStatus
        cell.setContentViewAction(feedModel)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
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
