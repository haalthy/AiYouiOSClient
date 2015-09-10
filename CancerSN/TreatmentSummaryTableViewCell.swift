//
//  TreatmentSummaryTableViewCell.swift
//  CancerSN
//
//  Created by lily on 9/9/15.
//  Copyright (c) 2015 lily. All rights reserved.
//

import UIKit

class TreatmentSummaryTableViewCell: UITableViewCell {
    @IBOutlet weak var chartScrollView: UIScrollView!
    var treatmentList = NSArray()
    var CEAList = [Float]()
    var ceaMax = Float()
    var ceaMin = Float()
    var chartVerticalHeight:CGFloat = 95
    
    var clinicReportList = NSArray(){
        didSet{
            updateUI()
        }
    }
    
    func getCEAList(){
        var initialCEA:Bool = true
        for clinicReport in clinicReportList{
            var clinicReport = clinicReport.objectForKey("clinicReport") as! String
            var clinicReportComponents = clinicReport.componentsSeparatedByString("CEA*")
            println(clinicReportComponents[clinicReportComponents.count-1])
            var CEADetailComponents = clinicReportComponents[clinicReportComponents.count-1].componentsSeparatedByString("**")
            var ceaValue = (CEADetailComponents[0] as NSString).floatValue
            CEAList.append(ceaValue)
            if initialCEA {
                ceaMax = ceaValue
                ceaMin = ceaValue
                initialCEA = false
            }else{
                if ceaMax < ceaValue {
                    ceaMax = ceaValue
                }
                if ceaMin > ceaValue {
                    ceaMin = ceaValue
                }
            }
        }
    }
    
    func setChartDateLabel(dateLabel: UILabel, dateInsertedInt: Int){
        var dateInserted = NSDate(timeIntervalSince1970: (dateInsertedInt as! Double)/1000 as NSTimeInterval)
        var dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MM/dd" // superset of OP's format
        let insertedDayStr = dateFormatter.stringFromDate(dateInserted)
        dateLabel.text = insertedDayStr
        dateLabel.font = UIFont(name: "Helvetica", size: 12)
        self.chartScrollView.addSubview(dateLabel)
    }
    
    func setCEAMarkLabel(ceaMarkLabel: UILabel){
        ceaMarkLabel.textColor = mainColor
        ceaMarkLabel.font = UIFont(name: "Helvetica", size: 11)
        ceaMarkLabel.textAlignment = NSTextAlignment.Left
        self.chartScrollView.addSubview(ceaMarkLabel)
    }
    
