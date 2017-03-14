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

func RGBA(_ r: CGFloat, _ g: CGFloat, _ b: CGFloat, _ a: CGFloat) -> UIColor {

    return UIColor(red: r / 255.0, green: g / 255.0, blue: b / 255.0, alpha: a)
}

// RGB颜色方法

func RGB(_ r: CGFloat, _ g: CGFloat, _ b: CGFloat) -> UIColor {
    
    return UIColor(red: r / 255.0, green: g / 255.0, blue: b / 255.0, alpha: 1.0)
}

// frameMake方法

func CGRECT(_ x: CGFloat, _ y: CGFloat, _ w: CGFloat, _ h: CGFloat) -> CGRect {

    return CGRect(x: x, y: y, width: w, height: h)
}

// MARK: - 常用常量

// 屏幕尺寸
let SCREEN_WIDTH = UIScreen.main.bounds.width
let SCREEN_HEIGHT = UIScreen.main.bounds.height

// 系统版本
let IOS_7 = (UIDevice.current.systemVersion as NSString).doubleValue >= 7.0
let IOS_8 = (UIDevice.current.systemVersion as NSString).doubleValue >= 8.0
let IOS_9 = (UIDevice.current.systemVersion as NSString).doubleValue >= 9.0


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

let genderMapping = NSDictionary(objects:["M","F"], forKeys:["男" as NSCopying,"女" as NSCopying])
let cancerTypeMapping = NSDictionary(objects: ["liver", "kidney", "lung", "bravery", "intestine", "stomach", "female", "blood"], forKeys: ["肝癌" as NSCopying, "肾癌" as NSCopying, "肺癌" as NSCopying, "胆管癌" as NSCopying, "肠癌" as NSCopying, "胃癌" as NSCopying, "妇科" as NSCopying, "血液" as NSCopying])
let pathologicalMapping = NSDictionary(objects: ["adenocarcinoma","carcinoma","AdenosquamousCarcinoma"], forKeys: ["腺癌" as NSCopying,"鳞癌" as NSCopying,"腺鳞癌" as NSCopying])
let stageMapping = NSDictionary(objects: [1,2,3,4], forKeys: ["I" as NSCopying,"II" as NSCopying,"III" as NSCopying,"IV" as NSCopying])
let smokingMapping = NSDictionary(objects: [0,1], forKeys: ["否" as NSCopying,"是" as NSCopying])
let metastasisMapping = NSDictionary(objects: ["liver","bone","adrenal","brain"], forKeys: ["肝转移" as NSCopying,"骨转移" as NSCopying,"肾上腺转移" as NSCopying,"脑转移" as NSCopying])
let geneticMutationMapping = NSDictionary(objects: ["KRAS", "EGFR", "ALK", "OTHERS", "NONE"], forKeys: ["KRAS" as NSCopying,"EGFR" as NSCopying,"ALK" as NSCopying,"其他" as NSCopying,"没有基因突变" as NSCopying])

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

let defaultTreatmentEndDate: TimeInterval = 1767225600
//默认图片背景色（当图片加载错误时）edeeee
let imageViewBackgroundColor: UIColor = UIColor.init(red:237 / 255.0, green:238 / 255.0, blue:238 / 255.0, alpha:1)

//屏幕宽 高
var screenWidth = CGFloat()
var screenHeight = CGFloat()

let uploadImageSize: CGSize = CGSize(width: 400, height: 600)

let qqAppID: String = "1105273097"

let WXAppID: String = "wx1606d9f1f10de6b4"

let WXAppSecret: String = "1b6d6a7b5c2fced9436deee258e4ef58"

let numberOfLinesInFeedVC: Int = 6

//网络异常代码
let networkErrorCode = "-1000"
