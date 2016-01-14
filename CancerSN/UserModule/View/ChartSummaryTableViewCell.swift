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
        let seperateLine = UIView(frame: CGRectMake(0, 43, screenWidth, 0.5))
//        seperateLine.backgroundColor = seperateLineColor
        seperateLine.backgroundColor = seperateLineColor
        chartHearderScrollView.backgroundColor = chartBackgroundColor
        chartScrollView.backgroundColor = chartBackgroundColor
        chartHearderScrollView.addSubview(seperateLine)
    }
    
    func updateUI(){
        initContentView()
        initVariable()
//        createHeaderBtn("CEA", index: 0)
//        createHeaderBtn("SSC", index: 1)
//        createHeaderBtn("CYFRA-21", index: 2)
        selectedItemIndex(buttonIndexPair.objectForKey(0) as! String, index: 0)
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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
