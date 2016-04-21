//
//  StaticVariables.swift
//  CancerSN
//
//  Created by lay on 15/12/16.
//  Copyright © 2015年 lily. All rights reserved.
//

import Foundation
import UIKit

// MARK: - Function

// RGBA颜色方法

func RGBA(r: CGFloat, _ g: CGFloat, _ b: CGFloat, _ a: CGFloat) -> UIColor {

    return UIColor(red: r / 255.0, green: g / 255.0, blue: b / 255.0, alpha: a)
}

// RGB颜色方法

func RGB(r: CGFloat, _ g: CGFloat, _ b: CGFloat) -> UIColor {
    
    return UIColor(red: r / 255.0, green: g / 255.0, blue: b / 255.0, alpha: 1.0)
}

// frameMake方法

func CGRECT(x: CGFloat, _ y: CGFloat, _ w: CGFloat, _ h: CGFloat) -> CGRect {

    return CGRectMake(x, y, w, h)
}

// MARK: - 常用常量

// 屏幕尺寸
let SCREEN_WIDTH = UIScreen.mainScreen().bounds.width
let SCREEN_HEIGHT = UIScreen.mainScreen().bounds.height

// 系统版本
let IOS_7 = (UIDevice.currentDevice().systemVersion as NSString).doubleValue >= 7.0
let IOS_8 = (UIDevice.currentDevice().systemVersion as NSString).doubleValue >= 8.0
let IOS_9 = (UIDevice.currentDevice().systemVersion as NSString).doubleValue >= 9.0


// MARK: - String Name

//store ImageFilename
let imageFileName = "portrait.jpg"

let usernameKeyChain = "haalthyUsernameIdentifier"
let passwordKeyChain = "haalthyPasswordIdentifier"

// MARK: String Timestamp

let latestBroadcastUpdateTimestamp = "haalthyLatestBroadcastUpdateTimestamp"
let latestFeedsUpdateTimestamp = "haalthyLatestFeedsUpdateTimestamp"

let placeHolderStr = "icon_placeholder"

// 计算判断是否加红点key
let unreadCommentBadgeCount = "unreadCommentBadgeCount"

let unreadFollowBadgeCount = "unreadFollowBadgeCount"

let unreadMentionedBadgeCount = "unreadMentionedBadgeCount"


// 删除tabbar红点通知
let deleteTabbarRedDotBadge = "deleteTabbarRedDotBadge"

// 添加tabbar红点通知
let addTabbarRedDotBadge = "addTabbarRedDotBadge"

// Remote Notification

let appKey = "659e4023ae5d594b3ab2cf81"

let channel = "Publish channel"

let isProduction: Bool = true

let kDeviceToken = "kDeviceToken"

//store info in NSUserData
let setTagListTimeStamp = "setTagListTimeStamp"
let favTagsNSUserData = "favoriteTags"
let genderNSUserData = "haalthyUserGender"
let ageNSUserData = "haalthyUserAge"
let cancerTypeNSUserData = "haalthyUserCancertype"
let pathologicalNSUserData = "haalthyUserPathological"
let stageNSUserData = "haalthyUserStage"
let smokingNSUserData = "haalthyUserSmoking"
let metastasisNSUserData = "haalthyUserMetastasis"
let geneticMutationNSUserData = "haalthyUserGeneticMutation"
let emailNSUserData = "haalthyUserEmail"
let phoneNSUserData = "haalthyUserPhone"
let accessNSUserData = "haalthyUserAccessToken"
let refreshNSUserData = "haalthyUserRefreshToken"
let imageNSUserData = "haalthyUserImageToken"
let displaynameUserData = "haalthyUserDisplayname"
let userTypeUserData = "haalthyUserType"
let qqUserType = "QQ"
let aiyouUserType = "AY"
let wechatUserType = "WC"

let newTreatmentBegindate = "haalthyNewTreatmentBeginDate"
let newTreatmentEnddate = "haalthyNewTreatmentEndDate"

