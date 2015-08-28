//
//  StageViewController.swift
//  CancerSN
//
//  Created by lily on 7/26/15.
//  Copyright (c) 2015 lily. All rights reserved.
//

import UIKit

class StageViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    @IBOutlet weak var stagePickerView: UIPickerView!
    
    @IBOutlet weak var selectBtn: UIButton!
    
    @IBOutlet weak var skipBtn: UIButton!
    var pickerDataSource = [String]()

    @IBAction func selectStage(sender: UIButton) {
        let profileSet = NSUserDefaults.standardUserDefaults()
        var stage = pickerDataSource[stagePickerView.selectedRowInComponent(0)]
        var selectedStage = stageMapping.objectForKey(stage)
        profileSet.setObject(selectedStage, forKey: stageNSUserData)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        pickerDataSource = stageMapping.allKeys as! [String]
        pickerDataSource = ["I","II","IV","V"]
        stagePickerView.delegate = self
        stagePickerView.dataSource = self
        stagePickerView.selectRow(1, inComponent: 0, animated: false)
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
