//
//  MetasticViewController.swift
//  CancerSN
//
//  Created by hui luo on 3/2/2016.
//  Copyright © 2016 lily. All rights reserved.
//

import UIKit
protocol MetastasisSettingVCDelegate{
    func updateMetastasis(_ metastasis: String)
}
class MetasticViewController: UIViewController {
    
    let metasticList = ["脑转移","骨转移", "肝转移", "肾上腺转移", "淋巴转移", "无转移", "其他"]
    let buttonSection = UIView()
    var metastasisSettingVCDelegate: MetastasisSettingVCDelegate?
    var offsetHeightForNavigation : CGFloat = 0
    var isUpdate = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        initVariables()
        initContentView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if isUpdate == false {
            self.navigationController?.navigationBar.isHidden = true
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
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
        previousBtn.addTarget(self, action: #selector(MetasticViewController.previousView(_:)), for: UIControlEvents.touchUpInside)
        previousBtn.addSubview(previousImgView)
        self.view.addSubview(previousBtn)
        
        //sign up title
        let signUpTitle = UILabel(frame: CGRect(x: signUpTitleMargin, y: signUpTitleTopSpace + offsetHeightForNavigation, width: screenWidth - signUpTitleMargin * 2, height: signUpTitleHeight + 10))
        signUpTitle.font = signUpTitleFont
        signUpTitle.textColor = signUpTitleTextColor
        signUpTitle.text = "请选择病人的转移情况"
        signUpTitle.textAlignment = NSTextAlignment.center
        self.view.addSubview(signUpTitle)
        
        //sign up subTitle
//        let signUpSubTitle = UILabel(frame: CGRect(x: 0, y: signUpSubTitleTopSpace + offsetHeightForNavigation, width: screenWidth, height: signUpSubTitleHeight))
//        signUpSubTitle.font = signUpSubTitleFont
//        signUpSubTitle.textColor = signUpTitleTextColor
//        signUpSubTitle.text = "不同的转移情况有不同的治疗方法"
//        signUpSubTitle.textAlignment = NSTextAlignment.Center
//        self.view.addSubview(signUpSubTitle)
        
        //top Item Name
        let topItemNameLbl = UILabel(frame: CGRect(x: 0, y: signUpTopItemNameTopSpace + offsetHeightForNavigation, width: screenWidth, height: signUpItemNameHeight))
        topItemNameLbl.font = signUpItemNameFont
        topItemNameLbl.textColor = headerColor
        topItemNameLbl.text = "转移部位"
        topItemNameLbl.textAlignment = NSTextAlignment.center
        self.view.addSubview(topItemNameLbl)
        
        if isUpdate == false {
            //next view button
            let btnMargin: CGFloat = 15
            let nextViewBtn = UIButton(frame: CGRect(x: 0, y: screenHeight - nextViewBtnButtomSpace - nextViewBtnHeight - btnMargin, width: screenWidth, height: nextViewBtnHeight + btnMargin * 2))
            nextViewBtn.setTitle("下一题", for: UIControlState())
            nextViewBtn.setTitleColor(nextViewBtnColor, for: UIControlState())
            nextViewBtn.titleLabel?.font = nextViewBtnFont
            nextViewBtn.addTarget(self, action: #selector(MetasticViewController.selectedNextView(_:)), for: UIControlEvents.touchUpInside)
            self.view.addSubview(nextViewBtn)
        }
        
        //metastic button section
        buttonSection.frame = CGRect(x: buttonSectionLeftSpace, y: buttonSectionTopSpace + offsetHeightForNavigation, width: screenWidth - buttonSectionLeftSpace * 2, height: buttonSectionHeight)
        var buttonX: CGFloat = 0
        var buttonY: CGFloat = 0
        let buttonHeight: CGFloat = CGFloat(29)
        let buttonsBeMoved = NSMutableArray()
        for metastic in metasticList {
            let textSize: CGSize = metastic.sizeWithFont(buttonTitleLabelFont, maxSize: CGSize(width: CGFloat.greatestFiniteMagnitude, height: buttonHeight))
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
            newButton.setTitle(metastic, for: UIControlState())
            newButton.titleLabel?.font = buttonTitleLabelFont
            newButton.setTitleColor(headerColor, for: UIControlState())
            newButton.layer.borderColor = headerColor.cgColor
            newButton.layer.cornerRadius = 2
            newButton.layer.masksToBounds = true
            newButton.layer.borderWidth = 1
            newButton.backgroundColor = UIColor.white
            newButton.addTarget(self, action: #selector(MetasticViewController.selectMetastic(_:)), for: UIControlEvents.touchUpInside)
            buttonsBeMoved.add(newButton)
            buttonSection.addSubview(newButton)
        }
        for button in buttonsBeMoved {
            (button as! UIButton).center = CGPoint(x: (button as! UIButton).center.x +  (buttonSection.frame.width - buttonX)/2, y: (button as! UIButton).center.y)
        }
        buttonsBeMoved.removeAllObjects()
        self.view.addSubview(buttonSection)
    }
    
    func selectMetastic(_ sender: UIButton){
        if sender.backgroundColor == UIColor.white {
            sender.setTitleColor(UIColor.white, for: UIControlState())
            sender.backgroundColor = headerColor
        }else{
            sender.setTitleColor(headerColor, for: UIControlState())
            sender.backgroundColor = UIColor.white
        }
    }
    
    func previousView(_ sender: UIButton){
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func selectedNextView(_ sender: UIButton){
        var metasticStr: String = ""
        for button in buttonSection.subviews {
            if button is UIButton {
                if button.backgroundColor == headerColor {
                    metasticStr += ((button as! UIButton).titleLabel?.text)! + " "
                }
            }
        }
        if isUpdate {
            metastasisSettingVCDelegate?.updateMetastasis(metasticStr)
            self.navigationController?.popViewController(animated: true)
        }else{
            let profileSet = UserDefaults.standard
            profileSet.set(metasticStr, forKey: metastasisNSUserData)
            self.performSegue(withIdentifier: "geneticMutationSegue", sender: self)
        }
    }
}


