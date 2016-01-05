//
//  PostFeedToolBar.swift
//  CancerSN
//
//  Created by lay on 15/12/28.
//  Copyright © 2015年 lily. All rights reserved.
//

import UIKit

// 时间字体大小
let kToolBarDateFont: UIFont = UIFont.systemFontOfSize(15)
// 时间字体颜色
let kToolBarDateColor: UIColor = RGB(153, 153, 153)

// 评论数量字体大小
let kToolBarcommentFont: UIFont = UIFont.systemFontOfSize(15)
// 评论数量字体颜色
let kToolBarcommentColor: UIColor = RGB(166, 191, 190)


class PostFeedToolBar: UIView {

    // 更新时间
    var updateTime: Int64?
    
    // 评论数量
    var commentCount: Int?
   
    override func drawRect(rect: CGRect) {
        // Drawing code
        
        super.drawRect(rect)

    }
    
    func initVariables(feedModel: PostFeedStatus) {
    
        self.updateTime = feedModel.dateUpdated
        self.commentCount = feedModel.countComments
    
    }
    func layoutWithContent() {
    
        // 添加时间label
        let dateLabel: UILabel = UILabel()
        
        let date: String = NSDate.createDate(self.updateTime!)!.fullDescription()
        
        let dateX: CGFloat = 0
        let dateY: CGFloat = 0
        let dateW: CGFloat = date.sizeWithFont(kToolBarDateFont, maxSize: CGSize(width: CGFloat.max, height: 20)).width
        let dateH: CGFloat = 15
        dateLabel.frame = CGRECT(dateX, dateY, dateW, dateH)
        dateLabel.text = date
        dateLabel.textColor = kToolBarDateColor
        self.addSubview(dateLabel)
        
        // 添加评论数量
        let commentCountLabel: UILabel = UILabel()
        let commentContent: String = setCommentCount(self.commentCount!)
        
        let commentW: CGFloat = commentContent.sizeWithFont(kToolBarcommentFont, maxSize: CGSize(width: CGFloat.max, height: 15)).width
        let commentX: CGFloat = self.frame.size.width - kCellLeftInside - commentW
        let commentY: CGFloat = 0
        let commentH: CGFloat = 15
        commentCountLabel.textColor = kToolBarcommentColor
        commentCountLabel.text = commentContent
        commentCountLabel.frame = CGRECT(commentX, commentY, commentW, commentH)
        self.addSubview(commentCountLabel)
        
        // 添加评论图片
        let commentPic: UIImageView = UIImageView()
        let commentPicW: CGFloat = 32
        let commentPicH: CGFloat = 30
        let commentPicX: CGFloat = self.frame.size.width - commentX - commentPicW
        let commentPicY: CGFloat = 0
        commentPic.image = UIImage(named: "btn_comment")
        commentPic.frame = CGRECT(commentPicX, commentPicY, commentPicW, commentPicH)
        self.addSubview(commentPic)
        
    }
    
    func setCommentCount(commentCount: Int) -> String {
    
        if commentCount > 10000 {
        
            return String(format:"评论%.1f", Double(commentCount) / 10000.0)
        }
        else {
        
            return "评论\(commentCount)"
        }

    }
}
