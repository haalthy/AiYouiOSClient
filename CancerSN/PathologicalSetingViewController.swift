//
//  PathologicalSetingViewController.swift
//  CancerSN
//
//  Created by lily on 7/26/15.
//  Copyright (c) 2015 lily. All rights reserved.
//

import UIKit

protocol PathologicalSettingVCDelegate{
    func updatePathological(pathological: String)
}
class PathologicalSetingViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate{
    var isUpdate = false
    var pathologicalSettingVCDelegate: PathologicalSettingVCDelegate?
    @IBOutlet weak var selectBtn: UIButton!

    @IBOutlet weak var skipBtn: UIButton!
    @IBOutlet weak var pathologicalPickerView: UIPickerView!

    @IBOutlet weak var titleLabel: UILabel!
    var pickerDataSource = [String]()

    @IBAction func skip(sender: UIButton) {
        self.performSegueWithIdentifier("selectStageSegue", sender: self)
    }
    @IBAction func selectPathological(sender: UIButton) {
        let profileSet = NSUserDefaults.standardUserDefaults()
        var pathological = pickerDataSource[pathologicalPickerView.selectedRowInComponent(0)]
        var selectedPathological:String = pathologicalMapping.objectForKey(pathological) as! String
        if isUpdate{
            pathologicalSettingVCDelegate?.updatePathological(selectedPathological)
            self.dismissViewControllerAnimated(true, completion: nil)
        }else{
            profileSet.setObject(selectedPathological, forKey: pathologicalNSUserData)
            self.performSegueWithIdentifier("selectStageSegue", sender: self)
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        if isUpdate{
            titleLabel.hidden = true
        }
        
        pickerDataSource = pathologicalMapping.allKeys as! [String]
        pathologicalPickerView.dataSource = self
        pathologicalPickerView.delegate = self
        pathologicalPickerView.selectRow(1, inComponent: 0, animated: false)
        selectBtn.layer.cornerRadius = 5
        selectBtn.layer.masksToBounds = true
        skipBtn.layer.cornerRadius = 5
        skipBtn.layer.masksToBounds = true
        if isUpdate{
            skipBtn.hidden = true
        }
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
