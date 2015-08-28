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
