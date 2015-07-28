//
//  AgeSettingViewController.swift
//  CancerSN
//
//  Created by lily on 7/24/15.
//  Copyright (c) 2015 lily. All rights reserved.
//


import UIKit

class AgeSettingViewController: UIViewController , UIPickerViewDataSource, UIPickerViewDelegate{
    @IBOutlet weak var ageUIPickerView: UIPickerView!
    var pickerDataSource = [String]()

    @IBAction func selectAge(sender: AnyObject) {
        let profileSet = NSUserDefaults.standardUserDefaults()
        var selectedAge :String = pickerDataSource[ageUIPickerView.selectedRowInComponent(0)]
        profileSet.setObject(selectedAge, forKey: ageNSUserData)
    }
    
    override func viewDidLoad(){
        super.viewDidLoad()
        
        var index : Int
        for index = 1; index<90; ++index{
            pickerDataSource.append(String(index))
        }
        ageUIPickerView.delegate = self
        ageUIPickerView.dataSource = self
        ageUIPickerView.selectRow(60, inComponent: 0, animated: false)
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