// MARK: - UI Displayname<--> Database Mapping

let genderMapping = NSDictionary(objects:["M","F"], forKeys:["男","女"])
let cancerTypeMapping = NSDictionary(objects: ["liver", "kidney", "lung", "bravery", "intestine", "stomach", "female", "blood"], forKeys: ["肝癌", "肾癌", "肺癌", "胆管癌", "肠癌", "胃癌", "妇科", "血液"])
let pathologicalMapping = NSDictionary(objects: ["adenocarcinoma","carcinoma","AdenosquamousCarcinoma"], forKeys: ["腺癌","鳞癌","腺鳞癌"])
let stageMapping = NSDictionary(objects: [1,2,3,4], forKeys: ["I","II","III","IV"])
let smokingMapping = NSDictionary(objects: [0,1], forKeys: ["否","是"])
let metastasisMapping = NSDictionary(objects: ["liver","bone","adrenal","brain"], forKeys: ["肝转移","骨转移","肾上腺转移","脑转移"])
let geneticMutationMapping = NSDictionary(objects: ["KRAS", "EGFR", "ALK", "OTHERS", "NONE"], forKeys: ["KRAS","EGFR","ALK","其他","没有基因突变"])

// MARK: - Color

// navigation Bar color
let headerColor : UIColor = UIColor.init(red:61 / 255.0, green:208 / 255.0, blue:221 / 255.0, alpha:1)

// tab Bar color
let tabBarColor : UIColor = UIColor.init(red:244 / 255.0, green:251 / 255.0, blue:252 / 255.0, alpha:0.3)

let tabBarItemNormalColor : UIColor = UIColor.init(red: 141 / 255.0, green: 162 / 255.0, blue: 164 / 255.0, alpha: 1)

let textInputViewPlaceholderColor: UIColor = UIColor(red: 221 / 255, green: 221 / 255, blue: 224 / 255, alpha: 1)

let defaultTextColor : UIColor = UIColor.init(red: 102 / 255, green: 102 / 255, blue: 102 / 255, alpha: 1)
let lightTextColor : UIColor = UIColor.init(red: 153 / 255, green: 153 / 255, blue: 153 / 255, alpha: 1)
let ultraLightTextColor: UIColor = UIColor.init(red: 202 / 255, green: 202 / 255, blue: 202 / 255, alpha: 1)

let highlightColor : UIColor = UIColor.init(red:0.15, green:0.75, blue:0.85, alpha:1)
let textColor : UIColor = UIColor.init(red:0.28, green:0.75, blue:0.85, alpha:1)
let lightBackgroundColor : UIColor = UIColor.init(red:0.15, green:0.75, blue:0.85, alpha:0.4)
let mainColor : UIColor = UIColor.init(red:0.28, green:0.75, blue:0.85, alpha:1)
let sectionHeaderColor: UIColor = UIColor.init(red:0.15, green:0.67, blue:0.8, alpha:0.2)

let fontStr: String = "Helvetica"

let fontBoldStr: String = "Helvetica-Bold"

let seperateLineColor: UIColor = UIColor.init(red:221 / 255.0, green:221 / 255.0, blue:224 / 255.0, alpha:1)

let defaultTreatmentEndDate: NSTimeInterval = 1767225600
//默认图片背景色（当图片加载错误时）edeeee
let imageViewBackgroundColor: UIColor = UIColor.init(red:237 / 255.0, green:238 / 255.0, blue:238 / 255.0, alpha:1)

//屏幕宽 高
var screenWidth = CGFloat()
var screenHeight = CGFloat()

let uploadImageSize: CGSize = CGSize(width: 400, height: 600)

let qqAppID: String = "1104886596"

let WXAppID: String = "wxd930ea5d5a258f4f"

let WXAppSecret: String = "145f45c39e367d6b2cf9865cf1971096"

let numberOfLinesInFeedVC: Int = 6

//网络异常代码
let networkErrorCode = "-1000"
