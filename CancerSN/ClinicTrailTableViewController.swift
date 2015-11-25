//
//  ClinicTrailTableViewController.swift
//  CancerSN
//
//  Created by lily on 10/22/15.
//  Copyright (c) 2015 lily. All rights reserved.
//

import UIKit

class ClinicTrailTableViewController: UITableViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    var resultList = NSArray()
    var selectionPicker = UIPickerView()
    var selectionPickerContainerView = UIView()
    var selectionPickerContainerViewHeight: CGFloat = 200
    var selectionPickerContainerAppear = false
    var pickerDataSource = [String]()
    var treatmentSelectionData =  ["PD-1", "PD-2", "PD-3"]
    var cancerTypeSelectionData = ["肝部", "肾部", "肺部", "胆管", "肠部", "胃部", "妇科", "血液"]
    var stageSelectionData = ["I","II","IV","V"]
    var treatmentBtn = UIButton()
    var typeBtn = UIButton()
    var stageBtn = UIButton()

    override func viewDidLoad() {
        super.viewDidLoad()
        print(UIApplication.sharedApplication().statusBarFrame.size.height)
        selectionPickerContainerView = UIView(frame: CGRectMake(0, UIScreen.mainScreen().bounds.height - (self.navigationController?.navigationBar.frame)!.height - UIApplication.sharedApplication().statusBarFrame.size.height, UIScreen.mainScreen().bounds.width, selectionPickerContainerViewHeight))
        selectionPickerContainerView.backgroundColor = UIColor.whiteColor()
        let btnInPickerWidth: CGFloat = 50
        let btnInPickerHeight: CGFloat = 25
        let cancelBtnInPicker = UIButton(frame: CGRectMake(20, 10, btnInPickerWidth, btnInPickerHeight))
        let submitBtnInPicker = UIButton(frame: CGRectMake(UIScreen.mainScreen().bounds.width - 20 - btnInPickerWidth, 10, btnInPickerWidth, btnInPickerHeight))
        cancelBtnInPicker.setTitle("取消", forState: UIControlState.Normal)
        submitBtnInPicker.setTitle("确定", forState: UIControlState.Normal)
        cancelBtnInPicker.setTitleColor(UIColor.lightGrayColor(), forState: UIControlState.Normal)
        submitBtnInPicker.setTitleColor(mainColor, forState: UIControlState.Normal)
        cancelBtnInPicker.titleLabel?.font = UIFont(name: fontStr, size: 14.0)
        submitBtnInPicker.titleLabel?.font = UIFont(name: fontStr, size: 14.0)
        cancelBtnInPicker.addTarget(self, action: "cancelSelectionPicker", forControlEvents: UIControlEvents.TouchUpInside)
        submitBtnInPicker.addTarget(self, action: "submitSelectionPicker", forControlEvents: UIControlEvents.TouchUpInside)
        selectionPickerContainerView.addSubview(cancelBtnInPicker)
        selectionPickerContainerView.addSubview(submitBtnInPicker)
        selectionPickerContainerView.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(1.0)
        self.view.addSubview(selectionPickerContainerView)
        
        selectionPicker = UIPickerView(frame: CGRectMake(10.0, 40.0, UIScreen.mainScreen().bounds.width - 20, 150.0))
        
        selectionPicker.delegate = self
        selectionPicker.dataSource = self
        self.selectionPickerContainerView.addSubview(selectionPicker)
    }
    
    func cancelSelectionPicker(){
        let durationTime: NSTimeInterval = 0.5
        UIView.animateWithDuration(durationTime, animations: {
            self.selectionPickerContainerView.center.y += self.selectionPickerContainerViewHeight
        })
        selectionPickerContainerAppear = false
    }
    
    func submitSelectionPicker(){
        let durationTime: NSTimeInterval = 0.5
        UIView.animateWithDuration(durationTime, animations: {
            self.selectionPickerContainerView.center.y += self.selectionPickerContainerViewHeight
        })
        let selectStr = pickerDataSource[selectionPicker.selectedRowInComponent(0)]
        print(selectStr)
        selectionPickerContainerAppear = false
        if (treatmentSelectionData as NSArray).containsObject(selectStr) {
            treatmentBtn.setTitle(selectStr, forState: UIControlState.Normal)
        }
        if (cancerTypeSelectionData as NSArray).containsObject(selectStr) {
            typeBtn.setTitle(selectStr, forState: UIControlState.Normal)
        }
        if (stageSelectionData as NSArray).containsObject(selectStr) {
            stageBtn.setTitle(selectStr, forState: UIControlState.Normal)
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        self.tabBarController?.tabBar.hidden = true
    }

    override func viewWillDisappear(animated: Bool) {
        self.tabBarController?.tabBar.hidden = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var numberOfRows = 0
        switch section{
        case 0: numberOfRows = 1
            break
        case 1: numberOfRows = resultList.count
            break
        default: break
        }
        return numberOfRows
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0{
            let cell = tableView.dequeueReusableCellWithIdentifier("clinicTrailHeader", forIndexPath: indexPath) 
            let selectBtnWidth: CGFloat = (cell.frame.width - 60)/2
            let selectBtnHeight: CGFloat = 30
            treatmentBtn = UIButton(frame: CGRectMake(20, 7, selectBtnWidth, selectBtnHeight))
            typeBtn = UIButton(frame: CGRectMake(30 + selectBtnWidth, 7, selectBtnWidth, selectBtnHeight))
//            stageBtn = UIButton(frame: CGRectMake(40 + selectBtnWidth * 2, 7, selectBtnWidth, selectBtnHeight))
            formatSelectBtn(treatmentBtn, title: "PD-1 v")
            formatSelectBtn(typeBtn, title: "选择癌症类型v")
//            formatSelectBtn(stageBtn, title: "选择癌症分期v")
            treatmentBtn.addTarget(self, action: "selectTreatment", forControlEvents: UIControlEvents.TouchUpInside)
            typeBtn.addTarget(self, action: "selectCancerType", forControlEvents: UIControlEvents.TouchUpInside)
//            stageBtn.addTarget(self, action: "selectStage", forControlEvents: UIControlEvents.TouchUpInside)
            cell.addSubview(treatmentBtn)
            cell.addSubview(typeBtn)
//            cell.addSubview(stageBtn)
            return cell
        }else{
            let cell = tableView.dequeueReusableCellWithIdentifier("clinicTrailList", forIndexPath: indexPath) 
            
            return cell
        }
    }
    
    func selectTreatment(){
        if selectionPickerContainerAppear == false{
            pickerDataSource = treatmentSelectionData
            self.selectionPicker.reloadAllComponents()
            selectionPickerContainerAppear = true
            let durationTime: NSTimeInterval = 0.5
            UIView.animateWithDuration(durationTime, animations: {
                self.selectionPickerContainerView.center.y -= self.selectionPickerContainerViewHeight
            })
        }
    }
    
    func selectCancerType(){
        if selectionPickerContainerAppear == false{
            pickerDataSource = cancerTypeSelectionData
            self.selectionPicker.reloadAllComponents()
            selectionPickerContainerAppear = true
            let durationTime: NSTimeInterval = 0.5
            UIView.animateWithDuration(durationTime, animations: {
                self.selectionPickerContainerView.center.y -= self.selectionPickerContainerViewHeight
            })
        }
    }
    
    func selectStage(){
        if selectionPickerContainerAppear == false{
            pickerDataSource = stageSelectionData
            self.selectionPicker.reloadAllComponents()
            selectionPickerContainerAppear = true
            let durationTime: NSTimeInterval = 0.5
            UIView.animateWithDuration(durationTime, animations: {
                self.selectionPickerContainerView.center.y -= self.selectionPickerContainerViewHeight
            })
        }
    }
    
    func formatSelectBtn(selectBtn: UIButton, title: String){
        selectBtn.setTitle(title, forState: UIControlState.Normal)
        selectBtn.setTitleColor(mainColor, forState: UIControlState.Normal)
        selectBtn.backgroundColor = UIColor.whiteColor()
        selectBtn.layer.borderColor = mainColor.CGColor
        selectBtn.layer.borderWidth = 1.5
        selectBtn.layer.cornerRadius = 5
        selectBtn.layer.masksToBounds = true
        selectBtn.titleLabel?.font = UIFont(name: fontStr, size: 12.0)
    }
    
    //MARK: - Delegates and data sources
    //MARK: Data Sources
    
    func pickerView(pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusingView view: UIView?) -> UIView {
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
