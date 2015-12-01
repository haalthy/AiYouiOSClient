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
        let getAccessToken = GetAccessToken()
        getAccessToken.getAccessToken()
        let accessToken = NSUserDefaults.standardUserDefaults().objectForKey(accessNSUserData)
        if accessToken == nil{
            let storyboard = UIStoryboard(name: "Registeration", bundle: nil)
            let controller = storyboard.instantiateViewControllerWithIdentifier("LoginEntry") as UIViewController
            
            self.presentViewController(controller, animated: true, completion: nil)
        }else{
            let storyboard = UIStoryboard(name: "Add", bundle: nil)
            let popController = (storyboard.instantiateViewControllerWithIdentifier("AddPost") as! AddPostViewController)
            popController.postID = self.post.objectForKey("postID") as? Int
            popController.isComment = 1
            self.presentViewController(popController, animated: true, completion: nil)
        }
    }

    
    func savePostData() {
        let appDel: AppDelegate = (UIApplication.sharedApplication().delegate as! AppDelegate)
        let context: NSManagedObjectContext = appDel.managedObjectContext!
        
        let fetchRequest = NSFetchRequest(entityName: entity)
        fetchRequest.predicate = NSPredicate(format: "postID = %d", post.objectForKey("postID") as! Int)
        if let fetchResults = (try? appDel.managedObjectContext!.executeFetchRequest(fetchRequest)) as? [NSManagedObject] {
            print(fetchResults.count)
            for (var index = 0; index<fetchResults.count; index++){
                let managedObject = fetchResults[index]
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
                do {
                    try context.save()
                } catch _ {
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if postId != nil{
            let getPostByIdData = haalthyService.getPostById(postId!)
            let jsonResult = try? NSJSONSerialization.JSONObjectWithData(getPostByIdData, options: NSJSONReadingOptions.MutableContainers)
            if(jsonResult is NSDictionary){
                self.post = jsonResult as! NSDictionary
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "addCommentSegue" {
            let destinationVC = segue.destinationViewController as! AddPostViewController
            destinationVC.postID = self.post.objectForKey("postID") as? Int
            destinationVC.isComment = 1
        }
    }

    
    override func viewWillAppear(animated: Bool) {
        self.tabBarController?.tabBar.hidden = true
        self.navigationController?.toolbarHidden = false
    }
    
    override func viewDidAppear(animated: Bool) {
        let getCommentsRespData = haalthyService.sendSyncGetCommentListRequest(post.objectForKey("postID") as! Int)
        let str: NSString = NSString(data: getCommentsRespData, encoding: NSUTF8StringEncoding)!
        print(str)
        let jsonResult = try? NSJSONSerialization.JSONObjectWithData(getCommentsRespData, options: NSJSONReadingOptions.MutableContainers)
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
            cell.removeAllSubviews()
            cell.isDetail = true
            cell.feedBodyDelegate = self
            cell.width = cell.frame.width
            cell.indexPath = indexPath
            cell.feed = post
            return cell
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
        let keyChainAcess = KeychainAccess()
        if keyChainAcess.getPasscode(usernameKeyChain) != nil{
            let storyboard = UIStoryboard(name: "User", bundle: nil)
            let controller = storyboard.instantiateViewControllerWithIdentifier("UserContent") as! UserProfileViewController
            controller.profileOwnername = selectedProfileOwnername
            self.navigationController?.pushViewController(controller, animated: true)
        }else{
            let storyboard = UIStoryboard(name: "Registeration", bundle: nil)
            let controller = storyboard.instantiateViewControllerWithIdentifier("LoginEntry") as UIViewController
            
            self.presentViewController(controller, animated: true, completion: nil)
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
