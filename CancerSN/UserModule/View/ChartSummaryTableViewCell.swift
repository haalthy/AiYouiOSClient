//
//  ChartSummaryTableViewCell.swift
//  CancerSN
//
//  Created by lily on 1/5/16.
//  Copyright © 2016 lily. All rights reserved.
//

import UIKit

class ChartSummaryTableViewCell: UITableViewCell {
    
    @IBOutlet weak var chartHearderScrollView: UIScrollView!
    @IBOutlet weak var chartScrollView: UIScrollView!

    var treatmentList = NSArray()
    
    //初始化变量
    let screenWidth: CGFloat = UIScreen.mainScreen().bounds.width
    let buttonIndexPair: NSMutableDictionary = NSMutableDictionary()
    
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
    }
    
    func updateUI(){
        initContentView()
        initVariable()
        selectedItemIndex(buttonIndexPair.objectForKey(0) as! String, index: 0)
        setClinicReport((clinicReportList.objectAtIndex(0) as! NSDictionary).objectForKey("clinicDataList") as! NSArray)
    }
    
    func initVariable(){
        var index: Int = 0
        for clinicReportItem in clinicReportList {
            buttonIndexPair.setObject((clinicReportItem as! NSDictionary).objectForKey("clinicItemName")!, forKey: index)
            createHeaderBtn((clinicReportItem as! NSDictionary).objectForKey("clinicItemName") as! String, index: index)
            index++
        }
    }
    
    func createHeaderBtn(btnText: String, index: Int){
        let headerItemW: CGFloat = btnText.sizeWithFont(userProfileChartHeaderFontSize, maxSize: CGSize(width: CGFloat.max, height: 15)).width
        let chartHeaderBtn = UIButton(frame: CGRect(x: chartHeaderLeftSpace + CGFloat(index) * chartHeaderSpaceBetweenItems, y: chartHeaderTopSpace, width: headerItemW, height: 37))
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
            
        }
    }
    
    func selectedItemIndex(btnText: String, index: Int){
        let headerItemW: CGFloat = btnText.sizeWithFont(userProfileChartHeaderFontSize, maxSize: CGSize(width: CGFloat.max, height: 15)).width
        chartItemBottomLine.frame = CGRect(x: chartHeaderLeftSpace + CGFloat(index) * chartHeaderSpaceBetweenItems, y: 41, width: headerItemW, height: 2)
        chartItemBottomLine.backgroundColor = headerColor
        chartHearderScrollView.addSubview(chartItemBottomLine)
    }
    
    func setClinicReport(clinicDataList: NSArray){
        
        self.chartScrollView.removeAllSubviews()
        let beginDate = clinicDataList[clinicDataList.count-1].objectForKey("insertDate") as! Int
        let endDate = clinicDataList[0].objectForKey("insertDate") as! Int
        var chartWidth:CGFloat = 0
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
                    
                    var coordinateX: CGFloat = CGFloat(Int(chartWidth) * ((clinicData.objectForKey("insertDate") as! Int) - beginDate)/(endDate - beginDate) + Int(chartLeftSpace) + Int(chartDateLabelWidth/2))
                    if (clinicDataList.count == 2) && (index == 0) {
                        coordinateX = chartWidth/2 + chartLeftSpace
                    }
                    let dateLabel = UILabel(frame: CGRectMake(CGFloat(coordinateX - chartDateLabelWidth/2), chartButtomLineTopSpace + chartDateTopSpace, chartDateLabelWidth, chartDateLabelHeight))
                    dateLabel.text = insertedDayStr
                    dateLabel.font = chartDateFont
                    self.chartScrollView.addSubview(dateLabel)
                    
                    let ceaValue = clinicDataList[index].objectForKey("clinicItemValue") as! Float
                    index++
                    var coordinateY:Float = 50
                    if dataMax != dataMin{
                        coordinateY = 75 - 60*(ceaValue - dataMin)/(dataMax - dataMin)
                    }
                    
                    let dataMarkView = UIButton(frame: CGRectMake(CGFloat(coordinateX), CGFloat(coordinateY), 6, 6))
                    dataMarkView.layer.borderColor = headerColor.CGColor
                    dataMarkView.layer.borderWidth = 2
                    dataMarkView.layer.cornerRadius = 3
                    dataMarkView.layer.masksToBounds = true
//                    dataMarkView.backgroundColor = mainColor
                    let ceaMarkLabel = UILabel(frame: CGRectMake(CGFloat(coordinateX), CGFloat(coordinateY-15), 40, 15))
                    ceaMarkLabel.textColor = mainColor
                    ceaMarkLabel.text = String(stringInterpolationSegment: ceaValue)
                    ceaMarkLabel.font = UIFont(name: "Helvetica", size: 11)
                    ceaMarkLabel.textAlignment = NSTextAlignment.Left
                    self.chartScrollView.addSubview(ceaMarkLabel)
                    self.chartScrollView.addSubview(dataMarkView)
                }
            }
