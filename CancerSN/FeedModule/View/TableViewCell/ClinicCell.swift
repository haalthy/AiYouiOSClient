//
//  ClinicCell.swift
//  CancerSN
//
//  Created by lay on 16/2/24.
//  Copyright © 2016年 lily. All rights reserved.
//

import UIKit

protocol ClinicCellDelegate{
    func updateCellHeight(height: CGFloat)
    
}

class ClinicCell: UITableViewCell {
    
    var clinicCellDelegate: ClinicCellDelegate?
    
    let otherInfoLabel = UILabel()
    let getMoreBtn = UIButton()
    let seperateLine = UIView()
    
    let labelLeftSpace: CGFloat = 15
    
    let drugNameTopSpace: CGFloat = 15
    let drugNameFont: UIFont = UIFont.systemFontOfSize(14)
    
    let labelButtonSpace: CGFloat = 15
    
    let otherInfoTopSpace: CGFloat = 39
    let otherInfoFont = UIFont.systemFontOfSize(13)
    
    var otherInfoStr: String = ""
    
    var clinicTrial = ClinicTrailObj(){
        didSet{
            initVariables()
            updateUI()
        }
    }
    
    func initVariables(){
        otherInfoStr = clinicTrial.subGroup + " " + clinicTrial.stage + "\n" + clinicTrial.effect + "\n" + clinicTrial.sideEffect + "\n" + clinicTrial.researchInfo
    }
    
    func updateUI(){
        self.removeAllSubviews()
        
        let drugnameLabel = UILabel(frame: CGRect(x: labelLeftSpace, y: drugNameTopSpace, width: screenWidth - labelLeftSpace * 2, height: 14))
        drugnameLabel.text = clinicTrial.drugName
        drugnameLabel.textColor = headerColor
        drugnameLabel.font = drugNameFont
        self.addSubview(drugnameLabel)
        let otherInfoLabelSize = otherInfoStr.sizeWithFont(otherInfoFont, maxSize: CGSize(width: screenWidth - labelLeftSpace * 2, height: CGFloat.max))

        otherInfoLabel.frame = CGRect(x: labelLeftSpace, y: otherInfoTopSpace, width: screenWidth - labelLeftSpace * 2, height:otherInfoLabelSize.height )
        otherInfoLabel.text = otherInfoStr
        otherInfoLabel.textColor = defaultTextColor
        otherInfoLabel.font = otherInfoFont
        otherInfoLabel.numberOfLines = 0
        otherInfoLabel.lineBreakMode = NSLineBreakMode.ByCharWrapping
        self.addSubview(otherInfoLabel)
        
//        getMoreBtn.frame = CGRect(x: labelLeftSpace, y: otherInfoTopSpace + otherInfoLabel.frame.height, width: 50, height: 29)
//        getMoreBtn.setTitle("更多...", forState: UIControlState.Normal)
//        getMoreBtn.setTitleColor(headerColor, forState: UIControlState.Normal)
//        getMoreBtn.titleLabel?.font = otherInfoFont
//        getMoreBtn.titleLabel?.textAlignment = NSTextAlignment.Left
//        getMoreBtn.addTarget(self, action: "addFullText:", forControlEvents: UIControlEvents.TouchUpInside)
//        self.addSubview(getMoreBtn)
        
        seperateLine.frame = CGRect(x: 0, y: self.frame.height - 1, width: screenWidth, height: 1)
        seperateLine.backgroundColor = seperateLineColor
        self.addSubview(seperateLine)
    }
    
//    func addFullText(sender: UIButton){
//        let otherInfoLabelSize = otherInfoStr.sizeWithFont(otherInfoFont, maxSize: CGSize(width: screenWidth - labelLeftSpace * 2, height: CGFloat.max))
//        otherInfoLabel.frame = CGRect(x: labelLeftSpace, y: otherInfoTopSpace, width: screenWidth - labelLeftSpace * 2, height:otherInfoLabelSize.height)
//        otherInfoLabel.numberOfLines = 0
//        getMoreBtn.frame = CGRECT(labelLeftSpace, otherInfoLabel.frame.origin.y + otherInfoLabel.frame.height + 9, 50, 29)
//        getMoreBtn.removeTarget(self, action: "showLessText:", forControlEvents: UIControlEvents.TouchUpInside)
//        getMoreBtn.setTitle("收起", forState: UIControlState.Normal)
//        seperateLine.frame = CGRect(x: 0, y: getMoreBtn.frame.origin.y + getMoreBtn.frame.height + 19, width: screenWidth, height: 1)
//        clinicCellDelegate?.updateCellHeight(getMoreBtn.frame.origin.y + getMoreBtn.frame.height + 20)
//    }
//    
//    func showLessText(sender: UIButton){
//        otherInfoLabel.frame = CGRect(x: labelLeftSpace, y: otherInfoTopSpace, width: screenWidth - labelLeftSpace * 2, height:57 )
//        otherInfoLabel.numberOfLines = 4
//        otherInfoLabel.lineBreakMode = NSLineBreakMode.ByCharWrapping
//        
//        getMoreBtn.frame = CGRect(x: labelLeftSpace, y: otherInfoTopSpace + otherInfoLabel.frame.height, width: 50, height: 29)
//        getMoreBtn.setTitle("更多...", forState: UIControlState.Normal)
//        getMoreBtn.addTarget(self, action: "addFullText:", forControlEvents: UIControlEvents.TouchUpInside)
//        clinicCellDelegate?.updateCellHeight(getMoreBtn.frame.origin.y + getMoreBtn.frame.height + 20)
//
//    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
