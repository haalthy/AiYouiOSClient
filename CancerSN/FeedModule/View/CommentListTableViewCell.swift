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
        username.text = comment.object(forKey: "insertUsername") as? String
        commentContent.text = comment.object(forKey: "body") as? String
        if comment.object(forKey: "image") != nil{
            let dataString = comment.value(forKey: "image") as! String
            userPortrait.image = UIImage(data: Data(base64Encoded: dataString, options: NSData.Base64DecodingOptions(rawValue: 0))!)
        }
        //insert date View
        let dateFormatter = DateFormatter()
        let insertedDate = Foundation.Date(timeIntervalSince1970: (comment.value(forKey: "dateInserted") as! Double)/1000 as TimeInterval)
        dateFormatter.dateFormat = "yyyy-MM-dd" // superset of OP's format
        let insertedDayStr = dateFormatter.string(from: insertedDate)
        let currentDayStr = dateFormatter.string(from: Foundation.Date())
        if(currentDayStr > insertedDayStr){
            dateFormatter.dateFormat = "MM-dd"
            date.text = dateFormatter.string(from: insertedDate)
        }else{
            dateFormatter.dateFormat = "HH:mm"
            date.text = dateFormatter.string(from: insertedDate)
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
