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
//    @IBOutlet weak var loginBtn: UIBarButtonItem!

    var userList : NSArray = []
    var username : NSString = ""
    var password: NSString = ""
    var haalthyService = HaalthyService()
    var keychainAccess = KeychainAccess()
    var hiddenFollowButton = true

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        var username = keychainAccess.getPasscode(usernameKeyChain)
        var password = keychainAccess.getPasscode(passwordKeyChain)

        var getSuggestUsers: NSData?
        if((username != nil) && (password != nil)){
            self.username = keychainAccess.getPasscode(usernameKeyChain)!
            self.password = keychainAccess.getPasscode(passwordKeyChain)!
            getSuggestUsers = haalthyService.getSuggestUserByProfile(0, rangeEnd: 20)
            self.navigationItem.rightBarButtonItem = nil
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
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var numberOfRowsInSection:Int = userList.count
        return numberOfRowsInSection
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var user: NSDictionary = userList[indexPath.row] as! NSDictionary
        let cell = tableView.dequeueReusableCellWithIdentifier("userListCell", forIndexPath: indexPath) as! UserListTableViewCell
        cell.hiddenFollowButton = true
        cell.user = userList[indexPath.row] as! NSDictionary
        cell.delegate = self
        return cell
    }
    
    override func tableView(_tableView: UITableView,
        heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat{
            var rowHeight:CGFloat = 80
            return rowHeight
    }
    func performLoginSegue() {
        self.performSegueWithIdentifier("loginSegue", sender: nil)
    }
    
    func imageTap(username: String) {
        
    }
}
