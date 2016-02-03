//
//  GeneticMutationViewController.swift
//  CancerSN
//
//  Created by lily on 11/12/15.
//  Copyright (c) 2015 lily. All rights reserved.
//

import UIKit

protocol GeneticMutationVCDelegate{
    func updateGeneticMutation(geneticMutation: String)
}

class GeneticMutationViewController: UIViewController {

//    let geneticDictionary = NSDictionary(objects: [25, 10, 30, 20, 15], forKeys: ["ALK","KARS", "EGFR", "其他", "无突变"])
    let geneticList: NSArray = ["ALK","KARS", "EGFR", "其他", "无突变"]
    let geneticValueList: NSArray = [25, 10, 30, 20, 15]
    let buttonSection = UIView()
    let pieChartCenterLabel = UILabel()
    var pieChartOuter = PNPieChart()
    
    var publicService = PublicService()
    let profileSet = NSUserDefaults.standardUserDefaults()

    var selectGeneticMutationStr = String()
    var isUpdate = false
    var geneticMutationVCDelegate: GeneticMutationVCDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initVariables()
        initContentView()
    }
    
    func initVariables(){
    
    }
    
    func initContentView(){
        //previous Btn
        let previousBtn = UIButton(frame: CGRect(x: previousBtnLeftSpace, y: previousBtnTopSpace, width: previousBtnWidth, height: previousBtnHeight))
        let previousImgView = UIImageView(frame: CGRECT(0, 0, previousBtn.frame.width, previousBtn.frame.height))
        previousImgView.image = UIImage(named: "btn_previous")
        previousBtn.addTarget(self, action: "previousView:", forControlEvents: UIControlEvents.TouchUpInside)
        previousBtn.addSubview(previousImgView)
        self.view.addSubview(previousBtn)
        
        //sign up title
        let signUpTitle = UILabel(frame: CGRect(x: signUpTitleMargin, y: signUpTitleTopSpace, width: screenWidth - signUpTitleMargin * 2, height: signUpTitleHeight))
        signUpTitle.font = signUpTitleFont
        signUpTitle.textColor = signUpTitleTextColor
        signUpTitle.text = "请选择病人的基因信息"
        signUpTitle.textAlignment = NSTextAlignment.Center
        self.view.addSubview(signUpTitle)
        
        //sign up subTitle
        let signUpSubTitle = UILabel(frame: CGRect(x: 0, y: signUpSubTitleTopSpace, width: screenWidth, height: signUpSubTitleHeight))
        signUpSubTitle.font = signUpSubTitleFont
        signUpSubTitle.textColor = signUpTitleTextColor
        signUpSubTitle.text = "靶向治疗方案的选择与病人的基因变异信息息息相关"
        signUpSubTitle.textAlignment = NSTextAlignment.Center
        self.view.addSubview(signUpSubTitle)
        
        //top Item Name
        let topItemNameLbl = UILabel(frame: CGRect(x: 0, y: signUpTopItemNameTopSpace, width: screenWidth, height: signUpItemNameHeight))
        topItemNameLbl.font = signUpItemNameFont
        topItemNameLbl.textColor = headerColor
        topItemNameLbl.text = "基因信息"
        topItemNameLbl.textAlignment = NSTextAlignment.Center
        self.view.addSubview(topItemNameLbl)
        
        //next view button
        let nextViewBtn = UIButton(frame: CGRect(x: 0, y: screenHeight - nextViewBtnButtomSpace - nextViewBtnHeight, width: screenWidth, height: nextViewBtnHeight))
        nextViewBtn.setTitle("下一题", forState: UIControlState.Normal)
        nextViewBtn.setTitleColor(nextViewBtnColor, forState: UIControlState.Normal)
        nextViewBtn.titleLabel?.font = nextViewBtnFont
        nextViewBtn.addTarget(self, action: "selectedNextView:", forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(nextViewBtn)
        
        //genetic button section
        buttonSection.frame = CGRect(x: buttonSectionLeftSpace, y: buttonSectionTopSpace, width: screenWidth - buttonSectionLeftSpace * 2, height: buttonSectionHeight)
        var buttonX: CGFloat = 0
        var buttonY: CGFloat = 0
        let buttonHeight: CGFloat = CGFloat(29)
        var buttonsBeMoved = NSMutableArray()
        for genetic in geneticList {
            
            let textSize: CGSize = (genetic as! String).sizeWithFont(buttonTitleLabelFont, maxSize: CGSize(width: buttonSection.frame.width - buttonX, height: buttonHeight))
            let buttonW: CGFloat = textSize.width + buttonTitleLabelHorizonMargin * 2
            if (buttonW + buttonX) > buttonSection.frame.width {
                let distanceBeMoved: CGFloat = (buttonSection.frame.width - buttonX)/2
                for button in buttonsBeMoved {
                    (button as! UIButton).center = CGPoint(x: (button as! UIButton).center.x + distanceBeMoved, y: (button as! UIButton).center.y)
                }
                buttonsBeMoved.removeAllObjects()
                buttonX = 0
                buttonY += buttonHeight + buttonVerticalSpace
            }
            let newButton = UIButton(frame: CGRect(x: buttonX, y: buttonY, width: buttonW, height: buttonHeight))
            buttonX += newButton.frame.width + 7
            newButton.setTitle((genetic as! String), forState: UIControlState.Normal)
            newButton.titleLabel?.font = buttonTitleLabelFont
            newButton.setTitleColor(headerColor, forState: UIControlState.Normal)
            newButton.layer.borderColor = headerColor.CGColor
            newButton.layer.cornerRadius = 2
            newButton.layer.masksToBounds = true
            newButton.layer.borderWidth = 1
            newButton.backgroundColor = UIColor.whiteColor()
            newButton.addTarget(self, action: "selectGenetic:", forControlEvents: UIControlEvents.TouchUpInside)
            buttonsBeMoved.addObject(newButton)
            buttonSection.addSubview(newButton)
        }
        for button in buttonsBeMoved {
            (button as! UIButton).center = CGPoint(x: (button as! UIButton).center.x +  (buttonSection.frame.width - buttonX)/2, y: (button as! UIButton).center.y)
        }
        buttonsBeMoved.removeAllObjects()
        self.view.addSubview(buttonSection)
        
        PieChart()

        //picCenterLabel
        pieChartCenterLabel.frame = CGRECT(0, pieChartOuter.frame.origin.y + 97, screenWidth, 24)
        pieChartCenterLabel.font = UIFont.systemFontOfSize(24)
        pieChartCenterLabel.textColor = headerColor
        pieChartCenterLabel.textAlignment = NSTextAlignment.Center
        pieChartCenterLabel.backgroundColor = UIColor.clearColor()
        self.view.addSubview(pieChartCenterLabel)

    }
    
    func previousView(sender: UIButton){
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func selectGenetic(sender: UIButton){
        if sender.backgroundColor == UIColor.whiteColor() {
            sender.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
            sender.backgroundColor = headerColor
        }else{
            sender.setTitleColor(headerColor, forState: UIControlState.Normal)
            sender.backgroundColor = UIColor.whiteColor()
        }
        
        let itemIndex: Int = geneticList.indexOfObject((sender.titleLabel?.text)!)
        var value1: CGFloat = 0
        for var index = 0; index < itemIndex; index++ {
            value1 += geneticValueList[index] as! CGFloat
        }
        let value2: CGFloat = geneticValueList.objectAtIndex(itemIndex) as! CGFloat
        let value3: CGFloat = 100 - value1 - value2

        let outerItems = [PNPieChartDataItem(value: value1, color: UIColor.clearColor()), PNPieChartDataItem(value: value2 - 0.2, color: headerColor, description: "ALK"), PNPieChartDataItem(value: 0.2, color: pieChartDarkGrayColor), PNPieChartDataItem(value: value3, color: UIColor.clearColor())]

        let newPieChartOuter = PNPieChart(frame: CGRectMake(pieChartOuter.frame.origin.x, pieChartOuter.frame.origin.y, pieChartOuter.frame.height, pieChartOuter.frame.height), items: outerItems as [AnyObject])
        newPieChartOuter.duration = 0
        pieChartCenterLabel.text = String(value2)
        self.view.addSubview(newPieChartOuter)
    }

    func PieChart(){
        
//        let items = [PNPieChartDataItem(value: 10, color: UIColor.blueColor(), description: ""),PNPieChartDataItem(value: 35, color: UIColor.redColor(), description: ""),PNPieChartDataItem(value: 15, color: UIColor.orangeColor(), description: ""),PNPieChartDataItem(value: 20, color: UIColor.greenColor(), description: ""),PNPieChartDataItem(value: 20, color: UIColor.yellowColor(), description: "")]
        let outerItems = [PNPieChartDataItem(value: 100, color: pieChartLightGrayColor)]
        let pieChartW: CGFloat = 219
        pieChartOuter = PNPieChart(frame: CGRectMake((screenWidth - pieChartW)/2, buttonSection.frame.origin.y + buttonSection.frame.height, pieChartW, pieChartW), items: outerItems)
        self.view.addSubview(pieChartOuter)
//        pieChartOuter.outerCircleRadius = 219/2
//        pieChartOuter.innerCircleRadius = 10
//        pieChartOuter.descriptionTextFont = UIFont.boldSystemFontOfSize(13)
//        pieChartOuter.strokeChart()
//        let innerItems = [PNPieChartDataItem(value: 100, color: pieChartDarkGrayColor)]
//        let innerPieChartW: CGFloat = 144
//        let pieChartInner = PNPieChart(frame: CGRectMake((screenWidth - innerPieChartW)/2, buttonSection.frame.origin.y + buttonSection.frame.height + 37.5, innerPieChartW, innerPieChartW), items: innerItems)
//        pieChartInner.innerCircleRadius = 40
//        print(pieChartInner.innerCircleRadius)
//        pieChartOuter.outerCircleRadius = 219/2
//        pieChartOuter.innerCircleRadius = 10
//        let items = [PNPieChartDataItem(value: 100, color: UIColor.redColor())]
//        let whietPieChartW: CGFloat = 124
//        let whitePieChartInner = PNPieChart(frame: CGRectMake((screenWidth - whietPieChartW)/2, buttonSection.frame.origin.y + buttonSection.frame.height + 47.5, whietPieChartW, whietPieChartW), items: items)
//        self.view.addSubview(whitePieChartInner)
//        self.view.addSubview(pieChartInner)
        
        //        pieChart.legendStyle = PNLegendItemStyle.Stacked
        //        let legend = pieChart.getLegendWithMaxWidth(200)
        //        legend.frame = CGRectMake(150,550, legend.frame.size.width, legend.frame.size.height)
        //        self.view.addSubview(legend)
    }

    
//    override func didReceiveMemoryWarning() {
//        super.didReceiveMemoryWarning()
//        // Dispose of any resources that can be recreated.
//    }
//    
//
//
//    @IBAction func selectGenetic(sender: UIButton) {
//        selectGeneticMutationStr = geneticMutationMapping.objectForKey((sender.titleLabel?.text)!) as! String
//        switch sender{
//        case krasBtn:
//            publicService.selectedBtnFormat(krasBtn)
//            publicService.unselectBtnFormat(egfrBtn)
//            publicService.unselectBtnFormat(alkBtn)
//            publicService.unselectBtnFormat(otherMutationBtn)
//            publicService.unselectBtnFormat(noMutationBtn)
//        case egfrBtn:
//            publicService.selectedBtnFormat(egfrBtn)
//            publicService.unselectBtnFormat(krasBtn)
//            publicService.unselectBtnFormat(alkBtn)
//            publicService.unselectBtnFormat(otherMutationBtn)
//            publicService.unselectBtnFormat(noMutationBtn)
//        case alkBtn:
//            publicService.selectedBtnFormat(alkBtn)
//            publicService.unselectBtnFormat(krasBtn)
//            publicService.unselectBtnFormat(egfrBtn)
//            publicService.unselectBtnFormat(otherMutationBtn)
//            publicService.unselectBtnFormat(noMutationBtn)
//        case otherMutationBtn:
//            publicService.selectedBtnFormat(otherMutationBtn)
//            publicService.unselectBtnFormat(krasBtn)
//            publicService.unselectBtnFormat(egfrBtn)
//            publicService.unselectBtnFormat(alkBtn)
//            publicService.unselectBtnFormat(noMutationBtn)
//        case noMutationBtn:
//            publicService.selectedBtnFormat(noMutationBtn)
//            publicService.unselectBtnFormat(krasBtn)
//            publicService.unselectBtnFormat(egfrBtn)
//            publicService.unselectBtnFormat(otherMutationBtn)
//            publicService.unselectBtnFormat(alkBtn)
//        default:
//            break
//        }
//        
//    }
//    
//    @IBAction func confirm(sender: UIButton) {
//        if isUpdate{
//            geneticMutationVCDelegate?.updateGeneticMutation(selectGeneticMutationStr)
//            self.dismissViewControllerAnimated(true, completion: nil)
//        }else{
//            profileSet.setObject(selectGeneticMutationStr, forKey: geneticMutationNSUserData)
//            self.performSegueWithIdentifier("stageAndMetastasisSegue", sender: self)
//        }
//    }
}
