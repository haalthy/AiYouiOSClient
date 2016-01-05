//
//  FeedTableViewController.swift
//  CancerSN
//
//  Created by lay on 15/12/15.
//  Copyright © 2015年 lily. All rights reserved.
//

import UIKit

let cellIdentifier = "FeedCell"

class FeedTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate  {

    // 控件关联
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var headerView: UIView!
    
    // 自定义变量
    
    var dataArr: NSMutableArray!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initVariables()
        initContentView()
        
        self .getFeedListFromServer()
        }

    // MARK: - Init Variables
    
    func initVariables() {
    
        dataArr = NSMutableArray()
        
        // 假数据
        let feedModel: PostFeedStatus = PostFeedStatus()
        feedModel.nickname = "王磊"
        feedModel.gender = "男"
        feedModel.age = "25"
        feedModel.feedId = 22
        feedModel.createdDate = "2015-22-22"
        feedModel.feedPortrait = ""
        feedModel.feedContent = "阿萨德浪费空间阿萨德了罚款就爱上了对方看见爱上了对方科技阿斯顿分老卡机是地方莱卡的说法徕卡的房间阿里SD卡放假"
        feedModel.picArr = ["http://pic.qiantucdn.com/58pic/16/13/59/31Q58PICAS2_1024.jpg", "http://pic.qiantucdn.com/58pic/16/13/59/31Q58PICAS2_1024.jpg"]
        let feedFrame: PostFeedFrame = PostFeedFrame(feedModel: feedModel)
        
        dataArr.addObject(feedFrame)

    }
    
    // MARK: - Init Related ContentView
    
    func initContentView() {
    
        //self.tableView.tableHeaderView?.frame = CGRectMake(0, 0, UIScreen.mainScreen().bounds.size.width, 45)
        
        // headerView样式
        headerView.layer.borderWidth = 0.7
        headerView.layer.borderColor = UIColor.init(red: 236/255.0, green: 239/255.0, blue: 237/255.0, alpha: 1).CGColor
        
        self.tableView.registerClass(FeedCell.self, forCellReuseIdentifier: cellIdentifier)
    }
    
    // MARK: - Net Request
    
    func getFeedListFromServer() {
        
        
        
        NetRequest.sharedInstance.POST("http://54.223.70.160:8080/haalthyservice/security/post/posts?access_token=74367639-ab0b-4c5a-a036-69d2f619ec9e", parameters:["begin":0,"end":1456803188202,"username":"AY1449549912985.679"],
            
            success: { (content , message) -> Void in
            
            print(content)
            
            }) { (content, message) -> Void in
                
        }
        
        
    }
    
    // MARK: - Function
    
    // 进入到查看临床数据
    
    @IBAction func pushClinicalDataAction(sender: AnyObject) {
        
        performSegueWithIdentifier("EnterClinicTVC", sender: self)
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
        
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier)! as! FeedCell
        
        
        let feedFrame: PostFeedFrame = dataArr[indexPath.row] as! PostFeedFrame

        cell.feedOriginFrame = feedFrame.feedOriginalFrame
        
        return cell
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
