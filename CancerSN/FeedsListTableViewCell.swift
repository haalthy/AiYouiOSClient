//
//  FeedsListTableViewCell.swift
//  CancerSN
//
//  Created by lily on 8/8/15.
//  Copyright (c) 2015 lily. All rights reserved.
//

import UIKit

class FeedsListTableViewCell: UITableViewCell {
    
    @IBOutlet weak var userPortrait: UIImageView!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var feedContent: UILabel!
    @IBOutlet weak var reviews: UILabel!
    @IBOutlet weak var timeInserted: UILabel!
    @IBOutlet weak var profile: UILabel!
    
    var feed: NSDictionary = NSDictionary(){
        didSet{
            updateUI()
        }
    }
    
    func updateUI(){
        //        username.text = broadcast["insertUsername"] as! String
        //        broadcastContent.text = broadcast["body"] as! String
        //        var tags = broadcast["tags"] as! String
        var rowOfContent = (feed.valueForKey("body") as! NSString).length/25
        feedContent.frame.size.height = CGFloat(20 * rowOfContent)
        feedContent.frame.size.height = CGFloat(100)
        username.text = feed.valueForKey("insertUsername") as? String
        reviews.text = feed.valueForKey("countComments")!.stringValue + "评论"
        var insertedDate = NSDate(timeIntervalSince1970: (feed.valueForKey("dateInserted") as! Double)/1000 as NSTimeInterval)
        

        var dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd" // superset of OP's format
        let insertedDayStr = dateFormatter.stringFromDate(insertedDate)
        let currentDayStr = dateFormatter.stringFromDate(NSDate())

        if(currentDayStr > insertedDayStr){
            dateFormatter.dateFormat = "MM-dd"
            timeInserted.text = dateFormatter.stringFromDate(insertedDate)
        }else{
            dateFormatter.dateFormat = "HH:mm"
            timeInserted.text = dateFormatter.stringFromDate(insertedDate)
        }
        
        if((feed.valueForKey("image") is NSNull) == false){
            let dataString = feed.valueForKey("image") as! String
            let imageData: NSData = NSData(base64EncodedString: dataString, options: NSDataBase64DecodingOptions(0))!
            userPortrait.image = UIImage(data: imageData)
        }

        feedContent.text = feed.valueForKey("body") as? String
        

        self.profile.text = feed.valueForKey("patientProfile") as? String
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
