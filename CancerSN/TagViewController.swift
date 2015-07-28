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

    @IBAction func tagsSubmit(sender: AnyObject) {
        self.delegate?.updateTagList(self.selectedTags)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
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
//            cell.tagList.text = tags[indexPath.row]
            
            var tag: NSDictionary = tags[indexPath.row] as! NSDictionary
            cell.tagList.text = tag["name"] as? String
//            tagBackgroundColor = cell.tagList!.backgroundColor!
            cell.tagList.backgroundColor = tagLabelColor
            return cell
            
        }
        else{
            let cell = tableView.dequeueReusableCellWithIdentifier("footer", forIndexPath: indexPath) as! TagFooterTableViewCell
            cell.tagsSelect.titleLabel?.text = "确认"
            return cell
        }

    }
    func connection(connection: NSURLConnection!, didReceiveData data: NSData!){
        self.data!.appendData(data)
    }

    func connectionDidFinishLoading(connection: NSURLConnection!)
    {
        var error: NSErrorPointer=nil

        var jsonResult: NSArray = NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers, error: error) as! NSArray
        
        self.tags = jsonResult
        self.tableView.reloadData()

    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var generalSselectedCell:UITableViewCell = tableView.cellForRowAtIndexPath(indexPath)! as UITableViewCell
        generalSselectedCell.contentView.backgroundColor = UIColor.whiteColor()
        if(indexPath.section == 1){
            var selectedCell:TagListTableViewCell = tableView.cellForRowAtIndexPath(indexPath)! as! TagListTableViewCell
            if(selectedTags.containsObject(tags[indexPath.row])==false){
                selectedCell.tagList.backgroundColor = tagSelectedLabelColor
                if(selectedTags.containsObject(tags[indexPath.row])==false){
                    selectedTags.addObject(tags[indexPath.row])
                }
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
