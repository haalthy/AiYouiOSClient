//
//  ContactTableViewController.swift
//  CancerSN
//
//  Created by hui luo on 14/2/2016.
//  Copyright © 2016 lily. All rights reserved.
//

import UIKit

protocol MentionVCDelegate {
    func updateMentionList(username: String)
}

class ContactTableViewController: UITableViewController, CheckedBtnDelegate {
    
    var haalthyService = HaalthyService()
    
    var contactList = NSArray()
    var userObjList = NSMutableArray()
    var checkedUserList = NSMutableArray()
    
    let heightForRowForUsers: CGFloat = 59
    let numberOfSections: Int = 2
    
    var mentionVCDelegate: MentionVCDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let hudProcessManager = HudProgressManager.sharedInstance
        hudProcessManager.dismissHud()
        hudProcessManager.showHudProgress(self, title: "加载中")
        initVariables()
        initContentView()
        hudProcessManager.dismissHud()
    }
    
    func initVariables(){
        let keychainAccess = KeychainAccess()
        let username = keychainAccess.getPasscode(usernameKeyChain) as! String
        self.tableView.delegate = self
        self.tableView.dataSource = self

        contactList = haalthyService.getFollowingUsers(username)
        for contact in contactList {
            let userObj = UserProfile()
            userObj.initVariables(contact as! NSDictionary)
            self.userObjList.addObject(userObj)
        }
    }
    
    func initContentView(){
        
    }
        
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return numberOfSections
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var numberOfRowsInSection: Int = 0
        switch section {
        case 0:
            numberOfRowsInSection = 1
            break
        case 1:
            numberOfRowsInSection = userObjList.count
            break
        default:
            break
        }
        return numberOfRowsInSection
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        var heightForRow: CGFloat = 0
        switch indexPath.section {
        case 1:
            heightForRow = heightForRowForUsers
            break
        default:
            break
        }
        return heightForRow
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("contactListCell", forIndexPath: indexPath) as! ContactsTableViewCell
        let user = userObjList.objectAtIndex(indexPath.row) as! UserProfile
        // Configure the cell...
        cell.userObj = user
        cell.checkBtnDelegate = self
        return cell
    }
    
    func checked(displayname: String) {
        checkedUserList.addObject(displayname)
    }
    
    func unchecked(displayname: String) {
        checkedUserList.removeObject(displayname)
    }

    @IBAction func submit(sender: AnyObject) {
        var usernameListStr = String()
        for user in checkedUserList {
            usernameListStr.appendContentsOf("@" + (user as! String) + " ")
        }
        mentionVCDelegate?.updateMentionList(usernameListStr)
        self.navigationController?.popViewControllerAnimated(true)
    }
}
