//
//  AddTreatmentViewController.swift
//  CancerSN
//
//  Created by lily on 9/21/15.
//  Copyright (c) 2015 lily. All rights reserved.
//

import UIKit

class AddTreatmentViewController: UIViewController, UITextViewDelegate {
    
    var pointer = UIImageView()
    var segmentHeight = CGFloat()
    var segmentSectionWidth = CGFloat()
    var segmentSections = Int()
    var suggestTreatmentDetailView = UIView()
    var treatmentTextInput = UITextView()
    var treatmentFormatList = NSArray()
    var haalthyService = HaalthyService()
    var treatmentFormatOfTKI = NSMutableArray()
    var treatmentFormatOfChemo = NSMutableArray()
    var treatmentList = NSMutableArray()
    var shareToFriendButton = UIButton()
    var saveToMyselfButton = UIButton()
    let profileSet = NSUserDefaults.standardUserDefaults()
    

    @IBAction func segmentIndexChanged(sender: UISegmentedControl) {
        
        if (treatmentList.count > 0) || (treatmentTextInput.textColor == UIColor.grayColor()){
            
            let alertController = UIAlertController(title: "保存您正在编辑的治疗方案吗？", message: nil, preferredStyle: .Alert)
            
            let OKAction = UIAlertAction(title: "好的", style: .Default) { (action) in
                self.resetView(self.treatmentTypeSegment.selectedSegmentIndex)
            }
            
            alertController.addAction(OKAction)
            let cancelAction = UIAlertAction(title: "不要", style: .Cancel) { (action) in
                self.resetView(self.treatmentTypeSegment.selectedSegmentIndex)
            }
            alertController.addAction(cancelAction)
            
            let ContinueAction = UIAlertAction(title: "继续编辑", style: .Default){ (action)in
                //...
                self.treatmentTypeSegment.selectedSegmentIndex = Int(self.pointer.center.x / self.segmentSectionWidth)
            }
            alertController.addAction(ContinueAction)
            
            self.presentViewController(alertController, animated: true) {
                // ...
            }
        }
    }
    
    func resetView(selectedSegmentIndex: Int){
        self.pointer.removeFromSuperview()
        self.suggestTreatmentDetailView.removeAllSubviews()
        self.suggestTreatmentDetailView.removeFromSuperview()
        if selectedSegmentIndex == 0 || selectedSegmentIndex == 1{
            pointer.center = CGPoint(x: treatmentTypeSegment.frame.origin.x + segmentSectionWidth/2 + segmentSectionWidth * CGFloat(selectedSegmentIndex), y: pointer.center.y)
            treatmentTextInput.center = CGPoint(x: treatmentTextInput.center.x, y: treatmentTypeSegment.center.y + 190)
            self.view.addSubview(pointer)
            self.view.addSubview(suggestTreatmentDetailView)
        }else{
            treatmentTextInput.center = CGPoint(x: treatmentTextInput.center.x, y: treatmentTypeSegment.center.y + 80)
        }
        shareToFriendButton.frame = CGRectMake(20, treatmentTextInput.frame.origin.y + 120, UIScreen.mainScreen().bounds.width/2 - 30, 30)
        saveToMyselfButton.frame = CGRectMake(shareToFriendButton.frame.width + 40, treatmentTextInput.frame.origin.y + 120, shareToFriendButton.frame.width, 30)
        var textPlaceholder = String()
        switch selectedSegmentIndex {
        case 0: textPlaceholder = "请输入病人的剂量以及使用方法（例如：200mg/天，隔天服用，午餐后两小时服用）"
        addTreatmentInView(treatmentFormatOfTKI, containerView: self.suggestTreatmentDetailView)
            break
        case 1: textPlaceholder = "请输入病人的剂量"
        addTreatmentInView(treatmentFormatOfChemo, containerView: self.suggestTreatmentDetailView)
            break
        case 2: textPlaceholder = "请输入病人的使用剂量以及放疗部位"
            break
        case 3: textPlaceholder = "请输入手术名称以及手术结果"
            break
        case 4: textPlaceholder = "请输入其他治疗方案"
            break
        default: textPlaceholder = ""
            break
        }
        treatmentTextInput.text = textPlaceholder
    }
    
