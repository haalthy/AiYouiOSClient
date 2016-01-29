//
//  AddPatientStatusFrame.swift
//  CancerSN
//
//  Created by hui luo on 22/1/2016.
//  Copyright © 2016 lily. All rights reserved.
//

import Foundation

//date section
let patientStatusDateLabelLeftSpace: CGFloat = CGFloat(15)
let patientStatusDateLabelFont: UIFont = UIFont.systemFontOfSize(13)
let patientStatusDataLabelColor: UIColor = UIColor(red: 153 / 255, green: 153 / 255, blue: 153 / 255, alpha: 1)

let patientStatusDateBtnLeftSpace: CGFloat = CGFloat(20)
let patientStatusDateBtnFont: UIFont = UIFont.systemFontOfSize(13)
let patientStatusDataBtnColor: UIColor = UIColor(red: 153 / 255, green: 153 / 255, blue: 153 / 255, alpha: 1)
let patientStatusDropdownLeftSpace: CGFloat = CGFloat(6)
let patientStatusDropdownW: CGFloat = CGFloat(10)

let patientStatusDateSectionHeight: CGFloat = CGFloat(44)

//symptoms section
let symptomsTitleTopSpace: CGFloat = CGFloat(15)
let symptomsSectionLeftSpace: CGFloat = CGFloat(15)
let symptomsFont: UIFont = UIFont.systemFontOfSize(13)
let symptomsTitleStr: String = String("请选择出现的副作用/症状")
let symptomsTitleColor: UIColor = UIColor(red: 153 / 255, green: 153 / 255, blue: 153 / 255, alpha: 1)
let symptomsBtnsTopSpace: CGFloat = CGFloat(13)
let symptomsBtnHeight: CGFloat = CGFloat(29)
let symptomDespTextHorizonSpace:CGFloat = CGFloat(13)
let symptomDespTextTopSpace: CGFloat = CGFloat(13)
let symptomDespTextHeight: CGFloat = CGFloat(135)
let symptomDespText: String = String("请详细描述病人的状态和对应方案：")
let symptomDespFont: UIFont = UIFont.systemFontOfSize(15)

//add more buttom
let addReportButtonLeftSpace = CGFloat(15)
let addReportButtonText: String = String("请输入医院报告")
let addReportButtonFont: UIFont = UIFont.systemFontOfSize(15)
let addReportButtonTextColor: UIColor = UIColor(red: 102 / 255, green: 102 / 255, blue: 102 / 255, alpha: 1)

//clinic report list
let clinicReportTitleListHeight: CGFloat = CGFloat(43)
let clinicReportListLeftSpace: CGFloat = CGFloat(15)
let reportListTitleStr: String = String("请在此输入病人的实验室资料吧")
let reportListTitleColor: UIColor = UIColor(red: 153 / 255, green: 153 / 255, blue: 153 / 255, alpha: 1)
let reportListTitleFont: UIFont = UIFont.systemFontOfSize(13)
let reportListItemColor: UIColor = UIColor(red: 102 / 255, green: 102 / 255, blue: 102 / 255, alpha: 1)
let reportListItemPlaceholder: String = "0.0"
let clinicReportLblW:CGFloat = CGFloat(90)
let clinicReportDelBtnRightSpace: CGFloat = CGFloat(15)
let clinicReportDelBtnWidth:CGFloat = CGFloat(12)
let patientstatusFooterH: CGFloat = CGFloat(44)
let scanReportTopSpace: CGFloat = CGFloat(25)
let scanReportHeight: CGFloat = CGFloat(110)
let scanReportDespStr: String = String("请输入影像资料:")
let scanReportDespFont: UIFont = UIFont.systemFontOfSize(15)