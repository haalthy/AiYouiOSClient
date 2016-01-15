//
//  PatientStatusTableViewCell.swift
//  CancerSN
//
//  Created by lily on 9/4/15.
//  Copyright (c) 2015 lily. All rights reserved.
//

import UIKit

class PatientStatusTableViewCell: UITableViewCell {
    
    @IBOutlet weak var patientStatusDetail: UILabel!

    @IBOutlet weak var patientStatusDate: UILabel!
    
    var indexPath: NSIndexPath?
    
    //自定义变量
    var cellWidth: CGFloat = CGFloat()
    
    var patientStatus = NSDictionary(){
        didSet{
            updateUI()
        }
    }
    
    func updateUI(){
        self.removeAllSubviews()
        cellWidth = self.frame.width
        var highlightStr: String?
        var detailStr: String?
        var scanDataStr: String?

        if ( patientStatus.objectForKey("scanData") != nil ) && ((patientStatus.objectForKey("scanData") is NSNull) == false) && ((patientStatus.objectForKey("scanData") as! String) != ""){
            scanDataStr = patientStatus.objectForKey("scanData") as! String
        }
        if ( patientStatus.objectForKey("statusDesc") != nil ) && ((patientStatus.objectForKey("statusDesc") is NSNull) == false) && ((patientStatus.objectForKey("statusDesc") as! String) != ""){
            let patientstatusHighlightStr = (patientStatus.objectForKey("statusDesc") as! String)
            let patientstatusHighlightAndDesp = patientstatusHighlightStr.componentsSeparatedByString(patientstatusSeperateStr)
            if patientstatusHighlightAndDesp.count > 1 {
                highlightStr = patientstatusHighlightAndDesp[0]
                detailStr = patientstatusHighlightAndDesp[1]
            }else{
                detailStr = patientstatusHighlightAndDesp[0]
            }
        }
        if (scanDataStr != nil){
            if (detailStr != nil){
                detailStr = detailStr! + "\n" + scanDataStr!
            }else{
                detailStr = scanDataStr
            }
        }
        var patientstatusX: CGFloat = patientstatusHighlightLeftSpace
        var patientstatusY: CGFloat = patientstatusHighlightTopSpace
        let patientstatusHighlightMaxW = cellWidth - patientstatusDateW - patientstatusDateRightSpace - patientstatusHighlightLeftSpace - patientstatusHighlightSpaceBetweenItems
        let patientsDetailMaxW = cellWidth - patientstatusDetailLeftSpace - patientstatusDetailRightSpace
        
        let dateLabel = UILabel(frame: CGRect(x: cellWidth - patientstatusDateW - patientstatusDateRightSpace, y: patientstatusY, width: patientstatusDateW, height: patientstatusDateH))
        let insertedDate = NSDate(timeIntervalSince1970: (patientStatus.objectForKey("insertedDate") as! Double)/1000 as NSTimeInterval)
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yy/MM/dd" // superset of OP's format
        let insertedDateStr = dateFormatter.stringFromDate(insertedDate)
        dateLabel.text = insertedDateStr
        dateLabel.font = dateFont
        dateLabel.textColor = dateColor
        self.addSubview(dateLabel)
        
        if highlightStr != nil && highlightStr != "" {
            let  patientstatusHighlightArr = highlightStr!.componentsSeparatedByString(" ")
            var patientstatusHighlightButtonX = patientstatusHighlightLeftSpace
            var patientstatusHighlightButtonY = patientstatusHighlightTopSpace
            for patientstatusHighlightItemStr in patientstatusHighlightArr{
                let whitespace = NSCharacterSet.whitespaceAndNewlineCharacterSet()
                patientstatusHighlightItemStr.stringByTrimmingCharactersInSet(whitespace)
                if patientstatusHighlightItemStr != "" {
                    let patientstatusHighlightStrSize = patientstatusHighlightItemStr.sizeWithFont(patientstatusHighlightFont, maxSize: CGSize(width: patientstatusHighlightMaxW, height: CGFloat.max))
                    let patientstatusHighlightButtonW: CGFloat = patientstatusHighlightStrSize.width + patientstatusHighlightButtonHorizonEdge * 2
                    let patientstatusHighlightButtonH: CGFloat = patientstatusHighlightStrSize.height + patientstatusHighlightButtonVerticalEdge * 2
                    if (patientstatusHighlightButtonX + patientstatusHighlightButtonW) > patientstatusHighlightMaxW {
                        patientstatusHighlightButtonX = patientstatusHighlightLeftSpace
                        patientstatusHighlightButtonY += patientstatusHighlightButtonHeight
                    }
                    let patientstatusHighlightButton = UIButton(frame: CGRect(x: patientstatusHighlightButtonX, y: patientstatusHighlightButtonY, width: patientstatusHighlightButtonW, height: patientstatusHighlightButtonH))
                    patientstatusHighlightButton.setTitle(patientstatusHighlightItemStr, forState: UIControlState.Normal)
                    patientstatusHighlightButton.setTitleColor(patientstatusHighlightColor, forState: UIControlState.Normal)
                    patientstatusHighlightButton.titleLabel?.font = patientstatusHighlightFont
                    patientstatusHighlightButtonX += patientstatusHighlightButtonW + patientstatusHighlightSpaceBetweenItems
                    patientstatusHighlightButton.layer.borderWidth = patientstatusHighlightBorderWidth
                    patientstatusHighlightButton.layer.borderColor = patientstatusHighlightBorderColor.CGColor
                    patientstatusHighlightButton.layer.cornerRadius = letpatientstatusHighlightCorner
                    patientstatusHighlightButton.layer.masksToBounds = true
                    self.addSubview(patientstatusHighlightButton)
                }
            }
            patientstatusY = patientstatusHighlightButtonY + patientstatusHighlightButtonHeight
        }
        if detailStr != nil{
            var detailWidth: CGFloat = patientsDetailMaxW
            if patientstatusY < patientstatusHighlightTopSpace + 1 {
                detailWidth = patientstatusHighlightMaxW
            }
            let patientstatusDetailStrSize = detailStr?.sizeWithFont(patientstatusDetailFont, maxSize: CGSize(width: detailWidth, height: CGFloat.max))
            let patientstatusDetail = UILabel(frame: CGRect(x: patientstatusX, y: patientstatusY, width: detailWidth, height: (patientstatusDetailStrSize?.height)!))
            patientstatusDetail.text = detailStr
            patientstatusDetail.font = patientstatusDetailFont
            patientstatusDetail.textColor = patientstatusDetailColor
            patientstatusDetail.numberOfLines = 0
            self.addSubview(patientstatusDetail)
            patientstatusY += patientstatusDetail.frame.height
        }
        let seperatorLine:UIView = UIView(frame: CGRect(x: treatmentTitleLeftSpace, y: 0, width: cellWidth - treatmentTitleLeftSpace, height: seperatorLineH))
        seperatorLine.backgroundColor = seperateLineColor
        if (patientStatus.objectForKey("imageURL") != nil) && ((patientStatus.objectForKey("imageURL") is NSNull) == false) && ((patientStatus.objectForKey("imageURL") as! String) != ""){
            let imageURLStr: String = patientStatus.objectForKey("imageURL") as! String
            var imageURLArr = imageURLStr.componentsSeparatedByString(";")
            var imageIndex: Int = 0
            for imageURL in imageURLArr{
                let whitespace = NSCharacterSet.whitespaceAndNewlineCharacterSet()
                imageURL.stringByTrimmingCharactersInSet(whitespace)
                if imageURL == ""{
                    imageURLArr.removeAtIndex(imageIndex)
                }
                imageIndex++
            }
            patientstatusX = imageLeftSpace
            patientstatusY += imageTopSpace
            var feedModel = PostFeedStatus()
            feedModel.imageURL = imageURLStr
//            feedModel.picArr = imageURLArr
            
            //配图
            let photosX: CGFloat = patientstatusX
            let photosY: CGFloat = patientstatusY
            
            let photosSize: CGSize = FeedPhotosView.layoutForPhotos((imageURLArr.count))
            let photosFrame = CGRECT(photosX, photosY, photosSize.width, photosSize.height)
            
            let picsView = FeedPhotosView(feedModel: feedModel, frame: photosFrame)
            picsView.frame = photosFrame
            picsView.picsUrl = imageURLArr
            self.addSubview(picsView)
        }
        self.addSubview(seperatorLine)
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
