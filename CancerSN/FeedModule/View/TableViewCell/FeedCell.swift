//
//  FeedCell.swift
//  CancerSN
//
//  Created by lay on 15/12/30.
//  Copyright © 2015年 lily. All rights reserved.
//

import UIKit

// MARK: - 配置常量

// 昵称颜色
let kNicknameColor: UIColor = RGB(51, 51, 51)

// 年龄颜色
let kAgeColor: UIColor = RGB(153, 153, 153)

// 性别颜色
let kGenderColor: UIColor = RGB(153, 153, 153)

// 内容颜色
let kContentColor: UIColor = RGB(51, 51, 51)

// 昵称字体
let kCellNicknameFontSize: CGFloat = 16.0

// 类别字体大小
let kFeedTypeFontSize: CGFloat = 16.0

// 内容字体大小
let kContentFontSize: CGFloat = 16.0

class FeedCell: UITableViewCell {

    
    var feedOriginFrame: FeedOriginalFrame? {
    
        didSet {
        
            // 添加feed内容
            self.setContentView()

        }
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    // MARK: - 添加相关View
    
    func setContentView() {
        
        let feedModel = self.feedOriginFrame?.feedModel
        
        // 1.头像
        let portraitView = UIImageView()
        portraitView.addImageCache((feedModel?.portraitURL)!, placeHolder: "icon_profile")
        portraitView.frame = (feedOriginFrame?.portraitFrame)!
        portraitView.backgroundColor = UIColor.greenColor()
        self.addSubview(portraitView)
        
        // 2.昵称
        let nickname = UILabel()
        nickname.text = feedModel?.displayname
        nickname.frame = (self.feedOriginFrame?.nicknameFrame)!
        nickname.textColor = kNicknameColor
        nickname.font = UIFont.systemFontOfSize(kCellNicknameFontSize)
        self.addSubview(nickname)
        
        // 3.帖子类别
        let feedTypeLabel = UILabel()
        feedTypeLabel.text = "我的提问"
        feedTypeLabel.frame = (self.feedOriginFrame?.feedTypeFrame)!
        feedTypeLabel.textColor = kAgeColor
        feedTypeLabel.font = UIFont.systemFontOfSize(kFeedTypeFontSize)
        self.addSubview(feedTypeLabel)
        
        // 4.性别
        let genderLabel = UILabel()
        genderLabel.text = feedModel?.gender
        genderLabel.frame = (self.feedOriginFrame?.genderFrame)!
        genderLabel.textColor = kGenderColor
        self.addSubview(genderLabel)
        
        // 5.年龄
        let ageLabel = UILabel()
        ageLabel.text = String.intToString((feedModel?.age)!)
        //print(String(feedModel?.age))
        ageLabel.frame = (self.feedOriginFrame?.ageFrame)!
        ageLabel.textColor = kAgeColor
        self.addSubview(ageLabel)
        
        if feedModel?.highlight != nil {
            
            // 6.标签
            var highTagsArr: [String] = ((feedModel?.highlight)?.componentsSeparatedByString(" "))!
            highTagsArr.removeLast()
            
            let highView = FeedTagView(frame: (self.feedOriginFrame?.cureFrame)!, highTag: highTagsArr)
            highView.frame = (self.feedOriginFrame?.cureFrame)!
            self.addSubview(highView)
        }
        
        
        // 7.帖子内容
        let contentLabel = UILabel()
        contentLabel.text = feedModel?.body
        contentLabel.frame = (self.feedOriginFrame?.contentFrame)!
        contentLabel.textColor = kContentColor
        contentLabel.font = UIFont.systemFontOfSize(kContentFontSize)
        contentLabel.numberOfLines = 0
        contentLabel.lineBreakMode = NSLineBreakMode.ByWordWrapping
        self.addSubview(contentLabel)
        
        if feedModel?.hasImage > 0 {
        
            // 8.配图
                        
            let picsView = FeedPhotosView(feedModel: feedModel!, frame: self.feedOriginFrame!.photosFrame!)
            picsView.frame = (self.feedOriginFrame?.photosFrame)!
            let picArr: Array<String> = ((feedModel!.imageURL)?.componentsSeparatedByString(";"))!
            picsView.picsUrl = picArr;
            self.addSubview(picsView)
        }
        
        // 8.tags
        if feedModel?.tags != nil {
            
            let tagsLabel = UILabel()
            tagsLabel.frame = (self.feedOriginFrame?.tagFrame)!
            tagsLabel.textColor = kAgeColor
            // 获取内容
            tagsLabel.text = self.showTagsWithString((feedModel?.tags)!)
            tagsLabel.font = UIFont.systemFontOfSize(kContentFontSize)
            self.addSubview(tagsLabel)
        }
        
        // 9.toolbar
        let toolsView: PostFeedToolBar = PostFeedToolBar()
        toolsView.frame = (self.feedOriginFrame?.toolBarFrame)!
        toolsView.backgroundColor = UIColor.clearColor()
        toolsView.initVariables(feedModel!)
        toolsView.layoutWithContent()
        self.addSubview(toolsView)

        
    }

    // MARK: - 功能方法
    
    // MARK: tag标签处理
    
    func showTagsWithString(tagsStr: String) -> String {
    
        let tagArr: Array<String> = tagsStr.componentsSeparatedByString("**")
        
        var resultStr: String = "Tag: "
        
        for  tag in tagArr {
        
            // tag为空不拼接
            if tag == "" {
                break
            }
            resultStr = "\(resultStr)\(tag), "
        }
        
        let result: NSString = resultStr as NSString
        // 去除最后一个逗号
        resultStr = result.substringToIndex(result.length - 2)
        
        return resultStr
    }
}
