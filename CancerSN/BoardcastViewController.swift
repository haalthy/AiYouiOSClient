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
        if((profileSet.objectForKey(latestBroadcastUpdateTimestamp)) != nil){
            requestBody.setValue(Int((profileSet.objectForKey(latestBroadcastUpdateTimestamp) as! Float)*1000), forKey: "begin")
        }else{
            requestBody.setValue(0, forKey: "begin")
        }
        
        requestBody.setValue(Int(NSDate().timeIntervalSince1970*1000), forKey: "end")
        requestBody.setValue(favTags, forKey: "tags")
        request.HTTPBody = NSJSONSerialization.dataWithJSONObject(requestBody, options: NSJSONWritingOptions.allZeros, error: nil)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        var getPostsByTagsData = NSURLConnection.sendSynchronousRequest(request, returningResponse: nil, error: nil)
        var jsonResult = NSJSONSerialization.JSONObjectWithData(getPostsByTagsData!, options: NSJSONReadingOptions.MutableContainers, error: nil)
        let str: NSString = NSString(data: getPostsData, encoding: NSUTF8StringEncoding)!
        println(str)
        if(jsonResult is NSArray){
            var newBroadcastList:NSMutableArray = jsonResult as! NSMutableArray
            
            refreshControl?.endRefreshing()
            //save Broadcast to local DB
            var appDel:AppDelegate = (UIApplication.sharedApplication().delegate as! AppDelegate)
            var context:NSManagedObjectContext = appDel.managedObjectContext!
            for broadcast in newBroadcastList{
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
            profileSet.setObject(NSDate().timeIntervalSince1970, forKey: latestBroadcastUpdateTimestamp)
        }else{
            println("get broadcast error")
            refreshControl?.endRefreshing()
        }

    }
    
    func sendSyncGetUserFavTagsRequest(accessToken:String)->NSData{
        let urlPath:String = (getUserFavTagsURL as String) + "?access_token=" + (accessToken as! String);
        let url : NSURL = NSURL(string: urlPath)!
        var request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        var response: AutoreleasingUnsafeMutablePointer<NSURLResponse?> = nil
        var getUserFavTagspData = NSURLConnection.sendSynchronousRequest(request, returningResponse: response, error: nil)
        return getUserFavTagspData!
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.estimatedRowHeight = tableView.rowHeight
        //self.tableView.estimatedRowHeight = UITableViewAutomaticDimension
        tableView.rowHeight = UITableViewAutomaticDimension
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
        let profileSet = NSUserDefaults.standardUserDefaults()
        if((favTags.count == 0)||(favtagsData == nil)){
            var accessToken = profileSet.objectForKey(accessNSUserData)
            if accessToken != nil{
                var jsonResult = NSJSONSerialization.JSONObjectWithData(self.sendSyncGetUserFavTagsRequest(accessToken as! String), options: NSJSONReadingOptions.MutableContainers, error: nil)
                if(jsonResult is NSArray){
                    favTags = jsonResult as! NSArray
                    let profileSet = NSUserDefaults.standardUserDefaults()
                    profileSet.setObject(favTags, forKey: favTagsNSUserData)
                }else{
                    accessToken = nil
                }
            }
            if accessToken == nil {
                let getAccessToken = GetAccessToken()
                getAccessToken.getAccessToken()
                accessToken = profileSet.objectForKey(accessNSUserData)
                var jsonResult = NSJSONSerialization.JSONObjectWithData(self.sendSyncGetUserFavTagsRequest(accessToken as! String), options: NSJSONReadingOptions.MutableContainers, error: nil)
                if(jsonResult is NSArray){
                    favTags = jsonResult as! NSArray
                    let profileSet = NSUserDefaults.standardUserDefaults()
                    profileSet.setObject(favTags, forKey: favTagsNSUserData)
                }
            }
            if accessToken != nil{
                refreshBroadcast()
            }
        }else{
            refreshBroadcast()
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
            (segue.destinationViewController as! TagTableViewController).selectedTags = NSMutableArray(array: favTags)
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
