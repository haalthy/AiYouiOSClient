//
//  PostFeedStatus.swift
//  CancerSN
//
//  Created by lay on 15/12/24.
//  Copyright © 2015年 lily. All rights reserved.
//

import UIKit

class PostFeedStatus: D3Model {
    
    // 创建时间
    var createdDate: String?
    
    // Feed id
    var postID: Int?
    
    // 用户标识
    var insertUsername: String?
    
    // Feed 内容
    var body: String?

    // 内容下面的标签
    var tags: String?
    
    // 评论数
    var countComments : Int?
    
    // 
    var countBookmarks: Int?
    
    // 浏览数
    var countViews: Int?
    
    //
    var closed: Int?
    
    // 是否为广播消息
    var isBroadcast: Int?
    
    // 插入时间
    var dateInserted: Int64?
    
    // 更新时间
    var dateUpdated: Int64?
    
    // 
    var isActive: Int?
    
    //
    var type: Int?
    
    // 治疗ID
    var treatmentID: Int?
    
    // 
    var patientStatusID: Int?
    
    // 性别
    var gender: String?
    
    // 病理类型
    var pathological: String?
    
    // 年龄
    var age: Int?
    
    // 癌症类型
    var cancerType: String?
    
    // 转移
    var metastasis: String?
    
    // 初诊分期
    var stage: Int?
    
    // 图片数量
    var hasImage: Int?
    
    // 用户昵称
    var displayname: String?
    
    // 类似 “特罗凯” “中药”这个部分,内容上部标签
    var highlight: String?
    
    //
    var clinicReport: String?
    
    // 图片信息
    var imageURL: String?
    
    // 用户头像
    var portraitURL: String?
    
    
}
