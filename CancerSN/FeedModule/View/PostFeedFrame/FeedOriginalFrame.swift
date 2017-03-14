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
let kCellLeftInside: CGFloat = CGFloat(15)
// cell上边间距
let kCellTopInside: CGFloat = CGFloat(20.0)
// 昵称的font
let kNicknameFontSize: UIFont = UIFont.systemFont(ofSize: 16)

// 距离头像的距离
let kPortraitMargin: CGFloat = CGFloat(10.0)

// nickname height

let kNicknameHeight: CGFloat = CGFloat(17.0)

// 帖子类别

func getFeedTypeName(_ type: Int, isBroadcast: Int) -> String {

    var resultStr: String = ""
    switch type {
    
    case 0:
        if isBroadcast == 1 {
            resultStr = "提出问题"
        }
        else{
            resultStr = "发表心得"
        }
        break
    case 1:
        resultStr = "治疗方案"
        break
    case 2:
        resultStr = "更新状态"
        break
    default: break
    }
    
    return resultStr
}

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
    
    // clinicFrame
    var clinicFrame: CGRect?
    
    // 正文frame
    var contentFrame: CGRect?
    
    // 配图frame
    var photosFrame: CGRect?
    
    // 标签frame
    var tagFrame: CGRect?
    
    // toolBar frame
    var toolBarFrame: CGRect?
    
    // 帖子的frame
    var frame: CGRect?
    
    var isShowFullText:Bool = false

    init(feedModel: PostFeedStatus, isShowFullText: Bool) {
        
        super.init()
        self.feedModel = feedModel;
        self.isShowFullText = isShowFullText
        self.setFrame()
    
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
        let nicknameX: CGFloat = self.portraitFrame!.maxX + kPortraitMargin
        let nicknameY: CGFloat = kCellTopInside
        let nicknameW: CGFloat = (feedModel?.displayname)!.sizeWithFont(kNicknameFontSize, maxSize: CGSize(width: CGFloat.greatestFiniteMagnitude, height: kNicknameHeight)).width
        let nicknameH: CGFloat = kNicknameHeight
        self.nicknameFrame = CGRECT(nicknameX, nicknameY, nicknameW, nicknameH)
        
        // 3.feed type
        let feedTypeX: CGFloat = self.nicknameFrame!.maxX
        let feedTypeY: CGFloat = kCellTopInside
        let feedTypeW: CGFloat = (getFeedTypeName((self.feedModel?.type)!, isBroadcast: (self.feedModel?.isBroadcast)!).sizeWithFont(kNicknameFontSize, maxSize: CGSize(width: CGFloat.greatestFiniteMagnitude, height: kNicknameHeight)).width)
        let feedTypeH: CGFloat = kNicknameHeight
        self.feedTypeFrame = CGRECT(feedTypeX, feedTypeY, feedTypeW, feedTypeH)
        
        // 4.性别
        let sexX: CGFloat = self.portraitFrame!.maxX + kPortraitMargin
        let sexY: CGFloat = self.nicknameFrame!.maxY + 7.0
        let sexW: CGFloat = 20.0
        let sexH: CGFloat = 20.0
        self.genderFrame = CGRECT(sexX, sexY, sexW, sexH)
        
        // 5.年龄
        let ageX: CGFloat = self.genderFrame!.maxX + CGFloat(5)
        let ageY: CGFloat = self.nicknameFrame!.maxY + 7.0
        let ageW: CGFloat = 40.0
        let ageH: CGFloat = 20.0
        self.ageFrame = CGRECT(ageX, ageY, ageW, ageH)
        
        // 6.患者状态
        let statusX: CGFloat = self.ageFrame!.maxX + 5
        let statusY: CGFloat = self.nicknameFrame!.maxY + 7.0
        let statusW: CGFloat = SCREEN_WIDTH - statusX - kCellLeftInside
        let statusH: CGFloat = 20.0
        self.userStatusFrame = CGRECT(statusX, statusY, statusW, statusH)
        
        // 7.tag标签
        let tagX: CGFloat = self.portraitFrame!.maxX + kPortraitMargin
        let tagY: CGFloat = self.ageFrame!.maxY + 8.0
        let tagW = SCREEN_WIDTH - tagX
        var tagH: CGFloat = 24
        if (self.feedModel!.highlight == "") || (self.feedModel!.highlight == "<null>"){
            tagH = 0
        }
        self.cureFrame = CGRECT(tagX, tagY, tagW, tagH)
        
        
        // 8.clinic
        let clinicX: CGFloat = self.portraitFrame!.maxX + kPortraitMargin
        var clinicY: CGFloat = 0
        var clinicSize: CGSize = CGSize(width: 0, height: 0)
        if (self.feedModel?.clinicReport != "") && (self.feedModel!.clinicReport != "<null>") {
            clinicSize = (self.feedModel?.clinicReport.sizeWithFont(kNicknameFontSize, maxSize: CGSize(width: SCREEN_WIDTH - clinicX - kCellLeftInside, height: CGFloat.greatestFiniteMagnitude)))!
        }
        if (self.feedModel!.highlight == "") || (self.feedModel!.highlight == "<null>"){
            clinicY = self.ageFrame!.maxY + 8.0
        }
        else {
            clinicY = self.cureFrame!.maxY + 8.0
        }
        self.clinicFrame = CGRECT(clinicX, clinicY, clinicSize.width, clinicSize.height)
        
        
        // 9.内容详情
        let contentX: CGFloat = self.portraitFrame!.maxX + kPortraitMargin
        var contentY: CGFloat = 0
        var feedContentFrameHMax: CGFloat = 130
        if isShowFullText {
            feedContentFrameHMax = CGFloat.greatestFiniteMagnitude
        }
        let contentSize: CGSize = (self.feedModel?.body.sizeWithFont(kNicknameFontSize, maxSize: CGSize(width: SCREEN_WIDTH - contentX - kCellLeftInside, height: feedContentFrameHMax)))!
        
        if (self.feedModel?.clinicReport == "") || (self.feedModel!.clinicReport == "<null>"){
            if (self.feedModel?.highlight == "") || (self.feedModel!.highlight == "<null>") {
                contentY = self.ageFrame!.maxY + 8.0
            }
            else {
                contentY = self.cureFrame!.maxY + 8.0
            }
        }
        else {
            contentY = self.clinicFrame!.maxY + 8.0

        }
        self.contentFrame = CGRECT(contentX, contentY, contentSize.width, contentSize.height)
        
        
        // 10.图片相册
        let photosX: CGFloat = self.portraitFrame!.maxX + kPortraitMargin
        let photosY: CGFloat = self.contentFrame!.maxY + 8.0
        
        let photosSize: CGSize = FeedPhotosView.layoutForPhotos(self.feedModel!.hasImage)
        self.photosFrame = CGRECT(photosX, photosY, photosSize.width, photosSize.height)
        
        if self.feedModel?.hasImage == 0 {
            
            // 11.tag标签（下面的）
            let tagsX: CGFloat = self.portraitFrame!.maxX + kPortraitMargin
            let tagsY: CGFloat = self.contentFrame!.maxY + 8
            let tagsW: CGFloat = SCREEN_WIDTH - tagsX - kCellLeftInside
            let tagsH: CGFloat = 17
            self.tagFrame = CGRECT(tagsX, tagsY, tagsW, tagsH)
        }
        else {
        
            // 11.tag标签（下面的）
            let tagsX: CGFloat = self.portraitFrame!.maxX + kPortraitMargin
            let tagsY: CGFloat = self.photosFrame!.maxY + 8
            let tagsW: CGFloat = SCREEN_WIDTH - tagsX - kCellLeftInside
            let tagsH: CGFloat = 17
            self.tagFrame = CGRECT(tagsX, tagsY, tagsW, tagsH)
            
        }
        
        // toolBar frame
        if self.feedModel?.tags == "" || self.feedModel?.tags == "<null>" {
        
            let toolX: CGFloat = self.portraitFrame!.maxX + kPortraitMargin
            var toolY: CGFloat = 0
            
            if feedModel?.hasImage == 0  {
                
                toolY = self.contentFrame!.maxY + 8
            }
            else {
                
                toolY = self.photosFrame!.maxY + 8
            }
            let toolW: CGFloat = SCREEN_WIDTH - toolX
            let toolH: CGFloat = 30
            
            self.toolBarFrame = CGRECT(toolX, toolY, toolW, toolH)
        }
        else {
            
            let toolX: CGFloat = self.portraitFrame!.maxX + kPortraitMargin
            let toolY: CGFloat = self.tagFrame!.maxY + 8
            let toolW: CGFloat = SCREEN_WIDTH - toolX
            let toolH: CGFloat = 30
            self.toolBarFrame = CGRECT(toolX, toolY, toolW, toolH)

        }
    
        // 12.帖子的frame
        let frameX: CGFloat = self.portraitFrame!.maxX + kPortraitMargin
        let frameY: CGFloat = 0
        var frameHeight: CGFloat = 0
        let frameWidth: CGFloat  = SCREEN_WIDTH - frameX
        
        frameHeight = self.toolBarFrame!.maxY + 10
        
        self.frame = CGRECT(frameX, frameY, frameWidth, frameHeight)
        
    }
    
}
