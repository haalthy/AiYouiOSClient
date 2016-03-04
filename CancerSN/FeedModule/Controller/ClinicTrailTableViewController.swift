//
//  ClinicTrailTableViewController.swift
//  CancerSN
//
//  Created by lily on 10/22/15.
//  Copyright (c) 2015 lily. All rights reserved.
//

import UIKit

class ClinicTrailTableViewController: UITableViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    var searchDataArr = NSMutableArray()

    var selectionPicker = UIPickerView()
    var selectionPickerContainerView = UIView()
    var selectionPickerContainerViewHeight: CGFloat = 200
    var selectionPickerContainerAppear = false
    var pickerDataSource = [String]()
    var treatmentSelectionData =  ["PD-1", "CTLA-4", "Vaccine", "CART",]
    var cancerTypeSelectionData = ["腺癌", "鳞癌", "小细胞癌症"]
    var stageSelectionData = ["I","II","IV","V"]
    var treatmentBtn = UIButton()
    var typeBtn = UIButton()
    var stageBtn = UIButton()
    
    //
    var headerHeight: CGFloat = 0
    let btnInPickerWidth: CGFloat = 50
    let btnInPickerHeight: CGFloat = 25

    override func viewDidLoad() {
        super.viewDidLoad()
        initVariables()
        initContentView()
        let parameters: Dictionary<String, AnyObject> = [
            
            "searchString" : "",
            "page" : 0,
            "count" : 10
        ]
        getPatientDataFromServer(parameters)
    }
    
    func initVariables(){
        headerHeight = (self.navigationController?.navigationBar.frame)!.height - UIApplication.sharedApplication().statusBarFrame.size.height

        self.tableView.registerClass(ClinicCell.self, forCellReuseIdentifier: cellSearchClinicTrailIdentifier)
    }
    
    func getPatientDataFromServer(parameters: Dictionary<String, AnyObject>) {
        
        HudProgressManager.sharedInstance.showHudProgress(self, title: "")
        
        NetRequest.sharedInstance.POST(searchClinicURL, parameters: parameters, success: { (content, message) -> Void in
            self.searchDataArr.removeAllObjects()
            let dict: NSArray = content as! NSArray
            let homeData = ClinicTrailObj.jsonToModelList(dict as Array) as! Array<ClinicTrailObj>
            
            self.searchDataArr.addObjectsFromArray(homeData)
            self.tableView.reloadData()
            HudProgressManager.sharedInstance.dismissHud()
            HudProgressManager.sharedInstance.showSuccessHudProgress(self, title: "搜索成功")
            }) { (content, message) -> Void in
                
                HudProgressManager.sharedInstance.dismissHud()
                HudProgressManager.sharedInstance.showOnlyTextHudProgress(self, title: message)
        }
        
    }
    
    func initContentView(){
        //init pickerView
        selectionPickerContainerView = UIView(frame: CGRectMake(0, UIScreen.mainScreen().bounds.height - headerHeight, UIScreen.mainScreen().bounds.width, selectionPickerContainerViewHeight))
        selectionPickerContainerView.backgroundColor = UIColor.whiteColor()
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
//        self.view.addSubview(selectionPickerContainerView)
        
        selectionPicker = UIPickerView(frame: CGRectMake(10.0, 40.0, UIScreen.mainScreen().bounds.width - 20, 150.0))
        
        selectionPicker.delegate = self
        selectionPicker.dataSource = self
        self.selectionPickerContainerView.addSubview(selectionPicker)
    }
    
    func cancelSelectionPicker(){
//        let durationTime: NSTimeInterval = 0.5
//        UIView.animateWithDuration(durationTime, animations: {
//            self.selectionPickerContainerView.center.y += self.selectionPickerContainerViewHeight
//        })
//        selectionPickerContainerAppear = false
        selectionPickerContainerView.removeFromSuperview()
    }
    
    func submitSelectionPicker(){
        let durationTime: NSTimeInterval = 0.5
//        UIView.animateWithDuration(durationTime, animations: {
//            self.selectionPickerContainerView.center.y += self.selectionPickerContainerViewHeight
//        })
        let selectStr = pickerDataSource[selectionPicker.selectedRowInComponent(0)]
        print(selectStr)
//        selectionPickerContainerAppear = false
        if (treatmentSelectionData as NSArray).containsObject(selectStr) {
            treatmentBtn.setTitle(selectStr, forState: UIControlState.Normal)
        }
        if (cancerTypeSelectionData as NSArray).containsObject(selectStr) {
            typeBtn.setTitle(selectStr, forState: UIControlState.Normal)
        }
        if (stageSelectionData as NSArray).containsObject(selectStr) {
            stageBtn.setTitle(selectStr, forState: UIControlState.Normal)
        }
        selectionPickerContainerView.removeFromSuperview()
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
        case 1: numberOfRows = self.searchDataArr.count
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
            formatSelectBtn(treatmentBtn, title: "PD-1 v")
            formatSelectBtn(typeBtn, title: "选择癌症类型v")
            treatmentBtn.addTarget(self, action: "selectTreatment", forControlEvents: UIControlEvents.TouchUpInside)
            typeBtn.addTarget(self, action: "selectCancerType", forControlEvents: UIControlEvents.TouchUpInside)
            cell.addSubview(treatmentBtn)
            cell.addSubview(typeBtn)
            return cell
        }else{
            let cell = tableView.dequeueReusableCellWithIdentifier(cellSearchClinicTrailIdentifier, forIndexPath: indexPath) as! ClinicCell
            
            cell.clinicTrial = self.searchDataArr[indexPath.row] as! ClinicTrailObj
//            cell.clinicCellDelegate = self
            return cell
        }
    }
    
    func selectTreatment(){
        if selectionPickerContainerAppear == false{
            pickerDataSource = treatmentSelectionData
            self.selectionPicker.reloadAllComponents()
            selectionPickerContainerAppear = true
            let durationTime: NSTimeInterval = 0.5
//            UIView.animateWithDuration(durationTime, animations: {
//                self.selectionPickerContainerView.center.y -= self.selectionPickerContainerViewHeight
//            })
            self.view.addSubview(selectionPickerContainerView)
        }
    }
    
    func selectCancerType(){
        if selectionPickerContainerAppear == false{
            pickerDataSource = cancerTypeSelectionData
            self.selectionPicker.reloadAllComponents()
            selectionPickerContainerAppear = true
            let durationTime: NSTimeInterval = 0.5
//            UIView.animateWithDuration(durationTime, animations: {
//                self.selectionPickerContainerView.center.y -= self.selectionPickerContainerViewHeight
//            })
            self.view.addSubview(selectionPickerContainerView)

        }
    }
    
    func selectStage(){
        if selectionPickerContainerAppear == false{
            pickerDataSource = stageSelectionData
            self.selectionPicker.reloadAllComponents()
            selectionPickerContainerAppear = true
            let durationTime: NSTimeInterval = 0.5
//            UIView.animateWithDuration(durationTime, animations: {
//                self.selectionPickerContainerView.center.y -= self.selectionPickerContainerViewHeight
//            })
            selectionPickerContainerView.removeFromSuperview()

        }
        selectionPickerContainerView.removeFromSuperview()
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
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerDataSource[row]
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat{
        if indexPath.section == 0 {
            return 40
        }else{
            return 120
        }
    }
}
