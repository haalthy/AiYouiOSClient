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
    var originalDataArr = NSMutableArray()
    
    var selectionPicker = UIPickerView()
    var selectionPickerContainerView = UIView()
    var selectionPickerContainerViewHeight: CGFloat = 250
    var selectionPickerContainerAppear = false
    var pickerDataSource = [String]()
    var treatmentSelectionData =  ["PD-1", "CTLA-4", "Vaccine", "CART",]
    var cancerTypeSelectionData = ["腺癌", "鳞癌", "非小细胞癌症", "弥漫性大B细胞淋巴瘤"]
    var treatmentBtn = UIButton()
    var typeBtn = UIButton()
    
    //
    var headerHeight: CGFloat = 0
    let btnInPickerWidth: CGFloat = 70
    let btnInPickerHeight: CGFloat = 30
    
    let transparentView = UIView()

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
        
        getDrugTypeFromServer()
        
        getSubGroupFromServer()
    }
    
    func getDrugTypeFromServer() {
        
        NetRequest.sharedInstance.GET(getCinicTrialDrugType, success: { (content, message) -> Void in
            if content is NSDictionary{
                self.treatmentSelectionData = (content as! NSDictionary).objectForKey("results") as! [String]
            }
            }) { (content, message) -> Void in
        }
        
    }
    
    func getSubGroupFromServer() {
        
        NetRequest.sharedInstance.GET(getCinicTrialSubGroup, success: { (content, message) -> Void in
            if content is NSDictionary{
                self.cancerTypeSelectionData = (content as! NSDictionary).objectForKey("results") as! [String]
            }
            }) { (content, message) -> Void in
                
        }
        
    }
    
    func getPatientDataFromServer(parameters: Dictionary<String, AnyObject>) {
        
        HudProgressManager.sharedInstance.showHudProgress(self, title: "")
        
        NetRequest.sharedInstance.POST(searchClinicURL, parameters: parameters, success: { (content, message) -> Void in
            self.searchDataArr.removeAllObjects()
            let dict: NSArray = content as! NSArray
            let homeData = ClinicTrailObj.jsonToModelList(dict as Array) as! Array<ClinicTrailObj>
            
            self.searchDataArr.addObjectsFromArray(homeData)
            self.originalDataArr.addObjectsFromArray(self.searchDataArr as [AnyObject])
            self.tableView.reloadData()
            HudProgressManager.sharedInstance.dismissHud()
            HudProgressManager.sharedInstance.showSuccessHudProgress(self, title: "搜索成功")
            }) { (content, message) -> Void in
                
                HudProgressManager.sharedInstance.dismissHud()
                HudProgressManager.sharedInstance.showOnlyTextHudProgress(self, title: message)
        }
        
    }
    
    func initContentView(){
        //设置透明层
        transparentView.frame = CGRECT(0, 0, UIScreen.mainScreen().bounds.width, UIScreen.mainScreen().bounds.height)
        transparentView.backgroundColor = UIColor.lightGrayColor()
        transparentView.alpha = 0.6
        
        //init pickerView
        selectionPickerContainerView = UIView(frame: CGRectMake(0, screenHeight - selectionPickerContainerViewHeight - headerHeight, screenWidth, selectionPickerContainerViewHeight))
        selectionPickerContainerView.backgroundColor = chartBackgroundColor
        let cancelBtnInPicker = UIButton(frame: CGRectMake(10, 10, btnInPickerWidth, btnInPickerHeight))
        let submitBtnInPicker = UIButton(frame: CGRectMake(screenWidth - 10 - btnInPickerWidth, 10, btnInPickerWidth, btnInPickerHeight))
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
        
        selectionPicker = UIPickerView(frame: CGRectMake(10.0, btnInPickerHeight, UIScreen.mainScreen().bounds.width - 20, 220.0))
        
        selectionPicker.delegate = self
        selectionPicker.dataSource = self
        self.selectionPickerContainerView.addSubview(selectionPicker)
        
        treatmentBtn = UIButton(frame: CGRectMake(0, 0, screenWidth / 2 - 1, 43))
        typeBtn = UIButton(frame: CGRectMake(screenWidth / 2 + 1, 0, screenWidth / 2 - 1, 43))

        
        let dropdownImageWidht: CGFloat = 15
        let dropdownImageview = UIImageView(frame: CGRect(x: screenWidth / 2 - 30, y: 0, width: dropdownImageWidht, height: 43))
        dropdownImageview.image = UIImage(named: "dropdown")
        dropdownImageview.contentMode = UIViewContentMode.ScaleAspectFit
        let anotherdropdownImageView: UIImageView = UIImageView(frame: CGRect(x: screenWidth / 2 - 30, y: 0, width: dropdownImageWidht, height: 43))
        anotherdropdownImageView.image = UIImage(named: "dropdown")
        anotherdropdownImageView.contentMode = UIViewContentMode.ScaleAspectFit
        
        treatmentBtn.addSubview(dropdownImageview)
        typeBtn.addSubview(anotherdropdownImageView)
        
        formatSelectBtn(treatmentBtn, title: "选择药物种类")
        formatSelectBtn(typeBtn, title: "选择癌症类型")
        
        treatmentBtn.addTarget(self, action: "selectTreatment", forControlEvents: UIControlEvents.TouchUpInside)
        typeBtn.addTarget(self, action: "selectCancerType", forControlEvents: UIControlEvents.TouchUpInside)
    }
    
    func cancelSelectionPicker(){
        transparentView.removeFromSuperview()
        selectionPickerContainerAppear = false
        selectionPickerContainerView.removeFromSuperview()
    }
    
    func submitSelectionPicker(){
        transparentView.removeFromSuperview()
        let selectStr = pickerDataSource[selectionPicker.selectedRowInComponent(0)]
        if (treatmentSelectionData as NSArray).containsObject(selectStr) {
            treatmentBtn.setTitle(selectStr, forState: UIControlState.Normal)
            //更新tableView
            self.searchDataArr.removeAllObjects()
            for cinicTrialItem in self.originalDataArr {
                if (cinicTrialItem as! ClinicTrailObj).drugType == selectStr {
                    self.searchDataArr.addObject(cinicTrialItem)
                }
            }
            if self.searchDataArr.count == 0 {
                HudProgressManager.sharedInstance.showOnlyTextHudProgress(self, title: "没有与此药物类型和癌症类型的临床信息")
            }
            self.tableView.reloadData()
        }
        if (cancerTypeSelectionData as NSArray).containsObject(selectStr) {
            typeBtn.setTitle(selectStr, forState: UIControlState.Normal)
            //更新tableView
            self.searchDataArr.removeAllObjects()
            for cinicTrialItem in self.originalDataArr {
                if (cinicTrialItem as! ClinicTrailObj).subGroup == selectStr {
                    self.searchDataArr.addObject(cinicTrialItem)
                }
            }
            if self.searchDataArr.count == 0 {
                HudProgressManager.sharedInstance.showOnlyTextHudProgress(self, title: "没有与此药物类型和癌症类型的临床信息")
            }
            self.tableView.reloadData()

        }
//        if (stageSelectionData as NSArray).containsObject(selectStr) {
//            stageBtn.setTitle(selectStr, forState: UIControlState.Normal)
//        }
        selectionPickerContainerAppear = false

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
            cell.removeAllSubviews()
            
            cell.addSubview(treatmentBtn)
            cell.addSubview(typeBtn)
            let seperateLine = UIView(frame: CGRect(x: 0, y: 43, width: screenWidth, height: 1))
            seperateLine.backgroundColor = seperateLineColor
            cell.addSubview(seperateLine)
            let verticalSeperateLine = UIView(frame: CGRect(x: screenWidth / 2, y: 15, width: 1, height: 13))
            verticalSeperateLine.backgroundColor = seperateLineColor
            cell.addSubview(verticalSeperateLine)
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
            self.view.addSubview(transparentView)
            pickerDataSource = treatmentSelectionData
            self.selectionPicker.reloadAllComponents()
            selectionPickerContainerAppear = true
            selectionPicker.selectRow(3, inComponent: 0, animated: false)
            self.view.addSubview(selectionPickerContainerView)
        }
    }
    
    func selectCancerType(){
        if selectionPickerContainerAppear == false{
            self.view.addSubview(transparentView)
            pickerDataSource = cancerTypeSelectionData
            self.selectionPicker.reloadAllComponents()
            selectionPickerContainerAppear = true
            selectionPicker.selectRow(3, inComponent: 0, animated: false)
            self.view.addSubview(selectionPickerContainerView)
        }
    }
    
    
    func formatSelectBtn(selectBtn: UIButton, title: String){
        selectBtn.setTitle(title, forState: UIControlState.Normal)
        selectBtn.setTitleColor(defaultTextColor, forState: UIControlState.Normal)
        selectBtn.titleLabel?.font = UIFont(name: fontStr, size: 12.0)
    }
    
    //MARK: - Delegates and data sources
    //MARK: Data Sources
    
    func pickerView(pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusingView view: UIView?) -> UIView {
        var pickerLabel = UILabel()
        if view == nil {
            pickerLabel = UILabel(frame: CGRectMake(0, 0, 270, 36))
        }else{
            pickerLabel = view as! UILabel
        }
        pickerLabel.textAlignment = NSTextAlignment.Center
        pickerLabel.textColor = pickerUnselectedColor
        pickerLabel.text = pickerDataSource[row]
        pickerLabel.font = pickerUnselectedFont
        return pickerLabel
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let pickerLabel = pickerView.viewForRow(row, forComponent: 0) as! UILabel
        pickerLabel.textColor = pickerSelectedColor
        pickerLabel.font = pickerSelectedFont
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
            return 44
        }else{
            
            let clinicTrial = self.searchDataArr[indexPath.row] as! ClinicTrailObj
            
            let otherInfoStr: String = clinicTrial.subGroup + " " + clinicTrial.stage + "\n" + clinicTrial.effect + "\n" + clinicTrial.sideEffect + "\n" + clinicTrial.researchInfo
            
            let strHeight = otherInfoStr.sizeWithFont(UIFont.systemFontOfSize(13), maxSize: CGSize(width: screenWidth - 30, height: CGFloat.max)).height
            return strHeight + 45
        }
    }
    
    var lastPosition: CGFloat = 0
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        let currentPostion: CGFloat = scrollView.contentOffset.y
        let distance: CGFloat = currentPostion - lastPosition;
        if distance > 25 {
            self.cancelSelectionPicker()
        }
    }

}
