//
//  ChartSummaryTableViewCell.swift
//  CancerSN
//
//  Created by lily on 1/5/16.
//  Copyright © 2016 lily. All rights reserved.
//

import UIKit
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class ChartSummaryTableViewCell: UITableViewCell {
    
    var chartHearderScrollView: UIScrollView!
    var chartScrollView: UIScrollView!
    var treatmentList = Array<TreatmentObj>()
    var chartHeaderCoordinateX = NSMutableArray()
    var chartWidth = CGFloat()
    //初始化变量
    let screenWidth: CGFloat = UIScreen.main.bounds.width
    let buttonIndexPair: NSMutableDictionary = NSMutableDictionary()
    let dataPointsXArr: NSMutableArray = NSMutableArray()
    let dataPointsYArr: NSMutableArray = NSMutableArray()

    //
    let chartItemBottomLine = UIView()
    
    var clinicReportList = Array<ClinicDataObj>(){
        didSet{
            updateUI()
        }
    }
    
    func initContentView() {
        chartHearderScrollView.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: 44)
        chartScrollView.frame = CGRect(x: 0, y: 44, width: self.frame.width, height: self.frame.height - chartHearderScrollView.frame.height)
        let seperateLine = UIView(frame: CGRect(x: 0, y: 43, width: screenWidth, height: 0.5))
        seperateLine.backgroundColor = seperateLineColor
        chartHearderScrollView.backgroundColor = chartBackgroundColor
        chartScrollView.backgroundColor = chartBackgroundColor
        chartHearderScrollView.addSubview(seperateLine)
        self.addSubview(self.chartHearderScrollView)
        self.addSubview(self.chartScrollView)
    }
    
    func updateUI(){
        chartHearderScrollView = UIScrollView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 44))
        chartScrollView = UIScrollView(frame: CGRect(x: 0, y: 45, width: screenWidth, height: 189))
        self.chartScrollView.removeAllSubviews()
        dataPointsXArr.removeAllObjects()
        dataPointsYArr.removeAllObjects()
        initContentView()
        initVariable()
        selectedItemIndex(buttonIndexPair.object(forKey: 0) as! String, index: 0)
        setClinicReport(clinicReportList[0].clinicDataList as NSArray)
    }
    
    func initVariable(){
        var index: Int = 0
        chartHeaderCoordinateX.add(chartHeaderLeftSpace)
        for clinicReportItem in clinicReportList {
            buttonIndexPair.setObject(clinicReportItem.clinicItemName, forKey: index as NSCopying)
            createHeaderBtn(clinicReportItem.clinicItemName, index: index)
            index += 1
        }
    }
    
    func createHeaderBtn(_ btnText: String, index: Int){
        let headerItemW: CGFloat = btnText.sizeWithFont(userProfileChartHeaderFontSize, maxSize: CGSize(width: CGFloat.greatestFiniteMagnitude, height: 15)).width
        let chartHeaderBtn = UIButton(frame: CGRect(x: (chartHeaderCoordinateX[index] as! CGFloat), y: chartHeaderTopSpace, width: headerItemW, height: 37))
        chartHeaderCoordinateX.add(headerItemW + (chartHeaderCoordinateX[index] as! CGFloat) + chartHeaderSpaceBetweenItems)
        chartHeaderBtn.setTitle(btnText, for: UIControlState())
        chartHeaderBtn.titleLabel?.font = userProfileChartHeaderFontSize
        chartHeaderBtn.setTitleColor(UIColor.lightGray, for: UIControlState())
        chartHeaderBtn.addTarget(self, action: #selector(ChartSummaryTableViewCell.selectClinicReportItem(_:)), for: UIControlEvents.touchUpInside)
        chartHearderScrollView.addSubview(chartHeaderBtn)
    }
    
    func selectClinicReportItem(_ sender: UIButton){
        var senderIndex = buttonIndexPair.allKeys(for: (sender.titleLabel?.text)!)
        if senderIndex.count > 0 {
            selectedItemIndex((sender.titleLabel?.text)!, index: senderIndex[0] as! Int)
            let buttonIndex: Int = senderIndex[0] as! Int
            setClinicReport(clinicReportList[buttonIndex].clinicDataList as NSArray)
        }
    }
    
    func selectedItemIndex(_ btnText: String, index: Int){
        let headerItemW: CGFloat = btnText.sizeWithFont(userProfileChartHeaderFontSize, maxSize: CGSize(width: CGFloat.greatestFiniteMagnitude, height: 15)).width
        chartItemBottomLine.frame = CGRect(x: (chartHeaderCoordinateX[index] as! CGFloat), y: 41, width: headerItemW, height: 2)
        chartItemBottomLine.backgroundColor = headerColor
        chartHearderScrollView.addSubview(chartItemBottomLine)
    }
    
    func setClinicReport(_ clinicDataList: NSArray){
        self.chartScrollView.removeAllSubviews()
        if self.chartScrollView.layer.sublayers?.count > 0{
            for subLayer in self.chartScrollView.layer.sublayers!{
                subLayer.removeFromSuperlayer()
            }
        }

        dataPointsXArr.removeAllObjects()
        dataPointsYArr.removeAllObjects()
        let beginDate = (clinicDataList[clinicDataList.count-1] as! SubClinicDataObj).insertDate
        let endDate = (clinicDataList[0] as! SubClinicDataObj).insertDate

        chartWidth = 0
        let maxItemsInScreen: Int = Int(self.frame.width/spaceBetweenClinicItems)
        
        if clinicDataList.count <= maxItemsInScreen{
            chartWidth = self.frame.width - chartLeftSpace
        }else{
            chartWidth = (CGFloat)(CGFloat(clinicDataList.count) * spaceBetweenClinicItems)  - chartLeftSpace
        }
        
        if clinicDataList.count > 0{
            let chartHorizonLine: UIView = UIView(frame: CGRect(x: chartLeftSpace, y: chartButtomLineTopSpace , width: chartWidth, height: chartButtomLineHeight))
            chartHorizonLine.backgroundColor = chartButtomLineColor
            self.chartScrollView.addSubview(chartHorizonLine)
            self.chartScrollView.contentSize = CGSize(width: chartWidth, height: self.chartScrollView.frame.height)
            self.chartScrollView.contentOffset = CGPoint(x: chartWidth - screenWidth , y: 0)
            
            var dataMax: Float = 0
            var dataMin: Float = 10000
            for clinicData in clinicDataList {
                let clinicItem = clinicData as! SubClinicDataObj
                if dataMax < clinicItem.clinicItemValue{
                    dataMax = clinicItem.clinicItemValue
                }
                if dataMin > clinicItem.clinicItemValue {
                    dataMin = clinicItem.clinicItemValue
                }
            }

            if clinicDataList.count >= 2 {
                var index = 0
                for clinicData in clinicDataList {
                    let clinicItem = clinicData as! SubClinicDataObj
                    let insertedDate = Foundation.Date(timeIntervalSince1970: (clinicItem.insertDate)/1000 as TimeInterval)
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "MM/dd" // superset of OP's format
                    let insertedDayStr = dateFormatter.string(from: insertedDate)
                    var coordinateX = CGFloat()
                    if endDate != beginDate {
                        let ration:Double = ((clinicItem.insertDate) - beginDate)/(endDate - beginDate)
                        let segmentLength: Double = Double(chartWidth - chartDateLabelWidth * 2) * ration
                        let segmentLengthInt: Int =  Int(segmentLength) + Int(chartLeftSpace) + Int(chartDateLabelWidth/2)
                        coordinateX = CGFloat(segmentLengthInt)
                    }else{
                        coordinateX = 100
                    }
                    if (clinicDataList.count == 2) && (index == 0) {
                        coordinateX = chartWidth/2 + chartLeftSpace
                    }
                    let dateLabel = UILabel(frame: CGRect(x: CGFloat(coordinateX - chartDateLabelWidth/2), y: chartButtomLineTopSpace + chartDateTopSpace, width: chartDateLabelWidth, height: chartDateLabelHeight))
                    dateLabel.text = insertedDayStr
                    dateLabel.font = chartDateFont
                    self.chartScrollView.addSubview(dateLabel)
                    
                    let dataValue = clinicItem.clinicItemValue
                    index += 1
                    var coordinateY:CGFloat = (dataValueMaxY - dataValueMinY)/2
                    if dataMax != dataMin{
                        coordinateY = dataValueMaxY - (dataValueMaxY - dataValueMinY)*CGFloat((dataValue - dataMin)/(dataMax - dataMin))
                    }else{
                        coordinateY = (dataValueMaxY - dataValueMinY)/2
                    }
                    let dataMarkLbl = UIButton(frame: CGRect(x: CGFloat(coordinateX - chartDateLabelWidth/2)+7, y: CGFloat(coordinateY - dataValueLblH - dataValueSpace), width: dataValueLblW, height: dataValueLblH))
                    dataMarkLbl.setBackgroundImage(UIImage(named: "chartDataMarkLbl"), for: UIControlState())
                    dataMarkLbl.setTitleColor(headerColor, for: UIControlState())
                    dataMarkLbl.setTitle(String(stringInterpolationSegment: dataValue), for: UIControlState())
                    dataMarkLbl.titleLabel?.font = UIFont(name: "Helvetica", size: 11)
                    dataMarkLbl.titleLabel!.textAlignment = NSTextAlignment.left
                    self.chartScrollView.addSubview(dataMarkLbl)
                    dataPointsXArr.add(coordinateX + 4)
                    dataPointsYArr.add(coordinateY + 4)
                }
            }else{
                let clinicData = clinicDataList[0] as! SubClinicDataObj
                let insertedDate = Foundation.Date(timeIntervalSince1970: (clinicData.insertDate)/1000 as TimeInterval)
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "MM/dd" // superset of OP's format
                let insertedDayStr = dateFormatter.string(from: insertedDate)
                
                let coordinateX: CGFloat = 50
                let dateLabel = UILabel(frame: CGRect(x: CGFloat(coordinateX - chartDateLabelWidth/2), y: chartButtomLineTopSpace + chartDateTopSpace, width: chartDateLabelWidth, height: chartDateLabelHeight))
                dateLabel.text = insertedDayStr
                dateLabel.font = chartDateFont
                self.chartScrollView.addSubview(dateLabel)
                
                let dataValue = clinicData.clinicItemValue
                let coordinateY:CGFloat = 100
                
                let dataMarkView = UIButton(frame: CGRect(x: CGFloat(coordinateX), y: CGFloat(coordinateY), width: dataMarkWidth, height: dataMarkWidth))
                dataMarkView.layer.borderColor = headerColor.cgColor
                dataMarkView.layer.borderWidth = dataMarkBorderWidth
                dataMarkView.layer.cornerRadius = dataMarkWidth/2
                dataMarkView.layer.masksToBounds = true
                let dataMarkLbl = UIButton(frame: CGRect(x: CGFloat(coordinateX - chartDateLabelWidth/2)+7, y: CGFloat(coordinateY - dataValueLblH - dataValueSpace), width: dataValueLblW, height: dataValueLblH))
                dataMarkLbl.setBackgroundImage(UIImage(named: "chartDataMarkLbl"), for: UIControlState())
                dataMarkLbl.setTitleColor(headerColor, for: UIControlState())
                dataMarkLbl.setTitle(String(stringInterpolationSegment: dataValue), for: UIControlState())
                dataMarkLbl.titleLabel?.font = UIFont(name: "Helvetica", size: 11)
                dataMarkLbl.titleLabel!.textAlignment = NSTextAlignment.left
                self.chartScrollView.addSubview(dataMarkLbl)
                self.chartScrollView.addSubview(dataMarkView)
                let dataPoint: CGPoint = dataMarkView.center
                dataPointsXArr.add(dataPoint.x)
                dataPointsYArr.add(dataPoint.y)
            }
        }
        if beginDate != endDate {
            var ceaTreatmentCount = 0
            for treatment in treatmentList {
                let treatmentBeginDate = treatment.beginDate
                let treatmentEndDate = treatment.endDate
                var ceaTreatmentBeginDate:Double = 0
                var ceaTreatmentEndDate:Double = 0
                if (treatmentBeginDate > beginDate) && (treatmentBeginDate < endDate) {
                    ceaTreatmentBeginDate = treatmentBeginDate
                    ceaTreatmentEndDate = (treatmentEndDate < endDate) ? treatmentEndDate : endDate
                }
                if (treatmentEndDate < endDate)&&(treatmentEndDate > beginDate) {
                    ceaTreatmentBeginDate = (treatmentBeginDate < beginDate) ? beginDate : treatmentBeginDate
                    ceaTreatmentEndDate = treatmentEndDate
                }
                if (treatmentEndDate >= endDate) && (treatmentBeginDate <= beginDate) {
                    ceaTreatmentBeginDate = beginDate
                    ceaTreatmentEndDate = endDate
                }
                let coordinateBeginX = (Double(chartWidth)-80) * Double(ceaTreatmentBeginDate - beginDate)/Double(endDate - beginDate) + 10
                let coordinateEndX = (Double(chartWidth)-80) * Double(ceaTreatmentEndDate - beginDate)/Double(endDate - beginDate) + 50
                
                let coordinateY = Int(self.chartScrollView.frame.height) - 37
                let treatmentMarkView = UIView(frame: CGRect(x: CGFloat(coordinateBeginX), y: CGFloat(coordinateY), width: CGFloat(coordinateEndX - coordinateBeginX), height: 5))
                var treatmentColor = UIColor()
                switch ceaTreatmentCount{
                case 0: treatmentColor = UIColor.green.withAlphaComponent(0.5)
                    break
                case 1: treatmentColor = UIColor.orange.withAlphaComponent(0.5)
                    break
                case 2: treatmentColor = UIColor.blue.withAlphaComponent(0.5)
                    break
                case 3: treatmentColor = UIColor.red.withAlphaComponent(0.5)
                    break
                default: treatmentColor = UIColor.gray.withAlphaComponent(0.5)
                    break
                }
                treatmentMarkView.backgroundColor = treatmentColor
                ceaTreatmentCount += 1
                self.chartScrollView.addSubview(treatmentMarkView)
                
                //add treatmentLabel
                let treatmentLabel = UILabel(frame: CGRect(x: CGFloat(coordinateBeginX), y: CGFloat(coordinateY - 10), width: 60, height: 10))
                if treatment.treatmentName != "" {
                    treatmentLabel.text = treatment.treatmentName
                }
                treatmentLabel.font = UIFont(name: "Helvetica", size: 11.0)
                treatmentLabel.backgroundColor = UIColor.white
                treatmentLabel.alpha = 1
                self.chartScrollView.addSubview(treatmentLabel)
            }
        }
        self.draw(CGRECT(0, 0, self.chartScrollView.contentSize.width, self.chartScrollView.frame.height))
    }
    
    override func draw(_ rect: CGRect) {
        //获取用语描画的全局对象
        let imageView=UIImageView(frame: rect)
        self.chartScrollView.addSubview(imageView)
        
        UIGraphicsBeginImageContext(imageView.frame.size);
        imageView.image?.draw(in: CGRect(x: 0, y: 0, width: imageView.frame.size.width, height: imageView.frame.size.height))
        
        UIGraphicsGetCurrentContext()?.setLineWidth(dataTrendLineWidth)
        UIGraphicsGetCurrentContext()?.setStrokeColor(red: 61 / 255.0, green: 208 / 255.0, blue: 221 / 255.0, alpha: 1.0);

        UIGraphicsGetCurrentContext()?.beginPath()

        if dataPointsXArr.count > 1{
            UIGraphicsGetCurrentContext()?.move(to: CGPoint(x: dataPointsXArr[0] as! CGFloat, y: dataPointsYArr[0] as! CGFloat))
            for pointIndex in 1...(dataPointsXArr.count - 1){
                UIGraphicsGetCurrentContext()?.addLine(to: CGPoint(x: dataPointsXArr[pointIndex] as! CGFloat, y: dataPointsYArr[pointIndex] as! CGFloat))
                UIGraphicsGetCurrentContext()?.move(to: CGPoint(x: dataPointsXArr[pointIndex] as! CGFloat, y: dataPointsYArr[pointIndex] as! CGFloat))
                let dataMarkView = UIButton(frame: CGRect(x: CGFloat((dataPointsXArr[pointIndex] as! CGFloat) - 4), y: CGFloat((dataPointsYArr[pointIndex] as! CGFloat)-4), width: dataMarkWidth, height: dataMarkWidth))
                dataMarkView.layer.borderColor = headerColor.cgColor
                dataMarkView.layer.borderWidth = dataMarkBorderWidth
                dataMarkView.layer.cornerRadius = dataMarkWidth/2
                dataMarkView.layer.masksToBounds = true
                dataMarkView.backgroundColor = chartBackgroundColor
                self.chartScrollView.addSubview(dataMarkView)
            }
        }
        UIGraphicsGetCurrentContext()?.strokePath()

        imageView.image=UIGraphicsGetImageFromCurrentImageContext()

        UIGraphicsEndImageContext();
        var context = UIGraphicsGetCurrentContext()

        let progressLayer = CAShapeLayer()
        let path = CGMutablePath()
//        CGPathMoveToPoint(path, nil, dataPointsXArr[0] as! CGFloat, chartButtomLineTopSpace)
        path.move(to: CGPoint(x: dataPointsXArr[0] as! CGFloat, y: chartButtomLineTopSpace))

        for pointIndex in 0...(dataPointsXArr.count - 1){
//            CGPathAddLineToPoint(path, nil, dataPointsXArr[pointIndex] as! CGFloat, dataPointsYArr[pointIndex] as! CGFloat)
            path.addLine(to: CGPoint(x: dataPointsXArr[pointIndex] as! CGFloat, y: dataPointsYArr[pointIndex] as! CGFloat))
        }
        
//        CGPathAddLineToPoint(path, nil, dataPointsXArr[dataPointsXArr.count - 1] as! CGFloat, chartButtomLineTopSpace)
        path.addLine(to: CGPoint(x: dataPointsXArr[dataPointsXArr.count - 1] as! CGFloat,y: chartButtomLineTopSpace))
        progressLayer.path = path
        self.chartScrollView.layer.addSublayer(progressLayer)
        
        let gradientLayer2 = CAGradientLayer()
        gradientLayer2.startPoint = CGPoint(x: 0.5, y: 1.0)
        gradientLayer2.endPoint = CGPoint(x: 0.5, y: 0.0)
        gradientLayer2.frame = CGRect(x: 0, y: 0, width: rect.width, height: rect.height)
        gradientLayer2.colors = [UIColor.init(red: 61 / 255.0, green:208 / 255.0, blue:221 / 255.0, alpha: 0.0).cgColor, UIColor.init(red: 61 / 255.0, green:208 / 255.0, blue:221 / 255.0, alpha: 0.2).cgColor]
        gradientLayer2.mask = progressLayer
        self.chartScrollView.layer.addSublayer(gradientLayer2)
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
