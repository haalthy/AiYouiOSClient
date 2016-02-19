//
//  FeedCommentCell.swift
//  CancerSN
//
//  Created by lay on 16/1/15.
//  Copyright © 2016年 lily. All rights reserved.
//

import UIKit

class FeedCommentCell: UITableViewCell {

    // 用户头像
    @IBOutlet weak var userPortrait: UIImageView!
    // 用户昵称
    @IBOutlet weak var userNickname: UILabel!
    // 评论时间
    @IBOutlet weak var dateLabel: UILabel!
    // 评论详情
    @IBOutlet weak var feedContentLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.initContentView()
    }

    // MARK: - init ContentView
    
    func initContentView() {
    
        self.userPortrait.layer.cornerRadius = self.userPortrait.bounds.size.height / 2
        self.userPortrait.clipsToBounds = true
    }
    
    func showFeedInfo(commentModel: CommentModel) {

        self.userPortrait.addImageCache(commentModel.imageURL, placeHolder: "")
        self.userNickname.text = commentModel.insertUsername
        self.dateLabel.text = NSDate.createDate(commentModel.dateInserted / 1000)?.fullDescription()
        self.feedContentLabel.text = commentModel.body
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
