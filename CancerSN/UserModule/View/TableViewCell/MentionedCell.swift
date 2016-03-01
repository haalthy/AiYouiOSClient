//
//  MentionedCell.swift
//  CancerSN
//
//  Created by lay on 16/3/1.
//  Copyright © 2016年 lily. All rights reserved.
//

import UIKit

class MentionedCell: UITableViewCell {

    
    
    @IBOutlet weak var portraitImage: UIImageView!
    
    @IBOutlet weak var showImage: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var bodyLabel: UILabel!
    
    @IBOutlet weak var typeLabel: UILabel!
    
    @IBOutlet weak var tagLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.initContentView()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func initContentView() {
    
        self.portraitImage.layer.cornerRadius = self.portraitImage.frame.width / 2
        self.portraitImage.clipsToBounds = true

    }
    
    func setContentViewAction(feedModel: PostFeedStatus) {
    
        
    }
    
}
