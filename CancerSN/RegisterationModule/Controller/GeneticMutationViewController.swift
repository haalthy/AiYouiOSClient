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

    let geneticList: NSArray = ["EGFR","FGFR1", "KARS","ALK", "其他", "无突变"]
    let geneticValueList: NSArray = [25, 20, 20, 5, 25, 5]
    let buttonSection = UIView()
    let pieChartCenterLabel = UILabel()
    var pieChartOuter = PNPieChart()
    var descriptionLabel = UILabel()
    var newPieChartOuter = PNPieChart()
    
    var haalthyService = HaalthyService()
    
    var offsetHeightForNavigation : CGFloat = 0
    
    let profileSet = NSUserDefaults.standardUserDefaults()

    var selectGeneticMutationStr = String()
    var isUpdate = false
    var geneticMutationVCDelegate: GeneticMutationVCDelegate?
    
    var marginpieChartOuter  = PNPieChart()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initVariables()
        initContentView()
    }
    
    override func viewWillAppear(animated: Bool) {
        if isUpdate == false {
            self.navigationController?.navigationBar.hidden = true
        }
    }
    
    func initVariables(){
        if isUpdate {
            offsetHeightForNavigation = 30
        }
    }
    
    func initContentView(){
        //previous Btn
        let btnMargin: CGFloat = 15
        let previousBtn = UIButton(frame: CGRect(x: 0, y: previousBtnTopSpace, width: previousBtnWidth + previousBtnLeftSpace + btnMargin, height: previousBtnHeight + btnMargin * 2))
        let previousImgView = UIImageView(frame: CGRECT(previousBtnLeftSpace, btnMargin, previousBtnWidth, previousBtnHeight))
        previousImgView.image = UIImage(named: "btn_previous")
        previousBtn.addTarget(self, action: "previousView:", forControlEvents: UIControlEvents.TouchUpInside)
        previousBtn.addSubview(previousImgView)
        self.view.addSubview(previousBtn)
        
        //sign up title
        let signUpTitle = UILabel(frame: CGRect(x: signUpTitleMargin, y: signUpTitleTopSpace + offsetHeightForNavigation, width: screenWidth - signUpTitleMargin * 2, height: signUpTitleHeight + 10))
        signUpTitle.font = signUpTitleFont
        signUpTitle.textColor = signUpTitleTextColor
        signUpTitle.text = "请选择病人的基因信息"
        signUpTitle.textAlignment = NSTextAlignment.Center
        self.view.addSubview(signUpTitle)
        
        //sign up subTitle
        let signUpSubTitle = UILabel(frame: CGRect(x: 0, y: signUpSubTitleTopSpace + offsetHeightForNavigation, width: screenWidth, height: signUpSubTitleHeight))
        signUpSubTitle.font = signUpSubTitleFont
        signUpSubTitle.textColor = signUpTitleTextColor
        signUpSubTitle.text = "靶向治疗方案的选择与病人的基因变异信息息息相关"
        signUpSubTitle.textAlignment = NSTextAlignment.Center
        self.view.addSubview(signUpSubTitle)
        
        //top Item Name
        /*
        let topItemNameLbl = UILabel(frame: CGRect(x: 0, y: signUpTopItemNameTopSpace + offsetHeightForNavigation, width: screenWidth, height: signUpItemNameHeight))
        topItemNameLbl.font = signUpItemNameFont
        topItemNameLbl.textColor = headerColor
        topItemNameLbl.text = "基因信息"
        topItemNameLbl.textAlignment = NSTextAlignment.Center
        self.view.addSubview(topItemNameLbl)
        */
        
        //next view button
        if isUpdate == false {
            let btnMargin: CGFloat = 15
            let nextViewBtn = UIButton(frame: CGRect(x: 0, y: screenHeight - nextViewBtnButtomSpace - nextViewBtnHeight - btnMargin, width: screenWidth, height: nextViewBtnHeight + btnMargin * 2))
            nextViewBtn.setTitle("下一题", forState: UIControlState.Normal)
            nextViewBtn.setTitleColor(nextViewBtnColor, forState: UIControlState.Normal)
            nextViewBtn.titleLabel?.font = nextViewBtnFont
            nextViewBtn.addTarget(self, action: "selectedNextView:", forControlEvents: UIControlEvents.TouchUpInside)
            self.view.addSubview(nextViewBtn)
        }
        
        //genetic button section
        if screenHeight < 600 {
            buttonSectionTopSpace = 120
        }
        buttonSection.frame = CGRect(x: buttonSectionLeftSpace, y: buttonSectionTopSpace + offsetHeightForNavigation, width: screenWidth - buttonSectionLeftSpace * 2, height: buttonSectionHeight)
        var buttonX: CGFloat = 0
        var buttonY: CGFloat = 0
        let buttonHeight: CGFloat = CGFloat(29)
        let buttonsBeMoved = NSMutableArray()
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

        //description label
        descriptionLabel.frame = CGRECT(0, pieChartOuter.frame.origin.y + pieChartOuter.frame.width + 21, screenWidth, 12)
        descriptionLabel.textColor = signUpTitleTextColor
        descriptionLabel.font = UIFont.systemFontOfSize(12)
        descriptionLabel.textAlignment = NSTextAlignment.Center
        self.view.addSubview(descriptionLabel)

    }
    
    func previousView(sender: UIButton){
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func selectGenetic(sender: UIButton){
        if sender.backgroundColor == UIColor.whiteColor() {
            sender.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
            sender.backgroundColor = headerColor
            
            //fill piechart
            let itemIndex: Int = geneticList.indexOfObject((sender.titleLabel?.text)!)
            var value1: CGFloat = 0
            for var index = 0; index < itemIndex; index++ {
                value1 += geneticValueList[index] as! CGFloat
            }
            let value2: CGFloat = geneticValueList.objectAtIndex(itemIndex) as! CGFloat
            let value3: CGFloat = 100 - value1 - value2
            
            let outerItems = [PNPieChartDataItem(value: value1, color: UIColor.clearColor()), PNPieChartDataItem(value: value2, color: headerColor), PNPieChartDataItem(value: value3, color: UIColor.clearColor())]
            newPieChartOuter.removeFromSuperview()
            newPieChartOuter = PNPieChart(frame: CGRectMake(pieChartOuter.frame.origin.x, pieChartOuter.frame.origin.y, pieChartOuter.frame.height, pieChartOuter.frame.height), items: outerItems as [AnyObject])
            pieChartOuter.duration = 0
            pieChartCenterLabel.text = String(value2) + "%"
            self.view.addSubview(newPieChartOuter)
            descriptionLabel.text = String(value2) + "%的患者为" + (sender.titleLabel?.text)! + "基因变异"
            self.view.bringSubviewToFront(pieChartOuter)
        }else{
            sender.setTitleColor(headerColor, forState: UIControlState.Normal)
            sender.backgroundColor = UIColor.whiteColor()
        }
        

    }

    func PieChart(){
        let pieChartW: CGFloat = 219

        let piechartFrame = PNPieChart(frame: CGRectMake((screenWidth - pieChartW)/2, buttonSection.frame.origin.y + buttonSection.frame.height, pieChartW, pieChartW), items: [PNPieChartDataItem(value: 100, color: pieChartLightGrayColor)])
        self.view.addSubview(piechartFrame)
        let outerItems = [PNPieChartDataItem(value: geneticValueList.objectAtIndex(0) as! CGFloat, color: UIColor.clearColor(), description: geneticList.objectAtIndex(0) as! String),PNPieChartDataItem(value: geneticValueList.objectAtIndex(1) as! CGFloat, color: UIColor.clearColor(), description: geneticList.objectAtIndex(1) as! String), PNPieChartDataItem(value: geneticValueList.objectAtIndex(2) as! CGFloat, color: UIColor.clearColor(), description: geneticList.objectAtIndex(2) as! String), PNPieChartDataItem(value: geneticValueList.objectAtIndex(3) as! CGFloat, color: UIColor.clearColor(), description: geneticList.objectAtIndex(3) as! String),PNPieChartDataItem(value: geneticValueList.objectAtIndex(4) as! CGFloat, color: UIColor.clearColor(), description: geneticList.objectAtIndex(4) as! String), PNPieChartDataItem(value: geneticValueList.objectAtIndex(5) as! CGFloat, color: UIColor.clearColor(), description: geneticList.objectAtIndex(5) as! String)]
        pieChartOuter = PNPieChart(frame: CGRectMake((screenWidth - pieChartW)/2, buttonSection.frame.origin.y + buttonSection.frame.height, pieChartW, pieChartW), items: outerItems)
        pieChartOuter.descriptionTextColor = UIColor.whiteColor()
        pieChartOuter.descriptionTextFont = UIFont.systemFontOfSize(13)
        pieChartOuter.descriptionTextShadowColor = UIColor.clearColor()
        
        //piechart 边界
        let marginouterItems = [PNPieChartDataItem(value: geneticValueList.objectAtIndex(0) as! CGFloat - 0.2, color: UIColor.clearColor()), PNPieChartDataItem(value: 0.2, color: UIColor.whiteColor()),PNPieChartDataItem(value: geneticValueList.objectAtIndex(1) as! CGFloat - 0.2, color: UIColor.clearColor()),PNPieChartDataItem(value: 0.2, color: UIColor.whiteColor()), PNPieChartDataItem(value: geneticValueList.objectAtIndex(2) as! CGFloat - 0.2, color: UIColor.clearColor()),PNPieChartDataItem(value: 0.2, color: UIColor.whiteColor()),PNPieChartDataItem(value: geneticValueList.objectAtIndex(3) as! CGFloat - 0.2, color: UIColor.clearColor()),PNPieChartDataItem(value: 0.2, color: UIColor.whiteColor()),PNPieChartDataItem(value: geneticValueList.objectAtIndex(4) as! CGFloat - 0.2, color: UIColor.clearColor()),PNPieChartDataItem(value: 0.2, color: UIColor.whiteColor()),PNPieChartDataItem(value: geneticValueList.objectAtIndex(5) as! CGFloat - 0.2, color: UIColor.clearColor()),PNPieChartDataItem(value: 0.2, color: UIColor.whiteColor())]
        marginpieChartOuter = PNPieChart(frame: CGRectMake((screenWidth - pieChartW)/2, buttonSection.frame.origin.y + buttonSection.frame.height, pieChartW, pieChartW), items: marginouterItems)
        self.view.addSubview(pieChartOuter)
        self.view.addSubview(marginpieChartOuter)

    }

    @IBAction func selectedNextView(sender: UIButton){
        for geneticBtn in buttonSection.subviews {
            if  (geneticBtn is UIButton) && (geneticBtn.backgroundColor == headerColor) {
                selectGeneticMutationStr += ((geneticBtn as! UIButton).titleLabel?.text)!
            }
        }
        if isUpdate {
            geneticMutationVCDelegate?.updateGeneticMutation(selectGeneticMutationStr)
            self.navigationController?.popViewControllerAnimated(true)
        }else{
            profileSet.setObject(selectGeneticMutationStr, forKey: geneticMutationNSUserData)
//            if (profileSet.objectForKey(userTypeUserData) as! String) != aiyouUserType{
                let result: NSDictionary = haalthyService.updateUser()
                if (result.objectForKey("result") as! Int) != 1 {
                    HudProgressManager.sharedInstance.showHudProgress(self, title: result.objectForKey("resultDesp") as! String)
                }
//            }
            self.performSegueWithIdentifier("selectTagSegue", sender: self)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "selectTagSegue" {
            (segue.destinationViewController as! FeedTagsViewController).isNavigationPop = true
        }
    }
}
