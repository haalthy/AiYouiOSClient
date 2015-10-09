//
//  SettingPasswordViewController.swift
//  CancerSN
//
//  Created by lily on 9/14/15.
//  Copyright (c) 2015 lily. All rights reserved.
//

import UIKit

//protocol SettingPasswordDelegate{
//    func getPassword(password: String)
//}

class SettingPasswordViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var confirmPassword: UITextField!
    var haalthyService = HaalthyService()
    var username = String()
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        usernameLabel.text = username
        self.title = "设置密码"
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        let titleDict: NSDictionary = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        self.navigationController?.navigationBar.titleTextAttributes = titleDict as [NSObject : AnyObject]
        
//        var cancelButton : UIBarButtonItem = UIBarButtonItem(title: "取消", style: UIBarButtonItemStyle.Plain, target: self, action: "cancel")
        
        var submitButton : UIBarButtonItem = UIBarButtonItem(title: "确定", style: UIBarButtonItemStyle.Plain, target: self, action: "submit")
        submitButton.tintColor = UIColor(white: 1, alpha: 0.5)
        
//        self.navigationItem.leftBarButtonItem = cancelButton
        self.navigationItem.rightBarButtonItem = submitButton
        password.delegate = self
        confirmPassword.delegate = self
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        textField.resignFirstResponder()
        return true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        if textField == confirmPassword{
            if password.text != nil {
                self.navigationItem.rightBarButtonItem?.tintColor = UIColor.whiteColor()
            }
        }
    }
    
//    func cancel(){
//        self.dismissViewControllerAnimated(true, completion: nil)
//    }
    
    func submit(){
        if password.text == confirmPassword.text {
            var jsonResult:AnyObject? = nil
            var resetPwd = haalthyService.resetPassword(password.text)
            if resetPwd != nil{
                jsonResult = NSJSONSerialization.JSONObjectWithData(resetPwd!, options: NSJSONReadingOptions.MutableContainers, error: nil)
                let str: NSString = NSString(data: resetPwd!, encoding: NSUTF8StringEncoding)!
                if str == "1"{
                    println(str)
                    var keychainAccess = KeychainAccess()
                    keychainAccess.setPasscode(passwordKeyChain, passcode: password.text)
                    self.navigationController?.popToRootViewControllerAnimated(true)
                }
            }
        }
        else{
            let alertController = UIAlertController(title: "密码不一致", message: nil, preferredStyle: .Alert)
            
            let OKAction = UIAlertAction(title: "OK", style: .Default) { (action) in
                // ...
            }
            alertController.addAction(OKAction)
            
            self.presentViewController(alertController, animated: true) {
                // ...
            }
        }
    }
    
}
