//
//  PatientStatusFrame.swift
//  CancerSN
//
//  Created by hui luo on 13/1/2016.
//  Copyright © 2016 lily. All rights reserved.
//

import Foundation

class PatientStatusFrame: NSObject {
    
    var cellHeight: CGFloat!
    
    var cellWidth: CGFloat?
//
//    var dateFrame: CGRect?
//    
//    var highlightFrame: CGRect?
//    
//    var detailFrame: CGRect?
//    
    var patientStatus = PatientStatusObj(){
        didSet{
            getHeight()
        }
    }
    
    // MARK: - 设置frame
    
    func getHeight() {
        var highlightStr: String?
        var detailStr: String?
        var scanDataStr: String?
        
        if ( patientStatus.scanData != ""){
            scanDataStr = patientStatus.scanData
        }
        if ( patientStatus.statusDesc != ""){
            let patientstatusHighlightStr = patientStatus.statusDesc
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
        let patientstatusHighlightMaxW = cellWidth! - patientstatusDateW - patientstatusDateRightSpace - patientstatusHighlightLeftSpace - patientstatusHighlightSpaceBetweenItems
        let patientsDetailMaxW = cellWidth! - patientstatusDetailLeftSpace - patientstatusDetailRightSpace
        
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
            let patientstatusDetail = UILabel(frame: CGRect(x: patientstatusX, y: patientstatusY, width: (patientstatusDetailStrSize?.width)!, height: (patientstatusDetailStrSize?.height)!))
            patientstatusDetail.numberOfLines = 0
            patientstatusY += patientstatusDetail.frame.height
        }
        
        if (patientStatus.imageURL != "") && (patientStatus.imageURL != "<null>"){
            let imageURLStr: String = patientStatus.imageURL
            let imageURLArr = imageURLStr.componentsSeparatedByString(";")
            patientstatusX = imageLeftSpace
            patientstatusY += imageTopSpace
            
            let feedModel = PostFeedStatus()
            feedModel.imageURL = imageURLStr
//            feedModel.picArr = imageURLArr
            
            //配图
            
            let photosSize: CGSize = FeedPhotosView.layoutForPhotos(imageURLArr.count)
            patientstatusY += photosSize.height + imageTopSpace
        }
        
        cellHeight = patientstatusY + patientstatusDetailButtomSpace
    }
    
}