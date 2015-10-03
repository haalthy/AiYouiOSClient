//
//  ShowPostDetailTableViewController.swift
//  CancerSN
//
//  Created by lily on 8/1/15.
//  Copyright (c) 2015 lily. All rights reserved.
//

import UIKit
import CoreData

class ShowPostDetailTableViewController: UITableViewController {
    
    @IBOutlet weak var addCommentToolbar: UIToolbar!
    
    var post : NSDictionary = NSDictionary()
    var commentList : NSArray = NSArray()
    let entity: String = "Broadcast"
    var selectedProfileOwnername = String()

    
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
    func sendSyncGetCommentListRequest()->NSData{
        let url : NSURL = NSURL(string: getCommentListByPostURL+((post.objectForKey("postID") as! NSNumber).stringValue))!
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "GET"
        var response: AutoreleasingUnsafeMutablePointer<NSURLResponse?> = nil
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        var getCommentsRespData = NSURLConnection.sendSynchronousRequest(request, returningResponse: response, error: nil)
        return getCommentsRespData!
    }
    
    func sendSyncGetPostRequest()->NSData{
        let url : NSURL = NSURL(string: getPostByIdURL + ((post.objectForKey("postID") as! NSNumber).stringValue))!
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "GET"
        var response: AutoreleasingUnsafeMutablePointer<NSURLResponse?> = nil
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        var getPostRespData = NSURLConnection.sendSynchronousRequest(request, returningResponse: response, error: nil)
        return getPostRespData!
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
        //add Toolbar
//        addCommentToolbar.center = CGPoint(x: 200, y: 300)
//        var toolBar = UIToolbar(frame: CGRectMake(0, UIScreen.mainScreen().bounds.height - 45 - UIApplication.sharedApplication().statusBarFrame.size.height, 300, 50))
//        toolBar.barStyle = UIBarStyle.Default
//        toolBar.translucent = true
//        toolBar.tintColor = UIColor.lightGrayColor()//UIColor(red: 76/255, green: 217/255, blue: 100/255, alpha: 1)
//        var flexibleItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: self, action: "addCommentView")
//
//        var addCommentButton = UIBarButtonItem(title: "添加评论", style: UIBarButtonItemStyle.Plain, target: self, action: "addCommentView")
//        toolBar.setItems([flexibleItem, addCommentButton, flexibleItem], animated: false)
//        toolBar.userInteractionEnabled = true
//        toolBar.sizeToFit()
//        
//        self.navigationController?.navigationBar.addSubview(toolBar)
        

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
/*        super.viewDidAppear(animated)
        var getPostByIdRespData = self.sendSyncGetPostRequest()
        let postJsonResult = NSJSONSerialization.JSONObjectWithData(getPostByIdRespData, options: NSJSONReadingOptions.MutableContainers, error: nil)
        if postJsonResult is NSDictionary{
            var postDic = postJsonResult as! NSDictionary
            if ((postDic.objectForKey("postID") as! Int) == (post.objectForKey("postID") as! Int)){
                post = postDic
            }
        }
        savePostData()*/
        var getCommentsRespData = self.sendSyncGetCommentListRequest()
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
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
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
        let cell = tableView.dequeueReusableCellWithIdentifier("postConentIdentifier", forIndexPath: indexPath) as! PostContentTableViewCell
            cell.post = self.post
            return cell
        // Configure the cell...
        }else{
            let cell = tableView.dequeueReusableCellWithIdentifier("commentListIdentifier", forIndexPath: indexPath) as! CommentListTableViewCell
            cell.comment = self.commentList[indexPath.row] as! NSDictionary
            return cell
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0{
            selectedProfileOwnername = post.objectForKey("insertUsername") as! String
        }else if indexPath.section == 1{
            selectedProfileOwnername = (commentList[indexPath.row] as! NSDictionary).objectForKey("insertUsername") as! String
        }
        var keyChainAcess = KeychainAccess()
        if keyChainAcess.getPasscode("username") != nil{
            self.performSegueWithIdentifier("showPatientProfileSegue", sender: self)
        }else{
            self.performSegueWithIdentifier("loginSegue", sender: self)
        }
    }
    
    
    override func tableView(_tableView: UITableView,
        heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat{
            return UITableViewAutomaticDimension
    }
    
    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 5.0
    }
    
}
