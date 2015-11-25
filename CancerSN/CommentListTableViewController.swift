//
//  CommentListTableViewController.swift
//  CancerSN
//
//  Created by lily on 9/16/15.
//  Copyright (c) 2015 lily. All rights reserved.
//

import UIKit

class CommentListTableViewController: UITableViewController {

    var commentList = NSArray()
    var heightForCommentRow = NSMutableDictionary()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return commentList.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("commentCellIdentifier", forIndexPath: indexPath) 
//        cell.comment = commentList[indexPath.row] as! NSDictionary

        let comment = commentList[indexPath.row] as! NSDictionary
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MM/dd" // superset of OP's format
        let dateInserted = NSDate(timeIntervalSince1970: (comment["dateInserted"] as! Double)/1000 as NSTimeInterval)
        let dateStr = dateFormatter.stringFromDate(dateInserted)
        
        let commentLabel = UILabel(frame: CGRectMake(15, 10, UIScreen.mainScreen().bounds.width - 30, CGFloat.max))
        commentLabel.numberOfLines = 0
        commentLabel.lineBreakMode = NSLineBreakMode.ByCharWrapping
        commentLabel.font = UIFont(name: "Helvetica", size: 13.0)
        commentLabel.text = comment.objectForKey("body") as! String
        commentLabel.textColor = UIColor.blackColor()
        commentLabel.sizeToFit()
        
        let dateInsertedLabel = UILabel(frame: CGRectMake(10, commentLabel.frame.height + 15, 60, 20))
        dateInsertedLabel.textColor = UIColor.darkGrayColor()
        dateInsertedLabel.text = dateStr
        dateInsertedLabel.font = UIFont(name: "Helvetica", size: 12.0)
        
        cell.addSubview(commentLabel)
        cell.addSubview(dateInsertedLabel)
        self.heightForCommentRow.setObject(commentLabel.frame.height, forKey: indexPath)

        return cell
    }
    
    override func tableView(_tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat{
        var rowHeight:CGFloat = 0
        let questionLabelHeight = self.heightForCommentRow.objectForKey(indexPath)
        if questionLabelHeight != nil{
            rowHeight = (self.heightForCommentRow.objectForKey(indexPath) as! CGFloat) + 35
        }
        return rowHeight
    }

}
