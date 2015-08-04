//
//  TagViewController.swift
//  CancerSN
//
//  Created by lily on 7/20/15.
//  Copyright (c) 2015 lily. All rights reserved.
//

import UIKit

protocol TagVCDelegate {
    func updateTagList(data: NSArray)
}

class TagViewController: UITableViewController {
    var delegate: TagVCDelegate?

    var tags: NSArray = []
    
    var selectedTags : NSMutableArray = []
    
    var updateTagsResponseData:NSMutableData = NSMutableData()

    var getTokenResponseData:NSMutableData = NSMutableData()
    
    var data :NSMutableData? = nil
    @IBOutlet var tagList: UITableView!
    
    
    let tagLabelColor: UIColor = UIColor.init(red:0.8, green:0.8, blue:1, alpha:0.65)
    
    let tagSelectedLabelColor : UIColor = UIColor.init(red:0.7, green:0.7, blue:1, alpha:1)

    let submitSelectedColor : UIColor = UIColor.init(red:0.9, green:0.7, blue:1, alpha:1)
    
//    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
//        if (segue.identifier == "showSuggestUsers") {
//            let viewController:UserListTableViewController = segue!.destinationViewController as! UserListTableViewController
//            
//            viewController.tagList = selectedTags
//        }
//    }
    
    func sendUpdateTagsHttpRequest(){
        updateTagsResponseData = NSMutableData()
        let accessToken = NSUserDefaults.standardUserDefaults().objectForKey(accessNSUserData)
        var url: NSURL = NSURL(string: updateFavTagsURL + "?access_token=" + (accessToken as! String))!
        var request: NSMutableURLRequest = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        var tagListDic = NSMutableDictionary()
        tagListDic.setValue(selectedTags, forKey: "tags")
        request.HTTPBody = NSJSONSerialization.dataWithJSONObject(tagListDic, options: NSJSONWritingOptions.allZeros, error: nil)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        println(NSString(data: (request.HTTPBody)!, encoding: NSUTF8StringEncoding)!)
        println(request.HTTPBody)
        var connection: NSURLConnection = NSURLConnection(request: request, delegate: self, startImmediately: true)!
        connection.start()
    }
    
    @IBAction func tagsSubmit(sender: AnyObject) {
        let favtags = NSUserDefaults.standardUserDefaults()
        favtags.setObject(self.selectedTags, forKey: favTagsNSUserData)
        self.delegate?.updateTagList(self.selectedTags)
        
        //update user fav tags on server
        let keychainAccess = KeychainAccess()
        let username = keychainAccess.getPasscode(usernameKeyChain)
        let password = keychainAccess.getPasscode(passwordKeyChain)
        
        let accessToken = NSUserDefaults.standardUserDefaults().objectForKey(accessNSUserData)
        if((username != nil) && (password != nil)){
            if(accessToken != nil){
//                updateTagsResponseData = NSMutableData()
//                var url: NSURL = NSURL(string: updateFavTagsURL + "?access_token=" + (accessToken as! String))!
//                var request: NSMutableURLRequest = NSMutableURLRequest(URL: url)
//                request.HTTPMethod = "POST"
//                request.HTTPBody = NSJSONSerialization.dataWithJSONObject(selectedTags, options: NSJSONWritingOptions.allZeros, error: nil)
//                request.addValue("application/json", forHTTPHeaderField: "Content-Type")
//                request.addValue("application/json", forHTTPHeaderField: "Accept")
//                var connection: NSURLConnection = NSURLConnection(request: request, delegate: self, startImmediately: true)!
//                connection.start()
                sendUpdateTagsHttpRequest()
            }
        }
    }
    
    func connection(connection: NSURLConnection!, didReceiveData data: NSData!){
        let connectionURLStr:NSString = (connection.currentRequest.URL)!.absoluteString!
        if( connectionURLStr.containsString(updateFavTagsURL)){
            updateTagsResponseData.appendData(data)
        }else if(connectionURLStr.containsString(getTagListURL)){
            self.data!.appendData(data)
        }else if(connectionURLStr.containsString(getOauthTokenURL)){
            getTokenResponseData.appendData(data)
        }
    }
    
