//
//  PostCellFrame.swift
//  CancerSN
//
//  Created by hui luo on 24/2/2016.
//  Copyright © 2016 lily. All rights reserved.
//

import UIKit

class PostCellFrame: NSObject {
    var cellHeight: CGFloat = 0
    
    let postContentTopSpace: CGFloat = 15
    let postContentLeftSpace: CGFloat = 80
    let postContentRightSpace: CGFloat = 5
    let postContentButtomSpace: CGFloat = 15
    let postLabelFont: UIFont = UIFont.systemFont(ofSize: 14)
    let postLabelLeftSpace: CGFloat = 10
    let postLabelTopSpace: CGFloat = 0

    let postImageLength: CGFloat = 50

    var post = PostFeedStatus() {
        didSet{
            updateUI()
        }
    }
    
    func updateUI(){
        let postContentWidth = screenWidth - postContentLeftSpace - postContentRightSpace

        //post Content
        let postLabel = UILabel()
        if post.hasImage > 0 {
            cellHeight = postImageLength
        }else{
            let postLabelSize = post.body.sizeWithFont(postLabelFont, maxSize: CGSize(width: postContentWidth - postLabelLeftSpace * 2, height: 36))
            postLabel.frame = CGRect(x: postLabelLeftSpace, y: postLabelTopSpace, width: postContentWidth - postLabelLeftSpace*2, height: postLabelSize.height)
            postLabel.text = post.body
            postLabel.numberOfLines = 2
            postLabel.lineBreakMode = NSLineBreakMode.byTruncatingTail
            postLabel.sizeToFit()
            cellHeight = postLabel.frame.height
        }

    }
    
}
