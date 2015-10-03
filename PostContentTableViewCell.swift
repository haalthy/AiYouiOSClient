//
//  PostContentTableViewCell.swift
//  CancerSN
//
//  Created by lily on 8/2/15.
//  Copyright (c) 2015 lily. All rights reserved.
//

import UIKit

class PostContentTableViewCell: UITableViewCell {
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var userPortrait: UIImageView!
    
    @IBOutlet weak var postContent: UILabel!
    
    @IBOutlet weak var countComments: UILabel!
    @IBOutlet weak var userProfile: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var tagsLabel: UILabel!
    
    @IBOutlet weak var type: UILabel!
    var post: NSDictionary = NSDictionary(){
        didSet{
            updateUI()
        }
    }
    
    func updateUI(){
        username.text = post.objectForKey("insertUsername") as! String
        postContent.text = post.objectForKey("body") as! String
        countComments.text = (post.objectForKey("countComments") as! NSNumber).stringValue + " reviews"
        if ((post.objectForKey("image") is NSNull) == false && (post.objectForKey("image") != nil)){
            let dataString = post.valueForKey("image") as! String
            userPortrait.image = UIImage(data: NSData(base64EncodedString: dataString, options: NSDataBase64DecodingOptions(0))!)
        }
        userProfile.text = post.valueForKey("patientProfile") as? String
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
        type.text = typeStr
        if (post.objectForKey("tags") is NSNull) == false{
            tagsLabel.text = "tag:" + (post.objectForKey("tags") as! NSString).stringByReplacingOccurrencesOfString("*", withString: " ")
        }else{
            tagsLabel.text = ""
        }
        
        //insert date View
        var dateFormatter = NSDateFormatter()
        var insertedDate = NSDate(timeIntervalSince1970: (post.valueForKey("dateInserted") as! Double)/1000 as NSTimeInterval)
        dateFormatter.dateFormat = "yyyy-MM-dd" // superset of OP's format
        let insertedDayStr = dateFormatter.stringFromDate(insertedDate)
        let currentDayStr = dateFormatter.stringFromDate(NSDate())
        if(currentDayStr > insertedDayStr){
            dateFormatter.dateFormat = "MM-dd"
            date.text = dateFormatter.stringFromDate(insertedDate)
        }else{
            dateFormatter.dateFormat = "HH:mm"
            date.text = dateFormatter.stringFromDate(insertedDate)
        }
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
