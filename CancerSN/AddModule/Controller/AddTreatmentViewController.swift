//
//  AddTreatmentViewController.swift
//  CancerSN
//
//  Created by lily on 9/21/15.
//  Copyright (c) 2015 lily. All rights reserved.
//

import UIKit

class AddTreatmentViewController: UIViewController, UITextViewDelegate {
    
    //global variable
    let getAccessToken = GetAccessToken()
    let keychainAccess = KeychainAccess()
    var treatmentTypeCount: Int = Int()
    var treatmentFormatList = NSArray()
    var treatmentFormatOfTKI = NSMutableArray()
    var treatmentFormatOfChemo = NSMutableArray()
    var treatmentTypeArr: NSArray = ["靶向", "化疗", "放疗", "手术", "其他"]
    var selectedIndex: Int = Int()
    var selectedTreatmentList: NSArray = NSArray()
    var treatmentList = NSMutableArray()
    var isPosted: Int = 1
    var keyboardheight:CGFloat = 0
    let profileSet = NSUserDefaults.standardUserDefaults()

    //
    var treatmentTypeBtmLineView = UIView()
    var treatmentFormatSectionView = UIView()
    var treatmentTextInput = UITextView()
    var treatmentBtmSectionView = UIView()
    
    var screenWidth: CGFloat = CGFloat()
    var treatmentTypeBtnW: CGFloat = CGFloat()
    