    func connectionDidFinishLoading(connection: NSURLConnection!)
    {
        let connectionURLStr:NSString = (connection.currentRequest.URL)!.absoluteString!
        if( connectionURLStr.containsString(updateFavTagsURL)){
            let str: NSString = NSString(data: updateTagsResponseData, encoding: NSUTF8StringEncoding)!
            println(str)
            var jsonResult = NSJSONSerialization.JSONObjectWithData(updateTagsResponseData, options: NSJSONReadingOptions.MutableContainers, error: nil)
            if(jsonResult is NSDictionary){
                if((jsonResult?.objectForKey("error") as! NSString).isEqualToString("invalid_token") ){
                    let keychainAccess = KeychainAccess()
                    let usernameStr:String = keychainAccess.getPasscode(usernameKeyChain) as! String
                    let passwordStr:String = keychainAccess.getPasscode(passwordKeyChain) as! String
                    var urlPath: String = getOauthTokenURL + "username=" + usernameStr + "&password=" + passwordStr
                    urlPath = urlPath.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
                    getTokenResponseData = NSMutableData()
                    var url: NSURL = NSURL(string: urlPath)!
                    var request: NSURLRequest = NSURLRequest(URL: url)
                    var connection: NSURLConnection = NSURLConnection(request: request, delegate: self, startImmediately: true)!
                    connection.start()
                }
            }

            self.dismissViewControllerAnimated(true, completion: nil)
        }else if(connectionURLStr.containsString(getTagListURL)){
            var error: NSErrorPointer=nil
            var jsonResult: NSArray = NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers, error: nil) as! NSArray
            self.tags = jsonResult
            self.tableView.reloadData()
        }else if(connectionURLStr.containsString(getOauthTokenURL)){
            var jsonResult = NSJSONSerialization.JSONObjectWithData(getTokenResponseData, options: NSJSONReadingOptions.MutableContainers, error: nil)
            var accessToken  = jsonResult?.objectForKey("access_token")
            var refreshToken = jsonResult?.objectForKey("refresh_token")
            if(accessToken != nil && refreshToken != nil){
                let profileSet = NSUserDefaults.standardUserDefaults()
                profileSet.setObject(accessToken, forKey: accessNSUserData)
                profileSet.setObject(refreshToken, forKey: refreshNSUserData)
                sendUpdateTagsHttpRequest()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.hidden = true
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        tagList.separatorColor = UIColor.clearColor()
        
        let urlPath: String = getTagListURL
         data = NSMutableData()
        var url: NSURL = NSURL(string: urlPath)!
        var request: NSURLRequest = NSURLRequest(URL: url)
        var connection: NSURLConnection = NSURLConnection(request: request, delegate: self, startImmediately: true)!
        connection.start()
        self.extendedLayoutIncludesOpaqueBars = true;
        
    }
    
//    override func viewWillAppear(animated: Bool) {
//        super.viewWillAppear(animated)
//        if(((UIDevice.currentDevice().systemVersion) as NSString).floatValue>=7){
//            var topWindow = UIApplication.sharedApplication().keyWindow
//            topWindow?.clipsToBounds = true;
//            topWindow!.frame =  CGRectMake(0,20,topWindow!.frame.size.width,topWindow!.frame.size.height-20);
//        }
//    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 3
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        if(section == 0){
            return 1
        }
        if(section == 1){
            return tags.count
        }
        if(section == 2){
            return 1
        }
        return 0
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        if(indexPath.section == 0){
            let cell = tableView.dequeueReusableCellWithIdentifier("header", forIndexPath: indexPath) as! TagHeaderTableViewCell
            cell.header.text = "请选择您关注的标签"
            return cell
            
        }
            // Configure the cell...
        else if(indexPath.section == 1){
            let cell = tableView.dequeueReusableCellWithIdentifier("list", forIndexPath: indexPath) as! TagListTableViewCell
            var tag: NSDictionary = tags[indexPath.row] as! NSDictionary
            cell.tagList.text = tag["name"] as? String
            if(selectedTags.containsObject(tags[indexPath.row])){
                cell.tagList.backgroundColor = tagSelectedLabelColor
            }else{
                cell.tagList.backgroundColor = tagLabelColor
            }
            return cell
        }
        else{
            let cell = tableView.dequeueReusableCellWithIdentifier("footer", forIndexPath: indexPath) as! TagFooterTableViewCell
            cell.tagsSelect.titleLabel?.text = "确认"
            return cell
        }

    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var generalSselectedCell:UITableViewCell = tableView.cellForRowAtIndexPath(indexPath)! as UITableViewCell
        generalSselectedCell.contentView.backgroundColor = UIColor.whiteColor()
        if(indexPath.section == 1){
            var selectedCell:TagListTableViewCell = tableView.cellForRowAtIndexPath(indexPath)! as! TagListTableViewCell
            if(selectedTags.containsObject(tags[indexPath.row])==false){
                selectedCell.tagList.backgroundColor = tagSelectedLabelColor
//                if(selectedTags.containsObject(tags[indexPath.row])==false){
                selectedTags.addObject(tags[indexPath.row])
//                }
            }else{
                selectedCell.tagList.backgroundColor = tagLabelColor
                selectedTags.removeObject(tags[indexPath.row])
            }
        }else if(indexPath.section == 2){
            var selectedCell:TagFooterTableViewCell = tableView.cellForRowAtIndexPath(indexPath)! as! TagFooterTableViewCell
            selectedCell.tagsSelect.backgroundColor = submitSelectedColor
        }
    }
    
    // if tableView is set in attribute inspector with selection to multiple Selection it should work.
    
    // Just set it back in deselect
    
    override func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        var generalDeselectedCell:UITableViewCell = tableView.cellForRowAtIndexPath(indexPath)! as UITableViewCell
        generalDeselectedCell.contentView.backgroundColor = UIColor.whiteColor()
        if(indexPath.section == 1){
            var deselectedCell:TagListTableViewCell = tableView.cellForRowAtIndexPath(indexPath)! as! TagListTableViewCell
            deselectedCell.contentView.backgroundColor = UIColor.whiteColor()
            if(selectedTags.containsObject(tags[indexPath.row])){
                deselectedCell.tagList.backgroundColor = tagSelectedLabelColor
                
            }else{
                deselectedCell.tagList.backgroundColor = tagLabelColor
            }
        }
    }

}
