//
//  CommentTableViewCell.swift
//  CancerSN
//
//  Created by lily on 9/16/15.
//  Copyright (c) 2015 lily. All rights reserved.
//

import UIKit

class CommentTableViewCell: UITableViewCell {

    var comment = NSDictionary()
    @IBOutlet weak var commentBodyLabel: UILabel!
    @IBOutlet weak var dateInsertedLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        commentBodyLabel.text = comment.objectForKey("body") as! String
        var dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MM/dd" // superset of OP's format
        var dateInserted = NSDate(timeIntervalSince1970: (comment["dateInserted"] as! Double)/1000 as NSTimeInterval)
        let dateStr = dateFormatter.stringFromDate(dateInserted)
        dateInsertedLabel.text = dateStr
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
