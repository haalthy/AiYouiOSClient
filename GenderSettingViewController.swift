//
//  GenderSettingViewController.swift
//  CancerSN
//
//  Created by lily on 7/23/15.
//  Copyright (c) 2015 lily. All rights reserved.
//

import UIKit

protocol GenderSettingVCDelegate{
    func updateGender(gender: String)
}

protocol AgeSettingVCDelegate{
    func updateAge(age: Int)
}

class GenderSettingViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    var isUpdate = false
    var pickerDataSource = [String]()
    var genderSettingVCDelegate: GenderSettingVCDelegate?
    var ageSettingVCDelegate: AgeSettingVCDelegate?
    var gender:String?
    @IBOutlet weak var confirmBtn: UIButton!
    @IBOutlet weak var maleSelect: UIButton!
    @IBOutlet weak var femaleSelect: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var agePickerView: UIPickerView!
    @IBAction func SelectGender(sender: UIButton) {
//        if isUpdate {
//            genderSettingVCDelegate?.updateGender(genderMapping.objectForKey((sender.titleLabel?.text)!) as! String)
//            self.dismissViewControllerAnimated(true, completion: nil)
//        }else{
//            let profileSet = NSUserDefaults.standardUserDefaults()
//        profileSet.setObject(genderMapping.objectForKey((sender.titleLabel?.text)!), forKey: genderNSUserData)
//            self.performSegueWithIdentifier("selectAgeSegue", sender: self)
//        }
//        gender = genderMapping.objectForKey((sender.titleLabel?.text)!) as! String
        if sender.backgroundColor == UIColor.whiteColor(){
            gender = genderMapping.objectForKey((sender.titleLabel?.text)!) as! String
        }else{
            gender = nil
        }
        if sender == maleSelect{
            maleSelect.backgroundColor = mainColor
            maleSelect.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
            femaleSelect.backgroundColor = UIColor.whiteColor()
            femaleSelect.setTitleColor(mainColor, forState: UIControlState.Normal)
        }else {
            femaleSelect.backgroundColor = mainColor
            femaleSelect.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
            maleSelect.backgroundColor = UIColor.whiteColor()
            maleSelect.setTitleColor(mainColor, forState: UIControlState.Normal)
        }
    }
    
    @IBAction func confirm(sender: UIButton) {
        var selectedAge: Int = pickerDataSource[agePickerView.selectedRowInComponent(0)].toInt()!
        if gender == nil{
            var alert = UIAlertController(title: "提示", message: "请您选择病人性别。", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "确定", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }else{
            if isUpdate{
                genderSettingVCDelegate?.updateGender(gender!)
                ageSettingVCDelegate?.updateAge(selectedAge)
                self.dismissViewControllerAnimated(true, completion: nil)
            }else{
                let profileSet = NSUserDefaults.standardUserDefaults()
                profileSet.setObject(gender, forKey: genderNSUserData)
                profileSet.setObject(selectedAge, forKey: ageNSUserData)
                self.performSegueWithIdentifier("cancerTypeSegue", sender: self)
            }
        }
    }
    
    override func viewDidLoad() {
        if isUpdate {
            titleLabel.hidden = true
        }
        
        agePickerView.delegate = self
        agePickerView.dataSource = self
        agePickerView.selectRow(60, inComponent: 0, animated: false)
        for var index = 1; index<90; ++index{
            pickerDataSource.append(String(index))
        }
        super.viewDidLoad()
        maleSelect.titleLabel?.text = "男"
        femaleSelect.titleLabel?.text = "女"

        maleSelect.layer.borderColor = textColor.CGColor
        maleSelect.layer.borderWidth = 2.0
        maleSelect.layer.cornerRadius = 5
        maleSelect.layer.masksToBounds = true
        maleSelect.backgroundColor = UIColor.whiteColor()
        maleSelect.titleLabel?.textColor = textColor
        
        femaleSelect.layer.borderColor = textColor.CGColor
        femaleSelect.layer.borderWidth = 2.0
        femaleSelect.layer.cornerRadius = 5
        femaleSelect.layer.masksToBounds = true
        femaleSelect.backgroundColor = UIColor.whiteColor()
        femaleSelect.titleLabel?.textColor = textColor
        
        confirmBtn.titleLabel?.textColor = UIColor.whiteColor()
        if isUpdate{
            confirmBtn.setTitle("确定", forState: UIControlState.Normal)
        }
    }
    
    override func viewWillAppear(animated: Bool) {
         super.viewWillAppear(animated)
        self.navigationController?.navigationBar.hidden = false

    }
    
    
    func pickerView(pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusingView view: UIView!) -> UIView {
        var pickerLabel = UILabel()
        if view == nil {
            pickerLabel = UILabel(frame: CGRectMake(0, 0, 270, 32))
        }else{
            pickerLabel = view as! UILabel
        }
        pickerLabel.textAlignment = NSTextAlignment.Center
        pickerLabel.textColor = textColor
        pickerLabel.text = pickerDataSource[row]
        pickerLabel.font = UIFont.boldSystemFontOfSize(15)
        return pickerLabel
    }
    
    //MARK: - Delegates and data sources
    //MARK: Data Sources
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerDataSource.count
    }
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        return pickerDataSource[row]
    }
}
