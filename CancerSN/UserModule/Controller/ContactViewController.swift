//
//  ContactViewController.swift
//  CancerSN
//
//  Created by lily on 9/18/15.
//  Copyright (c) 2015 lily. All rights reserved.
//

import UIKit

protocol MentionVCDelegate {
    func updateMentionList(username: String)
}

class ContactViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var mentionDelegate: MentionVCDelegate?
    var haalthyService = HaalthyService()
    var contactList = NSArray()
    var userObjList = NSMutableArray()
    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func cancel(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return contactList.count
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("contactListCell", forIndexPath: indexPath) 
        let user = userObjList.objectAtIndex(indexPath.row) as! UserProfile
        // Configure the cell...
        if(user.portraitUrl != nil){
            
            let url : NSURL = NSURL(string: user.portraitUrl!)!
            let imageData = NSData(contentsOfURL: url)
            if imageData != nil {
                cell.imageView?.image = UIImage(data: imageData!)
            }else{
                cell.imageView?.backgroundColor = imageViewBackgroundColor
            }
            
        }
        cell.textLabel?.text = user.nick
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.mentionDelegate?.updateMentionList((tableView.cellForRowAtIndexPath(indexPath)?.textLabel?.text)!)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
}
