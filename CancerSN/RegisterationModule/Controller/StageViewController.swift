//
//  StageViewController.swift
//  CancerSN
//
//  Created by lily on 7/26/15.
//  Copyright (c) 2015 lily. All rights reserved.
//

import UIKit
protocol StageSettingVCDelegate{
    func updateStage(stage: Int)
}
protocol MetastasisSettingVCDelegate{
    func updateMetastasis(metastasis: String)
}
//class StageViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate {
class StageViewController: UIViewController,UIPickerViewDataSource, UIPickerViewDelegate{

    var isUpdate = false
    var stageSettingVCDelegate: StageSettingVCDelegate?
    var metastasisSettingVCDelegate: MetastasisSettingVCDelegate?
    let topPickerView = UIPickerView()
    var stagePickerDataSource = [String]()
    
    override func viewDidLoad() {
        initVariables()
        initContentView()
        topPickerView.selectRow(2, inComponent: 0, animated: true)
    }
    
    func initVariables(){
        stagePickerDataSource = ["I", "II", "III", "IV"]
    }
    
    func initContentView(){
        //previous Btn
        let previousBtn = UIButton(frame: CGRect(x: previousBtnLeftSpace, y: previousBtnTopSpace, width: previousBtnWidth, height: previousBtnHeight))
        let previousImgView = UIImageView(frame: CGRECT(0, 0, previousBtn.frame.width, previousBtn.frame.height))
        previousImgView.image = UIImage(named: "btn_previous")
        previousBtn.addTarget(self, action: "prevousView:", forControlEvents: UIControlEvents.TouchUpInside)
        previousBtn.addSubview(previousImgView)
        self.view.addSubview(previousBtn)
        
        //sign up title
        let signUpTitle = UILabel(frame: CGRect(x: signUpTitleMargin, y: signUpTitleTopSpace, width: screenWidth - signUpTitleMargin * 2, height: signUpTitleHeight))
        signUpTitle.font = signUpTitleFont
        signUpTitle.textColor = signUpTitleTextColor
        signUpTitle.text = "请选择病人的诊断结果"
        signUpTitle.textAlignment = NSTextAlignment.Center
        self.view.addSubview(signUpTitle)
        
        //sign up subTitle
        let signUpSubTitle = UILabel(frame: CGRect(x: 0, y: signUpSubTitleTopSpace, width: screenWidth, height: signUpSubTitleHeight))
        signUpSubTitle.font = signUpSubTitleFont
        signUpSubTitle.textColor = signUpTitleTextColor
        signUpSubTitle.text = "不同类型原发的治疗效果是不一样的"
        signUpSubTitle.textAlignment = NSTextAlignment.Center
        self.view.addSubview(signUpSubTitle)
        
        //top Item Name
        let topItemNameLbl = UILabel(frame: CGRect(x: 0, y: signUpTopItemNameTopSpace, width: screenWidth, height: signUpItemNameHeight))
        topItemNameLbl.font = signUpItemNameFont
        topItemNameLbl.textColor = headerColor
        topItemNameLbl.text = "部位"
        topItemNameLbl.textAlignment = NSTextAlignment.Center
        self.view.addSubview(topItemNameLbl)
        
        //top pickerView
        topPickerView.frame = CGRect(x: pickerMargin, y: topPickerTopSpace, width: screenWidth - pickerMargin * 2, height: screenHeight - topPickerTopSpace - topPickerButtomSpace)
        topPickerView.delegate = self
        topPickerView.dataSource = self
        self.view.addSubview(topPickerView)
        
        //next view button
        let nextViewBtn = UIButton(frame: CGRect(x: 0, y: screenHeight - nextViewBtnButtomSpace - nextViewBtnHeight, width: screenWidth, height: nextViewBtnHeight))
        nextViewBtn.setTitle("下一题", forState: UIControlState.Normal)
        nextViewBtn.setTitleColor(nextViewBtnColor, forState: UIControlState.Normal)
        nextViewBtn.titleLabel?.font = nextViewBtnFont
        nextViewBtn.addTarget(self, action: "selectedNextView:", forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(nextViewBtn)
    }
    
    func pickerView(pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusingView view: UIView?) -> UIView {
        var pickerLabel = UILabel()
        if view == nil {
            pickerLabel = UILabel(frame: CGRectMake(0, 0, 270, 32))
        }else{
            pickerLabel = view as! UILabel
        }

        pickerLabel.text = stagePickerDataSource[row]
        pickerLabel.textAlignment = NSTextAlignment.Center
        pickerLabel.textColor = pickerUnselectedColor
        pickerLabel.font = pickerUnselectedFont
        return pickerLabel
    }
    
    //MARK: - Delegates and data sources
    //MARK: Data Sources
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return stagePickerDataSource.count
    }
    
    func pickerView(pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return pickerComponentHeight
    }
    
