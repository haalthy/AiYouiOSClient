//
//  UserFollowViewController.swift
//  CancerSN
//
//  Created by lay on 16/2/28.
//  Copyright © 2016年 lily. All rights reserved.
//

import UIKit

let cellFollowIdentifier = "UserCell"

class UserFollowViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    
    @IBOutlet weak var tableView: UITableView!
    
    var followData: NSMutableArray!
    var followrData: NSMutableArray!
    var friendData: NSMutableArray!
    
    var keychainAccess = KeychainAccess()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.initVariables()
        
        self.registerCell()
        self.initContentView()
        
        self.getFollowDataFromServer()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        // 重置未读个数为0
        self.resetUnreadFollowCountFromServer()
    }

    // MARK: - 初始化数据
    
    func initVariables() {
        
        self.followData = NSMutableArray(capacity: 0)
        self.followrData = NSMutableArray(capacity: 0)
        self.friendData = NSMutableArray(capacity: 0)
    }
    
    // MARK: - 初始化相关view
    
    func initContentView() {
        
        self.tableView.tableFooterView = UIView(frame: CGRECT(0, 0, 0, 0))
    }
    
    // MARK: - 注册cell
    
    func registerCell() {
        
        self.tableView.registerNib(UINib(nibName: cellFollowIdentifier, bundle: nil), forCellReuseIdentifier: cellFollowIdentifier)
    }
    
    // MARK: - 初始化刷新
    
    func addRefresh() {
        
        self.tableView.mj_header = MJRefreshNormalHeader.init(refreshingBlock: { () -> Void in
            
            
        })
        
        //self.tableView.mj_footer = MJRefreshAutoNormalFooter.init(refreshingBlock: { () -> Void in
        //})
        
    }
    
    
    // MARK: - 网络请求
    
    func getFollowDataFromServer() {
        
        let keychainAccess = KeychainAccess()
        HudProgressManager.sharedInstance.showHudProgress(self, title: "")
        NetRequest.sharedInstance.POST(userFollowURL, isToken: true, parameters: ["username":keychainAccess.getPasscode(usernameKeyChain)!], success: { (content, message) -> Void in
            
            HudProgressManager.sharedInstance.dismissHud()
            HudProgressManager.sharedInstance.showSuccessHudProgress(self, title: "获取成功")
            self.followData.removeAllObjects()
            self.followrData.removeAllObjects()
            self.friendData.removeAllObjects()
            
            let friends: NSArray = content["friends"] as! NSArray
            if friends.count != 0 {
                
                let friendsArr = FollowModel.jsonToModelList(friends as Array) as! Array<FollowModel>
                self.friendData =  NSMutableArray(array: friendsArr as NSArray)
            }
            
            let follow: NSArray = content["followingUsers"] as! NSArray
            if follow.count != 0 {
                
                let followArr = FollowModel.jsonToModelList(follow as Array) as! Array<FollowModel>
                self.followData =  NSMutableArray(array: followArr as NSArray)
            }
            
            let follower: NSArray = content["followerUsers"] as! NSArray
            if follower.count != 0 {
                
                let followerArr = FollowModel.jsonToModelList(follower as Array) as! Array<FollowModel>
                self.followrData =  NSMutableArray(array: followerArr as NSArray)
            }
            
            self.tableView.reloadData()
            
            
            }) { (content, message) -> Void in
                
                HudProgressManager.sharedInstance.dismissHud()
                HudProgressManager.sharedInstance.showOnlyTextHudProgress(self, title: "")
        }
        
        
    }
    
    // MARK: 重置未读关注的数量为0
    
    func resetUnreadFollowCountFromServer() {
        
        NetRequest.sharedInstance.POST(refreshNewFollowCountURL , isToken: true, parameters: [ "username" : keychainAccess.getPasscode(usernameKeyChain)!], success: { (content, message) -> Void in
            
            
            }) { (content, message) -> Void in
                
        }
    }
    
    // MARK: - Table view data source
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.followData.count + self.followrData.count + self.friendData.count
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        return 70
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier(cellFollowIdentifier)! as! UserCell
        var followModel: FollowModel?
        if indexPath.row < self.friendData.count {
            
            followModel = self.friendData[indexPath.row] as? FollowModel
            cell.addBtn.setImage(UIImage(named: "icon_follow"), forState: .Normal)
            
        }
            
        else if indexPath.row < self.followData.count + self.friendData.count {
            
            followModel = self.followData[indexPath.row - self.friendData.count] as? FollowModel
            cell.addBtn.setImage(UIImage(named: "icon_followM"), forState: .Normal)
        }
            
        else if indexPath.row < self.followrData.count + self.friendData.count + self.followData.count {
            
            followModel = self.followrData[indexPath.row - self.friendData.count - self.followData.count] as? FollowModel
            cell.addBtn.setImage(UIImage(named: "icon_followY"), forState: .Normal)
        }
        
        let imageURL = followModel!.imageURL! + "@80h_80w_1e"
        cell.portraitImage.addImageCache(imageURL, placeHolder: placeHolderStr)
        
        cell.nameLabel.text = followModel!.displayname
        //self.getGenderAction(followModel.gender!) + "，" + String(followModel.age) + "岁，" + followModel.cancerType! + "，" + followModel.pathological! + "，" + followModel.stage + "期"
        var userInfo: String = ""
        if followModel!.gender != "<null>" {
            userInfo += (followModel!.gender) + " "
        }
        if followModel!.age != 0 {
            userInfo += String(followModel!.age) + " "
        }
        if followModel!.cancerType != "<null>" {
            userInfo += followModel!.cancerType  + " "
        }
        if followModel!.pathological != "<null>" {
            userInfo += followModel!.pathological + " "
        }
        if followModel!.stage != "<null>" {
            userInfo += followModel!.stage + "期 "
        }
        if followModel!.geneticMutation != "<null>" {
            userInfo += followModel!.geneticMutation
        }
        cell.infoLabel.text = userInfo
        //        cell.addBtn.setImage(UIImage(named: "icon_follow"), forState: .Normal)
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        var user: FollowModel?
        if indexPath.row < self.friendData.count {
            user = self.friendData.objectAtIndex(indexPath.row) as? FollowModel
        }
        if (indexPath.row < self.friendData.count + self.followData.count) && (indexPath.row >= self.friendData.count){
            user = self.followData.objectAtIndex(indexPath.row - self.friendData.count) as? FollowModel
        }
        if indexPath.row > (self.friendData.count + self.followData.count) {
            user = self.followrData.objectAtIndex(indexPath.row - self.friendData.count - self.followData.count) as? FollowModel
        }
        let storyboard = UIStoryboard(name: "User", bundle: nil)
        let userProfileController = storyboard.instantiateViewControllerWithIdentifier("UserContent") as! UserProfileViewController
        userProfileController.profileOwnername = user?.username
        self.navigationController?.pushViewController(userProfileController, animated: true)
        
    }
    
    // MARK: - 功能方法
    
    // MARK: 获取性别
    
    func getGenderAction(type: String) -> String {
        
        var gender: String = "男"
        
        
        if type == "F" {
            
            gender = "女"
        }
        else {
            
            gender = "男"
        }
        
        return gender
    }
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        
        
    }
    
    
}
