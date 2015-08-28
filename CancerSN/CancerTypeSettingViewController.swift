//
//  CancerTypeSettingViewController.swift
//  CancerSN
//
//  Created by lily on 7/24/15.
//  Copyright (c) 2015 lily. All rights reserved.
//

import UIKit

class CancerTypeSettingViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate{

    @IBOutlet weak var selectBtn: UIButton!
    @IBOutlet weak var skipBtn: UIButton!
    @IBOutlet weak var cancerTypePickerView: UIPickerView!
    var pickerDataSource = [String]()
    
    @IBAction func selectCancerType(sender: UIButton) {
        let profileSet = NSUserDefaults.standardUserDefaults()
        var cancerType = pickerDataSource[cancerTypePickerView.selectedRowInComponent(0)]
        var selectedCancerType :String = cancerTypeMapping.objectForKey(cancerType) as! String
        profileSet.setObject(selectedCancerType, forKey: cancerTypeNSUserData)
        if(cancerType == "肺部"){
            self.performSegueWithIdentifier("showMoreForLung", sender: nil)
        }else{
            self.performSegueWithIdentifier("signup", sender: nil)
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        pickerDataSource = cancerTypeMapping.allKeys as! [String]
        cancerTypePickerView.delegate = self
        cancerTypePickerView.dataSource = self
        cancerTypePickerView.selectRow(3, inComponent: 0, animated: false)
        
        selectBtn.layer.cornerRadius = 5
        selectBtn.layer.masksToBounds = true
        skipBtn.layer.cornerRadius = 5
        skipBtn.layer.masksToBounds = true
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
        return pickerDataSource.count
    }
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        return pickerDataSource[row]
    }

}
