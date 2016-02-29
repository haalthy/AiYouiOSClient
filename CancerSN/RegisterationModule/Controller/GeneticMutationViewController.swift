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
    
    var haalthyService = HaalthyService()
    
    var offsetHeightForNavigation : CGFloat = 0
    
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
        if isUpdate {
            offsetHeightForNavigation = 30
        }
    }
    
    func initContentView(){
        //previous Btn
        let previousBtn = UIButton(frame: CGRect(x: 0, y: previousBtnTopSpace, width: previousBtnWidth + previousBtnLeftSpace, height: previousBtnHeight))
        let previousImgView = UIImageView(frame: CGRECT(previousBtnLeftSpace, 0, previousBtnWidth, previousBtn.frame.height))
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
        let nextViewBtn = UIButton(frame: CGRect(x: 0, y: screenHeight - nextViewBtnButtomSpace - nextViewBtnHeight, width: screenWidth, height: nextViewBtnHeight))
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
        pieChartCenterLabel.text = String(value2) + "%"
        self.view.addSubview(newPieChartOuter)
        descriptionLabel.text = String(value2) + "%的患者为" + (sender.titleLabel?.text)! + "基因变异"
    }

    func PieChart(){
        let outerItems = [PNPieChartDataItem(value: 100, color: pieChartLightGrayColor)]
        let pieChartW: CGFloat = 219
        pieChartOuter = PNPieChart(frame: CGRectMake((screenWidth - pieChartW)/2, buttonSection.frame.origin.y + buttonSection.frame.height, pieChartW, pieChartW), items: outerItems)
        self.view.addSubview(pieChartOuter)
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
            if (profileSet.objectForKey(userTypeUserData) as! String) != aiyouUserType{
                let result: NSDictionary = haalthyService.addUser(profileSet.objectForKey(userTypeUserData) as! String)
                if (result.objectForKey("result") as! Int) != 1 {
                    HudProgressManager.sharedInstance.showHudProgress(self, title: result.objectForKey("resultDesp") as! String)
                }
            }
            self.performSegueWithIdentifier("selectTagSegue", sender: self)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "selectTagSegue" {
            (segue.destinationViewController as! FeedTagsViewController).isNavigationPop = true
        }
    }
}
