//
//  FeedsTableViewController.swift
//  CancerSN
//
//  Created by lily on 7/28/15.
//  Copyright (c) 2015 lily. All rights reserved.
//

import UIKit
import CoreData

class FeedsTableViewController: UITableViewController, UIPopoverPresentationControllerDelegate, UserTagVCDelegate, UIGestureRecognizerDelegate, ImageTapDelegate {
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
        latestFeedFetchTimeStamp = Int(NSDate().timeIntervalSince1970*100000)
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
        var jsonResult:AnyObject? = nil
        var postCount:Int = 0
        if getUpdatePostCountData != nil{
            jsonResult = NSJSONSerialization.JSONObjectWithData(getUpdatePostCountData!, options: NSJSONReadingOptions.MutableContainers, error: nil)
            postCount = (NSString(data: getUpdatePostCountData!, encoding: NSUTF8StringEncoding)! as String).toInt()!
        }
        latestFeedFetchTimeStamp = Int(NSDate().timeIntervalSince1970*100000)
        if postCount == 0{
            self.getexistFeedsFromLocalDB()
        }else{
            clearFeedLocalTable()
            previousFeedFetchTimeStamp = Int(NSDate().timeIntervalSince1970*100000)
            self.getMorePreviousFeeds()
        }
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.myTags.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        if isRefreshData {
            feedList = NSArray()
            clearFeedLocalTable()
            previousFeedFetchTimeStamp = Int(NSDate().timeIntervalSince1970*100000)
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
            return cell
        }else{
//            let cell = tableView.dequeueReusableCellWithIdentifier("feedCell", forIndexPath: indexPath) as! UITableViewCell
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
                //                feedBody.text = (feedDic as! NSDictionary).objectForKey("body") as! String
            }else{
                feed = feedList[indexPath.row] as! NSDictionary
                //                feedBody.text = (feedList[indexPath.row] as! NSDictionary).objectForKey("body") as! String
            }
            cell.feed = feed

            cell.imageTapDelegate = self
            
            //username View
            var usernameLabelView = UILabel(frame: CGRectMake(10 + 32 + 10, 10, cell.frame.width - 10 - 32 - 10 - 80, 20))
            usernameLabelView.font = UIFont(name: "Helvetica-Bold", size: 13.0)
            usernameLabelView.text = feed.valueForKey("insertUsername") as? String
            
            //insert date View
            var insertDateLabelView = UILabel(frame: CGRectMake(cell.frame.width - 90, 10, 80, 20))
            insertDateLabelView.font = UIFont(name: "Helvetica", size: 12.0)
            var dateFormatter = NSDateFormatter()
            var insertedDate = NSDate(timeIntervalSince1970: (feed.valueForKey("dateInserted") as! Double)/1000 as NSTimeInterval)
            dateFormatter.dateFormat = "yyyy-MM-dd" // superset of OP's format
            let insertedDayStr = dateFormatter.stringFromDate(insertedDate)
            let currentDayStr = dateFormatter.stringFromDate(NSDate())
            if(currentDayStr > insertedDayStr){
                dateFormatter.dateFormat = "MM-dd"
                insertDateLabelView.text = dateFormatter.stringFromDate(insertedDate)
            }else{
                dateFormatter.dateFormat = "HH:mm"
                insertDateLabelView.text = dateFormatter.stringFromDate(insertedDate)
            }
            insertDateLabelView.textAlignment = NSTextAlignment.Right
            insertDateLabelView.textColor = UIColor.grayColor()
            
            //
            
            //profile View
            var profileLabelView = UILabel(frame: CGRectMake(10 + 32 + 10, 30, cell.frame.width - 10 - 32 - 10, 12))
            profileLabelView.font = UIFont(name: "Helvetica", size: 11.5)
            profileLabelView.text = feed.valueForKey("patientProfile") as? String
            profileLabelView.textColor = UIColor.grayColor()
            
            //feed type view
            var typeStr = String()
            if (feed.objectForKey("type") != nil) && (feed.objectForKey("type") is NSNull) == false{
                if (feed.objectForKey("type") as!Int) == 0{
                    if (feed.objectForKey("isBroadcast") as! Int) == 1 {
                        typeStr = "提出新问题"
                    }else{
                        typeStr = "分享心情"
                    }
                }
                if (feed.objectForKey("type") as! Int) == 1{
                    typeStr = "添加治疗方案"
                }
                if (feed.objectForKey("type") as! Int) == 2{
                    typeStr = "更新病友状态"
                }
            }
            var typeLabel = UILabel(frame: CGRectMake(10, 50, 80, 25))
            typeLabel.text = typeStr
            typeLabel.backgroundColor = sectionHeaderColor
            typeLabel.font = UIFont(name: fontStr, size: 12.0)
            typeLabel.textAlignment = NSTextAlignment.Center
            
