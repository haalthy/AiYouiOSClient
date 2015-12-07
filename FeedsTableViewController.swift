//
//  FeedsTableViewController.swift
//  CancerSN
//
//  Created by lily on 7/28/15.
//  Copyright (c) 2015 lily. All rights reserved.
//

import UIKit
import CoreData

class FeedsTableViewController: UITableViewController, UIPopoverPresentationControllerDelegate, UserTagVCDelegate, UIGestureRecognizerDelegate, ImageTapDelegate, FeedBodyDelegate {
    var username:String?
    var password:String?
    var feedList = NSArray()
    var automatedShowDiscoverView:Bool = true
    var heightForFeedRow = NSMutableDictionary()
    var selectTags = NSArray()
    var selectedProfileOwnername = String()
    var haalthyService = HaalthyService()
    var latestFeedFetchTimeStamp: Int = 0
    var previousFeedFetchTimeStamp: Int = 0
    var isRefreshData: Bool = false
    let profileSet = NSUserDefaults.standardUserDefaults()
    
    @IBOutlet weak var addItem: UIButton!
    @IBAction func selectTags(sender: UIButton) {
//        self.performSegueWithIdentifier("showTagsSegue", sender: self)
        let storyboard = UIStoryboard(name: "Registeration", bundle: nil)
        let controller = storyboard.instantiateViewControllerWithIdentifier("TagEntry") as! TagTableViewController
        controller.userTagDelegate = self
        self.presentViewController(controller, animated: true, completion: nil)
    }
    
    @IBAction func discover(sender: UIButton) {
        self.performSegueWithIdentifier("discoverSegue", sender: self)
    }
    
    @IBAction func addPopover(sender: UIButton) {
        if username != nil{
            let storyboard = UIStoryboard(name: "Add", bundle: nil)
            let popoverContent = storyboard.instantiateViewControllerWithIdentifier("AddEntry")
            let nav = UINavigationController(rootViewController: popoverContent)
            nav.modalPresentationStyle = UIModalPresentationStyle.Popover
            let popover = nav.popoverPresentationController
            popoverContent.preferredContentSize = CGSizeMake(100,100)
            popover!.delegate = self
            popover!.sourceView = self.view
            popover!.sourceRect = CGRectMake(300,0,0,0)
            popover?.permittedArrowDirections = UIPopoverArrowDirection.Up
            
            self.presentViewController(nav, animated: true, completion: nil)
        }else{
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let controller = storyboard.instantiateViewControllerWithIdentifier("LoginEntry") as UIViewController
            
            self.presentViewController(controller, animated: true, completion: nil)
        }
    }
    
    @IBAction func addActionPopover(sender: UIBarButtonItem) {
        let storyboard = UIStoryboard(name: "Add", bundle: nil)
        let popController = (storyboard.instantiateViewControllerWithIdentifier("AddEntry") as UIViewController).popoverPresentationController
        popController?.delegate = self
        popController!.permittedArrowDirections = UIPopoverArrowDirection.Any
        popController?.sourceView = self.view
        popController!.sourceRect = CGRectMake(30, 50, 10, 10)
        self.presentViewController(popController as! UIViewController, animated: true, completion: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "postDetailSegue" {
            (segue.destinationViewController as! ShowPostDetailTableViewController).post = feed
        }
        if segue.identifier == "showTagsSegue" {
            (segue.destinationViewController as! TagTableViewController).userTagDelegate = self
        }
    }
    
    //add pop over segue
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return .None
    }
    
    @IBOutlet weak var myTags: UIButton!
    
    func getexistFeedsFromLocalDB(){
        let appDel:AppDelegate = (UIApplication.sharedApplication().delegate as! AppDelegate)
        let context:NSManagedObjectContext = appDel.managedObjectContext!
        let postsRequest = NSFetchRequest(entityName: "Feed")
        if username != nil{
            postsRequest.predicate = NSPredicate(format: "ownerName = %@", username!)
        }else{
            postsRequest.predicate = NSPredicate(format: "ownerName = %@", "")
        }
        postsRequest.returnsObjectsAsFaults = false
        postsRequest.sortDescriptors = [NSSortDescriptor(key: "dateInserted", ascending: false)]
        feedList = try! context.executeFetchRequest(postsRequest)
    }
    
