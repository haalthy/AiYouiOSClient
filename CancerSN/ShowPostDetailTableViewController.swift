//
//  ShowPostDetailTableViewController.swift
//  CancerSN
//
//  Created by lily on 8/1/15.
//  Copyright (c) 2015 lily. All rights reserved.
//

import UIKit
import CoreData

class ShowPostDetailTableViewController: UITableViewController, FeedBodyDelegate {
    
    @IBOutlet weak var addCommentToolbar: UIToolbar!
    
    var post : NSDictionary = NSDictionary()
    var commentList : NSArray = NSArray()
    let entity: String = "Broadcast"
    var selectedProfileOwnername = String()
    var haalthyService = HaalthyService()
    var heightForFeedRow:CGFloat = 0
    var postId:Int?
    
    @IBAction func addCommentView(sender: UIBarButtonItem) {
        var getAccessToken = GetAccessToken()
        getAccessToken.getAccessToken()
        let accessToken = NSUserDefaults.standardUserDefaults().objectForKey(accessNSUserData)
        if accessToken == nil{
            self.performSegueWithIdentifier("loginSegue", sender: self)
        }else{
            self.performSegueWithIdentifier("addCommentSegue", sender: self)
        }
    }

    
    func savePostData() {
        var appDel: AppDelegate = (UIApplication.sharedApplication().delegate as! AppDelegate)
        var context: NSManagedObjectContext = appDel.managedObjectContext!
        
        var fetchRequest = NSFetchRequest(entityName: entity)
        fetchRequest.predicate = NSPredicate(format: "postID = %d", post.objectForKey("postID") as! Int)
        if let fetchResults = appDel.managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [NSManagedObject] {
            println(fetchResults.count)
            for (var index = 0; index<fetchResults.count; index++){
                var managedObject = fetchResults[index]
                managedObject.setValue(post.objectForKey("body"), forKey: "body")
                managedObject.setValue(post.objectForKey("tags"), forKey: "tags")
                managedObject.setValue(post.objectForKey("countComments"), forKey: "countComments")
                managedObject.setValue(post.objectForKey("countBookmarks"), forKey: "countBookmarks")
                managedObject.setValue(post.objectForKey("countViews"), forKey: "countViews")
                managedObject.setValue(post.objectForKey("closed"), forKey: "closed")
                managedObject.setValue(post.objectForKey("dateUpdated"), forKey: "dateUpdated")
                if( ((post.objectForKey("image")) is NSNull) == false ){
                    managedObject.setValue(post.objectForKey("image"), forKey: "image")
                }
                context.save(nil)
            }
        }
    }
    
    @IBAction func addComment(sender: UIButton) {
        self.performSegueWithIdentifier("addCommentSegue", sender: self)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if postId != nil{
            var getPostByIdData = haalthyService.getPostById(postId!)
            var jsonResult = NSJSONSerialization.JSONObjectWithData(getPostByIdData, options: NSJSONReadingOptions.MutableContainers, error: nil)
            if(jsonResult is NSDictionary){
                self.post = jsonResult as! NSDictionary
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "addCommentSegue" {
            var destinationVC = segue.destinationViewController as! AddPostViewController
            destinationVC.postID = self.post.objectForKey("postID") as! Int
            destinationVC.isComment = 1
        }
        if segue.identifier == "showPatientProfileSegue"{
            (segue.destinationViewController as! UserProfileViewController).profileOwnername = selectedProfileOwnername
        }
    }

    
    override func viewWillAppear(animated: Bool) {
        self.tabBarController?.tabBar.hidden = true
        self.navigationController?.toolbarHidden = false
    }
    
    override func viewDidAppear(animated: Bool) {
        var getCommentsRespData = haalthyService.sendSyncGetCommentListRequest(post.objectForKey("postID") as! Int)
        let str: NSString = NSString(data: getCommentsRespData, encoding: NSUTF8StringEncoding)!
        println(str)
        var jsonResult = NSJSONSerialization.JSONObjectWithData(getCommentsRespData, options: NSJSONReadingOptions.MutableContainers, error: nil)
        if(jsonResult is NSArray){
            commentList = jsonResult as! NSArray
        }
        self.tableView.reloadData()
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.tabBarController?.tabBar.hidden = false
        self.navigationController?.toolbarHidden = true
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
        var numberOfRowsInSection: Int = 0
        switch section{
        case 0:
            numberOfRowsInSection = 1
            break
        case 1:
            numberOfRowsInSection = commentList.count
            break
        default:
            numberOfRowsInSection = 0
            break
        }
        
        return numberOfRowsInSection
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if(indexPath.section == 0){
        let cell = tableView.dequeueReusableCellWithIdentifier("postIdentifier", forIndexPath: indexPath) as! FeedTableViewCell
//            cell.post = self.post
            cell.removeAllSubviews()
            
//            cell.imageTapDelegate = self
            cell.feedBodyDelegate = self
            cell.width = cell.frame.width
            cell.indexPath = indexPath
            cell.feed = post
            return cell
        // Configure the cell...
        }else{
            let cell = tableView.dequeueReusableCellWithIdentifier("commentListIdentifier", forIndexPath: indexPath) as! CommentListTableViewCell
            cell.comment = self.commentList[indexPath.row] as! NSDictionary
            return cell
        }
    }
    
    func setFeedBodyHeight(height: CGFloat, indexpath: NSIndexPath) {
        self.heightForFeedRow = height
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0{
            selectedProfileOwnername = post.objectForKey("insertUsername") as! String
        }else if indexPath.section == 1{
            selectedProfileOwnername = (commentList[indexPath.row] as! NSDictionary).objectForKey("insertUsername") as! String
        }
        var keyChainAcess = KeychainAccess()
        if keyChainAcess.getPasscode(usernameKeyChain) != nil{
            self.performSegueWithIdentifier("showPatientProfileSegue", sender: self)
        }else{
            self.performSegueWithIdentifier("loginSegue", sender: self)
        }
    }
    
    
    override func tableView(_tableView: UITableView,
        heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat{
            if indexPath.section == 0{
                return heightForFeedRow + 110
            }else{
                return UITableViewAutomaticDimension
            }
    }
    
    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 5.0
    }
    
}
