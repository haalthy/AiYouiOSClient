//
//  LoginViewController.swift
//  CancerSN
//
//  Created by lily on 7/28/15.
//  Copyright (c) 2015 lily. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var portrait: UIImageView!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var username: UITextField!
    var data:NSMutableData?  = nil
    var haalthyService = HaalthyService()
    
    @IBAction func login(sender: UIButton) {
        let usernameStr = username.text
        let passwordStr = password.text
        let respData = haalthyService.getAccessToken(usernameStr, password: passwordStr)
        var jsonResult: AnyObject? = NSJSONSerialization.JSONObjectWithData(respData, options: NSJSONReadingOptions.MutableContainers, error: nil)
        var accessToken: AnyObject?  = jsonResult?.objectForKey("access_token")
        var refreshToken: AnyObject? = jsonResult?.objectForKey("refresh_token")
        if(accessToken != nil && refreshToken != nil){
            let profileSet = NSUserDefaults.standardUserDefaults()
            profileSet.setObject(accessToken, forKey: accessNSUserData)
            profileSet.setObject(refreshToken, forKey: refreshNSUserData)
            let keychainAccess = KeychainAccess()
            keychainAccess.setPasscode(usernameKeyChain, passcode: username.text)
            keychainAccess.setPasscode(passwordKeyChain, passcode: password.text)
        }
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func forgetPassword(sender: UIButton) {
        
    }
    
    @IBAction func cancel(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as! String
        
        var imageFilePath = "\(paths)/" + imageFileName
        portrait.image = UIImage(contentsOfFile: imageFilePath)
        password.delegate = self
        username.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool{
        textField.resignFirstResponder()
        return true
    }
}
