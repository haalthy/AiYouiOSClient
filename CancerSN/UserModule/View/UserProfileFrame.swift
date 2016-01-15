//
//  UserProfileFrame.swift
//  CancerSN
//
//  Created by hui luo on 6/1/2016.
//  Copyright © 2016 lily. All rights reserved.
//

import Foundation

//segment section
let myProfileStr: String = String("与我相关")
let herProfileStr: String = String("与她相关")
let hisProfileStr: String = String("与他相关")
let processHeaderStr: String = String("治疗过程")

//nickname
let nicknameFont = UIFont.systemFontOfSize(14)
let nicknameColor = UIColor.init(red: 51 / 255.0, green: 51 / 255.0, blue: 51 / 255.0, alpha: 1)

//关注 按钮
let followBtnTopSpace: CGFloat = CGFloat(65)
let followBtnWidth: CGFloat = CGFloat(64)
let followBtnHeight: CGFloat = CGFloat(40)
let followBtnRightSpace: CGFloat = CGFloat(15)
let cornerRadius: CGFloat = CGFloat(2)
let followBtnBorderWidth: CGFloat = CGFloat(1)
let followBtnBorderColor: UIColor = UIColor.init(red:228 / 255.0, green:228 / 255.0, blue:228 / 255.0, alpha:1)

//chart图表内框架设置
let userProfileChartHeaderFontSize: UIFont = UIFont.systemFontOfSize(12)

//chart header左距离
let chartHeaderLeftSpace: CGFloat = CGFloat(30)
//chart header item间距
let chartHeaderSpaceBetweenItems: CGFloat = CGFloat(34)
//chart header top space
let chartHeaderTopSpace: CGFloat = CGFloat(7)

//chart主背景色
let chartBackgroundColor : UIColor = UIColor.init(red:242 / 255.0, green:248 / 255.0, blue:248 / 255.0, alpha:1)

//treatment header title
let treatmentHeaderStr: String = "治疗过程"
//“治疗过程”字体
let treatmentHeaderFont: UIFont = UIFont.systemFontOfSize(13)
//"治疗过程"左边距
let treatmentHeaderLeftSpace: CGFloat = CGFloat(15)
//"治疗过程"上边距
let treatmentHeaderTopSpace: CGFloat = CGFloat(16)

//treatment title
let treatmentTitleFont: UIFont = UIFont.systemFontOfSize(17)
let treatmentTitleColor : UIColor = UIColor.init(red:102 / 255.0, green:102 / 255.0, blue:102 / 255.0, alpha:1)
let dosageFont: UIFont = UIFont.systemFontOfSize(13)
let dosageColor : UIColor = UIColor.init(red:153 / 255.0, green:153 / 255.0, blue:143 / 255, alpha:1)
let dateFont: UIFont = UIFont.systemFontOfSize(12)
let dateColor : UIColor = UIColor.init(red:204 / 255.0, green:204 / 255.0, blue:204 / 255.0, alpha:1)
//treatment frame
let treatmentTitleLeftSpace: CGFloat = CGFloat(15)
let treatmentTitleRightSpace: CGFloat = CGFloat(15)
let treatmentTitleTopSpace: CGFloat = CGFloat(14)
//dosage frame
let dosageTopSpace: CGFloat = CGFloat(7.5)
let dosageLeftSpace: CGFloat = CGFloat(15)
let dosageRightSpace: CGFloat = CGFloat(15)
let dosageButtomSpace: CGFloat = CGFloat(14)

//treatment date frame设置
let treatmentDateRightSpace: CGFloat = CGFloat(15)
let treatmentDateW: CGFloat = CGFloat(117)
let treatmentDateTopSpace: CGFloat = CGFloat(17)
let treatmentDateH: CGFloat = CGFloat(12)

//seperator Line
let seperatorLineColor = UIColor.init(red:221 / 255.0, green:221 / 255.0, blue:224 / 255.0, alpha:1)
let seperatorLineH:CGFloat = CGFloat(0.5)

//空窗期
let noTreatmentTimeStr: String = String("空窗期")

