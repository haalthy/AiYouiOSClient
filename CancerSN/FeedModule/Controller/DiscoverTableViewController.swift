//
//  DiscoverTableViewController.swift
//  CancerSN
//
//  Created by lily on 9/1/15.
//  Copyright (c) 2015 lily. All rights reserved.
//

import UIKit

class DiscoverTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UserListDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    var username: NSString?
    var password: NSString?
    var haalthyService = HaalthyService()
    var keychainAccess = KeychainAccess()
    var tagList: NSArray = []
    var userList : NSArray = []
    var showUserlist:Bool = true
    var loginBtn = UIBarButtonItem()
    var selectedProfileOwner = String()
    
    @IBAction func indexChanged(sender: UISegmentedControl) {
        if showUserlist {
            showUserlist = false
        }else{
            showUserlist = true
        }
        self.tableView.reloadData()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        username = keychainAccess.getPasscode(usernameKeyChain)
        password = keychainAccess.getPasscode(passwordKeyChain)
        loginBtn = UIBarButtonItem(title: "注册/登陆", style: .Plain, target: self, action: "login")
        self.navigationItem.rightBarButtonItem = loginBtn
    }
    
    override func viewWillAppear(animated: Bool) {
        
        let userData = NSUserDefaults.standardUserDefaults()
        if((userData.objectForKey(favTagsNSUserData)) != nil){
            tagList = userData.objectForKey(favTagsNSUserData) as! NSArray
        }
        var getSuggestUsers:NSData?
        if((username != nil) && (password != nil)){
            getSuggestUsers = haalthyService.getSuggestUserByProfile(0, rangeEnd: 20)
            self.navigationItem.rightBarButtonItem = nil
        }else{
            var tagIdList = [Int]()
            for tagItem in tagList {
                let tag = tagItem as! NSDictionary
                tagIdList.append(tag.objectForKey("tagId") as! Int)
            }
            getSuggestUsers = haalthyService.getSuggestUserByTags(tagIdList, rangeBegin: 0, rangeEnd: 10)
            self.navigationItem.rightBarButtonItem = loginBtn
        }
        if getSuggestUsers != nil{
            let jsonResult: AnyObject? = try? NSJSONSerialization.JSONObjectWithData(getSuggestUsers!, options: NSJSONReadingOptions.MutableContainers)
            if(jsonResult is NSArray){
                userList = jsonResult as! NSArray
            }
            self.tableView.reloadData()
        }else{
            let publicService = PublicService()
            publicService.presentAlertController("网络不给力", sender: self)
        }
    }
    
    func login(){
    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        if showUserlist {
            return userList.count
        }else{
            return 0
        }
    }

    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if showUserlist{
            let cell = tableView.dequeueReusableCellWithIdentifier("userListCell", forIndexPath: indexPath) as! UserListTableViewCell
            cell.username = userList.objectAtIndex(indexPath.row) as! String
            cell.addFollowingBtn.layer.cornerRadius = 5
            cell.addFollowingBtn.layer.borderWidth = 2.0
            cell.addFollowingBtn.layer.borderColor = mainColor.CGColor
            cell.addFollowingBtn.layer.masksToBounds = true
            cell.addFollowingBtn.backgroundColor = UIColor.whiteColor()
            cell.addFollowingBtn.titleLabel?.textColor = mainColor
            cell.hiddenFollowButton = false
            cell.user = userList[indexPath.row] as! NSDictionary
            cell.delegate = self
            return cell
        }else{
            let cell = tableView.dequeueReusableCellWithIdentifier("contentListCell", forIndexPath: indexPath) 
            return cell
        }
    }
    func tableView(_tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat{
        var rowHeight: CGFloat
        if showUserlist{
            rowHeight = 80
        }else{
            rowHeight = 100
        }
        return rowHeight
    }

    func performLoginSegue() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewControllerWithIdentifier("LoginEntry") as UIViewController
        
        self.presentViewController(controller, animated: true, completion: nil)
    }
    func imageTap(username:String){
        if self.username == nil{
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let controller = storyboard.instantiateViewControllerWithIdentifier("LoginEntry") as UIViewController
            
            self.presentViewController(controller, animated: true, completion: nil)
        }else{
            selectedProfileOwner = username
            let storyboard = UIStoryboard(name: "User", bundle: nil)
            let controller = storyboard.instantiateViewControllerWithIdentifier("UserContent") as! UserProfileViewController
            controller.profileOwnername = selectedProfileOwner
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    
}