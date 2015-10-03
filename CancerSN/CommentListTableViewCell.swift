//
//  CommentListTableViewCell.swift
//  CancerSN
//
//  Created by lily on 8/3/15.
//  Copyright (c) 2015 lily. All rights reserved.
//

import UIKit

class CommentListTableViewCell: UITableViewCell {
    
    @IBOutlet weak var userPortrait: UIImageView!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var commentContent: UILabel!
    @IBOutlet weak var date: UILabel!
    
    var comment : NSDictionary = NSDictionary(){
        didSet{
            updateUI()
        }
    }
    func updateUI(){
        username.text = comment.objectForKey("insertUsername") as! String
        commentContent.text = comment.objectForKey("body") as! String
        if comment.objectForKey("image") != nil{
            let dataString = comment.valueForKey("image") as! String
            userPortrait.image = UIImage(data: NSData(base64EncodedString: dataString, options: NSDataBase64DecodingOptions(0))!)
        }
        //insert date View
        var dateFormatter = NSDateFormatter()
        var insertedDate = NSDate(timeIntervalSince1970: (comment.valueForKey("dateInserted") as! Double)/1000 as NSTimeInterval)
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
