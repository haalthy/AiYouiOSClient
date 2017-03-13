//
//  GeneticMutationViewController.swift
//  CancerSN
//
//  Created by lily on 11/12/15.
//  Copyright (c) 2015 lily. All rights reserved.
//

import UIKit

protocol GeneticMutationVCDelegate{
    func updateGeneticMutation(_ geneticMutation: String)
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
    
    let profileSet = UserDefaults.standard

    var selectGeneticMutationStr = String()
    var isUpdate = false
    var geneticMutationVCDelegate: GeneticMutationVCDelegate?
    
    var marginpieChartOuter  = PNPieChart()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initVariables()
        initContentView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if isUpdate == false {
            self.navigationController?.navigationBar.isHidden = true
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
        previousBtn.addTarget(self, action: #selector(GeneticMutationViewController.previousView(_:)), for: UIControlEvents.touchUpInside)
        previousBtn.addSubview(previousImgView)
        self.view.addSubview(previousBtn)
        
        //sign up title
        let signUpTitle = UILabel(frame: CGRect(x: signUpTitleMargin, y: signUpTitleTopSpace + offsetHeightForNavigation, width: screenWidth - signUpTitleMargin * 2, height: signUpTitleHeight + 10))
        signUpTitle.font = signUpTitleFont
        signUpTitle.textColor = signUpTitleTextColor
        signUpTitle.text = "请选择病人的基因信息"
        signUpTitle.textAlignment = NSTextAlignment.center
        self.view.addSubview(signUpTitle)
        
        //sign up subTitle
        let signUpSubTitle = UILabel(frame: CGRect(x: 0, y: signUpSubTitleTopSpace + offsetHeightForNavigation, width: screenWidth, height: signUpSubTitleHeight))
        signUpSubTitle.font = signUpSubTitleFont
        signUpSubTitle.textColor = signUpTitleTextColor
        signUpSubTitle.text = "靶向治疗方案的选择与病人的基因变异信息息息相关"
        signUpSubTitle.textAlignment = NSTextAlignment.center
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
            nextViewBtn.setTitle("下一题", for: UIControlState())
            nextViewBtn.setTitleColor(nextViewBtnColor, for: UIControlState())
            nextViewBtn.titleLabel?.font = nextViewBtnFont
            nextViewBtn.addTarget(self, action: #selector(GeneticMutationViewController.selectedNextView(_:)), for: UIControlEvents.touchUpInside)
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
            newButton.setTitle((genetic as! String), for: UIControlState())
            newButton.titleLabel?.font = buttonTitleLabelFont
            newButton.setTitleColor(headerColor, for: UIControlState())
            newButton.layer.borderColor = headerColor.cgColor
            newButton.layer.cornerRadius = 2
            newButton.layer.masksToBounds = true
            newButton.layer.borderWidth = 1
            newButton.backgroundColor = UIColor.white
            newButton.addTarget(self, action: #selector(GeneticMutationViewController.selectGenetic(_:)), for: UIControlEvents.touchUpInside)
            buttonsBeMoved.add(newButton)
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
        pieChartCenterLabel.font = UIFont.systemFont(ofSize: 24)
        pieChartCenterLabel.textColor = headerColor
        pieChartCenterLabel.textAlignment = NSTextAlignment.center
        pieChartCenterLabel.backgroundColor = UIColor.clear
        self.view.addSubview(pieChartCenterLabel)

        //description label
        descriptionLabel.frame = CGRECT(0, pieChartOuter.frame.origin.y + pieChartOuter.frame.width + 21, screenWidth, 12)
        descriptionLabel.textColor = signUpTitleTextColor
        descriptionLabel.font = UIFont.systemFont(ofSize: 12)
        descriptionLabel.textAlignment = NSTextAlignment.center
        self.view.addSubview(descriptionLabel)

    }
    
    func previousView(_ sender: UIButton){
        self.navigationController?.popViewController(animated: true)
    }
    
    func selectGenetic(_ sender: UIButton){
        if sender.backgroundColor == UIColor.white {
            sender.setTitleColor(UIColor.white, for: UIControlState())
            sender.backgroundColor = headerColor
            
            //fill piechart
            let itemIndex: Int = geneticList.index(of: (sender.titleLabel?.text)!)
            var value1: CGFloat = 0
            for index in 0 ..< itemIndex {
                value1 += geneticValueList[index] as! CGFloat
            }
            let value2: CGFloat = geneticValueList.object(at: itemIndex) as! CGFloat
            let value3: CGFloat = 100 - value1 - value2
            
            let outerItems = [PNPieChartDataItem(value: value1, color: UIColor.clear), PNPieChartDataItem(value: value2, color: headerColor), PNPieChartDataItem(value: value3, color: UIColor.clear)]
            newPieChartOuter.removeFromSuperview()
            newPieChartOuter = PNPieChart(frame: CGRect(x: pieChartOuter.frame.origin.x, y: pieChartOuter.frame.origin.y, width: pieChartOuter.frame.height, height: pieChartOuter.frame.height), items: outerItems as [AnyObject])
            pieChartOuter.duration = 0
            pieChartCenterLabel.text = String(describing: value2) + "%"
            self.view.addSubview(newPieChartOuter)
            descriptionLabel.text = String(describing: value2) + "%的患者为" + (sender.titleLabel?.text)! + "基因变异"
            self.view.bringSubview(toFront: pieChartOuter)
        }else{
            sender.setTitleColor(headerColor, for: UIControlState())
            sender.backgroundColor = UIColor.white
        }
        

    }

    func PieChart(){
        let pieChartW: CGFloat = 219

        let piechartFrame = PNPieChart(frame: CGRect(x: (screenWidth - pieChartW)/2, y: buttonSection.frame.origin.y + buttonSection.frame.height, width: pieChartW, height: pieChartW), items: [PNPieChartDataItem(value: 100, color: pieChartLightGrayColor)])
        self.view.addSubview(piechartFrame!)
        let outerItems = [PNPieChartDataItem(value: geneticValueList.object(at: 0) as! CGFloat, color: UIColor.clear, description: geneticList.object(at: 0) as! String),PNPieChartDataItem(value: geneticValueList.object(at: 1) as! CGFloat, color: UIColor.clear, description: geneticList.object(at: 1) as! String), PNPieChartDataItem(value: geneticValueList.object(at: 2) as! CGFloat, color: UIColor.clear, description: geneticList.object(at: 2) as! String), PNPieChartDataItem(value: geneticValueList.object(at: 3) as! CGFloat, color: UIColor.clear, description: geneticList.object(at: 3) as! String),PNPieChartDataItem(value: geneticValueList.object(at: 4) as! CGFloat, color: UIColor.clear, description: geneticList.object(at: 4) as! String), PNPieChartDataItem(value: geneticValueList.object(at: 5) as! CGFloat, color: UIColor.clear, description: geneticList.object(at: 5) as! String)]
        pieChartOuter = PNPieChart(frame: CGRect(x: (screenWidth - pieChartW)/2, y: buttonSection.frame.origin.y + buttonSection.frame.height, width: pieChartW, height: pieChartW), items: outerItems)
        pieChartOuter.descriptionTextColor = UIColor.white
        pieChartOuter.descriptionTextFont = UIFont.systemFont(ofSize: 13)
        pieChartOuter.descriptionTextShadowColor = UIColor.clear
        
        //piechart 边界
        let marginouterItems = [PNPieChartDataItem(value: geneticValueList.object(at: 0) as! CGFloat - 0.2, color: UIColor.clear), PNPieChartDataItem(value: 0.2, color: UIColor.white),PNPieChartDataItem(value: geneticValueList.object(at: 1) as! CGFloat - 0.2, color: UIColor.clear),PNPieChartDataItem(value: 0.2, color: UIColor.white), PNPieChartDataItem(value: geneticValueList.object(at: 2) as! CGFloat - 0.2, color: UIColor.clear),PNPieChartDataItem(value: 0.2, color: UIColor.white),PNPieChartDataItem(value: geneticValueList.object(at: 3) as! CGFloat - 0.2, color: UIColor.clear),PNPieChartDataItem(value: 0.2, color: UIColor.white),PNPieChartDataItem(value: geneticValueList.object(at: 4) as! CGFloat - 0.2, color: UIColor.clear),PNPieChartDataItem(value: 0.2, color: UIColor.white),PNPieChartDataItem(value: geneticValueList.object(at: 5) as! CGFloat - 0.2, color: UIColor.clear),PNPieChartDataItem(value: 0.2, color: UIColor.white)]
        marginpieChartOuter = PNPieChart(frame: CGRect(x: (screenWidth - pieChartW)/2, y: buttonSection.frame.origin.y + buttonSection.frame.height, width: pieChartW, height: pieChartW), items: marginouterItems)
        self.view.addSubview(pieChartOuter)
        self.view.addSubview(marginpieChartOuter)

    }

    @IBAction func selectedNextView(_ sender: UIButton){
        for geneticBtn in buttonSection.subviews {
            if  (geneticBtn is UIButton) && (geneticBtn.backgroundColor == headerColor) {
                selectGeneticMutationStr += ((geneticBtn as! UIButton).titleLabel?.text)!
            }
        }
        if isUpdate {
            geneticMutationVCDelegate?.updateGeneticMutation(selectGeneticMutationStr)
            self.navigationController?.popViewController(animated: true)
        }else{
            profileSet.set(selectGeneticMutationStr, forKey: geneticMutationNSUserData)
//            if (profileSet.objectForKey(userTypeUserData) as! String) != aiyouUserType{
                let result: NSDictionary = haalthyService.updateUser()
                if (result.object(forKey: "result") as! Int) != 1 {
                    HudProgressManager.sharedInstance.showHudProgress(self, title: result.object(forKey: "resultDesp") as! String)
                }
//            }
            self.performSegue(withIdentifier: "selectTagSegue", sender: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "selectTagSegue" {
            (segue.destination as! FeedTagsViewController).isNavigationPop = true
        }
    }
}
