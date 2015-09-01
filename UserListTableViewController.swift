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
    var addFollowingResponseData : NSMutableData? = nil
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
            var jsonResult = NSJSONSerialization.JSONObjectWithData(getUserFavTags, options: NSJSONReadingOptions.MutableContainers, error: nil)
//          let str: NSString = NSString(data: getSuggestUsers, encoding: NSUTF8StringEncoding)!
//          println(str)
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
//            loginBtn.enabled = false
        }else{
            getSuggestUsers = haalthyService.getSuggestUserByTags(tagList, rangeBegin: 0, rangeEnd: 10)
            self.navigationItem.rightBarButtonItem = loginBtn
//            loginBtn.enabled = true
        }
        
        var jsonResult = NSJSONSerialization.JSONObjectWithData(getSuggestUsers, options: NSJSONReadingOptions.MutableContainers, error: nil)
        let str: NSString = NSString(data: getSuggestUsers, encoding: NSUTF8StringEncoding)!
        println(str)
        if(jsonResult is NSArray){
            userList = jsonResult as! NSArray
        }

//        if(((UIDevice.currentDevice().systemVersion) as NSString).floatValue>=7){
//            var topWindow = UIApplication.sharedApplication().keyWindow
//            topWindow?.clipsToBounds = true;
//            topWindow!.frame =  CGRectMake(0,20,topWindow!.frame.size.width,topWindow!.frame.size.height-20);
//        }
//        self.tabBarController?.tabBar.hidden = false
//        self.navigationController?.navigationBar.hidden = true
//        let urlPath: String = getSuggestUserByTagsURL
//        getSuggestUserData = NSMutableData()
//        var url: NSURL = NSURL(string: urlPath)!
//        var request: NSMutableURLRequest = NSMutableURLRequest(URL: url)
//        request.HTTPMethod = "POST"
//        var tagListStr:String = ""
//        for(var tagIndex = 0;tagIndex<tagList.count-1; tagIndex++){
//            tagListStr = tagListStr + (tagList[tagIndex]["tagId"] as! NSNumber).stringValue + ","
//        }
//        
//        if(tagList.count>0){
//            tagListStr = tagListStr + (tagList[tagList.count-1]["tagId"] as! NSNumber).stringValue
//        }
//
//        let requestBodyStr:String = "{\"tags\":[" + tagListStr + "],\"rangeBegin\":0,\"rangeEnd\":5}"
//        request.HTTPBody = requestBodyStr.dataUsingEncoding(NSUTF8StringEncoding)
//        println(requestBodyStr)
//        //request.HTTPBody = "{\"tags\":[2,4,9],\"rangeBegin\":0,\"rangeEnd\":5}".dataUsingEncoding(NSUTF8StringEncoding)
//        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
//        request.addValue("application/json", forHTTPHeaderField: "Accept")
//        var connection: NSURLConnection = NSURLConnection(request: request, delegate: self, startImmediately: true)!
//        connection.start()
        
//        self.tabBarController?.tabBar.hidden = false
    }
    
//    override func viewWillDisappear(animated: Bool) {
//        super.viewWillDisappear(animated)
////        self.navigationController?.navigationBar.hidden = false
//    }
//    
//    func connection(connection: NSURLConnection!, didReceiveData data: NSData!){
//        let connectionURLStr:NSString = (connection.currentRequest.URL)!.absoluteString!
//        if( connectionURLStr.containsString(getSuggestUserByTagsURL)){
//            getSuggestUserData!.appendData(data)
//        }
//    }
//    
//    func connectionDidFinishLoading(connection: NSURLConnection!)
//    {
//        var error: NSErrorPointer=nil
//        let connectionURLStr:NSString = (connection.currentRequest.URL)!.absoluteString!
//        if( connectionURLStr.containsString(getSuggestUserByTagsURL)){
//            var jsonResult: NSArray = NSJSONSerialization.JSONObjectWithData(getSuggestUserData!, options: NSJSONReadingOptions.MutableContainers, error: error) as! NSArray
//            self.userList = jsonResult
//            //get current Following User
////            var appDel:AppDelegate = (UIApplication.sharedApplication().delegate as! AppDelegate)
////            var context:NSManagedObjectContext = appDel.managedObjectContext!
////            var followingUsersRequest = NSFetchRequest(entityName: "Following")
////            followingUsersRequest.returnsObjectsAsFaults = false
////            var followingUsers:NSArray = context.executeFetchRequest(followingUsersRequest, error: nil)!
////            if(followingUsers.count>0){
////                for (var followingUser in followingUsers){
////                    for(var index = 0; index<userList.count; index++){
////                        if(userList[index]["username"] == followingUser["username"]){
////                        }
////                    }
////                }
////            }
//            
//            self.tableView.reloadData()
//        }
//    }

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
