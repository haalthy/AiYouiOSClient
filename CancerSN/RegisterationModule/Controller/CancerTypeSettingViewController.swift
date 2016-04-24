//
//  CancerTypeSettingViewController.swift
//  CancerSN
//
//  Created by lily on 7/24/15.
//  Copyright (c) 2015 lily. All rights reserved.
//

import UIKit

protocol CancerTypeSettingVCDelegate{
    func updateCancerType(cancerType: String)
}

protocol PathologicalSettingVCDelegate{
    func updatePathological(pathological: String)
}

class CancerTypeSettingViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate{
    var isUpdate = false
    var pathologicalSettingVCDelegate: PathologicalSettingVCDelegate?
    var cancerTypeSettingVCDelegate: CancerTypeSettingVCDelegate?
    var cancerTypePickerDataSource = [String]()
    var pathologicaPickerDataSource = [String]()
    let profileSet = NSUserDefaults.standardUserDefaults()
    let topPickerView = UIPickerView()
    let buttomPickerView = UIPickerView()
    let buttomSection = UIView()
    
    let haalthyService = HaalthyService()
    
    var offsetHeightForNavigation : CGFloat = 0
    
    @IBAction func selectedNextView(sender: UIButton) {
        let cancerType: String = cancerTypePickerDataSource[topPickerView.selectedRowInComponent(0)]
        var pathological: String = ""
        if isUpdate {
            cancerTypeSettingVCDelegate?.updateCancerType(cancerType)
            if cancerType == "肺癌" {
                pathological = pathologicaPickerDataSource[buttomPickerView.selectedRowInComponent(0)]
            }
            pathologicalSettingVCDelegate?.updatePathological(pathological)
            self.navigationController?.popViewControllerAnimated(true)
        }else {
            if(cancerType == "肺癌") && (buttomSection.hidden == false){
                pathological = pathologicaPickerDataSource[buttomPickerView.selectedRowInComponent(0)]
                profileSet.setObject(cancerType, forKey: cancerTypeNSUserData)
                profileSet.setObject(pathological, forKey: pathologicalNSUserData)
                self.performSegueWithIdentifier("stageSegue", sender: nil)
            }else{
                profileSet.setObject(cancerType, forKey: cancerTypeNSUserData)
//                if (profileSet.objectForKey(userTypeUserData) as! String) != aiyouUserType{
                    let result: NSDictionary = haalthyService.updateUser()
                    if (result.objectForKey("result") as! Int) != 1 {
                        HudProgressManager.sharedInstance.showHudProgress(self, title: result.objectForKey("resultDesp") as! String)
                    }
//                }
                self.performSegueWithIdentifier("selectTagSegue", sender: self)
            }
        }
    }
//
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "selectTagSegue" {
            (segue.destinationViewController as! FeedTagsViewController).isNavigationPop = true
        }
    }
    
    override func viewDidLoad() {
//        if isUpdate{
//            titleLabel.hidden = true
//        }

        initVariables()
        initContentView()
    }
    
    override func viewWillAppear(animated: Bool) {
        if isUpdate == false {
            self.navigationController?.navigationBar.hidden = true
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        topPickerView.selectRow(4, inComponent: 0, animated: false)
        buttomPickerView.selectRow(1, inComponent: 0, animated: false)
    }
    
    func initVariables(){
        cancerTypePickerDataSource = cancerTypeMapping.allKeys as! [String]
        pathologicaPickerDataSource = ["腺癌","鳞癌","腺鳞癌", "小细胞癌"]
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
        
        //sign vartitle
        let signUpTitle = UILabel(frame: CGRect(x: signUpTitleMargin, y: signUpTitleTopSpace + offsetHeightForNavigation, width: screenWidth - signUpTitleMargin * 2, height: signUpTitleHeight))
        signUpTitle.font = signUpTitleFont
        signUpTitle.textColor = signUpTitleTextColor
        signUpTitle.text = "请选择病人的诊断结果"
        signUpTitle.textAlignment = NSTextAlignment.Center
        self.view.addSubview(signUpTitle)
        
        //sign up subTitle
        let signUpSubTitle = UILabel(frame: CGRect(x: 0, y: signUpSubTitleTopSpace + offsetHeightForNavigation, width: screenWidth, height: signUpSubTitleHeight))
        signUpSubTitle.font = signUpSubTitleFont
        signUpSubTitle.textColor = signUpTitleTextColor
        signUpSubTitle.text = "不同类型原发的治疗效果是不一样的"
        signUpSubTitle.textAlignment = NSTextAlignment.Center
        self.view.addSubview(signUpSubTitle)
        
        //top Item Name
        let topItemNameLbl = UILabel(frame: CGRect(x: 0, y: signUpTopItemNameTopSpace + offsetHeightForNavigation, width: screenWidth, height: signUpItemNameHeight))
        topItemNameLbl.font = signUpItemNameFont
        topItemNameLbl.textColor = headerColor
        topItemNameLbl.text = "部位"
        topItemNameLbl.textAlignment = NSTextAlignment.Center
        self.view.addSubview(topItemNameLbl)
        
        //top pickerView
        topPickerView.frame = CGRect(x: pickerMargin, y: topPickerTopSpace + offsetHeightForNavigation, width: screenWidth - pickerMargin * 2, height: screenHeight - topPickerTopSpace - topPickerButtomSpace)
        topPickerView.delegate = self
        topPickerView.dataSource = self
        self.view.addSubview(topPickerView)
        
        //seperate Line
        let seperateLine = UIImageView(frame: CGRECT(0, screenHeight - signUpSeperateLineBtmSpace, screenWidth, 1))
        seperateLine.image = UIImage(named: "img_signUpSeperateLine")
        self.view.addSubview(seperateLine)
        
        //buttom section
        if screenHeight < 600 {
            buttomViewHeight = 240
        }
        buttomSection.frame  = CGRect(x: 0, y: screenHeight - buttomViewHeight - buttomViewButtomSpace, width: screenWidth, height: buttomViewHeight)
        buttomSection.hidden = true
        let buttomItemName = UILabel(frame: CGRECT(0, 33, screenWidth, signUpItemNameHeight))
        buttomItemName.text = "病理"
        buttomItemName.textAlignment = NSTextAlignment.Center
        buttomItemName.font = signUpItemNameFont
        buttomItemName.textColor = headerColor
        buttomSection.addSubview(buttomItemName)
        buttomPickerView.frame = CGRECT(pickerMargin, 76, screenWidth - pickerMargin * 2, buttomViewHeight - 76 - 40)
        buttomPickerView.delegate = self
        buttomPickerView.dataSource = self
        buttomSection.addSubview(buttomPickerView)
        self.view.addSubview(buttomSection)
        
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
    }
    
    func previousView(sender: UIButton){
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func pickerView(pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusingView view: UIView?) -> UIView {
        var pickerLabel = UILabel()
        if view == nil {
            pickerLabel = UILabel(frame: CGRectMake(0, 0, 270, 32))
        }else{
            pickerLabel = view as! UILabel
        }
        if pickerView == topPickerView{
            pickerLabel.text = cancerTypePickerDataSource[row]
        }else{
            pickerLabel.text = pathologicaPickerDataSource[row]
        }
        pickerLabel.textAlignment = NSTextAlignment.Center
        pickerLabel.textColor = pickerUnselectedColor
        pickerLabel.font = pickerUnselectedFont
        return pickerLabel
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - Delegates and data sources
    //MARK: Data Sources
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == topPickerView{
            return cancerTypePickerDataSource.count
        }else{
            return pathologicaPickerDataSource.count
        }
    }

    func pickerView(pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return pickerComponentHeight
    }
    
    //
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let pickerLabel = pickerView.viewForRow(row, forComponent: 0) as! UILabel
        pickerLabel.textColor = pickerSelectedColor
        pickerLabel.font = pickerSelectedFont
        if (pickerView == topPickerView)  {
            if ((pickerLabel.text)! == "肺癌")  {
                buttomSection.hidden = false
            }else {
                buttomSection.hidden = true
            }
        }
    }
    
}
