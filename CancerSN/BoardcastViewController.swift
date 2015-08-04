//
//  BoardcastViewController.swift
//  CancerSN
//
//  Created by lily on 7/29/15.
//  Copyright (c) 2015 lily. All rights reserved.
//

import UIKit
import CoreData

class BoardcastViewController: UITableViewController{
    
    var broadcastList : NSArray = []
    var favTags : NSArray = []
    var tagResqData : NSMutableData = NSMutableData()
    var getTokenResponseData : NSMutableData = NSMutableData()
    var getPostsData : NSMutableData = NSMutableData()
    
    var didSelectPost:NSDictionary = NSDictionary()
    
    func refreshBroadcast(){
        if refreshControl != nil{
            refreshControl?.beginRefreshing()
        }
        refreshBroadcast(refreshControl!)
    }

    @IBAction func refreshBroadcast(sender: UIRefreshControl) {
        let urlPath: String = getBroadcastsByTagsURL
        getPostsData = NSMutableData()
        var url: NSURL = NSURL(string: urlPath)!
        var request: NSMutableURLRequest = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        
        let profileSet = NSUserDefaults.standardUserDefaults()
        
        var requestBody:NSMutableDictionary = NSMutableDictionary()
        if((profileSet.objectForKey(latestUpdateTimestamp)) != nil){
            requestBody.setValue(Int((profileSet.objectForKey(latestUpdateTimestamp) as! Float)*1000), forKey: "begin")
        }else{
            requestBody.setValue(0, forKey: "begin")
        }
        
        requestBody.setValue(Int(NSDate().timeIntervalSince1970*1000), forKey: "end")
        requestBody.setValue(favTags, forKey: "tags")
        request.HTTPBody = NSJSONSerialization.dataWithJSONObject(requestBody, options: NSJSONWritingOptions.allZeros, error: nil)
//      println(NSString(data: (NSJSONSerialization.dataWithJSONObject(requestBody, options: NSJSONWritingOptions.allZeros, error: nil))!, encoding: NSUTF8StringEncoding)!)
//      println(NSJSONSerialization.dataWithJSONObject(requestBody, options: NSJSONWritingOptions.allZeros, error: nil))
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        var connection: NSURLConnection = NSURLConnection(request: request, delegate: self, startImmediately: true)!
        connection.start()
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.estimatedRowHeight = tableView.rowHeight
        tableView.rowHeight = UITableViewAutomaticDimension
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        var appDel:AppDelegate = (UIApplication.sharedApplication().delegate as! AppDelegate)
        var context:NSManagedObjectContext = appDel.managedObjectContext!
        
        var postsRequest = NSFetchRequest(entityName: "Broadcast")
        postsRequest.returnsObjectsAsFaults = false
        
        postsRequest.sortDescriptors = [NSSortDescriptor(key: "dateInserted", ascending: false)]
        
        broadcastList = context.executeFetchRequest(postsRequest, error: nil)!
        
        let favtagsData = NSUserDefaults.standardUserDefaults().objectForKey(favTagsNSUserData)
        if (((favtagsData)?.isKindOfClass(NSArray)) != nil){
            favTags = favtagsData as! NSMutableArray
        }
        if((favTags.count == 0)||(favtagsData == nil)){
            let urlPath: String = getUserFavTags
            tagResqData = NSMutableData()
            var url: NSURL = NSURL(string: urlPath)!
            var request: NSURLRequest = NSURLRequest(URL: url)
            
            var connection: NSURLConnection = NSURLConnection(request: request, delegate: self, startImmediately: true)!
            connection.start()
        }else{
            //get posts by tags
//            let urlPath: String = getBroadcastsByTagsURL
//            getPostsData = NSMutableData()
//            var url: NSURL = NSURL(string: urlPath)!
//            var request: NSMutableURLRequest = NSMutableURLRequest(URL: url)
//            request.HTTPMethod = "POST"
//            
//            let profileSet = NSUserDefaults.standardUserDefaults()
//            
//            var requestBody:NSMutableDictionary = NSMutableDictionary()
//            if((profileSet.objectForKey(latestUpdateTimestamp)) != nil){
//            requestBody.setValue(profileSet.objectForKey(latestUpdateTimestamp), forKey: "begin")
//            }else{
//                requestBody.setValue(0, forKey: "begin")
//            }
//            
//            requestBody.setValue(Int(NSDate().timeIntervalSince1970*1000), forKey: "end")
//            requestBody.setValue(favTags, forKey: "tags")
//            request.HTTPBody = NSJSONSerialization.dataWithJSONObject(requestBody, options: NSJSONWritingOptions.allZeros, error: nil)
////            println(NSString(data: (NSJSONSerialization.dataWithJSONObject(requestBody, options: NSJSONWritingOptions.allZeros, error: nil))!, encoding: NSUTF8StringEncoding)!)
////            println(NSJSONSerialization.dataWithJSONObject(requestBody, options: NSJSONWritingOptions.allZeros, error: nil))
//            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
//            request.addValue("application/json", forHTTPHeaderField: "Accept")
//            var connection: NSURLConnection = NSURLConnection(request: request, delegate: self, startImmediately: true)!
//            connection.start()
            refreshBroadcast()
        }
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func connection(connection: NSURLConnection!, didReceiveData data: NSData!){
        let connectionURLStr:NSString = (connection.currentRequest.URL)!.absoluteString!
        if( connectionURLStr.containsString(getUserFavTags)){
            tagResqData.appendData(data)
        }
        if(connectionURLStr.containsString(getBroadcastsByTagsURL)){
            getPostsData.appendData(data)
        }
        if(connectionURLStr.containsString(getOauthTokenURL)){
        getTokenResponseData.appendData(data)
        }
    }
    
    func connectionDidFinishLoading(connection: NSURLConnection!)
    {
        var error: NSErrorPointer=nil
        let connectionURLStr:NSString = (connection.currentRequest.URL)!.absoluteString!
        if( connectionURLStr.containsString(getUserFavTags)){
            var jsonResult = NSJSONSerialization.JSONObjectWithData(tagResqData, options: NSJSONReadingOptions.MutableContainers, error: error)
            let str: NSString = NSString(data: tagResqData, encoding: NSUTF8StringEncoding)!
            println(str)
            if(jsonResult is NSDictionary){
                var jsonResultDic: NSDictionary = jsonResult as! NSDictionary
//                var respError = jsonResultDic["error"] as! NSString
//                if(respError.isEqualToString("invalid_token") ){
                    let keychainAccess = KeychainAccess()
                    let usernameStr:String = keychainAccess.getPasscode(usernameKeyChain) as! String
                    let passwordStr:String = keychainAccess.getPasscode(passwordKeyChain) as! String
                    var urlPath: String = getOauthTokenURL + "username=" + usernameStr + "&password=" + passwordStr
                    urlPath = urlPath.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
                    getTokenResponseData = NSMutableData()
                    var url: NSURL = NSURL(string: urlPath)!
                println(urlPath)
                    var request: NSURLRequest = NSURLRequest(URL: url)
                    var connection: NSURLConnection = NSURLConnection(request: request, delegate: self, startImmediately: true)!
                    connection.start()
//                }
            }else if(jsonResult is NSArray){
                favTags = jsonResult as! NSArray
                let profileSet = NSUserDefaults.standardUserDefaults()
                profileSet.setObject(favTags, forKey: favTagsNSUserData)
                
                //send get broadcast request
                
            }
        }
        if(connectionURLStr.containsString(getOauthTokenURL)){
            var jsonResult = NSJSONSerialization.JSONObjectWithData(getTokenResponseData, options: NSJSONReadingOptions.MutableContainers, error: error)
            let str: NSString = NSString(data: getTokenResponseData, encoding: NSUTF8StringEncoding)!
            println(str)
            var accessToken  = jsonResult?.objectForKey("access_token")
            var refreshToken = jsonResult?.objectForKey("refresh_token")
            if(accessToken != nil && refreshToken != nil){
                let profileSet = NSUserDefaults.standardUserDefaults()
                profileSet.setObject(accessToken, forKey: accessNSUserData)
                profileSet.setObject(refreshToken, forKey: refreshNSUserData)
                let urlPath: String = getUserFavTags + "?access_token=" + (accessToken as! String)
                println(urlPath)
                tagResqData = NSMutableData()
                var url: NSURL = NSURL(string: urlPath)!
                var request: NSMutableURLRequest = NSMutableURLRequest(URL: url)
                var connection: NSURLConnection = NSURLConnection(request: request, delegate: self, startImmediately: true)!
                connection.start()
            }
        }
        if(connectionURLStr.containsString(getBroadcastsByTagsURL)){
            var jsonResult = NSJSONSerialization.JSONObjectWithData(getPostsData, options: NSJSONReadingOptions.MutableContainers, error: error)
            let str: NSString = NSString(data: getPostsData, encoding: NSUTF8StringEncoding)!
            println(str)
            if(jsonResult is NSArray){
                var newBroadcastList:NSMutableArray = jsonResult as! NSMutableArray

                refreshControl?.endRefreshing()
                //save Broadcast to local DB
                var appDel:AppDelegate = (UIApplication.sharedApplication().delegate as! AppDelegate)
                var context:NSManagedObjectContext = appDel.managedObjectContext!
                for broadcast in newBroadcastList{
             /*       postID: 47
                    type: null
                    insertUserName: "user1"
                    body: "it's a test"
                    tags: "tarceva**易瑞沙**腺癌**"
                    countComments: 0
                    countBookmarks: 0
                    countViews: 0
                    closed: 0
                    isBroadcast: 0
                    dateInserted: 1438360997000
                    dateUpdated: 1438360996568
                    isActive: 1
                    image:*/
                    var post = NSEntityDescription.insertNewObjectForEntityForName("Broadcast", inManagedObjectContext: context) as! NSManagedObject
                    post.setValue(broadcast["postID"], forKey: "postID")
                    post.setValue(broadcast["insertUsername"], forKey: "insertUsername")
                    post.setValue(broadcast["countComments"], forKey: "countComments")
                    post.setValue(broadcast["body"], forKey: "body")
                    post.setValue(broadcast["tags"], forKey: "tags")
                    post.setValue(broadcast["countViews"], forKey: "countViews")
                    post.setValue(broadcast["countBookmarks"], forKey: "countBookmarks")
                    post.setValue(broadcast["closed"], forKey: "closed")
                    post.setValue(broadcast["isBroadcast"], forKey: "isBroadcast")
                    post.setValue(broadcast["dateInserted"], forKey: "dateInserted")
                    post.setValue(broadcast["dateUpdated"], forKey: "dateUpdated")
                    let imgValue = broadcast["image"]
                    if( ((broadcast["image"]) is NSNull) == false ){
                        post.setValue(broadcast["image"], forKey: "image")
                    }
                    context.save(nil)
                }
                newBroadcastList.addObjectsFromArray(broadcastList as [AnyObject])
                broadcastList = newBroadcastList as! NSArray
                self.tableView.reloadData()
                //set timestamp
                let profileSet = NSUserDefaults.standardUserDefaults()
                profileSet.setObject(NSDate().timeIntervalSince1970, forKey: latestUpdateTimestamp)
            }else{
                println("get broadcast error")
                refreshControl?.endRefreshing()
            }
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
        return 2
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        var numberOfRows: Int = 0
        if(section == 1){
            numberOfRows = broadcastList.count
        }
        return numberOfRows
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if(indexPath.section == 1){
            let cell = tableView.dequeueReusableCellWithIdentifier("broadcastListCell", forIndexPath: indexPath) as! BroadcastListTableViewCell
            if(broadcastList[indexPath.row] is NSManagedObject){
                var keys = broadcastList[indexPath.row].entity.attributesByName.keys.array
                let broadcastDic = broadcastList[indexPath.row].dictionaryWithValuesForKeys(keys)
                
//                var bytes = NSJSONSerialization.dataWithJSONObject(broadcastDic, options: NSJSONWritingOptions.allZeros, error: nil)
//                var jsonObj = NSJSONSerialization.JSONObjectWithData(bytes!, options: nil, error: nil)

                cell.broadcast = broadcastDic
            }else{
                cell.broadcast = broadcastList[indexPath.row] as! NSDictionary
            }
            return cell
        }else{            let cell = tableView.dequeueReusableCellWithIdentifier("broadcastHeaderCell", forIndexPath: indexPath) as! UITableViewCell
            return cell
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if(indexPath.section == 1){
            if(broadcastList[indexPath.row] is NSManagedObject){
                var keys = broadcastList[indexPath.row].entity.attributesByName.keys.array
                let broadcastDic = broadcastList[indexPath.row].dictionaryWithValuesForKeys(keys)
                didSelectPost = broadcastDic
            }else{
                didSelectPost = broadcastList[indexPath.row] as! NSDictionary
            }
            self.performSegueWithIdentifier("postDetailSegue", sender: self)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "tagListSegue" {
            (segue.destinationViewController as! TagViewController).selectedTags = NSMutableArray(array: favTags)
        }
        if segue.identifier == "postDetailSegue" {
            (segue.destinationViewController as! ShowPostDetailTableViewController).post = didSelectPost
        }
    }
    
    override func tableView(_tableView: UITableView,
        heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat{
            var rowHeight:CGFloat
            switch indexPath.section{
            case 0: rowHeight = 0
                break
            case 1: rowHeight = UITableViewAutomaticDimension
                break
            default:rowHeight = 0
                break
            }
            return rowHeight
    }

    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
}