    var headerHeight: CGFloat = CGFloat()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initVariables()
        initContentView()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillAppear:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillDisappear:", name:UIKeyboardWillHideNotification, object: nil)
    }
    
    func getTreatmentFormatList(){
        let parameters = NSDictionary()
        let hudProcess = HudProgressManager.sharedInstance
        //        hudProcess.showHudProgress(self, title: "loading")
        let jsonResult = NetRequest.sharedInstance.GET_A(getTreatmentformatURL, parameters: parameters as! Dictionary<String, AnyObject>)
        if (jsonResult.objectForKey("content") != nil){
            treatmentFormatList = jsonResult.objectForKey("content") as! NSArray
            for treatment in treatmentFormatList {
                if ((treatment as! NSDictionary).objectForKey("type") as! String) == "TKI" {
                    treatmentFormatOfTKI.addObject(treatment)
                }
                if ((treatment as! NSDictionary).objectForKey("type") as! String) == "CHEMO" {
                    treatmentFormatOfChemo.addObject(treatment)
                }
            }
        }else{
            hudProcess.dismissHud()
            
            hudProcess.showOnlyTextHudProgress(self, title: "fail")
            //            hudProcess.showSuccessHudProgress(self, title: )
        }
    }
    
    func initVariables(){
        screenWidth = UIScreen.mainScreen().bounds.width
        headerHeight = UIApplication.sharedApplication().statusBarFrame.height + (self.navigationController?.navigationBar.frame.height)!
        getTreatmentFormatList()
        treatmentTextInput.delegate = self
    }
    
    func initContentView(){
        //添加 治疗方案类别 按钮
        treatmentTypeBtnW = (screenWidth - treatmentTypeSectionLeftSpace - treatmentTypeSectionRightSpace)/CGFloat(treatmentTypeArr.count)
        for var typeIndex = 0; typeIndex < treatmentTypeArr.count; typeIndex++ {
            let treatmentTypeBtn = UIButton(frame: CGRect(x: treatmentTypeSectionLeftSpace + CGFloat(typeIndex) * treatmentTypeBtnW, y: headerHeight, width: treatmentTypeBtnW, height: treatmentTypeSectionHeight))
            treatmentTypeBtn.setTitle(treatmentTypeArr[typeIndex] as! String, forState: UIControlState.Normal)
            treatmentTypeBtn.setTitleColor(treatmentTypeSectionTextColor, forState: UIControlState.Normal)
            treatmentTypeBtn.titleLabel?.font = treatmentTypeSectionUIFont
            treatmentTypeBtn.addTarget(self, action: "selectedTreatmentType:", forControlEvents: UIControlEvents.TouchUpInside)
            if typeIndex == 0 {
                selectedTreatmentType(treatmentTypeBtn)
            }
            self.view.addSubview(treatmentTypeBtn)
        }
        
        //添加 治疗方案类别 按钮下划线
        treatmentTypeBtmLineView.frame = CGRECT(treatmentTypeSectionLeftSpace, headerHeight + treatmentTypeSectionHeight, treatmentTypeBtnW, treatmentTypeBtmLineHeight)
        treatmentTypeBtmLineView.backgroundColor = treatmentTypeBtmLineColor
        self.view.addSubview(treatmentTypeBtmLineView)
        
        //添加 分割线
        let treatmentHeaderSeperateLine = UIView(frame: CGRect(x: 0, y: headerHeight + treatmentTypeSectionHeight + treatmentTypeBtmLineHeight, width: screenWidth, height: 0.5))
        treatmentHeaderSeperateLine.backgroundColor = treatmentSeperateLineColor
        self.view.addSubview(treatmentHeaderSeperateLine)
        
        //添加底部选择框
        let privateCheckUIView = PrivateCheckUIView()
        treatmentBtmSectionView = privateCheckUIView.createCheckedSection()
        privateCheckUIView.checkbox.addTarget(self, action: "checkedPrivate:", forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(treatmentBtmSectionView)
    }
    
    func selectedTreatmentType(sender: UIButton){
        var isSelectedTreatment:Bool = false
        for treatmentButtonView in treatmentFormatSectionView.subviews {
            if treatmentButtonView is UIButton && treatmentButtonView.backgroundColor == headerColor{
                isSelectedTreatment = true
            }
        }
        if isSelectedTreatment || ((treatmentTextInput.textColor != treatmentTextInputViewColor) && (treatmentTextInput.text != "")){
            
            let alertController = UIAlertController(title: "保存您正在编辑的治疗方案吗？", message: nil, preferredStyle: .Alert)
            
            let OKAction = UIAlertAction(title: "好的", style: .Default) { (action) in
                self.getTreatmentDetail()
                self.resetView(sender)
            }
            
            alertController.addAction(OKAction)
            let cancelAction = UIAlertAction(title: "不要", style: .Cancel) { (action) in
                self.resetView(sender)
            }
            alertController.addAction(cancelAction)
            
            let ContinueAction = UIAlertAction(title: "继续编辑", style: .Default){ (action)in
                //...
//                self.treatmentTypeSegment.selectedSegmentIndex = Int(self.pointer.center.x / self.segmentSectionWidth)
            }
            alertController.addAction(ContinueAction)
            
            self.presentViewController(alertController, animated: true) {
                // ...
            }
        }else{
            self.resetView(sender)
        }

    }
    
    @IBAction func loadPreviousView(sender: UIButton) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func keyboardWillAppear(notification: NSNotification) {
        if self.treatmentBtmSectionView.center.y > UIScreen.mainScreen().bounds.height - 50{
            
            // 获取键盘信息
            let keyboardinfo = notification.userInfo![UIKeyboardFrameBeginUserInfoKey]
            
            keyboardheight = (keyboardinfo?.CGRectValue.size.height)!
            
            self.treatmentBtmSectionView.center = CGPoint(x: self.treatmentBtmSectionView.center.x, y: self.treatmentBtmSectionView.center.y - keyboardheight)
        }
    }
    
    func keyboardWillDisappear(notification:NSNotification){
        
        self.treatmentBtmSectionView.center = CGPoint(x: self.treatmentBtmSectionView.center.x, y: self.treatmentBtmSectionView.center.y + keyboardheight)
    }
    
    func checkedPrivate(sender: UIButton){
        if isPosted == 0 {
            isPosted = 1
            sender.backgroundColor = UIColor.whiteColor()
            sender.layer.borderColor = privateLabelColor.CGColor
            sender.removeAllSubviews()
        }else{
            isPosted = 0
            sender.backgroundColor = headerColor
            let checkImgView = UIImageView(image: UIImage(named: "btn_check"))
            checkImgView.frame = CGRECT(0, 0, sender.frame.width, sender.frame.height)
            checkImgView.contentMode = UIViewContentMode.ScaleAspectFit
            sender.layer.borderColor = headerColor.CGColor
            sender.addSubview(checkImgView)
        }
    }
    
    func resetView(sender: UIButton){
        let typeIndex = treatmentTypeArr.indexOfObject((sender.titleLabel?.text)!)
        selectedIndex = typeIndex
        treatmentTypeBtmLineView.frame = CGRECT(treatmentTypeSectionLeftSpace + CGFloat(typeIndex) * treatmentTypeBtnW, headerHeight + treatmentTypeSectionHeight, treatmentTypeBtnW, treatmentTypeBtmLineHeight)
        //添加治疗方案 选择 按钮
        treatmentFormatSectionView.removeAllSubviews()
        if selectedIndex == 0{
            selectedTreatmentList = treatmentFormatOfTKI
        }else if selectedIndex == 1 {
            selectedTreatmentList = treatmentFormatOfChemo
        }else{
            selectedTreatmentList = NSArray()
            treatmentFormatSectionView = UIView()
        }
        if selectedIndex == 0 || selectedIndex == 1{
            var treatmentBtnX: CGFloat = treatmentBtnLeftSpace
            var treatmentBtnY: CGFloat =  treatmentBtnTopSpace
            for treatment in selectedTreatmentList{
                let treatmentName: String = (treatment as! NSDictionary).objectForKey("treatmentName") as! String
                let treatmentNameTextSize = (treatmentName).sizeWithFont(treatmentBtnTextFont, maxSize: CGSize(width: CGFloat.max, height: treatmentBtnHeight))
                if (treatmentNameTextSize.width + treatmentBtnX + treatmentBtnTextHorizonSpace * 2 + treatmentBtnTextHorizonSpace ) > screenWidth - treatmentBtnLeftSpace * 2 {
                    treatmentBtnX = treatmentBtnLeftSpace
                    treatmentBtnY += treatmentBtnHeight + treatmentBtnVerticalSpace
                }
                let treatmentNameBtn = UIButton(frame: CGRect(x: treatmentBtnX, y: treatmentBtnY, width: treatmentNameTextSize.width + treatmentBtnTextHorizonSpace * 2, height: treatmentBtnHeight))
                treatmentNameBtn.setTitle(treatmentName, forState: UIControlState.Normal)
                treatmentNameBtn.setTitleColor(headerColor, forState: UIControlState.Normal)
                treatmentNameBtn.titleLabel?.font = treatmentBtnTextFont
                treatmentNameBtn.layer.borderColor = treatmentBtnBorderColor.CGColor
                treatmentNameBtn.layer.borderWidth = treatmentBtnBorderWidth
                treatmentNameBtn.layer.cornerRadius = treatmentBtnCornerRadius
                treatmentNameBtn.addTarget(self, action: "selectTreatment:", forControlEvents: UIControlEvents.TouchUpInside)
                treatmentFormatSectionView.addSubview(treatmentNameBtn)
                treatmentBtnX += treatmentNameBtn.frame.width + treatmentBtnHorizonSpace
            }
            treatmentFormatSectionView.frame = CGRECT(0, 0 + headerHeight + treatmentTypeSectionHeight, screenWidth - treatmentBtnLeftSpace * 2, treatmentBtnY + treatmentBtnHeight + treatmentBtnTopSpace)
            let treatmentSectionSeperateLine = UIView(frame: CGRect(x: 0, y: treatmentFormatSectionView.frame.height, width: screenWidth, height: 0.5))
            treatmentSectionSeperateLine.backgroundColor = seperateLineColor
            treatmentFormatSectionView.addSubview(treatmentSectionSeperateLine)
            self.view.addSubview(treatmentFormatSectionView)
        }
        //treatment text view
        let treatmentTextInputY = treatmentTextInputViewTopSpace + headerHeight + treatmentTypeSectionHeight + treatmentFormatSectionView.frame.height
        treatmentTextInput.frame = CGRECT(treatmentTextInputViewLeftSpace, treatmentTextInputY, screenWidth - treatmentTextInputViewLeftSpace * 2, UIScreen.mainScreen().bounds.height - treatmentTextInputY - buttomSectionHeight)
        treatmentTextInput.text = "请输入剂量及使用方法..."
        treatmentTextInput.font = treatmentTextInputViewFont
        treatmentTextInput.textColor = treatmentTextInputViewColor
        self.view.addSubview(treatmentTextInput)
    }
    
    func getTreatmentDetail(){
        var treatmentName = String()
        for treatmentButtonView in treatmentFormatSectionView.subviews {
            if treatmentButtonView is UIButton && treatmentButtonView.backgroundColor == headerColor{
                treatmentName += ((treatmentButtonView as! UIButton).titleLabel!).text! + " "
            }
        }
        if (treatmentName as NSString).length == 0{
            treatmentName = treatmentTypeArr.objectAtIndex(selectedIndex) as! String
        }
        var treatmentDosage = String()
        if treatmentTextInput.textColor == UIColor.blackColor(){
            treatmentDosage = treatmentTextInput.text!
        }
        let treatment = NSMutableDictionary(objects: [treatmentName, treatmentDosage], forKeys: ["treatmentName", "dosage"])
        treatmentList.addObject(treatment)
    }
    
    func selectTreatment(sender:UIButton){
        if sender.backgroundColor == UIColor.whiteColor(){
            sender.backgroundColor = headerColor
            sender.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        }else{
            sender.backgroundColor = UIColor.whiteColor()
            sender.setTitleColor(headerColor, forState: UIControlState.Normal)
        }
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if text == "\n"{
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        if textView.textColor != UIColor.blackColor() {
            textView.text = nil
            textView.textColor = UIColor.blackColor()
        }
    }
    
    @IBAction func submitTreatment(){
        self.getTreatmentDetail()
        if treatmentList.count > 0 {
            for treatment in treatmentList{
                treatment.setObject(isPosted, forKey:"isPosted")
                treatment.setObject((profileSet.objectForKey(newTreatmentBegindate) as! Int)*1000, forKey: "beginDate")
                if profileSet.objectForKey(newTreatmentEnddate) != nil {
                    treatment.setObject((profileSet.objectForKey(newTreatmentEnddate) as! Int)*1000, forKey: "endDate")
                }
            }
            addTreatment(treatmentList)
        }
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func addTreatment(treatmentList: NSArray){
        var accessToken = NSUserDefaults.standardUserDefaults().objectForKey(accessNSUserData)
        if accessToken == nil {
            getAccessToken.getAccessToken()
            accessToken = NSUserDefaults.standardUserDefaults().objectForKey(accessNSUserData)
        }
        let urlPath:String = (addTreatmentURL as String) + "?access_token=" + (accessToken as! String);
        let url : NSURL = NSURL(string: urlPath)!
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        let requestBody = NSMutableDictionary()
        requestBody.setObject(treatmentList, forKey: "treatments")
        requestBody.setObject(keychainAccess.getPasscode(usernameKeyChain)!, forKey: "insertUsername")
        request.HTTPBody = try? NSJSONSerialization.dataWithJSONObject(requestBody as NSDictionary, options: NSJSONWritingOptions())
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        NetRequest.sharedInstance.POST(urlPath, parameters: (requestBody as NSDictionary) as! Dictionary<String, AnyObject>,
            
            success: { (content , message) -> Void in
                print(content)
                
            }) { (content, message) -> Void in
                
                HudProgressManager.sharedInstance.showOnlyTextHudProgress(self, title: message)
        }
    }
}
