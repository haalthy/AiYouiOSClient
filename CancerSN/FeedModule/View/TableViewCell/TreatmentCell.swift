//
//  TreatmentCell.swift
//  CancerSN
//
//  Created by lily on 2/29/16.
//  Copyright © 2016 lily. All rights reserved.
//

import UIKit

class TreatmentCell: UITableViewCell {
    let itemTopSpace: CGFloat = 20
    
    let portraitLeftSpace: CGFloat = 16
    let portraitLength: CGFloat = 40
    
    let profileLeftSpace: CGFloat = 66
    let textFont: UIFont = UIFont.systemFontOfSize(12)
    
    let highlightTopSpace: CGFloat = 42
    let highlightVerticalMargin: CGFloat = 2.5
    let highlightHorizonMargin: CGFloat = 4
    let highlightBtnHeight: CGFloat = 18
    
    let bodyFont: UIFont = UIFont.systemFontOfSize(14)
    
    let dateTopSpace: CGFloat = 12
    
    var treatmentObj = TreatmentModel(){
        didSet{
            updateUI()
        }
    }
    
    func updateUI(){
        self.removeAllSubviews()
        let portraitImage = UIImageView(frame: CGRect(x: portraitLeftSpace, y: itemTopSpace, width: portraitLength, height: portraitLength))
        let imageURL = treatmentObj.imageURL + "@80h_80w_1e"
        portraitImage.addImageCache(imageURL, placeHolder: placeHolderStr)
        portraitImage.layer.cornerRadius = portraitLength / 2
        portraitImage.layer.masksToBounds = true
        self.addSubview(portraitImage)
        
        let profileLabel  = UILabel(frame: CGRect(x: profileLeftSpace, y: itemTopSpace, width: screenWidth - profileLeftSpace, height: 13))
        profileLabel.text = treatmentObj.displayname + " " + treatmentObj.gender + " " + String(treatmentObj.age) + " " + treatmentObj.cancerType
        profileLabel.font = textFont
        profileLabel.textColor = lightTextColor
        self.addSubview(profileLabel)
        
        let highLightList = treatmentObj.treatmentName.componentsSeparatedByString(" ")
        var buttonX: CGFloat = profileLeftSpace
        var buttonY: CGFloat = highlightTopSpace
        for highLight in highLightList {
            if (highLight != "") {
                let buttonText = highLight.sizeWithFont(textFont, maxSize: CGSize(width: screenWidth, height: 12))
                if (buttonX + buttonText.width + buttonTitleLabelHorizonMargin * 2) > screenWidth {
                    buttonX = profileLeftSpace
                    buttonY += 26
                }
                let highLightButton = UIButton(frame: CGRect(x: buttonX, y: buttonY, width: buttonText.width + highlightHorizonMargin * 2, height: highlightBtnHeight))
                highLightButton.setTitle(highLight, forState: UIControlState.Normal)
                highLightButton.setTitleColor(defaultTextColor, forState: UIControlState.Normal)
                highLightButton.layer.borderColor = lightTextColor.CGColor
                highLightButton.layer.borderWidth = 1
                highLightButton.layer.cornerRadius = 2
                highLightButton.layer.masksToBounds = true
                highLightButton.titleLabel?.font = textFont
                buttonX += buttonText.width + 15
                self.addSubview(highLightButton)
            }
        }
        
        let dosageLabeSize = treatmentObj.dosage.sizeWithFont(bodyFont, maxSize: CGSize(width: screenWidth - profileLeftSpace, height: 38))
        
        let dosageLabel = UILabel(frame: CGRect(x: profileLeftSpace, y: buttonY + 30, width: screenWidth - profileLeftSpace, height: dosageLabeSize.height))
        dosageLabel.numberOfLines = 2
        dosageLabel.textColor = defaultTextColor
        dosageLabel.font = bodyFont
        dosageLabel.text = treatmentObj.dosage
        self.addSubview(dosageLabel)
        
        //date label
        // add date button
        let beginDateStr = (treatmentObj.beginDate as! NSString).substringToIndex(10)
        let endDateStr = (treatmentObj.endDate as! NSString).substringToIndex(10)
        let dateLabel = UILabel(frame: CGRect(x: profileLeftSpace, y: dosageLabel.frame.origin.y + dosageLabel.frame.height, width: screenWidth - profileLeftSpace, height: 13))
        dateLabel.text = beginDateStr + "-" + endDateStr
        dateLabel.textColor = lightTextColor
        dateLabel.font = textFont
        self.addSubview(dateLabel)
        
        //seperate line
        let seperateLine = UIView(frame: CGRect(x: 0, y: self.frame.height - 1, width: screenWidth, height: 1))
        seperateLine.backgroundColor = seperateLineColor
        self.addSubview(seperateLine)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
