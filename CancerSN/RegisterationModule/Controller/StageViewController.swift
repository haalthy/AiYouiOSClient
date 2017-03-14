//
//  StageViewController.swift
//  CancerSN
//
//  Created by lily on 7/26/15.
//  Copyright (c) 2015 lily. All rights reserved.
//

import UIKit
protocol StageSettingVCDelegate{
    func updateStage(_ stage: String)
}

//class StageViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate {
class StageViewController: UIViewController,UIPickerViewDataSource, UIPickerViewDelegate{

    var isUpdate = false
    var stageSettingVCDelegate: StageSettingVCDelegate?
    let topPickerView = UIPickerView()
    var stagePickerDataSource = [String]()
    
    var offsetHeightForNavigation : CGFloat = 0
    
    override func viewDidLoad() {
        initVariables()
        initContentView()
        topPickerView.selectRow(2, inComponent: 0, animated: true)
    }
    
    func initVariables(){
        stagePickerDataSource = ["I", "II", "III", "IV"]
        if isUpdate {
            offsetHeightForNavigation = 30
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        if isUpdate == false {
            self.navigationController?.navigationBar.isHidden = true
        }
    }
    
    func initContentView(){
        //previous Btn
        let btnMargin: CGFloat = 15
        let previousBtn = UIButton(frame: CGRect(x: 0, y: previousBtnTopSpace, width: previousBtnWidth + previousBtnLeftSpace + btnMargin, height: previousBtnHeight + btnMargin * 2))
        let previousImgView = UIImageView(frame: CGRECT(previousBtnLeftSpace, btnMargin, previousBtnWidth, previousBtnHeight))
        previousImgView.image = UIImage(named: "btn_previous")
        previousBtn.addTarget(self, action: #selector(StageViewController.previousView(_:)), for: UIControlEvents.touchUpInside)
        previousBtn.addSubview(previousImgView)
        self.view.addSubview(previousBtn)
        
        //sign up title
        let signUpTitle = UILabel(frame: CGRect(x: signUpTitleMargin, y: signUpTitleTopSpace + offsetHeightForNavigation, width: screenWidth - signUpTitleMargin * 2, height: signUpTitleHeight + 10))
        signUpTitle.font = signUpTitleFont
        signUpTitle.textColor = signUpTitleTextColor
        signUpTitle.text = "请选择病人的初诊分期"
        signUpTitle.textAlignment = NSTextAlignment.center
        self.view.addSubview(signUpTitle)
        
        //sign up subTitle
        let signUpSubTitle = UILabel(frame: CGRect(x: 0, y: signUpSubTitleTopSpace + offsetHeightForNavigation, width: screenWidth, height: signUpSubTitleHeight))
        signUpSubTitle.font = signUpSubTitleFont
        signUpSubTitle.textColor = signUpTitleTextColor
        signUpSubTitle.text = ""
        signUpSubTitle.textAlignment = NSTextAlignment.center
        self.view.addSubview(signUpSubTitle)
        
        //top Item Name
        let topItemNameLbl = UILabel(frame: CGRect(x: 0, y: signUpTopItemNameTopSpace + offsetHeightForNavigation, width: screenWidth, height: signUpItemNameHeight))
        topItemNameLbl.font = signUpItemNameFont
        topItemNameLbl.textColor = headerColor
        topItemNameLbl.text = "分期"
        topItemNameLbl.textAlignment = NSTextAlignment.center
        self.view.addSubview(topItemNameLbl)
        
        //top pickerView

        topPickerView.frame = CGRect(x: pickerMargin, y: topPickerTopSpace + offsetHeightForNavigation, width: screenWidth - pickerMargin * 2, height: screenHeight - topPickerTopSpace - topPickerButtomSpace)
        topPickerView.delegate = self
        topPickerView.dataSource = self
        self.view.addSubview(topPickerView)
        if isUpdate == false {
            //next view button
            let btnMargin: CGFloat = 15
            let nextViewBtn = UIButton(frame: CGRect(x: 0, y: screenHeight - nextViewBtnButtomSpace - nextViewBtnHeight - btnMargin, width: screenWidth, height: nextViewBtnHeight + btnMargin * 2))
            nextViewBtn.setTitle("下一题", for: UIControlState())
            nextViewBtn.setTitleColor(nextViewBtnColor, for: UIControlState())
            nextViewBtn.titleLabel?.font = nextViewBtnFont
            nextViewBtn.addTarget(self, action: #selector(StageViewController.selectedNextView(_:)), for: UIControlEvents.touchUpInside)
            self.view.addSubview(nextViewBtn)
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var pickerLabel = UILabel()
        if view == nil {
            pickerLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 270, height: 32))
        }else{
            pickerLabel = view as! UILabel
        }

        pickerLabel.text = stagePickerDataSource[row]
        pickerLabel.textAlignment = NSTextAlignment.center
        pickerLabel.textColor = pickerUnselectedColor
        pickerLabel.font = pickerUnselectedFont
        return pickerLabel
    }
    
    //MARK: - Delegates and data sources
    //MARK: Data Sources
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return stagePickerDataSource.count
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return pickerComponentHeight
    }
    
    //
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let pickerLabel = pickerView.view(forRow: row, forComponent: 0) as! UILabel
        pickerLabel.textColor = pickerSelectedColor
        pickerLabel.font = pickerSelectedFont
    }
    
    func previousView(_ sender: UIButton){
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func selectedNextView(_ sender: UIButton){
        let profileSet = UserDefaults.standard
        let stage = stagePickerDataSource[topPickerView.selectedRow(inComponent: 0)]
        profileSet.set(stage, forKey: stageNSUserData)
        if isUpdate {
            stageSettingVCDelegate?.updateStage(stage)
            self.navigationController?.popViewController(animated: true)
        }else {
            if topPickerView.selectedRow(inComponent: 0) == 3 {
                self.performSegue(withIdentifier: "metasticSegue", sender: self)
            }else{
                self.performSegue(withIdentifier: "geneticMutationSegue", sender: self)
            }
        }
    }
}