//patientstatus cell
let patientstatusHighlightLeftSpace: CGFloat = CGFloat(15)
let patientstatusHighlightTopSpace: CGFloat = CGFloat(13)
let patientstatusHighlightSpaceBetweenItems: CGFloat = CGFloat(7.5)
let patientstatusHighlightButtomSpace: CGFloat = CGFloat(7.5)
let patientstatusHighlightRightSpace: CGFloat = CGFloat(15)
let patientstatusHighlightButtonVerticalEdge: CGFloat = CGFloat(2.5)
let patientstatusHighlightButtonHorizonEdge: CGFloat = CGFloat(4)
let patientstatusHighlightButtonHeight: CGFloat = CGFloat(20)
let patientstatusHighlightFont = UIFont.systemFontOfSize(12)
let patientstatusHighlightColor:UIColor = UIColor.init(red:51 / 255.0, green:51 / 255.0, blue:51 / 255.0, alpha:1)
let patientstatusHighlightBorderWidth: CGFloat = CGFloat.init(1)
let patientstatusHighlightBorderColor: UIColor = UIColor.init(red:153 / 255.0, green:153 / 255.0, blue:153 / 255.0, alpha:1)
let letpatientstatusHighlightCorner: CGFloat = CGFloat(2)

let patientstatusDetailLeftSpace: CGFloat = CGFloat(16)
let patientstatusDetailButtomSpace: CGFloat = CGFloat(13)
let patientstatusDetailRightSpace: CGFloat = CGFloat(16)
let patientstatusDetailTopSpace: CGFloat = CGFloat(7.5)

let patientstatusDetailFont: UIFont = UIFont.systemFontOfSize(13)
let patientstatusDetailColor: UIColor = UIColor.init(red:153 / 255.0, green:153 / 255.0, blue:153 / 255.0, alpha:1)

let patientstatusDateRightSpace: CGFloat = CGFloat(15)
let patientstatusDateTopSpace: CGFloat = CGFloat(17)
let patientstatusDateW: CGFloat = CGFloat(54)
let patientstatusDateH: CGFloat = CGFloat(12)

let imageLeftSpace: CGFloat = CGFloat(15)
let imageTopSpace: CGFloat = CGFloat(7.5)
let imageButtomSpace: CGFloat = CGFloat(16)
let spaceBetweenImages: CGFloat = CGFloat(2)
let imageWidth: CGFloat = CGFloat(80)

//patientstatus分隔字符串
let patientstatusSeperateStr: String = String("::")

//与我相关
let relatedToMe: NSArray = ["我的信息列表", "@我的", "关注", "基本资料"]
let cellHeight: CGFloat = CGFloat(49)
let cellTextColor: UIColor = UIColor.init(red: 51 / 255.0, green: 51 / 255.0, blue: 51 / 255.0, alpha: 1)
let cellTextFont: UIFont = UIFont.systemFontOfSize(15)
//退出登录
let logoutCellHeight: CGFloat = CGFloat(105)
let logoutBtnTopSpace: CGFloat = CGFloat(30)
let logoutBtnLeftSpace: CGFloat = CGFloat(15)
let logoutBtnRightSpce: CGFloat = CGFloat(15)
let logoutBtnHeight: CGFloat = CGFloat(45)
let logoutBtnTextFont: UIFont = UIFont.systemFontOfSize(17)

//chart图表
let chartLeftSpace: CGFloat = CGFloat(18)
let spaceBetweenClinicItems: CGFloat = CGFloat(43)
let chartButtomLineButtomSpace: CGFloat =  CGFloat(33)
let chartButtomLineTopSpace: CGFloat =  CGFloat(158)
let chartButtomLineHeight: CGFloat = CGFloat(1)
let chartButtomLineColor: UIColor = UIColor.init(red:204 / 255.0, green:204 / 255.0, blue:204 / 255.0, alpha:1)
let chartDateLabelWidth: CGFloat = CGFloat(26)
let chartDateLabelHeight: CGFloat = CGFloat(9)
let chartDateTopSpace: CGFloat = CGFloat(2)
let chartDateFont = UIFont.systemFontOfSize(9)

