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
    
    var heightForFeedRow:CGFloat = 0
    
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
        let cell = tableView.dequeueReusableCellWithIdentifier("postIdentifier", forIndexPath: indexPath) as! UITableViewCell
//            cell.post = self.post
            cell.removeAllSubviews()
            //imageView
            var imageView = UIImageView(frame: CGRectMake(10, 10, 32, 32))
            if((post.valueForKey("image") is NSNull) == false){
                let dataString = post.valueForKey("image") as! String
                let imageData: NSData = NSData(base64EncodedString: dataString, options: NSDataBase64DecodingOptions(0))!
                imageView.image = UIImage(data: imageData)
            }else{
                imageView.image = UIImage(named: "Mario.jpg")
            }
            var tapImage = UITapGestureRecognizer(target: self, action: Selector("imageTapHandler:"))
            imageView.userInteractionEnabled = true
            imageView.addGestureRecognizer(tapImage)
            //username View
            var usernameLabelView = UILabel(frame: CGRectMake(10 + 32 + 10, 10, cell.frame.width - 10 - 32 - 10 - 80, 20))
            usernameLabelView.font = UIFont(name: "Helvetica-Bold", size: 13.0)
            usernameLabelView.text = post.valueForKey("insertUsername") as? String
            
            //insert date View
            var insertDateLabelView = UILabel(frame: CGRectMake(cell.frame.width - 90, 10, 80, 20))
            insertDateLabelView.font = UIFont(name: "Helvetica", size: 12.0)
            var dateFormatter = NSDateFormatter()
            var insertedDate = NSDate(timeIntervalSince1970: (post.valueForKey("dateInserted") as! Double)/1000 as NSTimeInterval)
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
            profileLabelView.text = post.valueForKey("patientProfile") as? String
            profileLabelView.textColor = UIColor.grayColor()
            
            //feed type view
            var typeStr = String()
            if (post.objectForKey("type") != nil) && (post.objectForKey("type") is NSNull) == false{
                if (post.objectForKey("type") as!Int) == 0{
                    if (post.objectForKey("isBroadcast") as! Int) == 1 {
                        typeStr = "提出新问题"
                    }else{
                        typeStr = "分享心情"
                    }
                }
                if (post.objectForKey("type") as! Int) == 1{
                    typeStr = "添加治疗方案"
                }
                if (post.objectForKey("type") as! Int) == 2{
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
            if (post.objectForKey("type") as! Int) != 1{
                feedBody.numberOfLines = 5
                feedBody.lineBreakMode = NSLineBreakMode.ByCharWrapping
                feedBody.font = UIFont(name: "Helvetica", size: 13.0)
                feedBody.text = post.objectForKey("body") as! String
                feedBody.textColor = UIColor.blackColor()
                feedBody.sizeToFit()
                self.heightForFeedRow = feedBody.frame.height
            }else if (post.objectForKey("type") as! Int) == 1{
                var treatmentStr = post.objectForKey("body") as! String
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
                self.heightForFeedRow = feedBody.frame.height
            }
            
            //tagBody
            var tagLabel = UILabel(frame: CGRectMake(10, 80 + feedBody.frame.height + 5, cell.frame.width - 80, 20))
            if (post.objectForKey("tags") is NSNull) == false{
                tagLabel.font = UIFont(name: "Helvetica", size: 11.5)
                tagLabel.text = "tag:" + (post.objectForKey("tags") as! NSString).stringByReplacingOccurrencesOfString("*", withString: " ")
                tagLabel.textColor = UIColor.grayColor()
                
            }
            //review View
            var reviewLabel = UILabel(frame: CGRectMake(10 + tagLabel.frame.width, tagLabel.frame.origin.y, 60, 20))
            reviewLabel.font = UIFont(name: "Helvetica", size: 11.5)
            reviewLabel.textAlignment = NSTextAlignment.Right
            reviewLabel.text = post.valueForKey("countComments")!.stringValue + "评论"
            reviewLabel.textColor = UIColor.grayColor()
            
            cell.addSubview(imageView)
            cell.addSubview(usernameLabelView)
            cell.addSubview(insertDateLabelView)
            cell.addSubview(profileLabelView)
            cell.addSubview(feedBody)
            cell.addSubview(tagLabel)
            cell.addSubview(reviewLabel)
            cell.addSubview(typeLabel)

            
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
