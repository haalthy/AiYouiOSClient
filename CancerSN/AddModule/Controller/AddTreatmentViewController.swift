//
//  AddTreatmentViewController.swift
//  CancerSN
//
//  Created by lily on 9/21/15.
//  Copyright (c) 2015 lily. All rights reserved.
//

import UIKit
import CoreData

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
    var isPosted: Int = 0
    var keyboardheight:CGFloat = 0
    let profileSet = UserDefaults.standard

    //
    var scrollView = UIScrollView()
    var treatmentTypeBtmLineView = UIView()
    var treatmentFormatSectionView = UIView()
    var treatmentTextInput = UITextView()
    var treatmentBtmSectionView = UIView()
    
    var screenWidth: CGFloat = CGFloat()
    var treatmentTypeBtnW: CGFloat = CGFloat()
    
    var headerHeight: CGFloat = CGFloat()
    
    var treatmentTextInputY: CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initVariables()
        initContentView()
        NotificationCenter.default.addObserver(self, selector: #selector(AddTreatmentViewController.keyboardWillAppear(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(AddTreatmentViewController.keyboardWillDisappear(_:)), name:NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func getTreatmentFormatList(){
        let parameters = NSDictionary()
        let hudProcess = HudProgressManager.sharedInstance
        //        hudProcess.showHudProgress(self, title: "loading")
        let jsonResult = NetRequest.sharedInstance.GET_A(getTreatmentformatURL, parameters: parameters as! Dictionary<String, AnyObject>)
        if (jsonResult.object(forKey: "content") != nil){
            treatmentFormatList = jsonResult.object(forKey: "content") as! NSArray
            for treatment in treatmentFormatList {
                if ((treatment as! NSDictionary).object(forKey: "type") as! String) == "TKI" {
                    treatmentFormatOfTKI.add(treatment)
                }
                if ((treatment as! NSDictionary).object(forKey: "type") as! String) == "CHEMO" {
                    treatmentFormatOfChemo.add(treatment)
                }
            }
        }else{
            hudProcess.dismissHud()
            
            hudProcess.showOnlyTextHudProgress(self, title: "fail")
            //            hudProcess.showSuccessHudProgress(self, title: )
        }
    }
    
    func initVariables(){
        screenWidth = UIScreen.main.bounds.width
        headerHeight = UIApplication.shared.statusBarFrame.height + (self.navigationController?.navigationBar.frame.height)!
        getTreatmentFormatList()
        treatmentTextInput.delegate = self
    }
    
    func initContentView(){

        //添加 治疗方案类别 按钮
        treatmentTypeBtnW = (screenWidth - treatmentTypeSectionLeftSpace - treatmentTypeSectionRightSpace)/CGFloat(treatmentTypeArr.count)
        for typeIndex in 0 ..< treatmentTypeArr.count {
            let treatmentTypeBtn = UIButton(frame: CGRect(x: treatmentTypeSectionLeftSpace + CGFloat(typeIndex) * treatmentTypeBtnW, y: 0, width: treatmentTypeBtnW, height: treatmentTypeSectionHeight))
            treatmentTypeBtn.setTitle(treatmentTypeArr[typeIndex] as? String, for: UIControlState())
            treatmentTypeBtn.setTitleColor(treatmentTypeSectionTextColor, for: UIControlState())
            treatmentTypeBtn.titleLabel?.font = treatmentTypeSectionUIFont
            treatmentTypeBtn.addTarget(self, action: #selector(AddTreatmentViewController.selectedTreatmentType(_:)), for: UIControlEvents.touchUpInside)
            if typeIndex == 0 {
                selectedTreatmentType(treatmentTypeBtn)
            }
            self.scrollView.addSubview(treatmentTypeBtn)
        }
        
        //添加 治疗方案类别 按钮下划线
        treatmentTypeBtmLineView.frame = CGRECT(treatmentTypeSectionLeftSpace, treatmentTypeSectionHeight, treatmentTypeBtnW, treatmentTypeBtmLineHeight)
        treatmentTypeBtmLineView.backgroundColor = treatmentTypeBtmLineColor
        self.scrollView.addSubview(treatmentTypeBtmLineView)
        
        //添加 分割线
        let treatmentHeaderSeperateLine = UIView(frame: CGRect(x: 0, y: treatmentTypeSectionHeight + treatmentTypeBtmLineHeight, width: screenWidth, height: 0.5))
        treatmentHeaderSeperateLine.backgroundColor = treatmentSeperateLineColor
        self.scrollView.addSubview(treatmentHeaderSeperateLine)
        
        //添加底部选择框
        let privateCheckUIView = PrivateCheckUIView()
        treatmentBtmSectionView = privateCheckUIView.createCheckedSection()
        privateCheckUIView.checkbox.addTarget(self, action: #selector(AddTreatmentViewController.checkedPrivate(_:)), for: UIControlEvents.touchUpInside)
        self.view.addSubview(treatmentBtmSectionView)
        
        //scrollView
        scrollView.frame = CGRECT(0, headerHeight, screenWidth, screenHeight - headerHeight - treatmentBtmSectionView.frame.height)
        self.view.addSubview(scrollView)
    }
    
    func selectedTreatmentType(_ sender: UIButton){
        var isSelectedTreatment:Bool = false
        for treatmentButtonView in treatmentFormatSectionView.subviews {
            if treatmentButtonView is UIButton && treatmentButtonView.backgroundColor == headerColor{
                isSelectedTreatment = true
            }
        }
        if isSelectedTreatment || ((treatmentTextInput.textColor != treatmentTextInputViewColor) && (treatmentTextInput.text != "")){
            
            let alertController = UIAlertController(title: "保存您正在编辑的治疗方案吗？", message: nil, preferredStyle: .alert)
            
            let OKAction = UIAlertAction(title: "好的", style: .default) { (action) in
                self.getTreatmentDetail()
                self.resetView(sender)
            }
            
            alertController.addAction(OKAction)
            let cancelAction = UIAlertAction(title: "不要", style: .cancel) { (action) in
                self.resetView(sender)
            }
            alertController.addAction(cancelAction)
            
            let ContinueAction = UIAlertAction(title: "继续编辑", style: .default){ (action)in
                //...
//                self.treatmentTypeSegment.selectedSegmentIndex = Int(self.pointer.center.x / self.segmentSectionWidth)
            }
            alertController.addAction(ContinueAction)
            
            self.present(alertController, animated: true) {
                // ...
            }
        }else{
            self.resetView(sender)
        }

    }
    
    @IBAction func loadPreviousView(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func keyboardWillAppear(_ notification: Notification) {
        if self.treatmentBtmSectionView.center.y > UIScreen.main.bounds.height - 50{
            
            // 获取键盘信息
            let keyboardinfo = notification.userInfo![UIKeyboardFrameBeginUserInfoKey]
            
            keyboardheight = ((keyboardinfo as AnyObject).cgRectValue.size.height)
            self.scrollView.frame = CGRECT(0, self.scrollView.frame.origin.y, screenWidth, self.scrollView.frame.height - keyboardheight)
            self.scrollView.contentOffset = CGPoint(x: 0, y: treatmentTextInputY)
            self.treatmentBtmSectionView.center = CGPoint(x: self.treatmentBtmSectionView.center.x, y: self.treatmentBtmSectionView.center.y - keyboardheight)
            
        }
    }
    
    func keyboardWillDisappear(_ notification:Notification){
        self.treatmentBtmSectionView.center = CGPoint(x: self.treatmentBtmSectionView.center.x, y: self.treatmentBtmSectionView.center.y + keyboardheight)
        self.scrollView.frame = CGRECT(0, self.scrollView.frame.origin.y, screenWidth, self.scrollView.frame.height + keyboardheight)
        self.scrollView.contentOffset = CGPoint(x: 0, y: 0)
    }
    
    func checkedPrivate(_ sender: UIButton){
        if isPosted == 0 {
            isPosted = 1
            sender.backgroundColor = headerColor
            let checkImgView = UIImageView(image: UIImage(named: "btn_check"))
            checkImgView.frame = CGRECT(0, 0, sender.frame.width, sender.frame.height)
            checkImgView.contentMode = UIViewContentMode.scaleAspectFit
            sender.layer.borderColor = headerColor.cgColor
            sender.addSubview(checkImgView)
        }else{
            isPosted = 0
            sender.backgroundColor = UIColor.white
            sender.layer.borderColor = privateLabelColor.cgColor
            sender.removeAllSubviews()
        }
    }
    
    func resetView(_ sender: UIButton){
        let typeIndex = treatmentTypeArr.index(of: (sender.titleLabel?.text)!)
        selectedIndex = typeIndex
        treatmentTypeBtmLineView.frame = CGRECT(treatmentTypeSectionLeftSpace + CGFloat(typeIndex) * treatmentTypeBtnW,  treatmentTypeSectionHeight, treatmentTypeBtnW, treatmentTypeBtmLineHeight)
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
                let treatmentName: String = (treatment as! NSDictionary).object(forKey: "treatmentName") as! String
                let treatmentNameTextSize = (treatmentName).sizeWithFont(treatmentBtnTextFont, maxSize: CGSize(width: CGFloat.greatestFiniteMagnitude, height: treatmentBtnHeight))
                if (treatmentNameTextSize.width + treatmentBtnX + treatmentBtnTextHorizonSpace * 2 + treatmentBtnTextHorizonSpace ) > screenWidth - treatmentBtnLeftSpace * 2 {
                    treatmentBtnX = treatmentBtnLeftSpace
                    treatmentBtnY += treatmentBtnHeight + treatmentBtnVerticalSpace
                }
                let treatmentNameBtn = UIButton(frame: CGRect(x: treatmentBtnX, y: treatmentBtnY, width: treatmentNameTextSize.width + treatmentBtnTextHorizonSpace * 2, height: treatmentBtnHeight))
                treatmentNameBtn.setTitle(treatmentName, for: UIControlState())
                treatmentNameBtn.setTitleColor(headerColor, for: UIControlState())
                treatmentNameBtn.titleLabel?.font = treatmentBtnTextFont
                treatmentNameBtn.layer.borderColor = treatmentBtnBorderColor.cgColor
                treatmentNameBtn.layer.borderWidth = treatmentBtnBorderWidth
                treatmentNameBtn.layer.cornerRadius = treatmentBtnCornerRadius
                treatmentNameBtn.backgroundColor = UIColor.white
                treatmentNameBtn.addTarget(self, action: "selectTreatment:", for: UIControlEvents.touchUpInside)
                treatmentFormatSectionView.addSubview(treatmentNameBtn)
                treatmentBtnX += treatmentNameBtn.frame.width + treatmentBtnHorizonSpace
            }
            treatmentFormatSectionView.frame = CGRECT(0, treatmentTypeSectionHeight, screenWidth - treatmentBtnLeftSpace * 2, treatmentBtnY + treatmentBtnHeight + treatmentBtnTopSpace)
            let treatmentSectionSeperateLine = UIView(frame: CGRect(x: 0, y: treatmentFormatSectionView.frame.height, width: screenWidth, height: 0.5))
            treatmentSectionSeperateLine.backgroundColor = seperateLineColor
            treatmentFormatSectionView.addSubview(treatmentSectionSeperateLine)
            self.scrollView.addSubview(treatmentFormatSectionView)
        }
        //treatment text view
        treatmentTextInputY = treatmentTextInputViewTopSpace + treatmentTypeSectionHeight + treatmentFormatSectionView.frame.height
        treatmentTextInput.frame = CGRECT(treatmentTextInputViewLeftSpace, treatmentTextInputY, screenWidth - treatmentTextInputViewLeftSpace * 2, 150)
        treatmentTextInput.text = "请输入剂量及使用方法..."
        treatmentTextInput.font = treatmentTextInputViewFont
        treatmentTextInput.textColor = treatmentTextInputViewColor
        treatmentTextInput.returnKeyType = UIReturnKeyType.done
        self.scrollView.addSubview(treatmentTextInput)
        
        self.scrollView.isUserInteractionEnabled = true
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(AddTreatmentViewController.tapDismiss))
        self.scrollView.addGestureRecognizer(tapGesture)
    }
    
    func tapDismiss(){
        self.view.endEditing(true)
    }
    
    func getTreatmentDetail(){
        var treatmentName = String()
        for treatmentButtonView in treatmentFormatSectionView.subviews {
            if treatmentButtonView is UIButton && treatmentButtonView.backgroundColor == headerColor{
                treatmentName += ((treatmentButtonView as! UIButton).titleLabel!).text! + " "
            }
        }
        if (treatmentName as NSString).length == 0{
            treatmentName = treatmentTypeArr.object(at: selectedIndex) as! String
        }
        var treatmentDosage = String()
        if treatmentTextInput.textColor == UIColor.black{
            treatmentDosage = treatmentTextInput.text!
        }
        let treatment = NSMutableDictionary(objects: [treatmentName, treatmentDosage], forKeys: ["treatmentName" as NSCopying, "dosage" as NSCopying])
        treatmentList.add(treatment)
    }
    
    func selectTreatment(_ sender:UIButton){
        if sender.backgroundColor == UIColor.white{
            sender.backgroundColor = headerColor
            sender.setTitleColor(UIColor.white, for: UIControlState())
        }else{
            sender.backgroundColor = UIColor.white
            sender.setTitleColor(headerColor, for: UIControlState())
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n"{
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor != UIColor.black {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    @IBAction func submitTreatment(){
        self.getTreatmentDetail()
        if treatmentList.count > 0 {
            for treatment in treatmentList{
                (treatment as AnyObject).set(isPosted, forKey:"isPosted")
                let beginDate: Int = profileSet.object(forKey: newTreatmentBegindate) as! Int
                
                let doubleBeginDate: Double = Double(beginDate) * 1000
                
                let endDate: Int = profileSet.object(forKey: newTreatmentEnddate) as! Int
                
                let doubleEndDate: Double = Double(endDate) * 1000
                (treatment as AnyObject).set(doubleBeginDate, forKey: "beginDate")
                if profileSet.object(forKey: newTreatmentEnddate) != nil {
                    (treatment as AnyObject).set(doubleEndDate, forKey: "endDate")
                }
            }
            addTreatment(treatmentList)
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    func saveTreatmentToLocalDB() {
        let appDel:AppDelegate = (UIApplication.shared.delegate as! AppDelegate)
        let context: NSManagedObjectContext = appDel.managedObjectContext!
        for treatment in treatmentList {
            let treatmentLocalDBItem = NSEntityDescription.insertNewObject(forEntityName: tableTreatment, into: context)
            let treatmentObjItem = treatment as! NSDictionary
            treatmentLocalDBItem.setValue(treatmentObjItem.object(forKey: "treatmentName") , forKey: propertyTreatmentName)
            treatmentLocalDBItem.setValue(treatmentObjItem.object(forKey: "username") , forKey: propertyTreatmentUsername)
            treatmentLocalDBItem.setValue(treatmentObjItem.object(forKey: "dosage") , forKey: propertyDosage)
            treatmentLocalDBItem.setValue(treatmentObjItem.object(forKey: "beginDate") , forKey: propertyBeginDate)
            treatmentLocalDBItem.setValue(treatmentObjItem.object(forKey: "endDate") , forKey: propertyEndDate)
            treatmentLocalDBItem.setValue(treatmentObjItem.object(forKey: "treatmentID"), forKey: propertyTreatmentID)
        }
        do {
            try context.save()
        } catch _ {
        }
    }
    
    func addTreatment(_ treatmentList: NSArray){
        var accessToken = UserDefaults.standard.object(forKey: accessNSUserData)
        if accessToken == nil {
            getAccessToken.getAccessToken()
            accessToken = UserDefaults.standard.object(forKey: accessNSUserData)
        }
        let urlPath:String = (addTreatmentURL as String) + "?access_token=" + (accessToken as! String);
        let url : URL = URL(string: urlPath)!
        let request = NSMutableURLRequest(url: url)
        request.httpMethod = "POST"
        let requestBody = NSMutableDictionary()
        requestBody.setObject(treatmentList, forKey: "treatments" as NSCopying)
        requestBody.setObject(keychainAccess.getPasscode(usernameKeyChain)!, forKey: "insertUsername" as NSCopying)
        request.httpBody = try? JSONSerialization.data(withJSONObject: requestBody as NSDictionary, options: JSONSerialization.WritingOptions())
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        NetRequest.sharedInstance.POST(urlPath, parameters: (requestBody as NSDictionary) as! Dictionary<String, AnyObject>,
            
            success: { (content , message) -> Void in
                let dict: NSDictionary = content as! NSDictionary
                let treatmentIdList = dict.object(forKey: "treatmentIDList") as! [Int]
                var index  = 0
                for treatment in self.treatmentList {
                    (treatment as! NSMutableDictionary).setObject(treatmentIdList[index], forKey: "treatmentID" as NSCopying)
                    index += 1
                }
                self.saveTreatmentToLocalDB()
            }) { (content, message) -> Void in
                
                HudProgressManager.sharedInstance.showOnlyTextHudProgress(self, title: message)
        }
    }
}
