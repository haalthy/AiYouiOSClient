//
//  FeedCell.swift
//  CancerSN
//
//  Created by lay on 15/12/30.
//  Copyright © 2015年 lily. All rights reserved.
//

import UIKit
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


// MARK: - 配置常量

// 昵称颜色
let kNicknameColor: UIColor = RGB(51, 51, 51)

// 年龄颜色
let kAgeColor: UIColor = RGB(153, 153, 153)

// 性别颜色
let kGenderColor: UIColor = RGB(153, 153, 153)

// 内容颜色
let kContentColor: UIColor = RGB(51, 51, 51)

// clinic颜色
let kClinicColor: UIColor = RGB(153, 153, 153)

// 昵称字体
let kCellNicknameFontSize: CGFloat = 16.0

// 类别字体大小
let kFeedTypeFontSize: CGFloat = 16.0

// 内容字体大小
let kContentFontSize: CGFloat = 16.0

// 得到病变位置

func getPatientLocation(_ name: String) -> String {

    var resultStr: String = ""
    switch name {
        
    case "liver":
        resultStr = "肝部"
        break
    case "kidney":
        resultStr = "肾部"
        break
    case "lung":
        resultStr = "肺部"
        break
    case "bravery":
        resultStr = "胆管"
        break
    case "intestine":
        resultStr = "肠部"
        break
    case "stomach":
        resultStr = "胃部"
        break
    case "female":
        resultStr = "妇科"
        break
    case "blood":
        resultStr = "血液"
        break

    default: break
    }
    
    return resultStr

}

// 得到病例分析

func getPathological(_ name: String) -> String {

    var resultStr: String = ""
    switch name {
        
    case "adenocarcinoma":
        resultStr = "腺癌"
        break
    case "carcinoma":
        resultStr = "鳞癌"
        break
    case "AdenosquamousCarcinoma":
        resultStr = "腺鳞癌"
        break
        
    default: break
    }
    
    return resultStr

}

// 得到病例期号

func getPatientNum(_ index: Int) -> String {

    var resultStr: String = ""
    switch index {
        
    case 0:
        resultStr = ""
        break
    case 1:
        resultStr = "I"
        break
    case 2:
        resultStr = "II"
        break
    case 3:
        resultStr = "III"
        break
    case 4:
        resultStr = "IV"
        break

    default: break
    }
    
    return resultStr

}

protocol FeedTableCellDelegate{
    func checkUserProfile(_ username: String)
    
    func checkPostComment(_ postID: Int)
}

class FeedCell: UITableViewCell {
    
    //是否显示全部文本
    var isShowFullText: Bool = false
    
    var feedTableCellDelegate: FeedTableCellDelegate?
    
