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
    var treatmentList = NSArray()
    var chartHeaderCoordinateX = NSMutableArray()
    var chartWidth = CGFloat()
    //初始化变量
    let screenWidth: CGFloat = UIScreen.mainScreen().bounds.width
    let buttonIndexPair: NSMutableDictionary = NSMutableDictionary()
    let dataPointsXArr: NSMutableArray = NSMutableArray()
    let dataPointsYArr: NSMutableArray = NSMutableArray()

    //
    let chartItemBottomLine = UIView()
    
    var clinicReportList = NSArray(){
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
        setClinicReport((clinicReportList.objectAtIndex(0) as! NSDictionary).objectForKey("clinicDataList") as! NSArray)
    }
    
    func initVariable(){
        var index: Int = 0
        chartHeaderCoordinateX.addObject(chartHeaderLeftSpace)
        for clinicReportItem in clinicReportList {
            buttonIndexPair.setObject((clinicReportItem as! NSDictionary).objectForKey("clinicItemName")!, forKey: index)
            createHeaderBtn((clinicReportItem as! NSDictionary).objectForKey("clinicItemName") as! String, index: index)
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
            var clinicItem = clinicReportList.objectAtIndex(senderIndex[0] as! Int).objectForKey("clinicDataList") as! NSArray
            setClinicReport((clinicReportList.objectAtIndex(senderIndex[0] as! Int) as! NSDictionary).objectForKey("clinicDataList") as! NSArray)
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
        dataPointsXArr.removeAllObjects()
        dataPointsYArr.removeAllObjects()
        let beginDate = clinicDataList[clinicDataList.count-1].objectForKey("insertDate") as! Int
        let endDate = clinicDataList[0].objectForKey("insertDate") as! Int
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
            
            var dataMax: Float = 0
            var dataMin: Float = 10000
            for clinicItem in clinicDataList {
                if dataMax < (clinicItem.objectForKey("clinicItemValue") as! Float){
                    dataMax = clinicItem.objectForKey("clinicItemValue") as! Float
                }
                if dataMin > (clinicItem.objectForKey("clinicItemValue") as! Float) {
                    dataMin = (clinicItem.objectForKey("clinicItemValue") as! Float)
                }
            }

            if clinicDataList.count >= 2 {
                var index = 0
                for clinicData in clinicDataList {
                    let insertedDate = NSDate(timeIntervalSince1970: (clinicData.objectForKey("insertDate") as! Double)/1000 as NSTimeInterval)
                    let dateFormatter = NSDateFormatter()
                    dateFormatter.dateFormat = "MM/dd" // superset of OP's format
                    let insertedDayStr = dateFormatter.stringFromDate(insertedDate)
                    var coordinateX = CGFloat()
                    if endDate != beginDate {
                        coordinateX = CGFloat(Int(chartWidth - chartDateLabelWidth * 2) * ((clinicData.objectForKey("insertDate") as! Int) - beginDate)/(endDate - beginDate) + Int(chartLeftSpace) + Int(chartDateLabelWidth/2))
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
                    
                    let dataValue = clinicDataList[index].objectForKey("clinicItemValue") as! Float
                    index++
                    var coordinateY:CGFloat = (dataValueMaxY - dataValueMinY)/2
                    if dataMax != dataMin{
                        coordinateY = dataValueMaxY - (dataValueMaxY - dataValueMinY)*CGFloat((dataValue - dataMin)/(dataMax - dataMin))
                    }else{
                        coordinateY = (dataValueMaxY - dataValueMinY)/2
                    }
                    
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
            }else{
                let clinicData = clinicDataList[0]
                let insertedDate = NSDate(timeIntervalSince1970: (clinicData.objectForKey("insertDate") as! Double)/1000 as NSTimeInterval)
                let dateFormatter = NSDateFormatter()
                dateFormatter.dateFormat = "MM/dd" // superset of OP's format
                let insertedDayStr = dateFormatter.stringFromDate(insertedDate)
                
                let coordinateX: CGFloat = 50
                let dateLabel = UILabel(frame: CGRectMake(CGFloat(coordinateX - chartDateLabelWidth/2), chartButtomLineTopSpace + chartDateTopSpace, chartDateLabelWidth, chartDateLabelHeight))
                dateLabel.text = insertedDayStr
                dateLabel.font = chartDateFont
                self.chartScrollView.addSubview(dateLabel)
                
                let dataValue = clinicData.objectForKey("clinicItemValue") as! Float
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
                let treatmentBeginDate = (treatment as! NSDictionary).objectForKey("beginDate") as! Int
                let treatmentEndDate = (treatment as! NSDictionary).objectForKey("endDate") as! Int
                var ceaTreatmentBeginDate = 0
                var ceaTreatmentEndDate = 0
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
                let coordinateBeginX = (Int(chartWidth)-80) * (ceaTreatmentBeginDate - beginDate)/(endDate - beginDate) + 10
                let coordinateEndX = (Int(chartWidth)-80) * (ceaTreatmentEndDate - beginDate)/(endDate - beginDate) + 50
                
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
                treatmentLabel.text = (treatment as! NSDictionary).objectForKey("treatmentName") as! String
                treatmentLabel.font = UIFont(name: "Helvetica", size: 11.0)
                treatmentLabel.backgroundColor = UIColor.whiteColor()
                treatmentLabel.alpha = 1
                self.chartScrollView.addSubview(treatmentLabel)
            }
        }
        self.drawRect(CGRECT(0, 0, self.chartScrollView.frame.width, self.chartScrollView.frame.height))
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
            CGContextMoveToPoint(UIGraphicsGetCurrentContext(), dataPointsXArr[0] as! CGFloat - 2, dataPointsYArr[0] as! CGFloat)
            for pointIndex in 1...(dataPointsXArr.count - 1){
                CGContextAddLineToPoint(UIGraphicsGetCurrentContext(),  dataPointsXArr[pointIndex] as! CGFloat + 2, dataPointsYArr[pointIndex] as! CGFloat)
                CGContextMoveToPoint(UIGraphicsGetCurrentContext(), dataPointsXArr[pointIndex] as! CGFloat - 2, dataPointsYArr[pointIndex] as! CGFloat)
            }
        }
        CGContextStrokePath(UIGraphicsGetCurrentContext())

        imageView.image=UIGraphicsGetImageFromCurrentImageContext()

        UIGraphicsEndImageContext();
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
