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
    
    @IBAction func selectTags(sender: UIButton) {
        self.performSegueWithIdentifier("showTagsSegue", sender: self)
    }
    
    @IBAction func discover(sender: UIButton) {
        self.performSegueWithIdentifier("discoverSegue", sender: self)
    }
    
    @IBAction func addPopover(sender: UIButton) {
        if username != nil{
            self.performSegueWithIdentifier("addViewSegue", sender: self)
        }else{
            self.performSegueWithIdentifier("loginSegue", sender: self)
        }
    }
    
    @IBAction func addActionPopover(sender: UIBarButtonItem) {
        self.performSegueWithIdentifier("addViewSegue", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "addViewSegue"{
            var vc = segue.destinationViewController as! UIViewController
            var controller = vc.popoverPresentationController
            if controller != nil{
                controller?.delegate = self
            }
        }
        if segue.identifier == "postDetailSegue" {
            (segue.destinationViewController as! ShowPostDetailTableViewController).post = feed
        }
        if segue.identifier == "showPatientProfileSegue" {
            (segue.destinationViewController as! UserProfileViewController).profileOwnername = selectedProfileOwnername
        }
        if segue.identifier == "showTagsSegue" {
            (segue.destinationViewController as! TagTableViewController).userTagDelegate = self
        }
    }
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return .None
    }
    
    @IBOutlet weak var myTags: UIButton!
    
    @IBAction func tags(sender: UIButton) {
        println("click tag button")
    }
    func getexistFeedsFromLocalDB(){
        var appDel:AppDelegate = (UIApplication.sharedApplication().delegate as! AppDelegate)
        var context:NSManagedObjectContext = appDel.managedObjectContext!
        var postsRequest = NSFetchRequest(entityName: "Feed")
        if username != nil{
            postsRequest.predicate = NSPredicate(format: "ownerName = %@", username!)
        }else{
            postsRequest.predicate = NSPredicate(format: "ownerName = %@", "")
        }
        postsRequest.returnsObjectsAsFaults = false
        postsRequest.sortDescriptors = [NSSortDescriptor(key: "dateInserted", ascending: false)]
        feedList = context.executeFetchRequest(postsRequest, error: nil)!
    }
    
    func clearFeedLocalTable(){
        var appDel:AppDelegate = (UIApplication.sharedApplication().delegate as! AppDelegate)
        var context:NSManagedObjectContext = appDel.managedObjectContext!
        var deletePostsRequet = NSFetchRequest(entityName: "Feed")
        if username != nil{
            deletePostsRequet.predicate = NSPredicate(format: "ownerName = %@", username!)
        }else{
            deletePostsRequet.predicate = NSPredicate(format: "ownerName = %@", "")
        }
        if let results = context.executeFetchRequest(deletePostsRequet, error: nil) {
            for param in results {
                context.deleteObject(param as! NSManagedObject);
            }
        }
        context.save(nil)
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
            var genderKey = (feed.valueForKey("gender")!) as! String
            profileStr += (genderMapping.allKeysForObject(genderKey)[0] as! String) + ","
        }
        if((feed.valueForKey("age") != nil) && ((feed.valueForKey("age") is NSNull) == false)){
            profileStr += (feed.valueForKey("age")!.stringValue) + ","
        }
        if((feed.valueForKey("cancerType") != nil) && ((feed.valueForKey("cancerType") is NSNull) == false)){
            if(feed.valueForKey("cancerType") as! String != "lung"){
                var cancerTypeKey = feed.valueForKey("cancerType")!
                profileStr += cancerTypeMapping.allKeysForObject(cancerTypeKey)[0] as! String
            }else if((feed.valueForKey("pathological") != nil) && ((feed.valueForKey("pathological") is NSNull) == false) && (feed.valueForKey("pathological") as! String != "")){
                
                profileStr += pathologicalMapping.allKeysForObject(feed.valueForKey("pathological")!)[0] as! String
            }
        }
        feed.setValue(profileStr, forKey: "patientProfile")
    }
    
    func addFeedslist(feedArray: NSArray, isLoadLatestFeeds: Bool){
        var newFeedList:NSMutableArray = feedArray as! NSMutableArray
        
        var appDel:AppDelegate = (UIApplication.sharedApplication().delegate as! AppDelegate)
        var context:NSManagedObjectContext = appDel.managedObjectContext!
        for feed in newFeedList{
            if (((feed as! NSDictionary)["postID"] as! Int) == ((newFeedList[newFeedList.count - 1] as! NSDictionary)["postID"] as! Int)) && (isLoadLatestFeeds == false) {
                println(feed["dateInserted"])
                previousFeedFetchTimeStamp = feed["dateInserted"] as! Int - 1000
                println(previousFeedFetchTimeStamp)
            }
            setPatientProfile(feed as! NSDictionary)
            var feedItem = NSEntityDescription.insertNewObjectForEntityForName("Feed", inManagedObjectContext: context) as! NSManagedObject
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
                            let imageData: NSData = NSData(base64EncodedString: dataString, options: NSDataBase64DecodingOptions(0))!
                            let fileManager = NSFileManager.defaultManager()
                            var paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as! String
                            var indexStr: String = (index as! NSNumber).stringValue
                            var fileNameStr: String = (feed["postID"] as! NSNumber).stringValue + "." + indexStr + ".small" + ".jpg"
                            var filePathToWrite = "\(paths)/" + fileNameStr
                            fileManager.createFileAtPath(filePathToWrite, contents: imageData, attributes: nil)
                            var getImagePath = paths.stringByAppendingPathComponent(fileNameStr)
                            println(getImagePath)
                            if (fileManager.fileExistsAtPath(getImagePath))
                            {
                                println("FILE AVAILABLE");
                            }
                            else
                            {
                                println("FILE NOT AVAILABLE");
                                
                            }
                            index++
                        }
                    }
                }
            }
            context.save(nil)
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
//        var getFeedsByTagsData = haalthyService.getFeeds(latestFeedFetchTimeStamp)
        println(Int(NSDate().timeIntervalSince1970*100000))
        var getFeedsData = haalthyService.getFeeds(latestFeedFetchTimeStamp)
        latestFeedFetchTimeStamp = Int(NSDate().timeIntervalSince1970*1000)
