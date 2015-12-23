//
//  StaticVariables.swift
//  CancerSN
//
//  Created by lay on 15/12/16.
//  Copyright © 2015年 lily. All rights reserved.
//

import Foundation
import UIKit

// MARK: - String Name

//store ImageFilename
let imageFileName = "portrait.jpg"

let usernameKeyChain = "haalthyUsernameIdentifier"
let passwordKeyChain = "haalthyPasswordIdentifier"

// MARK: String Timestamp

let latestBroadcastUpdateTimestamp = "haalthyLatestBroadcastUpdateTimestamp"
let latestFeedsUpdateTimestamp = "haalthyLatestFeedsUpdateTimestamp"


//store info in NSUserData
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
let cancerTypeMapping = NSDictionary(objects: ["liver", "kidney", "lung", "bravery", "intestine", "stomach", "female", "blood"], forKeys: ["肝部", "肾部", "肺部", "胆管", "肠部", "胃部", "妇科", "血液"])
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

let highlightColor : UIColor = UIColor.init(red:0.15, green:0.75, blue:0.85, alpha:1)
let textColor : UIColor = UIColor.init(red:0.28, green:0.75, blue:0.85, alpha:1)
let lightBackgroundColor : UIColor = UIColor.init(red:0.15, green:0.75, blue:0.85, alpha:0.4)
let mainColor : UIColor = UIColor.init(red:0.28, green:0.75, blue:0.85, alpha:1)
let sectionHeaderColor: UIColor = UIColor.init(red:0.15, green:0.67, blue:0.8, alpha:0.2)

let fontStr: String = "Helvetica"

let defaultTreatmentEndDate: NSTimeInterval = 1767225600
