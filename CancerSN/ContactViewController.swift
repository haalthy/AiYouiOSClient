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
    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func cancel(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        var userListData = NSData()
        let keychainAccess = KeychainAccess()
        let username = keychainAccess.getPasscode(usernameKeyChain) as! String
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        userListData = haalthyService.getFollowingUsers(username)!
        
        let jsonResult = try? NSJSONSerialization.JSONObjectWithData(userListData, options: NSJSONReadingOptions.MutableContainers)
        if jsonResult is NSArray {
            contactList = jsonResult as! NSArray
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
        var user = contactList[indexPath.row] as! NSDictionary
        // Configure the cell...
        if((user["image"] is NSNull) == false){
            let dataString = user.objectForKey("image") as! String
            let imageData: NSData = NSData(base64EncodedString: dataString, options: NSDataBase64DecodingOptions(rawValue: 0))!
            
            cell.imageView?.image = UIImage(data: imageData)
        }
        cell.textLabel?.text = user.objectForKey("username") as! String
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.mentionDelegate?.updateMentionList((tableView.cellForRowAtIndexPath(indexPath)?.textLabel?.text)!)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
}
