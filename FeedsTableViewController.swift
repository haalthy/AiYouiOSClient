//
//  FeedsTableViewController.swift
//  CancerSN
//
//  Created by lily on 7/28/15.
//  Copyright (c) 2015 lily. All rights reserved.
//

import UIKit
import CoreData

class FeedsTableViewController: UITableViewController, UIPopoverPresentationControllerDelegate {
    var username:String?
    var password:String?
    var feedList = NSArray()
    var latestFetchTimestamp = Int()
    var automatedShowDiscoverView:Bool = true
    var heightForFeedRow = NSMutableDictionary()
    
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
        postsRequest.returnsObjectsAsFaults = false
        postsRequest.sortDescriptors = [NSSortDescriptor(key: "dateInserted", ascending: false)]
        feedList = context.executeFetchRequest(postsRequest, error: nil)!
        if feedList.count > 0{
            let feed = feedList[0] as! NSManagedObject
            latestFetchTimestamp = feedList[0].valueForKey("dateInserted") as! Int
        }else{
            latestFetchTimestamp = 0
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
            }else if((feed.valueForKey("pathological") != nil) && ((feed.valueForKey("pathological") is NSNull) == false)){
                
                profileStr += pathologicalMapping.allKeysForObject(feed.valueForKey("pathological")!)[0] as! String
            }
        }
        feed.setValue(profileStr, forKey: "patientProfile")
    }
    
    @IBAction func refreshFeeds(sender: UIRefreshControl) {
        var haalthyService = HaalthyService()
        var getFeedsByTagsData = haalthyService.getFeeds(latestFetchTimestamp)
        var jsonResult:AnyObject? = nil
        if getFeedsByTagsData != nil{
            jsonResult = NSJSONSerialization.JSONObjectWithData(getFeedsByTagsData!, options: NSJSONReadingOptions.MutableContainers, error: nil)
            let str: NSString = NSString(data: getFeedsByTagsData!, encoding: NSUTF8StringEncoding)!
            println(str)
        }
        refreshControl?.endRefreshing()
        if(jsonResult is NSArray){
            //save Feed to local DB
            var newFeedList:NSMutableArray = jsonResult as! NSMutableArray
            
            var appDel:AppDelegate = (UIApplication.sharedApplication().delegate as! AppDelegate)
            var context:NSManagedObjectContext = appDel.managedObjectContext!
            for feed in newFeedList{
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
                feedItem.setValue(username, forKey: "ownerName")
                context.save(nil)
            }
            newFeedList.addObjectsFromArray(feedList as [AnyObject])
            feedList = newFeedList as NSArray
            if feedList.count > 0{
                latestFetchTimestamp = feedList[0].valueForKey("dateInserted") as! Int
            }
            self.tableView.reloadData()
//            if feedList.count == 0{
//                self.performSegueWithIdentifier("discoverSegue", sender: nil)
//            }
            //set timestamp
            let profileSet = NSUserDefaults.standardUserDefaults()
            profileSet.setObject(NSDate().timeIntervalSince1970, forKey: latestFeedsUpdateTimestamp)
        }else{
            println("get broadcast error")
        }
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
//        self.tableView.estimatedRowHeight = UITableViewAutomaticDimension
//        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        var appDel:AppDelegate = (UIApplication.sharedApplication().delegate as! AppDelegate)
        var context:NSManagedObjectContext = appDel.managedObjectContext!
        
        var postsRequest = NSFetchRequest(entityName: "Feed")
        postsRequest.returnsObjectsAsFaults = false
        
        postsRequest.sortDescriptors = [NSSortDescriptor(key: "dateInserted", ascending: false)]
        
        feedList = context.executeFetchRequest(postsRequest, error: nil)!
        
        self.navigationController?.navigationBar.backgroundColor = headerColor
        
//        let search = UIBarButtonItem(title: "search", style: UIBarButtonItemStyle.Plain , target: self, action: "searchAction")
//        let add = UIBarButtonItem(title: "add", style: UIBarButtonItemStyle.Plain , target: self, action: "addAction")
//        let arrBtns = NSArray(array: [search, add])
//        self.navigationItem.rightBarButtonItems = [search, add]
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
//        self.navigationController?.navigationBar.hidden = true
        self.myTags.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
//        self.myTags.setImage(UIImage (named: "mytagsBtnImg.png"), forState: UIControlState.Normal)
//        self.myTags.contentMode = UIViewContentMode.ScaleAspectFill
//        self.tabBarController?.tabBar.barTintColor = tabBarColor
//        self.tabBarController?.tabBar.tintColor = UIColor.whiteColor()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
//        self.navigationController?.navigationBar.hidden = false
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
            numberOfRows = 1;
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
        var keychainAccess = KeychainAccess()
        
        if((keychainAccess.getPasscode(usernameKeyChain) != nil) && (keychainAccess.getPasscode(passwordKeyChain) != nil)){
            //show feeds
            //            keychainAccess.deletePasscode(usernameKeyChain)
            //            keychainAccess.deletePasscode(passwordKeyChain)
           //             self.performSegueWithIdentifier("showSuggestUsersSegue", sender: nil)
            username = keychainAccess.getPasscode(usernameKeyChain) as? String
            password = keychainAccess.getPasscode(passwordKeyChain) as? String
            self.getexistFeedsFromLocalDB()
            if feedList.count == 0 {
                refreshFeeds()
            }
        }else if automatedShowDiscoverView {
            automatedShowDiscoverView = false
            self.performSegueWithIdentifier("discoverSegue", sender: nil)
        }
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("feedsHeader", forIndexPath: indexPath) as! FeedsHeaderTableViewCell
            cell.backgroundColor = headerColor
            return cell
        }else{
            let cell = tableView.dequeueReusableCellWithIdentifier("feedCell", forIndexPath: indexPath) as! UITableViewCell
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
            //imageView
            var imageView = UIImageView(frame: CGRectMake(10, 10, 32, 32))
            if((feed.valueForKey("image") is NSNull) == false){
                let dataString = feed.valueForKey("image") as! String
                let imageData: NSData = NSData(base64EncodedString: dataString, options: NSDataBase64DecodingOptions(0))!
                imageView.image = UIImage(data: imageData)
            }else{
                imageView.image = UIImage(named: "Mario.jpg")
            }
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
            
            //feed body view
            var feedBody = UILabel(frame: CGRectMake(10, 50, cell.frame.width - 20, 80))
            feedBody.numberOfLines = 5
            feedBody.lineBreakMode = NSLineBreakMode.ByCharWrapping
            feedBody.font = UIFont(name: "Helvetica", size: 13.0)
            feedBody.text = feed.objectForKey("body") as! String
            feedBody.textColor = UIColor.blackColor()
            feedBody.sizeToFit()
            self.heightForFeedRow.setObject(feedBody.frame.height, forKey: indexPath)
            
            //tagBody
            var tagLabel = UILabel(frame: CGRectMake(10, 50 + feedBody.frame.height + 5, cell.frame.width - 80, 20))
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
            cell.addSubview(imageView)
            cell.addSubview(usernameLabelView)
            cell.addSubview(insertDateLabelView)
            cell.addSubview(profileLabelView)
            cell.addSubview(feedBody)
            cell.addSubview(tagLabel)
            cell.addSubview(reviewLabel)

            return cell
        }
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
        case 0: rowHeight = 0
            break
        case 1:
            if self.heightForFeedRow.objectForKey(indexPath) != nil{
            rowHeight = (self.heightForFeedRow.objectForKey(indexPath) as! CGFloat) + 80
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
    
//    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
//        return UITableViewAutomaticDimension
//    }
}
