//
//  FeedOriginalFrame.swift
//  CancerSN
//
//  Created by lay on 15/12/28.
//  Copyright © 2015年 lily. All rights reserved.
//

import UIKit

// 配置常量

// cell左边间距
let kCellLeftInside: CGFloat = 15.0
// cell上边间距
let kCellTopInside: CGFloat = 20.0
// 昵称的font
let kNicknameFontSize: UIFont = UIFont.systemFontOfSize(12)


class FeedOriginalFrame: NSObject {
    
    // 加载数据
    var feedModel: PostFeedStatus?
    
    // 头像frame
    var portraitFrame: CGRect?
    
    // 昵称frame
    var nicknameFrame: CGRect?
    
    // feed类别frame
    var feedTypeFrame: CGRect?
    
    // 性别frame
    var genderFrame: CGRect?
    
    // 年龄frame
    var ageFrame: CGRect?
    
    // 患者情况frame
    var userStatusFrame: CGRect?
    
    // 治疗过程tagframe
    var cureFrame: CGRect?
    
    // 正文frame
    var contentFrame: CGRect?
    
    // 配图frame
    var photosFrame: CGRect?
    
    // 标签frame
    var tagFrame: CGRect?

     init(feedModel: PostFeedStatus) {
        
        super.init()
        self.feedModel = feedModel;
    }
    
    // MARK: - 设置frame
    
    func setFrame() {
    
        // 1.头像
        let portraitX: CGFloat = kCellLeftInside
        let portraitY: CGFloat = kCellTopInside
        let portraitW: CGFloat = 40.0
        let portraitH: CGFloat = 40.0
        self.portraitFrame = CGRECT(portraitX, portraitY, portraitW, portraitH)
        
        // 2.昵称
        let nicknameX: CGFloat = CGRectGetMaxX(self.portraitFrame!) + 10.0
        let nicknameY: CGFloat = kCellTopInside
        let nicknameW: CGFloat = (self.feedModel?.userName?.sizeWithFont(kNicknameFontSize, maxSize: CGSizeMake(CGFloat(MAXFLOAT), CGFloat(MAXFLOAT))).width)!
        let nicknameH: CGFloat = 12.0
        self.nicknameFrame = CGRECT(nicknameX, nicknameY, nicknameW, nicknameH)
        
        // 3.feed type
        let feedTypeX: CGFloat = CGRectGetMaxX(self.nicknameFrame!)
        let feedTypeY: CGFloat = kCellTopInside
        let feedTypeW: CGFloat = ("我的提问".sizeWithFont(kNicknameFontSize, maxSize: CGSizeMake(CGFloat(MAXFLOAT), CGFloat(MAXFLOAT))).width)
        let feedTypeH: CGFloat = 24.0
        self.feedTypeFrame = CGRECT(feedTypeX, feedTypeY, feedTypeW, feedTypeH)
        
        // 4.性别
        let sexX: CGFloat = CGRectGetMaxX(self.portraitFrame!) + 10.0
        let sexY: CGFloat = CGRectGetMaxY(self.nicknameFrame!) + 7.0
        let sexW: CGFloat = 14.0
        let sexH: CGFloat = 14.0
        self.genderFrame = CGRECT(sexX, sexY, sexW, sexH)
        
        // 5.年龄
        let ageX: CGFloat = CGRectGetMaxX(self.genderFrame!) + 5
        let ageY: CGFloat = CGRectGetMaxY(self.nicknameFrame!) + 7.0
        let ageW: CGFloat = 14.0
        let ageH: CGFloat = 14.0
        self.ageFrame = CGRECT(ageX, ageY, ageW, ageH)
        
        if (self.feedModel!.tag == nil) {
            
            // 6.内容详情
            let contentX: CGFloat = CGRectGetMaxX(self.portraitFrame!) + 10.0
            let contentY: CGFloat = CGRectGetMaxY(self.ageFrame!) + 8.0
            let contentSize: CGSize = (self.feedModel?.feedContent?.sizeWithFont(kNicknameFontSize, maxSize: CGSizeMake(CGFloat(MAXFLOAT), CGFloat(MAXFLOAT))))!
            self.contentFrame = CGRECT(contentX, contentY, contentSize.width, contentSize.height)
        }
        else {
            
            // 6.tag标签
            let tagX: CGFloat = CGRectGetMaxX(self.portraitFrame!) + 10.0
            let tagY: CGFloat = CGRectGetMaxY(self.ageFrame!) + 8.0
            let tagW = SCREEN_WIDTH - tagX
            let tagH: CGFloat = 24
            self.tagFrame = CGRECT(tagX, tagY, tagW, tagH)
            
            // 7.内容详情
            let contentX: CGFloat = CGRectGetMaxX(self.portraitFrame!) + 10.0
            let contentY: CGFloat = CGRectGetMaxY(self.tagFrame!) + 8.0
            let contentSize: CGSize = (self.feedModel?.feedContent?.sizeWithFont(kNicknameFontSize, maxSize: CGSizeMake(CGFloat(MAXFLOAT), CGFloat(MAXFLOAT))))!
            self.contentFrame = CGRECT(contentX, contentY, contentSize.width, contentSize.height)
        }
        
        // 8.图片相册
        
        let photosX: CGFloat = CGRectGetMaxX(self.portraitFrame!) + 10.0
        let photosY: CGFloat = CGRectGetMaxY(self.contentFrame!) + 8.0
        
        let photosSize: CGSize = FeedPhotosView .layoutForPhotos((self.feedModel!.picArr?.count)!)
        self.photosFrame = CGRECT(photosX, photosY, photosSize.width, photosSize.height)
    }
    
}
