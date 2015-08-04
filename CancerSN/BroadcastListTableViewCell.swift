//
//  BroadcastListTableViewCell.swift
//  CancerSN
//
//  Created by lily on 7/30/15.
//  Copyright (c) 2015 lily. All rights reserved.
//

import UIKit

class BroadcastListTableViewCell: UITableViewCell {

    @IBOutlet weak var userImage: UIView!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var broadcastContent: UILabel!
    @IBOutlet weak var tags: UILabel!
    @IBOutlet weak var reviews: UILabel!
    
    @IBOutlet weak var userPortrait: UIImageView!
    var broadcast: NSDictionary = NSDictionary(){
        didSet{
            updateUI()
        }
    }
    
    func updateUI(){
//        username.text = broadcast["insertUsername"] as! String
//        broadcastContent.text = broadcast["body"] as! String
//        var tags = broadcast["tags"] as! String
        username.text = broadcast.valueForKey("insertUsername") as! String
        broadcastContent.text = broadcast.valueForKey("body") as! String
        var tags = broadcast.valueForKey("tags") as! String
        tags = "标签:"+tags.stringByReplacingOccurrencesOfString("**", withString: " ")
        self.tags.text = tags
        reviews.text = broadcast.valueForKey("countComments")!.stringValue + "评论"
        if((broadcast.valueForKey("image") is NSNull) == false){
            let dataString = broadcast.valueForKey("image") as! String
            let imageData: NSData = NSData(base64EncodedString: dataString, options: NSDataBase64DecodingOptions(0))!
            userPortrait.image = UIImage(data: imageData)
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
