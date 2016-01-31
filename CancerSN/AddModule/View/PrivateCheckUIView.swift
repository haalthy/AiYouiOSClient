//
//  PrivateCheckUIView.swift
//  CancerSN
//
//  Created by hui luo on 25/1/2016.
//  Copyright © 2016 lily. All rights reserved.
//

import UIKit

class PrivateCheckUIView: UIView {

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    let screenWidth = UIScreen.mainScreen().bounds.width
    var checkedSectionView = UIView()
    var isPosted: Int = 1
    let checkbox = UIButton()

    func createCheckedSection()->UIView{
        checkedSectionView = UIView(frame: CGRect(x: 0, y: UIScreen.mainScreen().bounds.height - buttomSectionHeight, width: screenWidth, height: buttomSectionHeight))
        checkedSectionView.backgroundColor = UIColor.whiteColor()
        let btmSeperateLine = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 0.5))
        btmSeperateLine.backgroundColor = seperateLineColor
        checkedSectionView.addSubview(btmSeperateLine)
        checkbox.frame = CGRect(x: checkboxLeftSpace, y: checkboxTopSpace, width: checkboxHeight, height: checkboxHeight)
        checkbox.layer.borderColor = privateLabelColor.CGColor
        checkbox.layer.borderWidth = checkboxBorderWidth
        checkbox.layer.cornerRadius = checkboxCornerRadius
//        checkbox.addTarget(self, action: "checkedPrivate:", forControlEvents: UIControlEvents.TouchUpInside)
        checkedSectionView.addSubview(checkbox)
        let privateLbl = UILabel(frame: CGRect(x: privateLabelLeftSpace, y: 0, width: screenWidth - privateLabelLeftSpace, height: buttomSectionHeight))
        privateLbl.textAlignment = NSTextAlignment.Left
        privateLbl.textColor = privateLabelColor
        privateLbl.text = "不发送到我的智囊圈"
        checkedSectionView.addSubview(privateLbl)
        return checkedSectionView
    }
    

}
