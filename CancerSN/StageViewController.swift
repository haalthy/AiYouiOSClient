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
    
    var pickerDataSource = [String]()

    @IBAction func selectStage(sender: UIButton) {
        let profileSet = NSUserDefaults.standardUserDefaults()
        var stage = pickerDataSource[stagePickerView.selectedRowInComponent(0)]
        var selectedStage = stageMapping.objectForKey(stage)
        profileSet.setObject(selectedStage, forKey: stageNSUserData)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pickerDataSource = stageMapping.allKeys as! [String]
        stagePickerView.delegate = self
        stagePickerView.dataSource = self
        stagePickerView.selectRow(1, inComponent: 0, animated: false)

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
