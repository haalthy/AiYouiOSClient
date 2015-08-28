//
//  MetastasisViewController.swift
//  CancerSN
//
//  Created by lily on 7/26/15.
//  Copyright (c) 2015 lily. All rights reserved.
//

import UIKit

class MetastasisViewController: UIViewController, UITextFieldDelegate {

    var metastasisList : NSMutableArray = []
    
    @IBOutlet weak var selectBtn: UIButton!
    @IBOutlet weak var skipBtn: UIButton!
    
    @IBOutlet weak var liver: UIButton!
    @IBOutlet weak var bone: UIButton!
    @IBOutlet weak var adrenal: UIButton!
    @IBOutlet weak var brain: UIButton!
    @IBOutlet weak var other: UITextField!
    
    let unselectedLabelColor: UIColor = UIColor.init(red:0.8, green:0.8, blue:1, alpha:0.65)
    
    let selectedLabelColor : UIColor = UIColor.init(red:0.7, green:0.7, blue:1, alpha:1)
    
    @IBAction func selectMetastasis(sender: UIButton) {
        sender.backgroundColor = textColor
        sender.titleLabel?.textColor = UIColor.whiteColor()
        let metastasisDBStr:String = metastasisMapping.objectForKey((sender.titleLabel?.text)!) as! String
        if(metastasisList.containsObject(metastasisDBStr)){
            sender.backgroundColor = unselectedLabelColor
            metastasisList.removeObject(metastasisDBStr)
        }else{
            sender.backgroundColor = selectedLabelColor
            metastasisList.addObject(metastasisDBStr)
        }
    }
    
    @IBAction func submitMetastasis(sender: UIButton) {
        metastasisList.addObject(other.text)
        var metastasisListStr : String = ""
        for(var metastasisIndex = 0; metastasisIndex<metastasisList.count-1; metastasisIndex++){
            metastasisListStr = metastasisListStr + (metastasisList[metastasisIndex] as! String) + ";"
        }
        if(metastasisList.count>0){
            metastasisListStr = metastasisListStr + (metastasisList[metastasisList.count-1] as! String)
        }
        let profileSet = NSUserDefaults.standardUserDefaults()
        println(metastasisListStr)
        profileSet.setObject(metastasisListStr, forKey: metastasisNSUserData)
    }
    
    func setButtonFormat(sender: UIButton){
        sender.layer.borderColor = textColor.CGColor
        sender.layer.borderWidth = 2.0
        sender.layer.cornerRadius = 5
        sender.layer.masksToBounds = true
        sender.backgroundColor = UIColor.whiteColor()
        sender.titleLabel?.textColor = textColor
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        other.delegate = self
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name:UIKeyboardWillShowNotification, object: nil);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name:UIKeyboardWillHideNotification, object: nil);
        
        other.returnKeyType = UIReturnKeyType.Done
        liver.setTitle("肝转移", forState: .Normal)
        bone.setTitle("骨转移", forState: .Normal)
        adrenal.setTitle("肾上腺转移", forState: .Normal)
        brain.setTitle("脑转移", forState: .Normal)
//        liver.backgroundColor = unselectedLabelColor
//        bone.backgroundColor = unselectedLabelColor
//        adrenal.backgroundColor = unselectedLabelColor
//        brain.backgroundColor = unselectedLabelColor
        
        selectBtn.layer.cornerRadius = 5
        selectBtn.layer.masksToBounds = true
        skipBtn.layer.cornerRadius = 5
        skipBtn.layer.masksToBounds = true
        
        setButtonFormat(liver)
        setButtonFormat(bone)
        setButtonFormat(adrenal)
        setButtonFormat(brain)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        textField.resignFirstResponder()
        return true
    }
    
    func keyboardWillShow(sender: NSNotification) {
        self.view.frame.origin.y -= 50
    }
    func keyboardWillHide(sender: NSNotification) {
        self.view.frame.origin.y += 50
    }
}
