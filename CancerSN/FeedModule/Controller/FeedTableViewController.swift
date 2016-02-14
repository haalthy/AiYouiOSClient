//
//  FeedTableViewController.swift
//  CancerSN
//
//  Created by lay on 15/12/15.
//  Copyright © 2015年 lily. All rights reserved.
//

import UIKit

let cellFeedIdentifier = "FeedCell"

class FeedTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate  {

    // 控件关联
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var headerView: UIView!
    
    // 自定义变量
    
    var dataArr: NSMutableArray!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initVariables()
        initRefresh()
        initContentView()
       // self .getFeedListFromServer()
        var keychainAccess = KeychainAccess()
//        keychainAccess.setPasscode(usernameKeyChain, passcode: "AY1449535482715.927")
//        keychainAccess.setPasscode(passwordKeyChain, passcode: "password")

        
        }

    // MARK: - Init Variables
    
    func initVariables() {
    
        dataArr = NSMutableArray()
        
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
        
        
        NetRequest.sharedInstance.POST("http://54.223.70.160:8080/haalthyservice/security/post/posts?access_token=55d9bdd5-f4af-4012-baaa-ace83b05d77e", parameters:["since_id":0,
            "max_id":1000,
            "count": 5,
            "page": 0,"username":"AY1449549912985.679"],
            
            success: { (content , message) -> Void in
            
                
                self.tableView.mj_header.endRefreshing()
            
                self.dataArr.removeAllObjects()
                let dict: NSArray = content as! NSArray
                let homeData = PostFeedStatus.jsonToModelList(dict as Array) as! Array<PostFeedStatus>
                
                self.changeDataToFrame(homeData)
                self.tableView.reloadData()
                
                
            }) { (content, message) -> Void in
                
                self.tableView.mj_header.endRefreshing()
                
                HudProgressManager.sharedInstance.showOnlyTextHudProgress(self, title: message)
        }
        
        
    }
    
    func getMoreFeedListFromServer() {
        
        HudProgressManager.sharedInstance.showHudProgress(self, title: "")
        NetRequest.sharedInstance.POST("http://127.0.0.1:8080/haalthyservice/security/post/posts?access_token=a7bfb178-7863-4870-8270-1cc88c01b215", parameters:["since_id":0,
            "max_id":1000,
            "count": 5,
            "page": 0,"username":"AY1449549912985.679"],
            
            success: { (content , message) -> Void in
                
                self.tableView.mj_header.endRefreshing()
                
                
            }) { (content, message) -> Void in
                
                self.tableView.mj_header.endRefreshing()
                
                HudProgressManager.sharedInstance.dismissHud()
                HudProgressManager.sharedInstance.showOnlyTextHudProgress(self, title: message)
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

        let feedTagsVC = self.storyboard?.instantiateViewControllerWithIdentifier("FeedTagsView")
        let navigation: UINavigationController = UINavigationController.init(rootViewController: feedTagsVC!)
        self.presentViewController(navigation, animated: true, completion: nil)
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
        
        
        let feedFrame: PostFeedFrame = dataArr[indexPath.row] as! PostFeedFrame

        cell.feedOriginFrame = feedFrame.feedOriginalFrame
        
        
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        self.performSegueWithIdentifier("EnterDetailView", sender: self)
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
