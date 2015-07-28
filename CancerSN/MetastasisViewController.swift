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
    
    @IBOutlet weak var liver: UIButton!
    @IBOutlet weak var bone: UIButton!
    @IBOutlet weak var adrenal: UIButton!
    @IBOutlet weak var brain: UIButton!
    @IBOutlet weak var other: UITextField!
    
    let unselectedLabelColor: UIColor = UIColor.init(red:0.8, green:0.8, blue:1, alpha:0.65)
    
    let selectedLabelColor : UIColor = UIColor.init(red:0.7, green:0.7, blue:1, alpha:1)
    
    @IBAction func selectMetastasis(sender: UIButton) {
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
        liver.backgroundColor = unselectedLabelColor
        bone.backgroundColor = unselectedLabelColor
        adrenal.backgroundColor = unselectedLabelColor
        brain.backgroundColor = unselectedLabelColor
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