    func clearFeedLocalTable(){
        let appDel:AppDelegate = (UIApplication.sharedApplication().delegate as! AppDelegate)
        let context:NSManagedObjectContext = appDel.managedObjectContext!
        let deletePostsRequet = NSFetchRequest(entityName: "Feed")
        if username != nil{
            deletePostsRequet.predicate = NSPredicate(format: "ownerName = %@", username!)
        }else{
            deletePostsRequet.predicate = NSPredicate(format: "ownerName = %@", "")
        }
        if let results = try? context.executeFetchRequest(deletePostsRequet) {
            for param in results {
                context.deleteObject(param as! NSManagedObject);
            }
        }
        do {
            try context.save()
        } catch _ {
        }
    }
    
    func refreshFeeds(){
        if refreshControl != nil{
            refreshControl?.beginRefreshing()
        }
        refreshFeeds(refreshControl!)
    }
    
    func setPatientProfile(feed: NSDictionary){
        var profileStr:String = ""
        if((feed.valueForKey("gender") != nil) && ((feed.valueForKey("gender") is NSNull) == false)){
            let genderKey = (feed.valueForKey("gender")!) as! String
            profileStr += (genderMapping.allKeysForObject(genderKey)[0] as! String) + ","
        }
        if((feed.valueForKey("age") != nil) && ((feed.valueForKey("age") is NSNull) == false)){
            profileStr += (feed.valueForKey("age")!.stringValue) + ","
        }
        if((feed.valueForKey("cancerType") != nil) && ((feed.valueForKey("cancerType") is NSNull) == false)){
            if(feed.valueForKey("cancerType") as! String != "lung"){
                let cancerTypeKey = feed.valueForKey("cancerType") as! String
                if ((cancerTypeKey is NSNull) == false) && (cancerTypeKey != ""){
                    profileStr += cancerTypeMapping.allKeysForObject(cancerTypeKey)[0] as! String
                }
            }else if((feed.valueForKey("pathological") != nil) && ((feed.valueForKey("pathological") is NSNull) == false) && (feed.valueForKey("pathological") as! String != "")){
                
                profileStr += pathologicalMapping.allKeysForObject(feed.valueForKey("pathological")!)[0] as! String
            }
        }
        feed.setValue(profileStr, forKey: "patientProfile")
    }
    
