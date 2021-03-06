//
//  GenderSettingViewController.swift
//  CancerSN
//
//  Created by lily on 7/23/15.
//  Copyright (c) 2015 lily. All rights reserved.
//

import UIKit

protocol GenderSettingVCDelegate{
    func updateGender(_ gender: String)
}

protocol AgeSettingVCDelegate{
    func updateAge(_ age: Int)
}

class GenderSettingViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    var genderSettingVCDelegate: GenderSettingVCDelegate?
    var ageSettingVCDelegate: AgeSettingVCDelegate?
    var isUpdate = false
    var pickerDataSource = [String]()
    let agePickerView = UIPickerView()
    let maleBtn = UIButton()
    var femaleBtn = UIButton()
    var gender: String?
    
    var offsetHeightForNavigation : CGFloat = 0
    
    override func viewDidLoad() {
        initVariables()
        initContentView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if isUpdate == false {
            self.navigationController?.navigationBar.isHidden = true
        }
    }

    func initVariables(){
//        if isUpdate {
//            offsetHeightForNavigation =
//        }
    }
    
    func initContentView(){
        if (screenHeight < 600)  && (isUpdate == true){
            signUpTitleHeight = 0
            signUpSubTitleHeight = 0
            genderBtnTopSpace = 160
            signUpTopItemNameTopSpace = 95
        }
        //sign up title
        let signUpTitle = UILabel(frame: CGRect(x: 0, y: signUpTitleTopSpace + offsetHeightForNavigation, width: screenWidth, height: signUpTitleHeight))
        signUpTitle.font = signUpTitleFont
        signUpTitle.textColor = signUpTitleTextColor
        signUpTitle.text = "请选择病人的性别和年龄"
        signUpTitle.textAlignment = NSTextAlignment.center
        self.view.addSubview(signUpTitle)
        
        //sign up subTitle
        let signUpSubTitle = UILabel(frame: CGRect(x: 0, y: signUpSubTitleTopSpace + offsetHeightForNavigation, width: screenWidth, height: signUpSubTitleHeight))
        signUpSubTitle.font = signUpSubTitleFont
        signUpSubTitle.textColor = signUpTitleTextColor
        signUpSubTitle.text = "你知道吗？一些治疗药物的剂量需要根据性别和年龄进行调整"
        signUpSubTitle.textAlignment = NSTextAlignment.center
        self.view.addSubview(signUpSubTitle)
        
        //male 
        maleBtn.frame = CGRect(x: maleLeftSpace, y: genderBtnTopSpace + offsetHeightForNavigation, width: maleWidth, height: genderBtnHeight)
        let maleImageView = UIImageView(frame: CGRECT(0, 0, maleWidth, genderBtnHeight))
        maleImageView.image = UIImage(named: "btn_maleUnselected")
        maleBtn.addSubview(maleImageView)
        maleBtn.addTarget(self, action: #selector(GenderSettingViewController.selectGender(_:)), for: UIControlEvents.touchUpInside)
        self.view.addSubview(maleBtn)
        //female
        femaleBtn.frame = CGRect(x: screenWidth - femaleWidth - femaleRightSpace, y: genderBtnTopSpace + offsetHeightForNavigation, width: femaleWidth, height: genderBtnHeight)
        let femaleImageView = UIImageView(frame: CGRECT(0, 0, femaleWidth, genderBtnHeight))
        femaleImageView.image = UIImage(named: "btn_femaleUnselected")
        femaleBtn.addSubview(femaleImageView)
        femaleBtn.addTarget(self, action: #selector(GenderSettingViewController.selectGender(_:)), for: UIControlEvents.touchUpInside)
        self.view.addSubview(femaleBtn)
        
        //top Item Name
        let topItemNameLbl = UILabel(frame: CGRect(x: 0, y: signUpTopItemNameTopSpace  + offsetHeightForNavigation, width: screenWidth, height: signUpItemNameHeight))
        topItemNameLbl.font = signUpItemNameFont
        topItemNameLbl.textColor = headerColor
        topItemNameLbl.text = "性别"
        topItemNameLbl.textAlignment = NSTextAlignment.center
        self.view.addSubview(topItemNameLbl)
        
        //seperate Line
        let seperateLine = UIImageView(frame: CGRECT(0, screenHeight - signUpSeperateLineBtmSpace, screenWidth, 1))
        seperateLine.image = UIImage(named: "img_signUpSeperateLine")
        self.view.addSubview(seperateLine)
        
        //buttom item name
        let buttomItemNameLbl = UILabel(frame: CGRect(x: 0, y: screenHeight - signUpButtomItemNameButtomSpace, width: screenWidth, height: signUpItemNameHeight))
        buttomItemNameLbl.font = signUpItemNameFont
        buttomItemNameLbl.textColor = headerColor
        buttomItemNameLbl.text = "年龄"
        buttomItemNameLbl.textAlignment = NSTextAlignment.center
        self.view.addSubview(buttomItemNameLbl)
        
        //age picker view
        let agePickerViewHeight = agePickerYToButtom - (agePickerButtomSpace)
        agePickerView.frame = CGRect(x: pickerMargin, y: screenHeight - agePickerYToButtom, width: screenWidth - pickerMargin * 2, height: agePickerViewHeight)
        agePickerView.delegate = self
        agePickerView.dataSource = self
        for index in 1 ..< 90 {
            pickerDataSource.append(String(index))
        }
        self.view.addSubview(agePickerView)
        
        //next view button
        if isUpdate == false {
            let btnMargin: CGFloat = 15
            let nextViewBtn = UIButton(frame: CGRect(x: 0, y: screenHeight - nextViewBtnButtomSpace - nextViewBtnHeight - btnMargin, width: screenWidth, height: nextViewBtnHeight + btnMargin * 2))
            nextViewBtn.setTitle("下一题", for: UIControlState())
            nextViewBtn.setTitleColor(nextViewBtnColor, for: UIControlState())
            nextViewBtn.titleLabel?.font = nextViewBtnFont
            nextViewBtn.addTarget(self, action: #selector(GenderSettingViewController.selectedNextView(_:)), for: UIControlEvents.touchUpInside)
            self.view.addSubview(nextViewBtn)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        agePickerView.selectRow(60, inComponent: 0, animated: false)
    }

     func selectGender(_ sender: UIButton) {
        if sender == maleBtn{
            gender = "M"
            if (maleBtn.subviews.count > 0) && (maleBtn.subviews[0] is UIImageView){
                let maleImgView: UIImageView = maleBtn.subviews[0] as! UIImageView
                maleImgView.image = UIImage(named: "btn_maleSelected")
                let femaleImgView: UIImageView = femaleBtn.subviews[0] as! UIImageView
                femaleImgView.image = UIImage(named: "btn_femaleUnselected")
            }
        }else {
            gender = "F"
            if (maleBtn.subviews.count > 0) && (maleBtn.subviews[0] is UIImageView){
                let maleImgView: UIImageView = maleBtn.subviews[0] as! UIImageView
                maleImgView.image = UIImage(named: "btn_maleUnselected")
                let femaleImgView: UIImageView = femaleBtn.subviews[0] as! UIImageView
                femaleImgView.image = UIImage(named: "btn_femaleSelected")
            }
        }
    }
//
   @IBAction func selectedNextView(_ sender: UIButton) {
        let selectedAge: Int = Int(pickerDataSource[agePickerView.selectedRow(inComponent: 0)])!
        if gender == nil{
            let alert = UIAlertController(title: "提示", message: "请您选择病人性别。", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "确定", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }else{
            if isUpdate{
                genderSettingVCDelegate?.updateGender(gender!)
                ageSettingVCDelegate?.updateAge(selectedAge)
//                self.dismissViewControllerAnimated(true, completion: nil)
                self.navigationController?.popViewController(animated: true)
            }else{
                let profileSet = UserDefaults.standard
                profileSet.set(gender, forKey: genderNSUserData)
                profileSet.set(selectedAge, forKey: ageNSUserData)
                self.performSegue(withIdentifier: "cancerTypeSegue", sender: self)
            }
        }
    }
//
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return pickerComponentHeight
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var pickerLabel = UILabel()
        if view == nil {
            pickerLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 270, height: 32))
        }else{
            pickerLabel = view as! UILabel
        }
        pickerLabel.textAlignment = NSTextAlignment.center
        pickerLabel.textColor = pickerUnselectedColor
        pickerLabel.text = pickerDataSource[row]
        pickerLabel.font = pickerUnselectedFont
        return pickerLabel
    }
//
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let pickerLabel = agePickerView.view(forRow: row, forComponent: 0) as! UILabel
        pickerLabel.textColor = pickerSelectedColor
        pickerLabel.font = pickerSelectedFont
    }
    //MARK: - Delegates and data sources
    //MARK: Data Sources
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerDataSource.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerDataSource[row]
    }
}
