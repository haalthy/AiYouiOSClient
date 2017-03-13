//
//  ContactTableViewController.swift
//  CancerSN
//
//  Created by hui luo on 14/2/2016.
//  Copyright © 2016 lily. All rights reserved.
//

import UIKit

protocol MentionVCDelegate {
    func updateMentionList(_ username: String)
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
            self.userObjList.add(userObj)
        }
    }
    
    func initContentView(){
        
    }
        
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return numberOfSections
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
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
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
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

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "contactListCell", for: indexPath) as! ContactsTableViewCell
        let user = userObjList.object(at: indexPath.row) as! UserProfile
        // Configure the cell...
        cell.userObj = user
        cell.checkBtnDelegate = self
        return cell
    }
    
    func checked(_ displayname: String) {
        checkedUserList.add(displayname)
    }
    
    func unchecked(_ displayname: String) {
        checkedUserList.remove(displayname)
    }

    @IBAction func submit(_ sender: AnyObject) {
        var usernameListStr = String()
        for user in checkedUserList {
            usernameListStr.append("@" + (user as! String) + " ")
        }
        mentionVCDelegate?.updateMentionList(usernameListStr)
        self.navigationController?.popViewController(animated: true)
    }
}