//        var getFeedsByTagsData = haalthyService.getPreviousFeeds(latestFeedFetchTimeStamp, count: 10)
        println(NSDate().timeIntervalSince1970)
        var jsonResult:AnyObject? = nil
        if getFeedsData != nil{
            jsonResult = NSJSONSerialization.JSONObjectWithData(getFeedsData!, options: NSJSONReadingOptions.MutableContainers, error: nil)
            let str: NSString = NSString(data: getFeedsData!, encoding: NSUTF8StringEncoding)!
            println(str)
        }
        refreshControl?.endRefreshing()
        if((jsonResult is NSArray) && (jsonResult as! NSArray).count > 0){
            //save Feed to local DB
//            let profileSet = NSUserDefaults.standardUserDefaults()
//            profileSet.setObject(NSDate().timeIntervalSince1970, forKey: latestFeedsUpdateTimestamp)
            addFeedslist(jsonResult as! NSArray, isLoadLatestFeeds: true)
            
        }else{
            println("get broadcast error")
        }
    }
    
    func getMorePreviousFeeds(){
        var getFeedsData = haalthyService.getPreviousFeeds(previousFeedFetchTimeStamp, count: 20)
        var jsonResult:AnyObject? = nil
        if getFeedsData != nil{
            jsonResult = NSJSONSerialization.JSONObjectWithData(getFeedsData!, options: NSJSONReadingOptions.MutableContainers, error: nil)
            let str: NSString = NSString(data: getFeedsData!, encoding: NSUTF8StringEncoding)!
            println(str)
        }
        if(jsonResult is NSArray){
            addFeedslist(jsonResult as! NSArray, isLoadLatestFeeds: false)
            
        }else{
            println("get feeds error")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.backgroundColor = headerColor
        
        var keychainAccess = KeychainAccess()
        
        username = keychainAccess.getPasscode(usernameKeyChain) as? String
        password = keychainAccess.getPasscode(passwordKeyChain) as? String
        var getUpdatePostCountData = haalthyService.getUpdatedPostCount(0)
//        var getUpdatePostCountData:NSData? = nil
        var jsonResult:AnyObject? = nil
        var postCount:Int = 0
        if getUpdatePostCountData != nil{
            jsonResult = NSJSONSerialization.JSONObjectWithData(getUpdatePostCountData!, options: NSJSONReadingOptions.MutableContainers, error: nil)
            postCount = (NSString(data: getUpdatePostCountData!, encoding: NSUTF8StringEncoding)! as String).toInt()!
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
            var newFollowerCountData: NSData? = haalthyService.selectNewFollowCount()
            if newFollowerCountData != nil {
                var jsonResult = NSJSONSerialization.JSONObjectWithData(newFollowerCountData!, options: NSJSONReadingOptions.MutableContainers, error: nil)
                if jsonResult is NSDictionary {
                    var newFollowerCountStr = ((jsonResult as! NSDictionary).objectForKey("count") as! NSNumber).stringValue
                    if newFollowerCountStr != "0" {
                        ((self.tabBarController?.tabBar.items as! NSArray).objectAtIndex(1) as! UITabBarItem).title = "我 New"
                    }else{
                        var newMentionedPostCountData: NSData = haalthyService.getUnreadMentionedPostCount()!
                        var newMentionedPostCount =  (NSString(data: newMentionedPostCountData, encoding: NSUTF8StringEncoding)! as String).toInt()!
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
            let cell = tableView.dequeueReusableCellWithIdentifier("feedsHeader", forIndexPath: indexPath) as! FeedsHeaderTableViewCell
            cell.backgroundColor = UIColor.whiteColor()
            var clinicTrailButton = UIButton(frame: CGRectMake(0, 0, cell.frame.width, cell.frame.height))
//            clinicTrailButton.setTitle("想找到最适合自己的临床信息？请点击这里", forState: UIControlState.Normal)
            clinicTrailButton.titleLabel?.font = UIFont(name: fontStr, size: 12.0)
            clinicTrailButton.setTitleColor(UIColor.grayColor(), forState: UIControlState.Normal)
            clinicTrailButton.titleLabel?.textAlignment = NSTextAlignment.Center
            let underlineAttribute = [NSUnderlineStyleAttributeName: NSUnderlineStyle.StyleSingle.rawValue]
            let underlineAttributedString = NSAttributedString(string: "想找到最适合自己的临床信息？请点击这里", attributes: underlineAttribute)
//            clinicTrailButton.titleLabel?.attributedText = underlineAttributedString
            clinicTrailButton.setAttributedTitle(underlineAttributedString, forState: UIControlState.Normal)
            clinicTrailButton.addTarget(self, action: "selectClinicTrail", forControlEvents: UIControlEvents.TouchUpInside)
            cell.addSubview(clinicTrailButton)
            return cell
        }else{
            let cell = tableView.dequeueReusableCellWithIdentifier("feedCell", forIndexPath: indexPath) as! FeedTableViewCell
            cell.removeAllSubviews()

            //separatorLine
            var separatorLine:UIImageView = UIImageView(frame: CGRectMake(0, 0, tableView.frame.size.width-1.0, 3.0))
            separatorLine.image = UIImage(named: "grayline.png")?.stretchableImageWithLeftCapWidth(1, topCapHeight: 0)
            var feed = NSDictionary()
            if(feedList[indexPath.row] is NSManagedObject){
                var keys = feedList[indexPath.row].entity.attributesByName.keys.array
                let feedDic = feedList[indexPath.row].dictionaryWithValuesForKeys(keys)
                feed = feedDic
                var mutableFeed: NSMutableDictionary = feed.mutableCopy() as! NSMutableDictionary
                if (feed["hasImage"] != nil) && ((feed["hasImage"] is NSNull) == false) && ((feed["hasImage"] as! Int) > 0){
                    var postImageList = NSMutableArray()
                    for var index = 1; index <= (feed["hasImage"] as! Int); ++index{
                        var paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as! String
                        var indexStr: String = (index as! NSNumber).stringValue
                        var fileNameStr: String = (feed["postID"] as! NSNumber).stringValue + "." + indexStr + ".small" + ".jpg"
                        let fileManager = NSFileManager.defaultManager()
                        println(paths.stringByAppendingPathComponent(fileNameStr))
                        var fileData = fileManager.contentsAtPath(paths.stringByAppendingPathComponent(fileNameStr))
//                        var fileDataStr = NSString(data: fileData!, encoding: NSUTF8StringEncoding)
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
        println(username)
        selectedProfileOwnername = username
        if self.username != nil{
            self.performSegueWithIdentifier("showPatientProfileSegue", sender: self)
        }else{
            self.performSegueWithIdentifier("loginSegue", sender: self)
        }
    }
    
    func setFeedBodyHeight(height: CGFloat, indexpath: NSIndexPath) {
        self.heightForFeedRow.setObject(height, forKey: indexpath)
    }
    
    var feed = NSDictionary()
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 1 {
            if(feedList[indexPath.row] is NSManagedObject){
                var keys = feedList[indexPath.row].entity.attributesByName.keys.array
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
//        case 1: rowHeight = UITableViewAutomaticDimension
            break
        default:rowHeight = 0
            break
        }
        return rowHeight
    }
    
    override func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        print(self.tableView.contentSize)
        println(self.tableView.contentOffset.y + self.tableView.frame.height)
        if (self.tableView.contentOffset.y + self.tableView.frame.height) >  self.tableView.contentSize.height{
            println("load more")
            getMorePreviousFeeds()
        }
    }
    
    
//    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
//        return UITableViewAutomaticDimension
//    }
    func updateUserTagList(selectTags: NSArray) {
        self.selectTags = selectTags
        let userData = NSUserDefaults.standardUserDefaults()
        userData.setObject(selectTags, forKey: favTagsNSUserData)
        isRefreshData = true
    }
    
    func gestureRecognizer(UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWithGestureRecognizer:UIGestureRecognizer) -> Bool {
            return true
    }
    
    
//    override func tableView (tableView:UITableView,  viewForHeaderInSection section:Int)->UIView {
//        var viewForHeader = UIView()
//        if section == 0{
//            viewForHeader.frame = CGRectMake(0, 0, self.tableView.frame.width, 25)
//            var titleLabel = UILabel(frame: CGRectMake(5, 2.5, 90, 20))
//            titleLabel.text = "为您推荐"
//            titleLabel.font = UIFont(name: fontStr, size: 13.0)
//            var closeButton = UIButton(frame: CGRectMake(self.tableView.frame.width - 25, 2.5, 20, 20))
//            closeButton.backgroundColor = mainColor
//            viewForHeader.addSubview(titleLabel)
//            viewForHeader.addSubview(closeButton)
//        }
//        if section == 1{
//            viewForHeader.frame = CGRectMake(0, 0, self.tableView.frame.width, 5)
//        }
//        viewForHeader.backgroundColor = UIColor.whiteColor()
//        return viewForHeader
//    }
//    
//    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        var heightForHeader: CGFloat = 0.0
//        switch section {
//        case 0:
//            heightForHeader = 25
//            break
//        case 1:
//            heightForHeader = 5
//            break
//        default:
//            break
//        }
//        return heightForHeader
//    }
}