    //
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let pickerLabel = pickerView.viewForRow(row, forComponent: 0) as! UILabel
        pickerLabel.textColor = pickerSelectedColor
        pickerLabel.font = pickerSelectedFont
    }
    
    func prevousView(sender: UIButton){
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func selectedNextView(sender: UIButton){
        let profileSet = NSUserDefaults.standardUserDefaults()
        let stage = stagePickerDataSource[topPickerView.selectedRowInComponent(0)]
        profileSet.setObject(stage, forKey: stageNSUserData)
        if topPickerView.selectedRowInComponent(0) == 3 {
            self.performSegueWithIdentifier("metasticSegue", sender: self)
        }else{
            self.performSegueWithIdentifier("geneticMutationSegue", sender: self)
        }
    }
    
//    var publicService = PublicService()
//    var selectedStage:Int?
//    var selectedMetastasis = NSMutableArray()
//    var haalthyService = HaalthyService()
    
//    @IBOutlet weak var selectBtn: UIButton!
    
//    @IBAction func confirm(sender: UIButton) {
//        var selectedMetastasisStr = String()
//        for metastasisItem in selectedMetastasis{
//            selectedMetastasisStr += " " + (metastasisItem as! String)
//        }
//        selectedMetastasisStr += otherMetastasisBtn.text!
//        if isUpdate{
//            stageSettingVCDelegate?.updateStage(selectedStage!)
//            metastasisSettingVCDelegate?.updateMetastasis(selectedMetastasisStr)
//            self.dismissViewControllerAnimated(true, completion: nil)
//        }else{
//            let profileSet = NSUserDefaults.standardUserDefaults()
//            profileSet.setObject(selectedStage, forKey: stageNSUserData)
//            profileSet.setObject(selectedMetastasisStr, forKey: metastasisNSUserData)
//            if (profileSet.objectForKey(userTypeUserData) as! String) != aiyouUserType{
//                haalthyService.addUser(profileSet.objectForKey(userTypeUserData) as! String)
//            }
//            self.performSegueWithIdentifier("selectTagSegue", sender: self)
//            
//        }
//    }
//    
//    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//        if segue.identifier == "selectTagSegue" {
//            (segue.destinationViewController as! TagTableViewController).isFirstTagSelection = true
//        }
//    }
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        self.navigationController?.navigationBar.hidden = false
//        self.tabBarController?.tabBar.hidden = false
//        publicService.unselectBtnFormat(stage1Btn)
//        publicService.unselectBtnFormat(stage2Btn)
//        publicService.unselectBtnFormat(stage3Btn)
//        publicService.unselectBtnFormat(stage4Btn)
//
//        publicService.unselectBtnFormat(liverMetastasisBtn)
//        publicService.unselectBtnFormat(boneMetastasisBtn)
//        publicService.unselectBtnFormat(adrenalMetastasisBtn)
//        publicService.unselectBtnFormat(brainMetastasisBtn)
//        otherMetastasisBtn.delegate = self
//        
//        liverMetastasisBtn.hidden = true
//        boneMetastasisBtn.hidden = true
//        adrenalMetastasisBtn.hidden = true
//        brainMetastasisBtn.hidden = true
//        otherMetastasisBtn.hidden = true
//    }
//    
//    @IBAction func selectStage(sender: UIButton) {
//        print((sender.titleLabel?.text)!)
//        selectedStage = stageMapping.objectForKey((sender.titleLabel?.text)!) as! Int
//        switch sender{
//        case stage1Btn:
//            publicService.selectedBtnFormat(stage1Btn)
//            publicService.unselectBtnFormat(stage2Btn)
//            publicService.unselectBtnFormat(stage3Btn)
//            publicService.unselectBtnFormat(stage4Btn)
//            break
//        case stage2Btn:
//            publicService.selectedBtnFormat(stage2Btn)
//            publicService.unselectBtnFormat(stage1Btn)
//            publicService.unselectBtnFormat(stage3Btn)
//            publicService.unselectBtnFormat(stage4Btn)
//            break
//        case stage3Btn:
//            publicService.selectedBtnFormat(stage3Btn)
//            publicService.unselectBtnFormat(stage1Btn)
//            publicService.unselectBtnFormat(stage2Btn)
//            publicService.unselectBtnFormat(stage4Btn)
//            break
//        case stage4Btn:
//            publicService.selectedBtnFormat(stage4Btn)
//            publicService.unselectBtnFormat(stage1Btn)
//            publicService.unselectBtnFormat(stage2Btn)
//            publicService.unselectBtnFormat(stage3Btn)
//            liverMetastasisBtn.hidden = false
//            boneMetastasisBtn.hidden = false
//            adrenalMetastasisBtn.hidden = false
//            brainMetastasisBtn.hidden = false
//            otherMetastasisBtn.hidden = false
//
//            break
//        default:
//            break
//        }
//        
//    }
//    
//    @IBAction func selectMetastasis(sender: UIButton) {
//        if sender.backgroundColor == UIColor.whiteColor(){
//        selectedMetastasis.addObject(metastasisMapping.objectForKey((sender.titleLabel?.text)!) as! String)
//            sender.backgroundColor = mainColor
//            sender.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
//        }else{
//            selectedMetastasis.removeObject(metastasisMapping.objectForKey((sender.titleLabel?.text)!) as! String)
//            sender.backgroundColor = UIColor.whiteColor()
//            sender.setTitleColor(mainColor, forState: UIControlState.Normal)
//        }
//    }
//    
//    func textFieldShouldReturn(_ textField: UITextField) -> Bool{
//        textField.resignFirstResponder()
//        return true
//    }
//    
//    func keyboardWillShow(sender: NSNotification) {
//        self.view.frame.origin.y -= 50
//    }
//    func keyboardWillHide(sender: NSNotification) {
//        self.view.frame.origin.y += 50
//    }
}