//            else if( clinicReportItemList.count == 1){
//                let coordinateX = 10
//                let ceaMarkCoordinateY = 50
//                let dateLabel = UILabel(frame: CGRectMake(CGFloat(coordinateX), 100, 40, 15))
//                setChartDateLabel(dateLabel, dateInsertedInt: (clinicReportList[0] as! NSDictionary).objectForKey("dateInserted") as! Int)
//                let ceaMarkView = UIView(frame: CGRectMake(CGFloat(coordinateX), CGFloat(ceaMarkCoordinateY), 30, 3.5))
//                ceaMarkView.backgroundColor = mainColor
//                self.chartScrollView.addSubview(ceaMarkView)
//                let ceaMarkLabel = UILabel(frame: CGRectMake(CGFloat(coordinateX), CGFloat(ceaMarkCoordinateY - 15), 40, 15))
//                ceaMarkLabel.text = String(stringInterpolationSegment:CEAList[0])
//            }
        }
//        if beginDate != endDate {
//            var ceaTreatmentCount = 0
//            for treatment in treatmentList {
//                let treatmentBeginDate = (treatment as! NSDictionary).objectForKey("beginDate") as! Int
//                let treatmentEndDate = (treatment as! NSDictionary).objectForKey("endDate") as! Int
//                var ceaTreatmentBeginDate = 0
//                var ceaTreatmentEndDate = 0
//                if (treatmentBeginDate > beginDate) && (treatmentBeginDate < endDate) {
//                    ceaTreatmentBeginDate = treatmentBeginDate
//                    ceaTreatmentEndDate = (treatmentEndDate < endDate) ? treatmentEndDate : endDate
//                }
//                if (treatmentEndDate < endDate)&&(treatmentEndDate > beginDate) {
//                    ceaTreatmentBeginDate = (treatmentBeginDate < beginDate) ? beginDate : treatmentBeginDate
//                    ceaTreatmentEndDate = treatmentEndDate
//                }
//                if (treatmentEndDate >= endDate) && (treatmentBeginDate <= beginDate) {
//                    ceaTreatmentBeginDate = beginDate
//                    ceaTreatmentEndDate = endDate
//                }
//                let coordinateBeginX = (Int(width)-80) * (ceaTreatmentBeginDate - beginDate)/(endDate - beginDate) + 10
//                let coordinateEndX = (Int(width)-80) * (ceaTreatmentEndDate - beginDate)/(endDate - beginDate) + 50
//                
//                let coordinateY = Int(chartVerticalHeight) - 5
//                let treatmentMarkView = UIView(frame: CGRectMake(CGFloat(coordinateBeginX), CGFloat(coordinateY), CGFloat(coordinateEndX - coordinateBeginX), 5))
//                var treatmentColor = UIColor()
//                switch ceaTreatmentCount{
//                case 0: treatmentColor = UIColor.greenColor().colorWithAlphaComponent(0.5)
//                    break
//                case 1: treatmentColor = UIColor.orangeColor().colorWithAlphaComponent(0.5)
//                    break
//                case 2: treatmentColor = UIColor.blueColor().colorWithAlphaComponent(0.5)
//                    break
//                case 3: treatmentColor = UIColor.redColor().colorWithAlphaComponent(0.5)
//                    break
//                default: treatmentColor = UIColor.grayColor().colorWithAlphaComponent(0.5)
//                    break
//                }
//                treatmentMarkView.backgroundColor = treatmentColor
//                ceaTreatmentCount++
//                self.chartScrollView.addSubview(treatmentMarkView)
//                
//                //add treatmentLabel
//                let treatmentLabel = UILabel(frame: CGRectMake(CGFloat(coordinateBeginX), CGFloat(coordinateY - 10), 70, 10))
//                treatmentLabel.text = (treatment as! NSDictionary).objectForKey("treatmentName") as! String
//                treatmentLabel.font = UIFont(name: "Helvetica", size: 11.0)
//                treatmentLabel.backgroundColor = UIColor.whiteColor()
//                treatmentLabel.alpha = 1
//                self.chartScrollView.addSubview(treatmentLabel)
//            }
//        }
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
