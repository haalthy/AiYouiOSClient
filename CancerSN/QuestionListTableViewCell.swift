//
//  QuestionListTableViewCell.swift
//  CancerSN
//
//  Created by lily on 9/10/15.
//  Copyright (c) 2015 lily. All rights reserved.
//

import UIKit

class QuestionListTableViewCell: UITableViewCell {
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var dateInsertedLabel: UILabel!
    @IBOutlet weak var reviewsLabel: UILabel!
    
    var broadcast = NSDictionary()
//        {
//        didSet{
//            updateUI()
//        }
//    }
    
    func updateUI(){
        var dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MM/dd" // superset of OP's format
        var dateInserted = NSDate(timeIntervalSince1970: (broadcast["dateInserted"] as! Double)/1000 as NSTimeInterval)
        let dateStr = dateFormatter.stringFromDate(dateInserted)
        
        var questionLabel = UILabel(frame: CGRectMake(0, 0, 300, CGFloat.max))
        questionLabel.numberOfLines = 0
        questionLabel.lineBreakMode = NSLineBreakMode.ByCharWrapping
        questionLabel.font = UIFont(name: "", size: 13.0)
        questionLabel.text = broadcast.objectForKey("body") as! String
        
        
        dateInsertedLabel.text = dateStr
        reviewsLabel.text = (broadcast["countComments"] as! NSNumber).stringValue + "评论"
        questionLabel.sizeToFit()
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