    @IBOutlet weak var treatmentTypeSegment: UISegmentedControl!
    override func viewDidLoad() {
        super.viewDidLoad()
        segmentSections = 5
        treatmentTypeSegment.tintColor = mainColor
        pointer.image = UIImage(named: "triangle-xxl.png")
        pointer.alpha = 0.2
        suggestTreatmentDetailView.backgroundColor = sectionHeaderColor
//        suggestTreatmentDetailView.alpha = 0.3
        treatmentTextInput.delegate = self
        treatmentTextInput.returnKeyType = UIReturnKeyType.Done
        self.view.addSubview(pointer)
        self.view.addSubview(suggestTreatmentDetailView)
        self.view.addSubview(treatmentTextInput)
        self.view.addSubview(shareToFriendButton)
        self.view.addSubview(saveToMyselfButton)
        shareToFriendButton.backgroundColor = mainColor
        saveToMyselfButton.backgroundColor = mainColor
        shareToFriendButton.setTitle("听听病友们的意见", forState: UIControlState.Normal)
        saveToMyselfButton.setTitle("仅自己可见", forState: UIControlState.Normal)
        shareToFriendButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        saveToMyselfButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        shareToFriendButton.titleLabel!.font = UIFont(name: "Helvetica", size: 13.0)
        saveToMyselfButton.titleLabel!.font = UIFont(name: "Helvetica", size: 13.0)
        shareToFriendButton.addTarget(self, action: "addTreatmentPublic", forControlEvents: UIControlEvents.TouchUpInside)
        saveToMyselfButton.addTarget(self, action: "addTreatmentPrivate", forControlEvents: UIControlEvents.TouchUpInside)

        let getTreatmentFormatData = haalthyService.getTreatmentFormat()
        let jsonResult = try? NSJSONSerialization.JSONObjectWithData(getTreatmentFormatData, options: NSJSONReadingOptions.MutableContainers)
        treatmentFormatList = jsonResult as! NSArray
        for treatment in treatmentFormatList {
            if ((treatment as! NSDictionary).objectForKey("type") as! String) == "TKI" {
                treatmentFormatOfTKI.addObject(treatment)
            }
            if ((treatment as! NSDictionary).objectForKey("type") as! String) == "CHEMO" {
                treatmentFormatOfChemo.addObject(treatment)
            }
        }
    }
    
    func addTreatmentPublic(){
        submitTreatment(1)
//        self.performSegueWithIdentifier("patientStatusSegue", sender: self)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func addTreatmentPrivate(){
        submitTreatment(0)
//        self.performSegueWithIdentifier("patientStatusSegue", sender: self)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func submitTreatment(isPublic: Int){
        self.getTreatmentDetail()
        if treatmentList.count > 0 {
            for treatment in treatmentList{
                treatment.setObject(isPublic, forKey:"isPosted")
                treatment.setObject((profileSet.objectForKey(newTreatmentBegindate) as! Int)*1000, forKey: "beginDate")
                if profileSet.objectForKey(newTreatmentEnddate) != nil {
                    treatment.setObject((profileSet.objectForKey(newTreatmentEnddate) as! Int)*1000, forKey: "endDate")
                }
            }
            haalthyService.addTreatment(treatmentList)
        }
    }
    
