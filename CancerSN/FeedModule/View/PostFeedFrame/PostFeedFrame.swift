//
//  PostFeedFrame.swift
//  CancerSN
//
//  Created by lay on 15/12/31.
//  Copyright © 2015年 lily. All rights reserved.
//

import UIKit

class PostFeedFrame: NSObject {

    // 帖子数据
    var feedModel: PostFeedStatus!
    
    // feedOriginalFrame
    
    var feedOriginalFrame: FeedOriginalFrame!
    
    // 帖子frame
    var frame: CGRect!
    
    // cell高度
    var cellHeight: CGFloat!
    
    // 工具栏frame
    var feedToolBarFrame: CGRect!
    
    
    init(feedModel: PostFeedStatus) {
    
        super.init()
        self.feedModel = feedModel
        
        // 设置帖子frame
        self.setFeedOriginalFrame()
        
    }
    
    // MARK: - 设置帖子frame
    
    func setFeedOriginalFrame() {
    
        let feedOriginalFrame = FeedOriginalFrame.init(feedModel: self.feedModel)
        
        self.feedOriginalFrame = feedOriginalFrame
        self.frame = feedOriginalFrame.frame
        self.cellHeight = self.frame.height
    }
    
    func setTootBarFrame() {
    
        
    }
}
