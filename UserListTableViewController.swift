//
//  UserListTableViewController.swift
//  CancerSN
//
//  Created by lily on 7/21/15.
//  Copyright (c) 2015 lily. All rights reserved.
//

import UIKit

class UserListTableViewController: UITableViewController {

    var tagList: NSArray = []
    var userList : NSArray = []
    var data :NSMutableData? = nil
    var username : NSString = ""
    var password: NSString = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        let favtags = NSUserDefaults.standardUserDefaults()
        if((favtags.objectForKey(favTagsNSUserData)) != nil){
            tagList = favtags.objectForKey(favTagsNSUserData) as! NSArray
        }
        if(tagList.count == 0){
            self.performSegueWithIdentifier("modalsegue", sender: nil)
        }
    
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
//        self.navigationController?.navigationBar.hidden = false

    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        var keychainAccess = KeychainAccess()
        var username = keychainAccess.getPasscode(usernameKeyChain)
        var password = keychainAccess.getPasscode(passwordKeyChain)
        if((username != nil) && (password != nil)){
            self.username = keychainAccess.getPasscode(usernameKeyChain)!
            self.password = keychainAccess.getPasscode(passwordKeyChain)!
        }

//        if(((UIDevice.currentDevice().systemVersion) as NSString).floatValue>=7){
//            var topWindow = UIApplication.sharedApplication().keyWindow
//            topWindow?.clipsToBounds = true;
//            topWindow!.frame =  CGRectMake(0,20,topWindow!.frame.size.width,topWindow!.frame.size.height-20);
//        }
//        self.tabBarController?.tabBar.hidden = false
        self.navigationController?.navigationBar.hidden = true
        let urlPath: String = getSuggestUserByTagsURL
        data = NSMutableData()
        var url: NSURL = NSURL(string: urlPath)!
        var request: NSMutableURLRequest = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        var tagListStr:String = ""
        for(var tagIndex = 0;tagIndex<tagList.count-1; tagIndex++){
            tagListStr = tagListStr + (tagList[tagIndex]["tagId"] as! NSNumber).stringValue + ","
        }
        
        if(tagList.count>0){
            tagListStr = tagListStr + (tagList[tagList.count-1]["tagId"] as! NSNumber).stringValue
        }

        let requestBodyStr:String = "{\"tags\":[" + tagListStr + "],\"rangeBegin\":0,\"rangeEnd\":5}"
        request.HTTPBody = requestBodyStr.dataUsingEncoding(NSUTF8StringEncoding)
        
        //request.HTTPBody = "{\"tags\":[2,4,9],\"rangeBegin\":0,\"rangeEnd\":5}".dataUsingEncoding(NSUTF8StringEncoding)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        var connection: NSURLConnection = NSURLConnection(request: request, delegate: self, startImmediately: true)!
        connection.start()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.hidden = false
    }
    
    func connection(connection: NSURLConnection!, didReceiveData data: NSData!){
        self.data!.appendData(data)
    }
    
    func connectionDidFinishLoading(connection: NSURLConnection!)
    {
        var error: NSErrorPointer=nil
        var jsonResult: NSArray = NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers, error: error) as! NSArray
        
        self.userList = jsonResult
        self.tableView.reloadData()
        
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
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        if(section == 0){
            return 1
        }else if(section == 1){
            return 1
        }
        else if(section == 2){
            return userList.count
        }else{
            return 0
        }
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if(indexPath.section == 2){
            let cell = tableView.dequeueReusableCellWithIdentifier("userListCell", forIndexPath: indexPath) as! UserListTableViewCell
            
            let dataString = userList[indexPath.row]["image"] as! String
            let imageData: NSData = NSData(base64EncodedString: dataString, options: NSDataBase64DecodingOptions(0))!
            
            cell.userImage.image = UIImage(data: imageData)
            
            cell.usernameDisplay.text = userList[indexPath.row]["username"] as? String
            
            var userProfileStr : String
            var gender = userList[indexPath.row]["gender"] as! String
            var displayGender:String = ""
            if(gender == "M"){
                displayGender = "男"
            }else if(gender == "F"){
                displayGender = "女"
            }
            var age = (userList[indexPath.row]["age"] as! NSNumber).stringValue
            var pathological = userList[indexPath.row]["pathological"] as! String
            var stage = userList[indexPath.row]["stage"] as! String
            
            userProfileStr = displayGender + " " + age + "岁 " + pathological + " " + stage + "期"
            
            cell.userProfileDisplay.text = userProfileStr
            
            cell.userFollowers.text = (userList[indexPath.row]["followCount"] as! NSNumber).stringValue + "个关注者"
            return cell
        }else if(indexPath.section == 0){
            let cell = tableView.dequeueReusableCellWithIdentifier("userListHeaderCell", forIndexPath: indexPath) as! UserListHeaderTableViewCell
            if(username != "" && password != ""){
                cell.hidden = true
            }
            return cell
        }else{
            let cell = tableView.dequeueReusableCellWithIdentifier("userSearchCell", forIndexPath: indexPath) as! UserSearchTableViewCell
            return cell
        }
    }
    
    override func tableView(_tableView: UITableView,
        heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat{
            var headerRowHeight:CGFloat
            if(username != "" && password != ""){
                headerRowHeight = 0
            }else{
                headerRowHeight = 44
            }
            var rowHeight: CGFloat
            switch indexPath.section{
            case 0: rowHeight = headerRowHeight
                break
            case 1: rowHeight = 44
                break
            case 2: rowHeight = 95
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
}

extension UserListTableViewController: TagVCDelegate {
    func updateTagList(data: NSArray) {
        self.tagList = data
        
        let favtags = NSUserDefaults.standardUserDefaults()
        favtags.setObject(tagList, forKey: favTagsNSUserData)
    }
}
