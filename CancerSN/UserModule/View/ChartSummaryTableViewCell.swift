//
//  ChartSummaryTableViewCell.swift
//  CancerSN
//
//  Created by lily on 1/5/16.
//  Copyright © 2016 lily. All rights reserved.
//

import UIKit

class ChartSummaryTableViewCell: UITableViewCell {
    
    var chartHearderScrollView: UIScrollView!
    var chartScrollView: UIScrollView!
    var treatmentList = Array<TreatmentObj>()
    var chartHeaderCoordinateX = NSMutableArray()
    var chartWidth = CGFloat()
    //初始化变量
    let screenWidth: CGFloat = UIScreen.mainScreen().bounds.width
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
        chartHearderScrollView.frame = CGRectMake(0, 0, self.frame.width, 44)
        chartScrollView.frame = CGRectMake(0, 44, self.frame.width, self.frame.height - chartHearderScrollView.frame.height)
        let seperateLine = UIView(frame: CGRectMake(0, 43, screenWidth, 0.5))
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
        selectedItemIndex(buttonIndexPair.objectForKey(0) as! String, index: 0)
        let data = clinicReportList[0].clinicDataList
        setClinicReport(clinicReportList[0].clinicDataList)
    }
    
    func initVariable(){
        var index: Int = 0
        chartHeaderCoordinateX.addObject(chartHeaderLeftSpace)
        for clinicReportItem in clinicReportList {
            buttonIndexPair.setObject((clinicReportItem as! ClinicDataObj).clinicItemName, forKey: index)
            createHeaderBtn((clinicReportItem as! ClinicDataObj).clinicItemName, index: index)
            index++
        }
    }
    
    func createHeaderBtn(btnText: String, index: Int){
        let headerItemW: CGFloat = btnText.sizeWithFont(userProfileChartHeaderFontSize, maxSize: CGSize(width: CGFloat.max, height: 15)).width
        let chartHeaderBtn = UIButton(frame: CGRect(x: (chartHeaderCoordinateX[index] as! CGFloat), y: chartHeaderTopSpace, width: headerItemW, height: 37))
        chartHeaderCoordinateX.addObject(headerItemW + (chartHeaderCoordinateX[index] as! CGFloat) + chartHeaderSpaceBetweenItems)
        chartHeaderBtn.setTitle(btnText, forState: UIControlState.Normal)
        chartHeaderBtn.titleLabel?.font = userProfileChartHeaderFontSize
        chartHeaderBtn.setTitleColor(UIColor.lightGrayColor(), forState: UIControlState.Normal)
        chartHeaderBtn.addTarget(self, action: "selectClinicReportItem:", forControlEvents: UIControlEvents.TouchUpInside)
        chartHearderScrollView.addSubview(chartHeaderBtn)
    }
    
    func selectClinicReportItem(sender: UIButton){
        var senderIndex = buttonIndexPair.allKeysForObject((sender.titleLabel?.text)!)
        if senderIndex.count > 0 {
            selectedItemIndex((sender.titleLabel?.text)!, index: senderIndex[0] as! Int)
            setClinicReport((clinicReportList[senderIndex[0] as! Int]).clinicDataList)
        }
    }
    
    func selectedItemIndex(btnText: String, index: Int){
        let headerItemW: CGFloat = btnText.sizeWithFont(userProfileChartHeaderFontSize, maxSize: CGSize(width: CGFloat.max, height: 15)).width
        chartItemBottomLine.frame = CGRect(x: (chartHeaderCoordinateX[index] as! CGFloat), y: 41, width: headerItemW, height: 2)
        chartItemBottomLine.backgroundColor = headerColor
        chartHearderScrollView.addSubview(chartItemBottomLine)
    }
    
    func setClinicReport(clinicDataList: NSArray){
        self.chartScrollView.removeAllSubviews()
        if self.chartScrollView.layer.sublayers?.count > 0{
            for subLayer in self.chartScrollView.layer.sublayers!{
                subLayer.removeFromSuperlayer()
            }
        }

        dataPointsXArr.removeAllObjects()
        dataPointsYArr.removeAllObjects()
//        let beginDate = clinicDataList[clinicDataList.count-1].objectForKey("insertDate") as! Double
//        let endDate = clinicDataList[0].objectForKey("insertDate") as! Double
        let beginDate = (clinicDataList[clinicDataList.count-1] as! SubClinicDataObj).insertDate
        let endDate = (clinicDataList[clinicDataList.count-1] as! SubClinicDataObj).insertDate

        chartWidth = 0
        let maxItemsInScreen: Int = Int(self.frame.width/spaceBetweenClinicItems)
        
        if clinicDataList.count <= maxItemsInScreen{
            chartWidth = self.frame.width - chartLeftSpace
        }else{
            chartWidth = (CGFloat)(CGFloat(clinicDataList.count) * spaceBetweenClinicItems)  - chartLeftSpace
        }
        
        if clinicDataList.count > 0{
            let chartHorizonLine: UIView = UIView(frame: CGRectMake(chartLeftSpace, chartButtomLineTopSpace , chartWidth, chartButtomLineHeight))
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
                    let insertedDate = NSDate(timeIntervalSince1970: (clinicItem.insertDate)/1000 as NSTimeInterval)
                    let dateFormatter = NSDateFormatter()
                    dateFormatter.dateFormat = "MM/dd" // superset of OP's format
                    let insertedDayStr = dateFormatter.stringFromDate(insertedDate)
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
                    let dateLabel = UILabel(frame: CGRectMake(CGFloat(coordinateX - chartDateLabelWidth/2), chartButtomLineTopSpace + chartDateTopSpace, chartDateLabelWidth, chartDateLabelHeight))
                    dateLabel.text = insertedDayStr
                    dateLabel.font = chartDateFont
                    self.chartScrollView.addSubview(dateLabel)
                    
//                    let dataValue = clinicDataList[index].objectForKey("clinicItemValue") as! Float
                    let dataValue = clinicItem.clinicItemValue
                    index++
                    var coordinateY:CGFloat = (dataValueMaxY - dataValueMinY)/2
                    if dataMax != dataMin{
                        coordinateY = dataValueMaxY - (dataValueMaxY - dataValueMinY)*CGFloat((dataValue - dataMin)/(dataMax - dataMin))
                    }else{
                        coordinateY = (dataValueMaxY - dataValueMinY)/2
                    }
                    let dataMarkLbl = UIButton(frame: CGRectMake(CGFloat(coordinateX - chartDateLabelWidth/2)+7, CGFloat(coordinateY - dataValueLblH - dataValueSpace), dataValueLblW, dataValueLblH))
                    dataMarkLbl.setBackgroundImage(UIImage(named: "chartDataMarkLbl"), forState: UIControlState.Normal)
                    dataMarkLbl.setTitleColor(headerColor, forState: UIControlState.Normal)
                    dataMarkLbl.setTitle(String(stringInterpolationSegment: dataValue), forState: UIControlState.Normal)
                    dataMarkLbl.titleLabel?.font = UIFont(name: "Helvetica", size: 11)
                    dataMarkLbl.titleLabel!.textAlignment = NSTextAlignment.Left
                    self.chartScrollView.addSubview(dataMarkLbl)
                    dataPointsXArr.addObject(coordinateX + 4)
                    dataPointsYArr.addObject(coordinateY + 4)
                }
            }else{
                let clinicData = clinicDataList[0] as! SubClinicDataObj
                let insertedDate = NSDate(timeIntervalSince1970: (clinicData.insertDate)/1000 as NSTimeInterval)
                let dateFormatter = NSDateFormatter()
                dateFormatter.dateFormat = "MM/dd" // superset of OP's format
                let insertedDayStr = dateFormatter.stringFromDate(insertedDate)
                
                let coordinateX: CGFloat = 50
                let dateLabel = UILabel(frame: CGRectMake(CGFloat(coordinateX - chartDateLabelWidth/2), chartButtomLineTopSpace + chartDateTopSpace, chartDateLabelWidth, chartDateLabelHeight))
                dateLabel.text = insertedDayStr
                dateLabel.font = chartDateFont
                self.chartScrollView.addSubview(dateLabel)
                
                let dataValue = clinicData.clinicItemValue
                let coordinateY:CGFloat = 100
                
                let dataMarkView = UIButton(frame: CGRectMake(CGFloat(coordinateX), CGFloat(coordinateY), dataMarkWidth, dataMarkWidth))
                dataMarkView.layer.borderColor = headerColor.CGColor
                dataMarkView.layer.borderWidth = dataMarkBorderWidth
                dataMarkView.layer.cornerRadius = dataMarkWidth/2
                dataMarkView.layer.masksToBounds = true
                let dataMarkLbl = UIButton(frame: CGRectMake(CGFloat(coordinateX - chartDateLabelWidth/2)+7, CGFloat(coordinateY - dataValueLblH - dataValueSpace), dataValueLblW, dataValueLblH))
                dataMarkLbl.setBackgroundImage(UIImage(named: "chartDataMarkLbl"), forState: UIControlState.Normal)
                dataMarkLbl.setTitleColor(headerColor, forState: UIControlState.Normal)
                dataMarkLbl.setTitle(String(stringInterpolationSegment: dataValue), forState: UIControlState.Normal)
                dataMarkLbl.titleLabel?.font = UIFont(name: "Helvetica", size: 11)
                dataMarkLbl.titleLabel!.textAlignment = NSTextAlignment.Left
                self.chartScrollView.addSubview(dataMarkLbl)
                self.chartScrollView.addSubview(dataMarkView)
                let dataPoint: CGPoint = dataMarkView.center
                dataPointsXArr.addObject(dataPoint.x)
                dataPointsYArr.addObject(dataPoint.y)
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
                let treatmentMarkView = UIView(frame: CGRectMake(CGFloat(coordinateBeginX), CGFloat(coordinateY), CGFloat(coordinateEndX - coordinateBeginX), 5))
                var treatmentColor = UIColor()
                switch ceaTreatmentCount{
                case 0: treatmentColor = UIColor.greenColor().colorWithAlphaComponent(0.5)
                    break
                case 1: treatmentColor = UIColor.orangeColor().colorWithAlphaComponent(0.5)
                    break
                case 2: treatmentColor = UIColor.blueColor().colorWithAlphaComponent(0.5)
                    break
                case 3: treatmentColor = UIColor.redColor().colorWithAlphaComponent(0.5)
                    break
                default: treatmentColor = UIColor.grayColor().colorWithAlphaComponent(0.5)
                    break
                }
                treatmentMarkView.backgroundColor = treatmentColor
                ceaTreatmentCount++
                self.chartScrollView.addSubview(treatmentMarkView)
                
                //add treatmentLabel
                let treatmentLabel = UILabel(frame: CGRectMake(CGFloat(coordinateBeginX), CGFloat(coordinateY - 10), 60, 10))
                if treatment.treatmentName != "" {
                    treatmentLabel.text = treatment.treatmentName
                }
                treatmentLabel.font = UIFont(name: "Helvetica", size: 11.0)
                treatmentLabel.backgroundColor = UIColor.whiteColor()
                treatmentLabel.alpha = 1
                self.chartScrollView.addSubview(treatmentLabel)
            }
        }
        self.drawRect(CGRECT(0, 0, self.chartScrollView.contentSize.width, self.chartScrollView.frame.height))
    }
    
    override func drawRect(rect: CGRect) {
        //获取用语描画的全局对象
        let imageView=UIImageView(frame: rect)
        self.chartScrollView.addSubview(imageView)
        
        UIGraphicsBeginImageContext(imageView.frame.size);
        imageView.image?.drawInRect(CGRectMake(0, 0, imageView.frame.size.width, imageView.frame.size.height))
        
        CGContextSetLineWidth(UIGraphicsGetCurrentContext(), dataTrendLineWidth)
        CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), 61 / 255.0, 208 / 255.0, 221 / 255.0, 1.0);

        CGContextBeginPath(UIGraphicsGetCurrentContext())

        if dataPointsXArr.count > 1{
            CGContextMoveToPoint(UIGraphicsGetCurrentContext(), dataPointsXArr[0] as! CGFloat, dataPointsYArr[0] as! CGFloat)
            for pointIndex in 1...(dataPointsXArr.count - 1){
                CGContextAddLineToPoint(UIGraphicsGetCurrentContext(),  dataPointsXArr[pointIndex] as! CGFloat, dataPointsYArr[pointIndex] as! CGFloat)
                CGContextMoveToPoint(UIGraphicsGetCurrentContext(), dataPointsXArr[pointIndex] as! CGFloat, dataPointsYArr[pointIndex] as! CGFloat)
                let dataMarkView = UIButton(frame: CGRectMake(CGFloat((dataPointsXArr[pointIndex] as! CGFloat) - 4), CGFloat((dataPointsYArr[pointIndex] as! CGFloat)-4), dataMarkWidth, dataMarkWidth))
                dataMarkView.layer.borderColor = headerColor.CGColor
                dataMarkView.layer.borderWidth = dataMarkBorderWidth
                dataMarkView.layer.cornerRadius = dataMarkWidth/2
                dataMarkView.layer.masksToBounds = true
                dataMarkView.backgroundColor = chartBackgroundColor
                self.chartScrollView.addSubview(dataMarkView)
            }
        }
        CGContextStrokePath(UIGraphicsGetCurrentContext())

        imageView.image=UIGraphicsGetImageFromCurrentImageContext()

        UIGraphicsEndImageContext();
        var context = UIGraphicsGetCurrentContext()

        let progressLayer = CAShapeLayer()
        let path = CGPathCreateMutable()
        
        CGPathMoveToPoint(path, nil, dataPointsXArr[0] as! CGFloat, chartButtomLineTopSpace)

        for pointIndex in 0...(dataPointsXArr.count - 1){
            CGPathAddLineToPoint(path, nil, dataPointsXArr[pointIndex] as! CGFloat, dataPointsYArr[pointIndex] as! CGFloat)
        }
        
        CGPathAddLineToPoint(path, nil, dataPointsXArr[dataPointsXArr.count - 1] as! CGFloat, chartButtomLineTopSpace)

        progressLayer.path = path
        self.chartScrollView.layer.addSublayer(progressLayer)
        
        let gradientLayer2 = CAGradientLayer()
        gradientLayer2.startPoint = CGPointMake(0.5, 1.0)
        gradientLayer2.endPoint = CGPointMake(0.5, 0.0)
        gradientLayer2.frame = CGRectMake(0, 0, rect.width, rect.height)
        gradientLayer2.colors = [UIColor.init(red: 61 / 255.0, green:208 / 255.0, blue:221 / 255.0, alpha: 0.0).CGColor, UIColor.init(red: 61 / 255.0, green:208 / 255.0, blue:221 / 255.0, alpha: 0.2).CGColor]
        gradientLayer2.mask = progressLayer
        self.chartScrollView.layer.addSublayer(gradientLayer2)
        
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
