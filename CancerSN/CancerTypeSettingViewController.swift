//
//  CancerTypeSettingViewController.swift
//  CancerSN
//
//  Created by lily on 7/24/15.
//  Copyright (c) 2015 lily. All rights reserved.
//

import UIKit

class CancerTypeSettingViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate{

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
