//
//  MentionedPostTableViewController.swift
//  CancerSN
//
//  Created by lily on 10/19/15.
//  Copyright (c) 2015 lily. All rights reserved.
//

import UIKit

class MentionedPostTableViewController: UITableViewController, FeedBodyDelegate {
    
    var postList = NSMutableArray()
    var heightForPostRow =  NSMutableDictionary()
    var haalthyService = HaalthyService()
    var previousFeedFetchTimeStamp: Int = 0
    var selectedPost = NSDictionary()

    override func viewDidLoad() {
        super.viewDidLoad()
        previousFeedFetchTimeStamp = Int(NSDate().timeIntervalSince1970*1000)
//        var mentionedPostsData = haalthyService.getMentionedPostList(previousFeedFetchTimeStamp, count: 20)
//        var jsonResult = NSJSONSerialization.JSONObjectWithData(mentionedPostsData!, options: NSJSONReadingOptions.MutableContainers, error: nil)
//        if jsonResult is NSArray {
//            postList = jsonResult as! NSMutableArray
//        }
        getMorePreviousFeeds()
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return postList.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("postCell", forIndexPath: indexPath) as! FeedTableViewCell
        var post = postList[indexPath.row]
        cell.removeAllSubviews()
        
        //separatorLine
        var separatorLine:UIImageView = UIImageView(frame: CGRectMake(0, 0, tableView.frame.size.width-1.0, 3.0))
        separatorLine.image = UIImage(named: "grayline.png")?.stretchableImageWithLeftCapWidth(1, topCapHeight: 0)
        
//        cell.imageTapDelegate = self
        cell.feedBodyDelegate = self
        cell.width = cell.frame.width
        cell.indexPath = indexPath
        cell.feed = post as! NSDictionary
        cell.addSubview(separatorLine)
        return cell
    }
    
    func setFeedBodyHeight(height: CGFloat, indexpath: NSIndexPath) {
        self.heightForPostRow.setObject(height, forKey: indexpath)
    }
    
    override func tableView(_tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat{
        var rowHeight: CGFloat = 0
        if self.heightForPostRow.objectForKey(indexPath) != nil{
            rowHeight = (self.heightForPostRow.objectForKey(indexPath) as! CGFloat) + 110
        }else{
            rowHeight = 40
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
    
    func getMorePreviousFeeds(){
        var getFeedsData = haalthyService.getMentionedPostList(previousFeedFetchTimeStamp, count: 20)
        var jsonResult:AnyObject? = nil
        if getFeedsData != nil{
            jsonResult = NSJSONSerialization.JSONObjectWithData(getFeedsData!, options: NSJSONReadingOptions.MutableContainers, error: nil)
            let str: NSString = NSString(data: getFeedsData!, encoding: NSUTF8StringEncoding)!
            println(str)
        }
        if(jsonResult is NSArray) && (jsonResult as! NSArray).count > 0 {
            self.postList.addObjectsFromArray(jsonResult as! [AnyObject])
            previousFeedFetchTimeStamp = (postList.objectAtIndex(postList.count - 1) as! NSDictionary).objectForKey("dateInserted") as! Int - 1000
            self.tableView.reloadData()
        }else{
            println("get feeds error")
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.selectedPost = postList[indexPath.row] as! NSDictionary
        self.performSegueWithIdentifier("postDetailSegue", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "postDetailSegue" {
            (segue.destinationViewController as! ShowPostDetailTableViewController).post = self.selectedPost
        }
    }
}
