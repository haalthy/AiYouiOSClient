//
//  UserListTableViewController.swift
//  CancerSN
//
//  Created by lily on 7/21/15.
//  Copyright (c) 2015 lily. All rights reserved.
//

import UIKit
import CoreData

class UserListTableViewController: UITableViewController, UserListDelegate {
    @IBOutlet weak var loginBtn: UIBarButtonItem!

    var tagList: NSArray = []
    var userList : NSArray = []
    var getSuggestUserData :NSMutableData? = nil
    var username : NSString = ""
    var password: NSString = ""
    var haalthyService = HaalthyService()
    var keychainAccess = KeychainAccess()

    override func viewDidLoad() {
        super.viewDidLoad()
        let userData = NSUserDefaults.standardUserDefaults()
        if((userData.objectForKey(favTagsNSUserData)) != nil){
            tagList = userData.objectForKey(favTagsNSUserData) as! NSArray
        }
        if tagList.count == 0{
            var getUserFavTags = haalthyService.getUserFavTags()
            var jsonResult = NSJSONSerialization.JSONObjectWithData(getUserFavTags!, options: NSJSONReadingOptions.MutableContainers, error: nil)
            if(jsonResult is NSArray){
                tagList = jsonResult as! NSArray
                userData.setObject(tagList, forKey: favTagsNSUserData)
            }
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        var username = keychainAccess.getPasscode(usernameKeyChain)
        var password = keychainAccess.getPasscode(passwordKeyChain)
        if((tagList.count == 0) && (username == nil)){
            self.performSegueWithIdentifier("modalsegue", sender: nil)
        }

        var getSuggestUsers = NSData()
        if((username != nil) && (password != nil)){
            self.username = keychainAccess.getPasscode(usernameKeyChain)!
            self.password = keychainAccess.getPasscode(passwordKeyChain)!
            getSuggestUsers = haalthyService.getSuggestUserByProfile(0, rangeEnd: 20)
            self.navigationItem.rightBarButtonItem = nil
        }else{
            getSuggestUsers = haalthyService.getSuggestUserByTags(tagList, rangeBegin: 0, rangeEnd: 10)
            self.navigationItem.rightBarButtonItem = loginBtn
        }
        
        var jsonResult = NSJSONSerialization.JSONObjectWithData(getSuggestUsers, options: NSJSONReadingOptions.MutableContainers, error: nil)
        let str: NSString = NSString(data: getSuggestUsers, encoding: NSUTF8StringEncoding)!
        println(str)
        if(jsonResult is NSArray){
            userList = jsonResult as! NSArray
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 3
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var numberOfRowsInSection:Int = 0
        switch(section){
        case 0,1:
            numberOfRowsInSection = 1
            break
        case 2:
            numberOfRowsInSection = userList.count
            break
        default:
            numberOfRowsInSection = 0
            break
        }
        return numberOfRowsInSection
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if(indexPath.section == 2){
            var user: NSDictionary = userList[indexPath.row] as! NSDictionary
            let cell = tableView.dequeueReusableCellWithIdentifier("userListCell", forIndexPath: indexPath) as! UserListTableViewCell
            cell.user = userList[indexPath.row] as! NSDictionary
            cell.delegate = self
            return cell
        }else if(indexPath.section == 0){
            let cell = tableView.dequeueReusableCellWithIdentifier("userListHeaderCell", forIndexPath: indexPath) as! UserListHeaderTableViewCell

            return cell
        }else{
            let cell = tableView.dequeueReusableCellWithIdentifier("userSearchCell", forIndexPath: indexPath) as! UserSearchTableViewCell
            return cell
        }
    }
    
    override func tableView(_tableView: UITableView,
        heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat{
            var rowHeight: CGFloat
            switch indexPath.section{
            case 0,1: rowHeight = 44
                break
            case 2: rowHeight = 80
                break
            default:rowHeight = 0
                break
            }
            return rowHeight
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "modalsegue" {
            (segue.destinationViewController as! TagViewController).delegate = self
        }
    }
    func performLoginSegue() {
        self.performSegueWithIdentifier("loginSegue", sender: nil)
    }
}

extension UserListTableViewController: TagVCDelegate {
    func updateTagList(data: NSArray) {
        self.tagList = data

    }
}
