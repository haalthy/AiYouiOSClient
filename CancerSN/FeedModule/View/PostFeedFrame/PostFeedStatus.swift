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
    var feedId : Int?
    
    var feedPortrait: String?
    
    // Feed 内容
    var feedContent : String?
    
    // Feed 昵称
    var nickname : String?
    
    // user 性别
    var gender: String?

    // 年龄
    var age: String?
    
    // 评论数
    var commentCount : NSNumber?
    
    // Feed high标签
    var tag: String?
    
    // Feed 标签
    var highlight: String?
    
    // Feed 配图
    var picArr: [String]?
    
    
}