    func addFeedslist(feedArray: NSArray, isLoadLatestFeeds: Bool){
        let newFeedList:NSMutableArray = feedArray as! NSMutableArray
        
        let appDel:AppDelegate = (UIApplication.sharedApplication().delegate as! AppDelegate)
        let context:NSManagedObjectContext = appDel.managedObjectContext!
        for feed in newFeedList{
            if (((feed as! NSDictionary)["postID"] as! Int) == ((newFeedList[newFeedList.count - 1] as! NSDictionary)["postID"] as! Int)) && (isLoadLatestFeeds == false) {
                print(feed["dateInserted"])
                previousFeedFetchTimeStamp = feed["dateInserted"] as! Int - 1000
                print(previousFeedFetchTimeStamp)
            }
            setPatientProfile(feed as! NSDictionary)
            let feedItem = NSEntityDescription.insertNewObjectForEntityForName("Feed", inManagedObjectContext: context) 
            feedItem.setValue(feed["postID"], forKey: "postID")
            feedItem.setValue(feed["insertUsername"], forKey: "insertUsername")
            feedItem.setValue(feed["countComments"], forKey: "countComments")
            feedItem.setValue(feed["body"], forKey: "body")
            if (feed["tags"]  is NSNull) == false{
                feedItem.setValue(feed["tags"], forKey: "tags")
            }
            feedItem.setValue(feed["countViews"], forKey: "countViews")
            feedItem.setValue(feed["countBookmarks"], forKey: "countBookmarks")
            feedItem.setValue(feed["closed"], forKey: "closed")
            feedItem.setValue(feed["isBroadcast"], forKey: "isBroadcast")
            feedItem.setValue(feed["dateInserted"], forKey: "dateInserted")
            if feed["dateUpdated"] is NSNull == false{
                feedItem.setValue(feed["dateUpdated"], forKey: "dateUpdated")
            }
            feedItem.setValue(feed["patientProfile"], forKey: "patientProfile")
            let imgValue = feed["image"]
            if( ((feed["image"]) is NSNull) == false ){
                feedItem.setValue(feed["image"], forKey: "image")
            }
            if username != nil{
                feedItem.setValue(username, forKey: "ownerName")
            }else{
                feedItem.setValue("", forKey: "ownerName")
            }
            if (feed["type"] is NSNull) == false{
                feedItem.setValue(feed["type"], forKey: "type")
            }
            if (feed["hasImage"] is NSNull) == false{
                feedItem.setValue(feed["hasImage"], forKey: "hasImage")
                var index: Int = 1
                if ((feed["hasImage"] as! Int) > 0) && ((feed["postImageList"] is NSNull) == false){
                    dispatch_async(dispatch_get_main_queue()) {
                        for image in (feed["postImageList"] as! NSArray){
                            let dataString = image as! String
                            let imageData: NSData = NSData(base64EncodedString: dataString, options: NSDataBase64DecodingOptions(rawValue: 0))!
                            let fileManager = NSFileManager.defaultManager()
                            let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] 
                            let indexStr: String = (index as NSNumber).stringValue
                            let fileNameStr: String = (feed["postID"] as! NSNumber).stringValue + "." + indexStr + ".small" + ".jpg"
                            let filePathToWrite = "\(paths)/" + fileNameStr
                            fileManager.createFileAtPath(filePathToWrite, contents: imageData, attributes: nil)
                            let getImagePath = paths + fileNameStr
                            print(getImagePath)
                            if (fileManager.fileExistsAtPath(getImagePath))
                            {
                                print("FILE AVAILABLE");
                            }
                            else
                            {
                                print("FILE NOT AVAILABLE");
                                
                            }
                            index++
                        }
                    }
                }
            }
            do {
                try context.save()
            } catch _ {
            }
        }
        if isLoadLatestFeeds{
            newFeedList.addObjectsFromArray(feedList as [AnyObject])
            feedList = newFeedList as NSArray
        }else{
            feedList = feedList.arrayByAddingObjectsFromArray(newFeedList as [AnyObject])
        }
        self.tableView.reloadData()
    }
    
    @IBAction func refreshFeeds(sender: UIRefreshControl) {
        print(Int(NSDate().timeIntervalSince1970*100000))
        let getFeedsData = haalthyService.getFeeds(latestFeedFetchTimeStamp)
        latestFeedFetchTimeStamp = Int(NSDate().timeIntervalSince1970*1000)
        print(NSDate().timeIntervalSince1970)
        var jsonResult:AnyObject? = nil
        if getFeedsData != nil{
            jsonResult = try? NSJSONSerialization.JSONObjectWithData(getFeedsData!, options: NSJSONReadingOptions.MutableContainers)
            let str: NSString = NSString(data: getFeedsData!, encoding: NSUTF8StringEncoding)!
        }
        refreshControl?.endRefreshing()
        if((jsonResult is NSArray) && (jsonResult as! NSArray).count > 0){
            addFeedslist(jsonResult as! NSArray, isLoadLatestFeeds: true)
            
        }else{
            print("get broadcast error")
        }
    }
    
    func getMorePreviousFeeds(){
        let getFeedsData = haalthyService.getPreviousFeeds(previousFeedFetchTimeStamp, count: 20)
        var jsonResult:AnyObject? = nil
        if getFeedsData != nil{
            jsonResult = try? NSJSONSerialization.JSONObjectWithData(getFeedsData!, options: NSJSONReadingOptions.MutableContainers)
            let str: NSString = NSString(data: getFeedsData!, encoding: NSUTF8StringEncoding)!
        }
        if(jsonResult is NSArray){
            addFeedslist(jsonResult as! NSArray, isLoadLatestFeeds: false)
            
        }else{
            print("get feeds error")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UIApplication.sharedApplication().statusBarStyle = .LightContent

        self.navigationController?.navigationBar.backgroundColor = headerColor
        
        let keychainAccess = KeychainAccess()
        
        keychainAccess.deletePasscode(usernameKeyChain)
        keychainAccess.deletePasscode(passwordKeyChain)

        username = keychainAccess.getPasscode(usernameKeyChain) as? String
        password = keychainAccess.getPasscode(passwordKeyChain) as? String
        let getUpdatePostCountData = haalthyService.getUpdatedPostCount(0)
        var jsonResult:AnyObject? = nil
        var postCount:Int = 0
        if getUpdatePostCountData != nil{
            jsonResult = try? NSJSONSerialization.JSONObjectWithData(getUpdatePostCountData!, options: NSJSONReadingOptions.MutableContainers)
            postCount = Int((NSString(data: getUpdatePostCountData!, encoding: NSUTF8StringEncoding)! as String))!
        }else{
            let alert = UIAlertController(title: "提示", message: "oops....网络不给力", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "确定", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
        latestFeedFetchTimeStamp = Int(NSDate().timeIntervalSince1970*1000)
        if postCount == 0{
            self.getexistFeedsFromLocalDB()
        }else{
            clearFeedLocalTable()
            previousFeedFetchTimeStamp = Int(NSDate().timeIntervalSince1970*1000)
            self.getMorePreviousFeeds()
        }
        if username != nil{
            let newFollowerCountData: NSData? = haalthyService.selectNewFollowCount()
            if newFollowerCountData != nil {
                let jsonResult = try? NSJSONSerialization.JSONObjectWithData(newFollowerCountData!, options: NSJSONReadingOptions.MutableContainers)
                if jsonResult is NSDictionary {
                    let newFollowerCountStr = ((jsonResult as! NSDictionary).objectForKey("count") as! NSNumber).stringValue
                    if newFollowerCountStr != "0" {
                        ((self.tabBarController?.tabBar.items as! NSArray).objectAtIndex(1) as! UITabBarItem).title = "我 New"
                    }else{
                        let newMentionedPostCountData: NSData = haalthyService.getUnreadMentionedPostCount()!
                        let newMentionedPostCount =  Int((NSString(data: newMentionedPostCountData, encoding: NSUTF8StringEncoding)! as String))!
                        if newMentionedPostCount != 0 {
                            ((self.tabBarController?.tabBar.items as! NSArray).objectAtIndex(1) as! UITabBarItem).title = "我 New"
                        }
                    }
                }
            }
        }
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.myTags.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        if isRefreshData {
            feedList = NSArray()
            clearFeedLocalTable()
            previousFeedFetchTimeStamp = Int(NSDate().timeIntervalSince1970*1000)
            self.getMorePreviousFeeds()
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var numberOfRows:Int = 0
        switch section{
        case 0:
            numberOfRows = 1
            break
        case 1:
            numberOfRows = feedList.count
            break
        default:
            numberOfRows = 0
            break
        }
        return numberOfRows
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated);
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("feedsHeader", forIndexPath: indexPath) 
            cell.backgroundColor = UIColor.whiteColor()
            let clinicTrailButton = UIButton(frame: CGRectMake(0, 0, cell.frame.width, cell.frame.height))
            clinicTrailButton.titleLabel?.font = UIFont(name: fontStr, size: 12.0)
            clinicTrailButton.setTitleColor(UIColor.grayColor(), forState: UIControlState.Normal)
            clinicTrailButton.titleLabel?.textAlignment = NSTextAlignment.Center
            let underlineAttribute = [NSUnderlineStyleAttributeName: NSUnderlineStyle.StyleSingle.rawValue]
            let underlineAttributedString = NSAttributedString(string: "想找到最适合自己的临床信息？请点击这里", attributes: underlineAttribute)
            clinicTrailButton.setAttributedTitle(underlineAttributedString, forState: UIControlState.Normal)
            clinicTrailButton.addTarget(self, action: "selectClinicTrail", forControlEvents: UIControlEvents.TouchUpInside)
            cell.addSubview(clinicTrailButton)
            return cell
        }else{
            let cell = tableView.dequeueReusableCellWithIdentifier("feedCell", forIndexPath: indexPath) as! FeedTableViewCell
            cell.removeAllSubviews()

            //separatorLine
            let separatorLine:UIImageView = UIImageView(frame: CGRectMake(0, 0, tableView.frame.size.width-1.0, 3.0))
            separatorLine.image = UIImage(named: "grayline.png")?.stretchableImageWithLeftCapWidth(1, topCapHeight: 0)
            var feed = NSDictionary()
            if(feedList[indexPath.row] is NSManagedObject){
                let keys = Array(feedList[indexPath.row].entity.attributesByName.keys)
                let feedDic = (feedList[indexPath.row] as! NSManagedObject).dictionaryWithValuesForKeys(keys)
                feed = feedDic
                let mutableFeed: NSMutableDictionary = feed.mutableCopy() as! NSMutableDictionary
                if (feed["hasImage"] != nil) && ((feed["hasImage"] is NSNull) == false) && ((feed["hasImage"] as! Int) > 0){
                    let postImageList = NSMutableArray()
                    for var index = 1; index <= (feed["hasImage"] as! Int); ++index{
                        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] 
                        let indexStr: String = (index as NSNumber).stringValue
                        let fileNameStr: String = (feed["postID"] as! NSNumber).stringValue + "." + indexStr + ".small" + ".jpg"
                        let fileManager = NSFileManager.defaultManager()
                        let fileData = fileManager.contentsAtPath(paths + fileNameStr)
                        if fileData != nil{
                            postImageList.addObject(fileData!)
                        }
                    }
                    mutableFeed.setObject(postImageList, forKey: "postImageList")
                    feed = mutableFeed
                }
            }else{
                feed = feedList[indexPath.row] as! NSDictionary
            }
            
            cell.imageTapDelegate = self
            cell.feedBodyDelegate = self
            cell.width = cell.frame.width
            cell.indexPath = indexPath
            cell.feed = feed
            cell.addSubview(separatorLine)

            return cell
        }
    }
    
    func selectClinicTrail(){
        self.performSegueWithIdentifier("showClinicTrailSegue", sender: self)
    }
    
    func imageTap(username: String) {
        print(username)
        selectedProfileOwnername = username
        if self.username != nil{
            let storyboard = UIStoryboard(name: "User", bundle: nil)
            let controller = storyboard.instantiateViewControllerWithIdentifier("UserContent") as! UserProfileViewController
            controller.profileOwnername = selectedProfileOwnername
            self.navigationController?.pushViewController(controller, animated: true)
        }else{
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let controller = storyboard.instantiateViewControllerWithIdentifier("LoginEntry") as UIViewController
            
            self.presentViewController(controller, animated: true, completion: nil)
        }
    }
    
    func setFeedBodyHeight(height: CGFloat, indexpath: NSIndexPath) {
        self.heightForFeedRow.setObject(height, forKey: indexpath)
    }
    
    var feed = NSDictionary()
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 1 {
            if(feedList[indexPath.row] is NSManagedObject){
                let keys = Array(feedList[indexPath.row].entity.attributesByName.keys)
                let feedDic = feedList[indexPath.row].dictionaryWithValuesForKeys(keys)
                feed = feedDic
            }else{
                feed = feedList[indexPath.row] as! NSDictionary
            }
            self.performSegueWithIdentifier("postDetailSegue", sender: self)
        }

    }
    
    override func tableView(_tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat{
        var rowHeight:CGFloat
        switch indexPath.section{
        case 0: rowHeight = 28
            break
        case 1:
            if self.heightForFeedRow.objectForKey(indexPath) != nil{
            rowHeight = (self.heightForFeedRow.objectForKey(indexPath) as! CGFloat) + 110
            }else{
                rowHeight = 40
            }
            break
        default:rowHeight = 0
            break
        }
        return rowHeight
    }
    
    override func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        print(self.tableView.contentSize, terminator: "")
        print(self.tableView.contentOffset.y + self.tableView.frame.height)
        if (self.tableView.contentOffset.y + self.tableView.frame.height) >  self.tableView.contentSize.height{
            print("load more")
            getMorePreviousFeeds()
        }
    }
    
    func updateUserTagList(selectTags: NSArray) {
        self.selectTags = selectTags
        let userData = NSUserDefaults.standardUserDefaults()
        userData.setObject(selectTags, forKey: favTagsNSUserData)
        isRefreshData = true
    }
    
    func gestureRecognizer(_: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWithGestureRecognizer:UIGestureRecognizer) -> Bool {
            return true
    }
}