    var feedOriginFrame: FeedOriginalFrame? {
    
        didSet {
            feedOriginFrame?.isShowFullText = self.isShowFullText
            self.removeAllSubviews()
            // 添加feed内容
            self.setContentView()

        }
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    // MARK: - 添加相关View
    
    func setContentView() {
        
        let feedModel = self.feedOriginFrame?.feedModel
        
        // 1.头像
        let portraitButton = UIButton(frame: CGRect(x: (feedOriginFrame?.portraitFrame)!.origin.x - 5, y: (feedOriginFrame?.portraitFrame)!.origin.y - 5, width: (feedOriginFrame?.portraitFrame)!.width + 10, height: (feedOriginFrame?.portraitFrame)!.height + 10))
        let portraitView = UIImageView()
        let imageURL = (feedModel?.portraitURL)! + "@80h_80w_1e"
        portraitView.addImageCache(imageURL, placeHolder: "defaultUserImage")
        portraitView.frame = CGRECT(5, 5, portraitButton.frame.width - 10, portraitButton.frame.height - 10)
        portraitButton.backgroundColor = UIColor.white
        portraitButton.addSubview(portraitView)
        
        portraitView.layer.cornerRadius = portraitView.bounds.size.height / 2
        portraitView.clipsToBounds = true
        portraitButton.addTarget(self, action: #selector(FeedCell.checkUserProfile(_:)), for: UIControlEvents.touchUpInside)
        self.addSubview(portraitButton)
        
        // 2.昵称
        let nickname = UILabel()
        nickname.text = feedModel?.displayname
        nickname.frame = (self.feedOriginFrame?.nicknameFrame)!
        nickname.textColor = kNicknameColor
        nickname.font = UIFont.systemFont(ofSize: kCellNicknameFontSize)
        self.addSubview(nickname)
        
        // 3.帖子类别
        let feedTypeLabel = UILabel()
        feedTypeLabel.text = getFeedTypeName((feedModel?.type)!, isBroadcast: (feedModel?.isBroadcast)!)
        feedTypeLabel.frame = (self.feedOriginFrame?.feedTypeFrame)!
        feedTypeLabel.textColor = kAgeColor
        feedTypeLabel.font = UIFont.systemFont(ofSize: kFeedTypeFontSize)
        self.addSubview(feedTypeLabel)
        
        // 4.性别
        let genderLabel = UILabel()
        if feedModel?.gender == "F" {
        
            genderLabel.text = "女"
        }
        else {
        
            genderLabel.text = "男"
        }
        genderLabel.frame = (self.feedOriginFrame?.genderFrame)!
        genderLabel.textColor = kGenderColor
        self.addSubview(genderLabel)
        
        // 5.年龄
        let ageLabel = UILabel()
        ageLabel.text = String.intToString((feedModel?.age)!)
        ageLabel.frame = (self.feedOriginFrame?.ageFrame)!
        ageLabel.textColor = kAgeColor
        self.addSubview(ageLabel)
        
        // 6.病人状态
        let statusLabel = UILabel()
        var statusStr: String = ""
        if  (feedModel?.cancerType)! != "<null>" {
            statusStr += (feedModel?.cancerType)!
        }
        if (feedModel?.pathological)! != "<null>" {
            statusStr += " " + (feedModel?.pathological)!
        }
        if (feedModel?.stage)! != "<null>" {
            statusStr += " " + (feedModel?.stage)!
        }
        statusLabel.text = statusStr
        statusLabel.frame = (self.feedOriginFrame?.userStatusFrame)!
        statusLabel.textColor = kAgeColor
        self.addSubview(statusLabel)
        
        if (feedModel?.highlight) != "" {
            
            // 6.标签
            let highTagsArr: [String] = ((feedModel?.highlight)?.components(separatedBy: " "))!
            var newHighlightTagsArr: [String] = []
            for highTag in highTagsArr {
                if (highTag != "") && (highTag != "<null>") {
                    newHighlightTagsArr.append(highTag)
                }
            }
            let highView = FeedTagView(frame: (self.feedOriginFrame?.cureFrame)!, highTag: newHighlightTagsArr)
            highView.frame = (self.feedOriginFrame?.cureFrame)!
            self.addSubview(highView)
        }
        
        // 7.clinic
        if feedModel?.clinicReport != "" {
            
            let clinicLabel: UILabel = UILabel()
            clinicLabel.text = feedModel?.clinicReport
            clinicLabel.frame = (self.feedOriginFrame?.clinicFrame)!
            clinicLabel.textColor = kClinicColor
            clinicLabel.font = UIFont.systemFont(ofSize: 16)
            self.addSubview(clinicLabel)
        }
        
        
        // 7.帖子内容
        
        let contentLabel = UILabel()
        contentLabel.text = feedModel?.body
        contentLabel.frame = (self.feedOriginFrame?.contentFrame)!
        contentLabel.textColor = kContentColor
        contentLabel.font = UIFont.systemFont(ofSize: kContentFontSize)
        if isShowFullText {
            contentLabel.numberOfLines = 0
            contentLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
        }else{
            contentLabel.numberOfLines = numberOfLinesInFeedVC
            contentLabel.lineBreakMode = NSLineBreakMode.byTruncatingTail
        }

        self.addSubview(contentLabel)
        
        if (feedModel?.hasImage > 0) {
        
            // 8.配图
            let picsView = FeedPhotosView(feedModel: feedModel!, frame: self.feedOriginFrame!.photosFrame!)
            picsView.frame = (self.feedOriginFrame?.photosFrame)!
            
            let originPicArr: Array<String> = ((feedModel!.imageURL).components(separatedBy: ";"))
            var picArr: Array<String> = []
            for picurl in originPicArr {
                if picurl != "" {
                    picArr.append(picurl)
                }
            }
            picsView.picsUrl = picArr
            self.addSubview(picsView)
        }
        
        // 8.tags
        if feedModel?.tags != "" && feedModel?.tags != "<null>" {
            
            let tagsLabel = UILabel()
            tagsLabel.frame = (self.feedOriginFrame?.tagFrame)!
            tagsLabel.textColor = kAgeColor
            // 获取内容
            tagsLabel.text = self.showTagsWithString((feedModel?.tags)!)
            tagsLabel.font = UIFont.systemFont(ofSize: kContentFontSize)
            self.addSubview(tagsLabel)
        }
        
        // 9.toolbar
        let toolsView: PostFeedToolBar = PostFeedToolBar()
        toolsView.frame = (self.feedOriginFrame?.toolBarFrame)!
        toolsView.backgroundColor = UIColor.clear
        toolsView.initVariables(feedModel!)
        toolsView.layoutWithContent()
        self.addSubview(toolsView)
        
        // 10.分割线
        let cellSeparateView: UIView = UIView(frame: CGRect(x: 0, y: toolsView.frame.maxY + 9, width: SCREEN_WIDTH, height: 0.8))
        cellSeparateView.backgroundColor = RGB(221, 221, 224)
        self.addSubview(cellSeparateView)
    }

    // MARK: - 功能方法
    
    // MARK: tag标签处理
    
    func showTagsWithString(_ tagsStr: String) -> String {
    
        let tagArr: Array<String> = tagsStr.components(separatedBy: "**")
        
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
        resultStr = result.substring(to: result.length - 2)
        
        return resultStr
    }
    
    func checkUserProfile(_ sender: UIButton){
        feedTableCellDelegate?.checkUserProfile(((self.feedOriginFrame?.feedModel)?.insertUsername)!)
    }
    
}
