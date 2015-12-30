//
//  PostFeedStatus.swift
//  CancerSN
//
//  Created by lay on 15/12/24.
//  Copyright © 2015年 lily. All rights reserved.
//

import UIKit

class PostFeedStatus: NSObject {
    
    // 创建时间
    var createdDate : String?
    
    // Feed id
    var feedId : NSNumber?
    
    // Feed 内容
    var feedContent : String?
    
    // Feed 作者
    var userName : String?
    
    // 评论数
    var commentCount : NSNumber?
    
    // Feed high标签
    var tag: String?
    
    // Feed 标签
    var highlight: String?
    
    // Feed 配图
    var picArr: NSArray?
    
    
}
