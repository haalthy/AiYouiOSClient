//
//  LoginViewController.swift
//  CancerSN
//
//  Created by lily on 7/28/15.
//  Copyright (c) 2015 lily. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate, TencentSessionDelegate {
    var tencentOAuth:TencentOAuth? = nil
    
    @IBOutlet weak var portrait: UIImageView!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var username: UITextField!
    let profileSet = NSUserDefaults.standardUserDefaults()
    var data:NSMutableData?  = nil
    var haalthyService = HaalthyService()
    var isRootViewController = false
    
    @IBAction func loginViaQQ(sender: UIButton) {
        self.tencentOAuth = TencentOAuth(appId: "1104886596", andDelegate: self)
        var permissions = [kOPEN_PERMISSION_GET_INFO,kOPEN_PERMISSION_GET_USER_INFO,kOPEN_PERMISSION_GET_SIMPLE_USER_INFO]
        tencentOAuth!.authorize(permissions, inSafari: false)
    }
    
    @IBAction func loginViaWechat(sender: UIButton) {
        
    }
    
    @IBAction func signUp(sender: UIButton) {
        profileSet.setObject(aiyouUserType, forKey: userTypeUserData)
        self.performSegueWithIdentifier("fillInfoSegue", sender: self)
    }
    
    func tencentDidLogin(){
        tencentOAuth!.getUserInfo()
    }
    
    func tencentDidNotLogin(cancelled: Bool) {
        println("登录失败了")
    }
    
    //无网络
    func tencentDidNotNetWork() {
        println("没有网络")
    }
    
    func getUserInfoResponse(response: APIResponse!) {
        let accessToken = tencentOAuth!.accessToken
        let openId = tencentOAuth!.openId
        let expirationDate = tencentOAuth!.expirationDate.timeIntervalSince1970
        var resp: NSDictionary = response.jsonResponse
        
        println(resp.objectForKey("nickname"))
        if userLogin(openId, passwordStr: openId) == false {
            //store username, password, email in NSUserData
            profileSet.setObject("", forKey: emailNSUserData)
            var qqImage = UIImage(named: "Tencent_QQ.png")
            var imageData: NSData = UIImagePNGRepresentation(qqImage)

            var imageDataStr = imageData.base64EncodedStringWithOptions(.allZeros)

            profileSet.setObject(imageDataStr, forKey: imageNSUserData)
            profileSet.setObject(resp.objectForKey("nickname"), forKey: displaynameUserData)
            profileSet.setObject(qqUserType, forKey: userTypeUserData)
            let keychainAccess = KeychainAccess()
            keychainAccess.setPasscode(usernameKeyChain, passcode: openId)
            keychainAccess.setPasscode(passwordKeyChain, passcode: openId)
            self.performSegueWithIdentifier("fillInfoSegue", sender: self)
        }else{
            self.performSegueWithIdentifier("homeSegue", sender: self)
        }
    }
    
    func userLogin(usernameStr: String, passwordStr: String)->Bool{
        let respData = haalthyService.getAccessToken(usernameStr, password: passwordStr)
        var jsonResult: AnyObject? = NSJSONSerialization.JSONObjectWithData(respData, options: NSJSONReadingOptions.MutableContainers, error: nil)
        var accessToken: AnyObject?  = jsonResult?.objectForKey("access_token")
        var refreshToken: AnyObject? = jsonResult?.objectForKey("refresh_token")
        if(accessToken != nil && refreshToken != nil){
            let profileSet = NSUserDefaults.standardUserDefaults()
            profileSet.setObject(accessToken, forKey: accessNSUserData)
            profileSet.setObject(refreshToken, forKey: refreshNSUserData)
            let keychainAccess = KeychainAccess()
            keychainAccess.setPasscode(usernameKeyChain, passcode: usernameStr)
            keychainAccess.setPasscode(passwordKeyChain, passcode: passwordStr)
            return true
        }else{
            return false
        }
    }
    
    @IBAction func login(sender: UIButton) {
        let usernameStr = username.text
        let passwordStr = password.text
//        let respData = haalthyService.getAccessToken(usernameStr, password: passwordStr)
//        var jsonResult: AnyObject? = NSJSONSerialization.JSONObjectWithData(respData, options: NSJSONReadingOptions.MutableContainers, error: nil)
//        var accessToken: AnyObject?  = jsonResult?.objectForKey("access_token")
//        var refreshToken: AnyObject? = jsonResult?.objectForKey("refresh_token")
//        if(accessToken != nil && refreshToken != nil){
//            let profileSet = NSUserDefaults.standardUserDefaults()
//            profileSet.setObject(accessToken, forKey: accessNSUserData)
//            profileSet.setObject(refreshToken, forKey: refreshNSUserData)
//            let keychainAccess = KeychainAccess()
//            keychainAccess.setPasscode(usernameKeyChain, passcode: username.text)
//            keychainAccess.setPasscode(passwordKeyChain, passcode: password.text)
//        }
        userLogin(usernameStr, passwordStr: passwordStr)
        if isRootViewController{
            self.performSegueWithIdentifier("homeSegue", sender: self)
        }else{
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    @IBAction func forgetPassword(sender: UIButton) {
        
    }
    
    @IBAction func ignore(sender: UIButton) {
        self.performSegueWithIdentifier("tagSegue", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "tagSegue"{
            (segue.destinationViewController as! TagTableViewController).isFirstTagSelection = true
        }
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
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        let keychainAccess = KeychainAccess()
        let username = keychainAccess.getPasscode(usernameKeyChain)
        let password = keychainAccess.getPasscode(passwordKeyChain)
        if ( username != nil) && ( password != nil) && userLogin(username! as String, passwordStr: password! as String) {
            self.performSegueWithIdentifier("tagSegue", sender: self)
        }
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
