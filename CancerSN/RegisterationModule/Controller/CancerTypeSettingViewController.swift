//
//  CancerTypeSettingViewController.swift
//  CancerSN
//
//  Created by lily on 7/24/15.
//  Copyright (c) 2015 lily. All rights reserved.
//

import UIKit

protocol CancerTypeSettingVCDelegate{
    func updateCancerType(_ cancerType: String)
}

protocol PathologicalSettingVCDelegate{
    func updatePathological(_ pathological: String)
}

class CancerTypeSettingViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate{
    var isUpdate = false
    var pathologicalSettingVCDelegate: PathologicalSettingVCDelegate?
    var cancerTypeSettingVCDelegate: CancerTypeSettingVCDelegate?
    var cancerTypePickerDataSource = [String]()
    var pathologicaPickerDataSource = [String]()
    let profileSet = UserDefaults.standard
    let topPickerView = UIPickerView()
    let buttomPickerView = UIPickerView()
    let buttomSection = UIView()
    
    let haalthyService = HaalthyService()
    
    var offsetHeightForNavigation : CGFloat = 0
    
    @IBAction func selectedNextView(_ sender: UIButton) {
        let cancerType: String = cancerTypePickerDataSource[topPickerView.selectedRow(inComponent: 0)]
        var pathological: String = ""
        if isUpdate {
            cancerTypeSettingVCDelegate?.updateCancerType(cancerType)
            if cancerType == "肺癌" {
                pathological = pathologicaPickerDataSource[buttomPickerView.selectedRow(inComponent: 0)]
            }
            pathologicalSettingVCDelegate?.updatePathological(pathological)
            self.navigationController?.popViewController(animated: true)
        }else {
            if(cancerType == "肺癌") && (buttomSection.isHidden == false){
                pathological = pathologicaPickerDataSource[buttomPickerView.selectedRow(inComponent: 0)]
                profileSet.set(cancerType, forKey: cancerTypeNSUserData)
                profileSet.set(pathological, forKey: pathologicalNSUserData)
                self.performSegue(withIdentifier: "stageSegue", sender: nil)
            }else{
                profileSet.set(cancerType, forKey: cancerTypeNSUserData)
//                if (profileSet.objectForKey(userTypeUserData) as! String) != aiyouUserType{
                    let result: NSDictionary = haalthyService.updateUser()
                    if (result.object(forKey: "result") as! Int) != 1 {
                        HudProgressManager.sharedInstance.showHudProgress(self, title: result.object(forKey: "resultDesp") as! String)
                    }
//                }
                self.performSegue(withIdentifier: "selectTagSegue", sender: self)
            }
        }
    }
//
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "selectTagSegue" {
            (segue.destination as! FeedTagsViewController).isNavigationPop = true
        }
    }
    
    override func viewDidLoad() {
//        if isUpdate{
//            titleLabel.hidden = true
//        }

        initVariables()
        initContentView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if isUpdate == false {
            self.navigationController?.navigationBar.isHidden = true
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
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
        previousBtn.addTarget(self, action: #selector(CancerTypeSettingViewController.previousView(_:)), for: UIControlEvents.touchUpInside)
        previousBtn.addSubview(previousImgView)
        self.view.addSubview(previousBtn)
        
        //sign vartitle
        let signUpTitle = UILabel(frame: CGRect(x: signUpTitleMargin, y: signUpTitleTopSpace + offsetHeightForNavigation, width: screenWidth - signUpTitleMargin * 2, height: signUpTitleHeight))
        signUpTitle.font = signUpTitleFont
        signUpTitle.textColor = signUpTitleTextColor
        signUpTitle.text = "请选择病人的诊断结果"
        signUpTitle.textAlignment = NSTextAlignment.center
        self.view.addSubview(signUpTitle)
        
        //sign up subTitle
        let signUpSubTitle = UILabel(frame: CGRect(x: 0, y: signUpSubTitleTopSpace + offsetHeightForNavigation, width: screenWidth, height: signUpSubTitleHeight))
        signUpSubTitle.font = signUpSubTitleFont
        signUpSubTitle.textColor = signUpTitleTextColor
        signUpSubTitle.text = "不同类型原发的治疗效果是不一样的"
        signUpSubTitle.textAlignment = NSTextAlignment.center
        self.view.addSubview(signUpSubTitle)
        
        //top Item Name
        let topItemNameLbl = UILabel(frame: CGRect(x: 0, y: signUpTopItemNameTopSpace + offsetHeightForNavigation, width: screenWidth, height: signUpItemNameHeight))
        topItemNameLbl.font = signUpItemNameFont
        topItemNameLbl.textColor = headerColor
        topItemNameLbl.text = "部位"
        topItemNameLbl.textAlignment = NSTextAlignment.center
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
        buttomSection.isHidden = true
        let buttomItemName = UILabel(frame: CGRECT(0, 33, screenWidth, signUpItemNameHeight))
        buttomItemName.text = "病理"
        buttomItemName.textAlignment = NSTextAlignment.center
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
            nextViewBtn.setTitle("下一题", for: UIControlState())
            nextViewBtn.setTitleColor(nextViewBtnColor, for: UIControlState())
            nextViewBtn.titleLabel?.font = nextViewBtnFont
            nextViewBtn.addTarget(self, action: #selector(CancerTypeSettingViewController.selectedNextView(_:)), for: UIControlEvents.touchUpInside)
            self.view.addSubview(nextViewBtn)
        }
    }
    
    func previousView(_ sender: UIButton){
        self.navigationController?.popViewController(animated: true)
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var pickerLabel = UILabel()
        if view == nil {
            pickerLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 270, height: 32))
        }else{
            pickerLabel = view as! UILabel
        }
        if pickerView == topPickerView{
            pickerLabel.text = cancerTypePickerDataSource[row]
        }else{
            pickerLabel.text = pathologicaPickerDataSource[row]
        }
        pickerLabel.textAlignment = NSTextAlignment.center
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
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == topPickerView{
            return cancerTypePickerDataSource.count
        }else{
            return pathologicaPickerDataSource.count
        }
    }

    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return pickerComponentHeight
    }
    
    //
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let pickerLabel = pickerView.view(forRow: row, forComponent: 0) as! UILabel
        pickerLabel.textColor = pickerSelectedColor
        pickerLabel.font = pickerSelectedFont
        if (pickerView == topPickerView)  {
            if ((pickerLabel.text)! == "肺癌")  {
                buttomSection.isHidden = false
            }else {
                buttomSection.isHidden = true
            }
        }
    }
    
}
