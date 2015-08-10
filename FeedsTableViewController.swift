//
//  FeedsTableViewController.swift
//  CancerSN
//
//  Created by lily on 7/28/15.
//  Copyright (c) 2015 lily. All rights reserved.
//

import UIKit
import CoreData

class FeedsTableViewController: UITableViewController {
    var username:String?
    var password:String?
    var feedList = NSArray()
    
    func getexistFeedsFromLocalDB(){
        var appDel:AppDelegate = (UIApplication.sharedApplication().delegate as! AppDelegate)
        var context:NSManagedObjectContext = appDel.managedObjectContext!
        var postsRequest = NSFetchRequest(entityName: "Feed")
        postsRequest.returnsObjectsAsFaults = false
        postsRequest.sortDescriptors = [NSSortDescriptor(key: "dateInserted", ascending: false)]
        feedList = context.executeFetchRequest(postsRequest, error: nil)!
    }
    
    func refreshFeeds(){
        if refreshControl != nil{
            refreshControl?.beginRefreshing()
        }
        refreshFeeds(refreshControl!)
    }
    
    @IBAction func refreshFeeds(sender: UIRefreshControl) {
        var haalthyService = HaalthyService()
        var getFeedsByTagsData = haalthyService.getFeeds()
        var jsonResult = NSJSONSerialization.JSONObjectWithData(getFeedsByTagsData, options: NSJSONReadingOptions.MutableContainers, error: nil)
        let str: NSString = NSString(data: getFeedsByTagsData, encoding: NSUTF8StringEncoding)!
        println(str)
        refreshControl?.endRefreshing()
        if(jsonResult is NSArray){
            //save Feed to local DB
            var newFeedList:NSMutableArray = jsonResult as! NSMutableArray
            
            var appDel:AppDelegate = (UIApplication.sharedApplication().delegate as! AppDelegate)
            var context:NSManagedObjectContext = appDel.managedObjectContext!
            for feed in newFeedList{
                var feedItem = NSEntityDescription.insertNewObjectForEntityForName("Feed", inManagedObjectContext: context) as! NSManagedObject
                feedItem.setValue(feed["postID"], forKey: "postID")
                feedItem.setValue(feed["insertUsername"], forKey: "insertUsername")
                feedItem.setValue(feed["countComments"], forKey: "countComments")
                feedItem.setValue(feed["body"], forKey: "body")
                feedItem.setValue(feed["tags"], forKey: "tags")
                feedItem.setValue(feed["countViews"], forKey: "countViews")
                feedItem.setValue(feed["countBookmarks"], forKey: "countBookmarks")
                feedItem.setValue(feed["closed"], forKey: "closed")
                feedItem.setValue(feed["isBroadcast"], forKey: "isBroadcast")
                feedItem.setValue(feed["dateInserted"], forKey: "dateInserted")
                feedItem.setValue(feed["dateUpdated"], forKey: "dateUpdated")
                let imgValue = feed["image"]
                if( ((feed["image"]) is NSNull) == false ){
                    feedItem.setValue(feed["image"], forKey: "image")
                }
                context.save(nil)
            }
            newFeedList.addObjectsFromArray(feedList as [AnyObject])
            feedList = newFeedList as! NSArray
            self.tableView.reloadData()
            //set timestamp
            let profileSet = NSUserDefaults.standardUserDefaults()
            profileSet.setObject(NSDate().timeIntervalSince1970, forKey: latestFeedsUpdateTimestamp)
        }else{
            println("get broadcast error")
        }
        
    }
    
    @IBAction func searchUser(sender: UIButton) {
        self.performSegueWithIdentifier("searchUserSegue", sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        var appDel:AppDelegate = (UIApplication.sharedApplication().delegate as! AppDelegate)
        var context:NSManagedObjectContext = appDel.managedObjectContext!
        
        var postsRequest = NSFetchRequest(entityName: "Feed")
        postsRequest.returnsObjectsAsFaults = false
        
        postsRequest.sortDescriptors = [NSSortDescriptor(key: "dateInserted", ascending: false)]
        
        feedList = context.executeFetchRequest(postsRequest, error: nil)!

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
        }else{
            self.performSegueWithIdentifier("showSuggestUsersSegue", sender: nil)
        }
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("feedsHeader", forIndexPath: indexPath) as! FeedsHeaderTableViewCell
            
            cell.username.text = username
            return cell
        }else{
            let cell = tableView.dequeueReusableCellWithIdentifier("feedsList", forIndexPath: indexPath) as! FeedsListTableViewCell
            if(feedList[indexPath.row] is NSManagedObject){
                var keys = feedList[indexPath.row].entity.attributesByName.keys.array
                let feedDic = feedList[indexPath.row].dictionaryWithValuesForKeys(keys)
                cell.feed = feedDic
            }else{
                cell.feed = feedList[indexPath.row] as! NSDictionary
            }
            return cell
        }
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */
    
    override func tableView(_tableView: UITableView,
        heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat{
            var rowHeight:CGFloat
            switch indexPath.section{
            case 0: rowHeight = 44
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