            //feed body view
            var feedBody = UILabel(frame: CGRectMake(10, 80, cell.frame.width - 20, 0))
            if (feed.objectForKey("type") as! Int) != 1{
                feedBody.numberOfLines = 5
                feedBody.lineBreakMode = NSLineBreakMode.ByCharWrapping
                feedBody.font = UIFont(name: "Helvetica", size: 13.0)
                feedBody.text = (feed.objectForKey("body") as! String).stringByReplacingOccurrencesOfString("*", withString: " ", options: NSStringCompareOptions.LiteralSearch, range: nil)
                feedBody.textColor = UIColor.blackColor()
                feedBody.sizeToFit()
                self.heightForFeedRow.setObject(feedBody.frame.height, forKey: indexPath)
            }else if (feed.objectForKey("type") as! Int) == 1{
                var treatmentStr = feed.objectForKey("body") as! String
                var treatmentList: NSMutableArray = NSMutableArray(array: treatmentStr.componentsSeparatedByString("**"))
                for treatment in treatmentList {
                    var treatmentItemStr:String = treatment as! String
                    
                    treatmentItemStr = treatmentItemStr.stringByReplacingOccurrencesOfString("*", withString: "", options:  NSStringCompareOptions.LiteralSearch, range: nil)
                    if (treatmentItemStr as NSString).length == 0{
                        treatmentList.removeObject(treatment)
                    }
                }
                var treatmentY:CGFloat = 0
                for treatment in treatmentList {
                    var treatmentItemStr:String = treatment as! String

                    if (treatmentItemStr as! NSString).length == 0{
                        break
                    }
                    if treatmentItemStr.substringWithRange(Range(start: treatmentItemStr.startIndex, end: advance(treatmentItemStr.startIndex, 1))) == "*" {
                        treatmentItemStr = treatmentItemStr.substringFromIndex(advance(treatmentStr.startIndex, 1))
                    }
                    var treatmentNameAndDosage:NSArray = treatmentItemStr.componentsSeparatedByString("*")
                    var treatmentName = treatmentNameAndDosage[0] as! String
                    var treatmentDosage = String()
                    var treatmentNameLabel = UILabel()
                    var dosageLabel = UILabel()
                    treatmentNameLabel = UILabel(frame: CGRectMake(0.0, treatmentY, 90.0, 28.0))
                    treatmentNameLabel.text = treatmentName
                    treatmentNameLabel.font = UIFont(name: "Helvetica-Bold", size: 13.0)
                    treatmentNameLabel.layer.cornerRadius = 5
                    treatmentNameLabel.backgroundColor = tabBarColor
                    treatmentNameLabel.textColor = mainColor
                    treatmentNameLabel.layer.masksToBounds = true
                    treatmentNameLabel.layer.borderColor = mainColor.CGColor
                    treatmentNameLabel.layer.borderWidth = 1.0
                    treatmentNameLabel.textAlignment = NSTextAlignment.Center
                    if treatmentNameAndDosage.count > 1{
                        treatmentDosage = treatmentNameAndDosage[1] as! String
                        dosageLabel.frame = CGRectMake(100.0, treatmentY, feedBody.frame.width - 105, 0)
                        dosageLabel.text = treatmentDosage
                        dosageLabel.font = UIFont(name: "Helvetica-Bold", size: 12.0)
                        dosageLabel.numberOfLines = 0
                        dosageLabel.sizeToFit()
                        var height:CGFloat = dosageLabel.frame.height > treatmentNameLabel.frame.height ? dosageLabel.frame.height : treatmentNameLabel.frame.height
                        treatmentY += height + 5
                        dosageLabel.textColor = mainColor
                    }else{
                        treatmentY += 30
                    }
                    feedBody.addSubview(treatmentNameLabel)
                    feedBody.addSubview(dosageLabel)
                }
                feedBody.frame = CGRectMake(10, 80, cell.frame.width - 20, treatmentY)
                self.heightForFeedRow.setObject(feedBody.frame.height, forKey: indexPath)
            }
            
            //tagBody
            var tagLabel = UILabel(frame: CGRectMake(10, 80 + feedBody.frame.height + 5, cell.frame.width - 80, 20))
            if (feed.objectForKey("tags") is NSNull) == false{
                tagLabel.font = UIFont(name: "Helvetica", size: 11.5)
                tagLabel.text = "tag:" + (feed.objectForKey("tags") as! NSString).stringByReplacingOccurrencesOfString("*", withString: " ")
                tagLabel.textColor = UIColor.grayColor()
                
            }
            //review View
            var reviewLabel = UILabel(frame: CGRectMake(10 + tagLabel.frame.width, tagLabel.frame.origin.y, 60, 20))
            reviewLabel.font = UIFont(name: "Helvetica", size: 11.5)
            reviewLabel.textAlignment = NSTextAlignment.Right
            reviewLabel.text = feed.valueForKey("countComments")!.stringValue + "评论"
            reviewLabel.textColor = UIColor.grayColor()
            
            cell.addSubview(separatorLine)
//            cell.addSubview(imageView)
            cell.addSubview(usernameLabelView)
            cell.addSubview(insertDateLabelView)
            cell.addSubview(profileLabelView)
            cell.addSubview(feedBody)
            cell.addSubview(tagLabel)
            cell.addSubview(reviewLabel)
            cell.addSubview(typeLabel)

            return cell
        }
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
    func imageTapHandler(sender: UITapGestureRecognizer){
        println("tap")
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
        case 0: rowHeight = 50
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
