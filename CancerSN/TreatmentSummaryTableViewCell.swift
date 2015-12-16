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
    var ceaLabelWidth = 60
    
    var clinicReportList = NSArray(){
        didSet{
            CEAList = [Float]()
            updateUI()
        }
    }
    
    func getCEAList(){
        var initialCEA:Bool = true
        for clinicReport in clinicReportList{
            if clinicReport.objectForKey("cea") != nil {
//                let clinicReport = clinicReport.objectForKey("clinicReport") as! String
//                var clinicReportComponents = clinicReport.componentsSeparatedByString("CEA*")
//                print(clinicReportComponents[clinicReportComponents.count-1])
//                var CEADetailComponents = clinicReportComponents[clinicReportComponents.count-1].componentsSeparatedByString("**")
//                let ceaValue = (CEADetailComponents[0] as NSString).floatValue
                let ceaValue = clinicReport.objectForKey("cea") as! Float
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
    }
    
    func setChartDateLabel(dateLabel: UILabel, dateInsertedInt: Int){
        let dateInserted = NSDate(timeIntervalSince1970: (Double(dateInsertedInt))/1000 as NSTimeInterval)
        let dateFormatter = NSDateFormatter()
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
        
        self.chartScrollView.removeAllSubviews()
        let beginDate = clinicReportList[clinicReportList.count-1].objectForKey("dateInserted") as! Int
        let endDate = clinicReportList[0].objectForKey("dateInserted") as! Int
//        getCEAList()
        var width:CGFloat = 0
        if CEAList.count<=5 {
            width = UIScreen.mainScreen().bounds.width-10.0
        }else{
            width = (CGFloat)(CEAList.count * ceaLabelWidth)
        }
        if CEAList.count>0{
//        if clinicReportList.count <= 5 {
            let chartHorizonLine:UIImageView = UIImageView(frame: CGRectMake(1, chartVerticalHeight, width, 1.5))
            let chartVerticalLine:UIImageView = UIImageView(frame: CGRectMake(1, 1, 1.5, chartVerticalHeight))
            chartVerticalLine.image = UIImage(named: "chartLine.png")?.stretchableImageWithLeftCapWidth(1, topCapHeight: 95)
            chartHorizonLine.image = UIImage(named: "chartLine.png")?.stretchableImageWithLeftCapWidth(10, topCapHeight: 1)
            self.chartScrollView.addSubview(chartVerticalLine)
            self.chartScrollView.addSubview(chartHorizonLine)
            self.chartScrollView.contentSize = CGSize(width: width, height: self.chartScrollView.frame.height)
            print(self.chartScrollView.frame.height)
            if CEAList.count >= 2 {
                var index = 0
                for cea in CEAList {
                    let insertedDate = NSDate(timeIntervalSince1970: (clinicReportList[index].objectForKey("dateInserted") as! Double)/1000 as NSTimeInterval)
                    let dateFormatter = NSDateFormatter()
                    dateFormatter.dateFormat = "MM/dd" // superset of OP's format
                    let insertedDayStr = dateFormatter.stringFromDate(insertedDate)
                    
                    var coordinateX = (Int(width)-80) * ((clinicReportList[index].objectForKey("dateInserted") as! Int) - beginDate)/(endDate - beginDate) + 10
                    if (clinicReportList.count == 2) && (index == 0) {
                        coordinateX = Int(width/2 - 10.0)
                    }
                    let dateLabel = UILabel(frame: CGRectMake(CGFloat(coordinateX), 100, 40, 15))
                    dateLabel.text = insertedDayStr
                    dateLabel.font = UIFont(name: "Helvetica", size: 12)
                    self.chartScrollView.addSubview(dateLabel)
                    let ceaValue = CEAList[index]
                    index++
                    var coordinateY:Float = 50
                    if ceaMax != ceaMin{
                        coordinateY = 75 - 60*(ceaValue - ceaMin)/(ceaMax - ceaMin)
                    }
                    let ceaMarkView = UIView(frame: CGRectMake(CGFloat(coordinateX), CGFloat(coordinateY), 30, 3.5))
                    ceaMarkView.backgroundColor = mainColor
                    let ceaMarkLabel = UILabel(frame: CGRectMake(CGFloat(coordinateX), CGFloat(coordinateY-15), 40, 15))
                    ceaMarkLabel.textColor = mainColor
                    ceaMarkLabel.text = String(stringInterpolationSegment: ceaValue)
                    ceaMarkLabel.font = UIFont(name: "Helvetica", size: 11)
                    ceaMarkLabel.textAlignment = NSTextAlignment.Left
                    self.chartScrollView.addSubview(ceaMarkLabel)
                    self.chartScrollView.addSubview(ceaMarkView)
                }
            }else if( CEAList.count == 1){
                let coordinateX = 10
                let ceaMarkCoordinateY = 50
                let dateLabel = UILabel(frame: CGRectMake(CGFloat(coordinateX), 100, 40, 15))
                setChartDateLabel(dateLabel, dateInsertedInt: (clinicReportList[0] as! NSDictionary).objectForKey("dateInserted") as! Int)
                let ceaMarkView = UIView(frame: CGRectMake(CGFloat(coordinateX), CGFloat(ceaMarkCoordinateY), 30, 3.5))
                ceaMarkView.backgroundColor = mainColor
                self.chartScrollView.addSubview(ceaMarkView)
                let ceaMarkLabel = UILabel(frame: CGRectMake(CGFloat(coordinateX), CGFloat(ceaMarkCoordinateY - 15), 40, 15))
                ceaMarkLabel.text = String(stringInterpolationSegment:CEAList[0])
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
                let coordinateBeginX = (Int(width)-80) * (ceaTreatmentBeginDate - beginDate)/(endDate - beginDate) + 10
                let coordinateEndX = (Int(width)-80) * (ceaTreatmentEndDate - beginDate)/(endDate - beginDate) + 50
                
                let coordinateY = Int(chartVerticalHeight) - 5
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
                let treatmentLabel = UILabel(frame: CGRectMake(CGFloat(coordinateBeginX), CGFloat(coordinateY - 10), 70, 10))
                treatmentLabel.text = (treatment as! NSDictionary).objectForKey("treatmentName") as! String
                treatmentLabel.font = UIFont(name: "Helvetica", size: 11.0)
                treatmentLabel.backgroundColor = UIColor.whiteColor()
                treatmentLabel.alpha = 1
                self.chartScrollView.addSubview(treatmentLabel)
            }
        }
  //      }
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