    func addTreatmentInView(treatmentFormatList : NSArray, containerView: UIView){
        let tagBtnHeight:CGFloat = 40
        let tagBtnWidth:CGFloat = (containerView.frame.width - 10)/5
        var index:Int = 0
        let maxTagCount = treatmentFormatList.count > 10 ? 10 : treatmentFormatList.count
        for index = 0; index < maxTagCount; index++ {
            let coordinateX:CGFloat = 5 + CGFloat(index%5) * tagBtnWidth
            var coordinateY:CGFloat = 0
            if index < 5{
                coordinateY = 5
            }else{
                coordinateY = 55
            }
            let tagBtn = UIButton(frame: CGRectMake(coordinateX, coordinateY, tagBtnWidth - 5, tagBtnHeight))
            tagBtn.setTitle(treatmentFormatList[index].objectForKey("treatmentName") as! String, forState: UIControlState.Normal)
            tagBtn.titleLabel?.font = UIFont(name: "Helvetica", size: 13.0)
            tagBtn.setTitleColor(mainColor, forState: UIControlState.Normal)
            tagBtn.backgroundColor = UIColor.whiteColor()
            tagBtn.layer.borderColor = mainColor.CGColor
            tagBtn.layer.borderWidth = 1.0
            tagBtn.layer.masksToBounds = true
            tagBtn.layer.cornerRadius = 5.0
            tagBtn.alpha = 1.0
            tagBtn.addTarget(self, action: "selectTreatment:", forControlEvents: UIControlEvents.TouchUpInside)
            
            self.suggestTreatmentDetailView.addSubview(tagBtn)

        }
    }
    
    func getTreatmentDetail(){
        var treatmentName = String()
        for treatmentButtonView in suggestTreatmentDetailView.subviews {
            if treatmentButtonView is UIButton && treatmentButtonView.backgroundColor == mainColor{
                 treatmentName += ((treatmentButtonView as! UIButton).titleLabel!).text! + " "
            }
        }
        if (treatmentName as NSString).length == 0{
            treatmentName = treatmentTypeSegment.titleForSegmentAtIndex(treatmentTypeSegment.selectedSegmentIndex)!
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
            sender.backgroundColor = mainColor
            sender.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        }else{
            sender.backgroundColor = UIColor.whiteColor()
            sender.setTitleColor(mainColor, forState: UIControlState.Normal)
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        treatmentTypeSegment.selectedSegmentIndex = 0
        segmentHeight = treatmentTypeSegment.frame.height
        segmentSectionWidth = treatmentTypeSegment.frame.width/CGFloat(segmentSections)
        pointer.frame = CGRectMake(treatmentTypeSegment.frame.origin.x + segmentSectionWidth/2, treatmentTypeSegment.frame.origin.y + segmentHeight, 20, 20)
        suggestTreatmentDetailView.frame = CGRectMake(10, pointer.frame.origin.y + 18, UIScreen.mainScreen().bounds.width - 20, 100)
        
        treatmentTextInput.frame = CGRectMake(10, suggestTreatmentDetailView.frame.origin.y + 105, UIScreen.mainScreen().bounds.width - 20, 100)
        treatmentTextInput.layer.borderColor = mainColor.CGColor
        treatmentTextInput.layer.borderWidth = 1.0
        treatmentTextInput.textColor = UIColor.grayColor()
        treatmentTextInput.text = "请输入剂量及使用方法"
        shareToFriendButton.frame = CGRectMake(20, treatmentTextInput.frame.origin.y + 120, UIScreen.mainScreen().bounds.width/2 - 30, 30)
        saveToMyselfButton.frame = CGRectMake(shareToFriendButton.frame.width + 40, treatmentTextInput.frame.origin.y + 120, shareToFriendButton.frame.width, 30)
        addTreatmentInView(treatmentFormatOfTKI, containerView: suggestTreatmentDetailView)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        if textView.textColor != UIColor.blackColor() {
            textView.text = nil
            textView.textColor = UIColor.blackColor()
        }
    }
    
//    func textViewShouldEndEditing(textView: UITextView) -> Bool {
//        textView.resignFirstResponder()
//        return true
//    }
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if text == "\n"{
            textView.resignFirstResponder()
            return false
        }
        return true
    }
}
