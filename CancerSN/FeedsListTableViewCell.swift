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
    var feed: NSDictionary = NSDictionary(){
        didSet{
            updateUI()
        }
    }
    
    func updateUI(){
        //        username.text = broadcast["insertUsername"] as! String
        //        broadcastContent.text = broadcast["body"] as! String
        //        var tags = broadcast["tags"] as! String
        username.text = feed.valueForKey("insertUsername") as! String
        feedContent.text = feed.valueForKey("body") as! String
        reviews.text = feed.valueForKey("countComments")!.stringValue + "评论"
        if((feed.valueForKey("image") is NSNull) == false){
            let dataString = feed.valueForKey("image") as! String
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
