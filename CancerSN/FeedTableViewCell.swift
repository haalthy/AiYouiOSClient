//
//  FeedTableViewCell.swift
//  CancerSN
//
//  Created by lily on 10/2/15.
//  Copyright (c) 2015 lily. All rights reserved.
//

import UIKit

protocol ImageTapDelegate {
    func imageTap(username: String)
}

class FeedTableViewCell: UITableViewCell {

    var imageTapDelegate: ImageTapDelegate?
    var feed = NSDictionary(){
        didSet{
            var imageView = UIImageView(frame: CGRectMake(10, 10, 32, 32))
            if((feed.valueForKey("image") is NSNull) == false){
                let dataString = feed.valueForKey("image") as! String
                let imageData: NSData = NSData(base64EncodedString: dataString, options: NSDataBase64DecodingOptions(0))!
                imageView.image = UIImage(data: imageData)
            }else{
                imageView.image = UIImage(named: "Mario.jpg")
            }
            var tapImage = UITapGestureRecognizer(target: self, action: Selector("imageTapHandler:"))
            imageView.userInteractionEnabled = true
            imageView.addGestureRecognizer(tapImage)
            self.addSubview(imageView)
        }
    }
    
    func imageTapHandler(sender: UITapGestureRecognizer){
        
        println(feed["insertUsername"])
        self.imageTapDelegate?.imageTap(feed["insertUsername"] as! String)
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
