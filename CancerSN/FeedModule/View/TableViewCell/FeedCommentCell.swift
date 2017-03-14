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
    
        self.userPortrait.layer.cornerRadius = 20
        self.userPortrait.clipsToBounds = true
    }
    
    func showFeedInfo(_ commentModel: CommentModel) {
        
        self.userNickname.text = commentModel.displayname
        let imageURL = commentModel.imageURL + "@80h_80w_1e"
        self.userPortrait.addImageCache(imageURL, placeHolder: placeHolderStr)
        self.dateLabel.text = Foundation.Date.createDate(commentModel.dateInserted / 1000)?.fullDescription()
        self.feedContentLabel.text = commentModel.body
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
