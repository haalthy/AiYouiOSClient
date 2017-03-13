//
//  ClinicTrailTableViewController.swift
//  CancerSN
//
//  Created by lily on 10/22/15.
//  Copyright (c) 2015 lily. All rights reserved.
//

import UIKit
import CoreData

class ClinicTrailTableViewController: UITableViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    let setClinicTrialListTimeStamp = "setClinicTrialListTimeStamp"
    
    var searchDataArr = NSMutableArray()
    var originalDataArr = NSMutableArray()
    
    var selectionPicker = UIPickerView()
    var selectionPickerContainerView = UIView()
    var selectionPickerContainerViewHeight: CGFloat = 270
    var selectionPickerContainerAppear = false
    var pickerDataSource = [String]()
    var treatmentSelectionData =  [String]()
    var cancerTypeSelectionData = [String]()
    var treatmentBtn = UIButton()
    var typeBtn = UIButton()
    
    //
    var headerHeight: CGFloat = 0
    let btnInPickerWidth: CGFloat = 70
    let btnInPickerHeight: CGFloat = 40
    
    let transparentView = UIView()

    override func viewDidLoad() {
        super.viewDidLoad()
        initVariables()
        initContentView()
        let parameters: Dictionary<String, AnyObject> = [
            "searchString" : "" as AnyObject,
            "page" : 0 as AnyObject,
            "count" : 50 as AnyObject
        ]
        getClinicTrialDataFromServer(parameters)
    }
    
    func initVariables(){
        headerHeight = (self.navigationController?.navigationBar.frame)!.height - UIApplication.shared.statusBarFrame.size.height

        self.tableView.register(ClinicCell.self, forCellReuseIdentifier: cellSearchClinicTrailIdentifier)
        
        getDrugTypeFromServer()
        
        getSubGroupFromServer()
    }
    
    //get ClinicTrial From Local DB
    func getClinicTrailFromLocalDB(){
        let appDel:AppDelegate = (UIApplication.shared.delegate as! AppDelegate)
        let context:NSManagedObjectContext = appDel.managedObjectContext!
        let clinicTrialRequest = NSFetchRequest<NSFetchRequestResult>(entityName: tableClinicTrial)
        clinicTrialRequest.returnsDistinctResults = true
        clinicTrialRequest.returnsObjectsAsFaults = false
        
        clinicTrialRequest.resultType = NSFetchRequestResultType.dictionaryResultType
        let clinicTrialList = try! context.fetch(clinicTrialRequest)
        let homeData = ClinicTrailObj.jsonToModelList(clinicTrialList as AnyObject?) as! Array<ClinicTrailObj>
        self.searchDataArr.removeAllObjects()
        self.searchDataArr.addObjects(from: homeData)
        self.originalDataArr.addObjects(from: self.searchDataArr as [AnyObject])
//        self.searchDataArr.addObjectsFromArray(clinicTrialList)
    }
    
    //save ClinicTrial to Local DB
    func saveClinicTrialToLocalDB(){
        let appDel:AppDelegate = (UIApplication.shared.delegate as! AppDelegate)
        let context:NSManagedObjectContext = appDel.managedObjectContext!
        for clinicTrial in self.searchDataArr {
            let clinicTrialItem = clinicTrial as! ClinicTrailObj
            let clinicTrialLocalDBItem = NSEntityDescription.insertNewObject(forEntityName: tableClinicTrial, into: context)
            clinicTrialLocalDBItem.setValue(clinicTrialItem.drugType, forKey: propertyDrugType)
            clinicTrialLocalDBItem.setValue(clinicTrialItem.subGroup, forKey: propertySubGroup)
            clinicTrialLocalDBItem.setValue(clinicTrialItem.drugName, forKey: propertyDrugName)
            clinicTrialLocalDBItem.setValue(clinicTrialItem.stage, forKey: propertyStage)
            clinicTrialLocalDBItem.setValue(clinicTrialItem.effect, forKey: propertyEffect)
            clinicTrialLocalDBItem.setValue(clinicTrialItem.sideEffect, forKey: propertySideEffect)
            clinicTrialLocalDBItem.setValue(clinicTrialItem.researchInfo, forKey: propertyResearchInfo)
            clinicTrialLocalDBItem.setValue(clinicTrialItem.original, forKey: propertyOriginal)
        }
        do {
            try context.save()
        } catch _ {
        }
    }
    
    //func clear ClinicTrial From LocalDB
    func clearClinicTrialLocalDB(){
        let appDel:AppDelegate = (UIApplication.shared.delegate as! AppDelegate)
        let context:NSManagedObjectContext = appDel.managedObjectContext!
        let deletePostsRequet = NSFetchRequest<NSFetchRequestResult>(entityName: tableClinicTrial)
        if let results = try? context.fetch(deletePostsRequet) {
            for param in results {
                context.delete(param as! NSManagedObject);
            }
        }
        do {
            try context.save()
        } catch _ {
        }
    }
    
    func getDrugTypeFromServer() {
        
        NetRequest.sharedInstance.GET(getCinicTrialDrugType, success: { (content, message) -> Void in
            if content is NSDictionary{
                self.treatmentSelectionData = (content as! NSDictionary).object(forKey: "results") as! [String]
            }
            }) { (content, message) -> Void in
        }
        
    }
    
    func getSubGroupFromServer() {
        
        NetRequest.sharedInstance.GET(getCinicTrialSubGroup, success: { (content, message) -> Void in
            if content is NSDictionary{
                self.cancerTypeSelectionData = (content as! NSDictionary).object(forKey: "results") as! [String]
            }
            }) { (content, message) -> Void in
                
        }
        
    }
    
    func getClinicTrialDataFromServer(_ parameters: Dictionary<String, AnyObject>) {
        
        let currentTimeStamp: Double = Foundation.Date().timeIntervalSince1970
        var previousStoreTimestamp: Double = 0
        if  UserDefaults.standard.object(forKey: setClinicTrialListTimeStamp) != nil {
            previousStoreTimestamp = UserDefaults.standard.object(forKey: setClinicTrialListTimeStamp) as! Double
            
        }
        if (currentTimeStamp - previousStoreTimestamp) > (28 * 86400) {
            clearClinicTrialLocalDB()
        }else{
            getClinicTrailFromLocalDB()
        }
                
        if self.searchDataArr.count == 0 {
            
            HudProgressManager.sharedInstance.showHudProgress(self, title: "")
            
            NetRequest.sharedInstance.POST(searchClinicURL, parameters: parameters, success: { (content, message) -> Void in
                self.searchDataArr.removeAllObjects()
                let dict: NSArray = content as! NSArray
                let homeData = ClinicTrailObj.jsonToModelList(dict as NSObject) as! Array<ClinicTrailObj>
                
                self.searchDataArr.addObjects(from: homeData)
                self.originalDataArr.addObjects(from: self.searchDataArr as [AnyObject])
                self.tableView.reloadData()
                self.saveClinicTrialToLocalDB()
                UserDefaults.standard.set(Foundation.Date().timeIntervalSince1970, forKey: self.setClinicTrialListTimeStamp)
                HudProgressManager.sharedInstance.dismissHud()
                HudProgressManager.sharedInstance.showSuccessHudProgress(self, title: "搜索成功")
                }) { (content, message) -> Void in
                    
                    HudProgressManager.sharedInstance.dismissHud()
                    HudProgressManager.sharedInstance.showOnlyTextHudProgress(self, title: message)
            }
        }
        
    }
    
    func initContentView(){
        //设置透明层
        transparentView.frame = CGRECT(0, 0, UIScreen.main.bounds.width, UIScreen.main.bounds.height)
        transparentView.backgroundColor = UIColor.lightGray
        transparentView.alpha = 0.6
        
        //init pickerView
        selectionPickerContainerView = UIView(frame: CGRect(x: 0, y: screenHeight - selectionPickerContainerViewHeight - headerHeight, width: screenWidth, height: selectionPickerContainerViewHeight))
        selectionPickerContainerView.backgroundColor = chartBackgroundColor
        let cancelBtnInPicker = UIButton(frame: CGRect(x: 10, y: 5, width: btnInPickerWidth, height: btnInPickerHeight))
        let submitBtnInPicker = UIButton(frame: CGRect(x: screenWidth - 10 - btnInPickerWidth, y: 5, width: btnInPickerWidth, height: btnInPickerHeight))
        cancelBtnInPicker.setTitle("取消", for: UIControlState())
        submitBtnInPicker.setTitle("确定", for: UIControlState())
        cancelBtnInPicker.setTitleColor(UIColor.lightGray, for: UIControlState())
        submitBtnInPicker.setTitleColor(mainColor, for: UIControlState())
        cancelBtnInPicker.titleLabel?.font = UIFont(name: fontStr, size: 14.0)
        submitBtnInPicker.titleLabel?.font = UIFont(name: fontStr, size: 14.0)
        cancelBtnInPicker.addTarget(self, action: #selector(ClinicTrailTableViewController.cancelSelectionPicker), for: UIControlEvents.touchUpInside)
        submitBtnInPicker.addTarget(self, action: #selector(ClinicTrailTableViewController.submitSelectionPicker), for: UIControlEvents.touchUpInside)
        selectionPickerContainerView.addSubview(cancelBtnInPicker)
        selectionPickerContainerView.addSubview(submitBtnInPicker)
        selectionPickerContainerView.backgroundColor = UIColor.white.withAlphaComponent(1.0)
//        self.view.addSubview(selectionPickerContainerView)
        
        selectionPicker = UIPickerView(frame: CGRect(x: 10.0, y: btnInPickerHeight + 10, width: UIScreen.main.bounds.width - 20, height: 220.0))
        
        selectionPicker.delegate = self
        selectionPicker.dataSource = self
        self.selectionPickerContainerView.addSubview(selectionPicker)
        
        treatmentBtn = UIButton(frame: CGRect(x: 0, y: 0, width: screenWidth / 2 - 1, height: 43))
        typeBtn = UIButton(frame: CGRect(x: screenWidth / 2 + 1, y: 0, width: screenWidth / 2 - 1, height: 43))

        
        let dropdownImageWidht: CGFloat = 15
        let dropdownImageview = UIImageView(frame: CGRect(x: screenWidth / 2 - 30, y: 0, width: dropdownImageWidht, height: 43))
        dropdownImageview.image = UIImage(named: "dropdown")
        dropdownImageview.contentMode = UIViewContentMode.scaleAspectFit
        let anotherdropdownImageView: UIImageView = UIImageView(frame: CGRect(x: screenWidth / 2 - 30, y: 0, width: dropdownImageWidht, height: 43))
        anotherdropdownImageView.image = UIImage(named: "dropdown")
        anotherdropdownImageView.contentMode = UIViewContentMode.scaleAspectFit
        
        treatmentBtn.addSubview(dropdownImageview)
        typeBtn.addSubview(anotherdropdownImageView)
        
        formatSelectBtn(treatmentBtn, title: "选择药物种类")
        formatSelectBtn(typeBtn, title: "选择癌症类型")
        
        treatmentBtn.addTarget(self, action: #selector(ClinicTrailTableViewController.selectTreatment), for: UIControlEvents.touchUpInside)
        typeBtn.addTarget(self, action: #selector(ClinicTrailTableViewController.selectCancerType), for: UIControlEvents.touchUpInside)
        
        self.transparentView.isUserInteractionEnabled = true
        let tapTransparentView = UITapGestureRecognizer(target: self, action: #selector(self.cancelSelectionPicker))
        self.transparentView.addGestureRecognizer(tapTransparentView)
        
    }
    
    func cancelSelectionPicker(){
        transparentView.removeFromSuperview()
        selectionPickerContainerAppear = false
        selectionPickerContainerView.removeFromSuperview()
    }
    
    func submitSelectionPicker(){
        transparentView.removeFromSuperview()
        let selectStr = pickerDataSource[selectionPicker.selectedRow(inComponent: 0)]
        if (treatmentSelectionData as NSArray).contains(selectStr) {
            treatmentBtn.setTitle(selectStr, for: UIControlState())
            //更新tableView
            self.searchDataArr.removeAllObjects()
            for cinicTrialItem in self.originalDataArr {
                if (cinicTrialItem as! ClinicTrailObj).drugType == selectStr {
                    self.searchDataArr.add(cinicTrialItem)
                }
            }
            if self.searchDataArr.count == 0 {
                HudProgressManager.sharedInstance.showOnlyTextHudProgress(self, title: "没有与此药物类型和癌症类型的临床信息")
            }
            self.tableView.reloadData()
        }
        if (cancerTypeSelectionData as NSArray).contains(selectStr) {
            typeBtn.setTitle(selectStr, for: UIControlState())
            //更新tableView
            self.searchDataArr.removeAllObjects()
            for cinicTrialItem in self.originalDataArr {
                if (cinicTrialItem as! ClinicTrailObj).subGroup == selectStr {
                    self.searchDataArr.add(cinicTrialItem)
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
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
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

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0{
            let cell = tableView.dequeueReusableCell(withIdentifier: "clinicTrailHeader", for: indexPath)
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
            let cell = tableView.dequeueReusableCell(withIdentifier: cellSearchClinicTrailIdentifier, for: indexPath) as! ClinicCell
            
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
    
    
    func formatSelectBtn(_ selectBtn: UIButton, title: String){
        selectBtn.setTitle(title, for: UIControlState())
        selectBtn.setTitleColor(defaultTextColor, for: UIControlState())
        selectBtn.titleLabel?.font = UIFont(name: fontStr, size: 12.0)
    }
    
    //MARK: - Delegates and data sources
    //MARK: Data Sources
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var pickerLabel = UILabel()
        if view == nil {
            pickerLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 270, height: 36))
        }else{
            pickerLabel = view as! UILabel
        }
        pickerLabel.textAlignment = NSTextAlignment.center
        pickerLabel.textColor = pickerUnselectedColor
        pickerLabel.text = pickerDataSource[row]
        pickerLabel.font = pickerUnselectedFont
        return pickerLabel
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let pickerLabel = pickerView.view(forRow: row, forComponent: 0) as! UILabel
        pickerLabel.textColor = pickerSelectedColor
        pickerLabel.font = pickerSelectedFont
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerDataSource.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerDataSource[row]
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
        if indexPath.section == 0 {
            return 44
        }else{
            
            let clinicTrial = self.searchDataArr[indexPath.row] as! ClinicTrailObj
            
            let otherInfoStr: String = clinicTrial.subGroup + " " + clinicTrial.stage + "\n" + clinicTrial.effect + "\n" + clinicTrial.sideEffect + "\n" + clinicTrial.researchInfo
            
            let strHeight = otherInfoStr.sizeWithFont(UIFont.systemFont(ofSize: 13), maxSize: CGSize(width: screenWidth - 30, height: CGFloat.greatestFiniteMagnitude)).height
            return strHeight + 80
        }
    }
    
    var lastPosition: CGFloat = 0
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let currentPostion: CGFloat = scrollView.contentOffset.y
        let distance: CGFloat = currentPostion - lastPosition;
        if distance > 25 {
            self.cancelSelectionPicker()
        }
    }

}
