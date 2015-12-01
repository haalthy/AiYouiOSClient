//
//  SettingPasswordViewController.swift
//  CancerSN
//
//  Created by lily on 9/14/15.
//  Copyright (c) 2015 lily. All rights reserved.
//

import UIKit

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
        self.navigationController?.navigationBar.titleTextAttributes = titleDict as? [String : AnyObject]
        
        let submitButton : UIBarButtonItem = UIBarButtonItem(title: "确定", style: UIBarButtonItemStyle.Plain, target: self, action: "submit")
        submitButton.tintColor = UIColor(white: 1, alpha: 0.5)
        
        self.navigationItem.rightBarButtonItem = submitButton
        password.delegate = self
        confirmPassword.delegate = self
    }
    
    
    func textFieldShouldReturn(textField: UITextField) -> Bool{
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
            let resetPwd = haalthyService.resetPassword(password.text!)
            if resetPwd != nil{
                jsonResult = try? NSJSONSerialization.JSONObjectWithData(resetPwd!, options: NSJSONReadingOptions.MutableContainers)
                let str: NSString = NSString(data: resetPwd!, encoding: NSUTF8StringEncoding)!
                if str == "1"{
                    print(str)
                    let keychainAccess = KeychainAccess()
                    keychainAccess.setPasscode(passwordKeyChain, passcode: password.text!)
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