    func updateUI(){
        var beginDate = clinicReportList[clinicReportList.count-1].objectForKey("dateInserted") as! Int
        var endDate = clinicReportList[0].objectForKey("dateInserted") as! Int
        var width = UIScreen.mainScreen().bounds.width-10.0
        getCEAList()
        if clinicReportList.count <= 5 {
            var chartHorizonLine:UIImageView = UIImageView(frame: CGRectMake(0, chartVerticalHeight, UIScreen.mainScreen().bounds.width-10.0, 1.5))
            var chartVerticalLine:UIImageView = UIImageView(frame: CGRectMake(0, 0, 1.5, chartVerticalHeight))
            chartVerticalLine.image = UIImage(named: "chartLine.png")?.stretchableImageWithLeftCapWidth(0, topCapHeight: 95)
            chartHorizonLine.image = UIImage(named: "chartLine.png")?.stretchableImageWithLeftCapWidth(10, topCapHeight: 0)
            self.chartScrollView.addSubview(chartVerticalLine)
            self.chartScrollView.addSubview(chartHorizonLine)
//            var width = self.chartScrollView.frame.width
            self.chartScrollView.contentSize = CGSize(width: width, height: self.chartScrollView.frame.height)
            println(self.chartScrollView.frame.height)
            if clinicReportList.count >= 2 {
                var index = 0
                for clinicReport in clinicReportList {
                    var insertedDate = NSDate(timeIntervalSince1970: (clinicReport.objectForKey("dateInserted") as! Double)/1000 as NSTimeInterval)
                    var dateFormatter = NSDateFormatter()
                    dateFormatter.dateFormat = "MM/dd" // superset of OP's format
                    let insertedDayStr = dateFormatter.stringFromDate(insertedDate)
                    
                    var coordinateX = (Int(width)-80) * ((clinicReport.objectForKey("dateInserted") as! Int) - beginDate)/(endDate - beginDate) + 10
                    if (clinicReportList.count == 2) && (index == 0) {
                        coordinateX = Int(width/2 - 10.0)
                    }
                    var dateLabel = UILabel(frame: CGRectMake(CGFloat(coordinateX), 100, 40, 15))
                    dateLabel.text = insertedDayStr
                    dateLabel.font = UIFont(name: "Helvetica", size: 12)
                    self.chartScrollView.addSubview(dateLabel)
                    var ceaValue = CEAList[index]
                    index++
                    var coordinateY = 75 - 60*(ceaValue - ceaMin)/(ceaMax - ceaMin)
                    var ceaMarkView = UIView(frame: CGRectMake(CGFloat(coordinateX), CGFloat(coordinateY), 30, 3.5))
                    ceaMarkView.backgroundColor = mainColor
                    var ceaMarkLabel = UILabel(frame: CGRectMake(CGFloat(coordinateX), CGFloat(coordinateY-15), 40, 15))
                    ceaMarkLabel.textColor = mainColor
                    ceaMarkLabel.text = String(stringInterpolationSegment: ceaValue)
                    ceaMarkLabel.font = UIFont(name: "Helvetica", size: 11)
                    ceaMarkLabel.textAlignment = NSTextAlignment.Left
                    self.chartScrollView.addSubview(ceaMarkLabel)
                    self.chartScrollView.addSubview(ceaMarkView)
                }
            }else{
                var coordinateX = 10
                var ceaMarkCoordinateY = 50
                var dateCoordinateY = 100
                var dateLabel = UILabel(frame: CGRectMake(CGFloat(coordinateX), 100, 40, 15))
                setChartDateLabel(dateLabel, dateInsertedInt: (clinicReportList[0] as! NSDictionary).objectForKey("dateInserted") as! Int)
                var ceaMarkView = UIView(frame: CGRectMake(CGFloat(coordinateX), CGFloat(ceaMarkCoordinateY), 30, 3.5))
                ceaMarkView.backgroundColor = mainColor
                self.chartScrollView.addSubview(ceaMarkView)
                var ceaMarkLabel = UILabel(frame: CGRectMake(CGFloat(coordinateX), CGFloat(ceaMarkCoordinateY - 15), 40, 15))
                ceaMarkLabel.text = String(stringInterpolationSegment:CEAList[0])
            }
        }

        var ceaTreatmentCount = 0
        for treatment in treatmentList {
            var treatmentBeginDate = (treatment as! NSDictionary).objectForKey("beginDate") as! Int
            var treatmentEndDate = (treatment as! NSDictionary).objectForKey("endDate") as! Int
            var ceaTreatmentBeginDate = 0
            var ceaTreatmentEndDate = 0
            if (treatmentBeginDate > beginDate) && (treatmentBeginDate < endDate) {
                ceaTreatmentBeginDate = treatmentBeginDate
                ceaTreatmentEndDate = (treatmentEndDate < endDate) ? treatmentEndDate : endDate
            }
            
            if (treatmentEndDate < endDate)&&(treatmentEndDate > beginDate) {
                ceaTreatmentBeginDate = (treatmentBeginDate < beginDate) ? beginDate : treatmentBeginDate
                ceaTreatmentEndDate = endDate
            }
            
            if (treatmentEndDate >= endDate) && (treatmentBeginDate <= beginDate) {
                ceaTreatmentBeginDate = beginDate
                ceaTreatmentEndDate = endDate
            }
            var coordinateBeginX = (Int(width)-80) * (ceaTreatmentBeginDate - beginDate)/(endDate - beginDate) + 10
            var coordinateEndX = (Int(width)-80) * (ceaTreatmentEndDate - beginDate)/(endDate - beginDate) + 50
            
            var overlapCount = 0
            
            var coordinateY = Int(chartVerticalHeight) - 5
            var treatmentMarkView = UIView(frame: CGRectMake(CGFloat(coordinateBeginX), CGFloat(coordinateY), CGFloat(coordinateEndX - coordinateBeginX), 5))
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
            var treatmentLabel = UILabel(frame: CGRectMake(CGFloat(coordinateBeginX), CGFloat(coordinateY - 10), 70, 10))
            treatmentLabel.text = (treatment as! NSDictionary).objectForKey("treatmentName") as! String
            treatmentLabel.font = UIFont(name: "Helvetica", size: 11.0)
            self.chartScrollView.addSubview(treatmentLabel)
            
        }
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
