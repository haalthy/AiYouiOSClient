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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    // MARK: - 初始化数据
    
    func initVariables() {
        
        self.mentionedData = NSMutableArray(capacity: 0)
    }
    
    // MARK: - 初始化相关view
    
    func initContentView() {
        
        self.tableView.tableFooterView = UIView(frame: CGRECT(0, 0, 0, 0))
    }
    
    // MARK: - 注册cell
    
    func registerCell() {
        
        self.tableView.registerNib(UINib(nibName: cellMentionedIdentifier, bundle: nil), forCellReuseIdentifier: cellMentionedIdentifier)
    }
    
    // MARK: - 初始化刷新
    
    func addRefresh() {
        
        self.tableView.mj_header = MJRefreshNormalHeader.init(refreshingBlock: { () -> Void in
            
            
        })
        
        self.tableView.mj_footer = MJRefreshAutoNormalFooter.init(refreshingBlock: { () -> Void in
        })
        
    }
    
    
    // MARK: - 网络请求
    
    func getFollowDataFromServer() {
        
        let keychainAccess = KeychainAccess()
        HudProgressManager.sharedInstance.showHudProgress(self, title: "")
        NetRequest.sharedInstance.POST(userFollowURL, isToken: true, parameters: ["username":keychainAccess.getPasscode(usernameKeyChain)!], success: { (content, message) -> Void in
            
            HudProgressManager.sharedInstance.dismissHud()
            HudProgressManager.sharedInstance.showSuccessHudProgress(self, title: "获取成功")
            let mentioned: NSArray = content["followerUsers"] as! NSArray
            
                let mentionedArr = FollowModel.jsonToModelList(mentioned as Array) as! Array<FollowModel>
                self.mentionedData =  NSMutableArray(array: mentionedArr as NSArray)
        
            
            self.tableView.reloadData()
            
            
            }) { (content, message) -> Void in
                
                HudProgressManager.sharedInstance.dismissHud()
                HudProgressManager.sharedInstance.showOnlyTextHudProgress(self, title: "")
        }
        
        
    }
    
    // MARK: - Table view data source
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.mentionedData.count
    
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        return 70
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier(cellFollowIdentifier)! as! UserCell
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        self.performSegueWithIdentifier("EnterDetailView", sender: self)
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
