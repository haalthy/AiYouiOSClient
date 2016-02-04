//
//  SignupViewController.swift
//  CancerSN
//
//  Created by lily on 7/26/15.
//  Copyright (c) 2015 lily. All rights reserved.
//

import UIKit

class SignupViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate, UIGestureRecognizerDelegate, UITextFieldDelegate  {
    
    let textFieldHeight: CGFloat = CGFloat(44)
    let textFieldLineCount: Int = 4
    let getAuthCodeBtnW: CGFloat = 94
    let textFieldLeftSpace: CGFloat = 15
    
    let id: UITextField = UITextField()
    let authCode: UITextField = UITextField()
    let nick: UITextField = UITextField()
    let password: UITextField = UITextField()
    let reenterPassword: UITextField = UITextField()
    
    let haalthyService = HaalthyService()
    let keychainAccess = KeychainAccess()
    let publicService = PublicService()
    let profileSet = NSUserDefaults.standardUserDefaults()
    
    override func viewDidLoad() {
        initVariables()
        initContentView()
    }
    
    func initVariables(){
    
    }
    
    func initContentView(){
        let backgroudImgView = UIImageView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight))
        backgroudImgView.image = UIImage(named: "img_background")
        self.view.addSubview(backgroudImgView)
        //app icon view
        let appIconLeftSpace: CGFloat = (screenWidth - appIconLength)/2
        let appIconImageView = UIImageView(frame: CGRECT(appIconLeftSpace, appIconTopSpace, appIconLength, appIconLength))
        appIconImageView.image = UIImage(named: "img_appIcon")
        appIconImageView.backgroundColor = UIColor.clearColor()
        appIconImageView.layer.cornerRadius = 16
        appIconImageView.layer.masksToBounds = true
        self.view.addSubview(appIconImageView)
        //textInputView
        let textInputView: UIView = UIView(frame: CGRect(x: inputViewMargin, y: inputViewTopSpace, width: screenWidth - inputViewMargin * 2, height: textFieldHeight * CGFloat(textFieldLineCount) + 4))
        textInputView.layer.cornerRadius = 4
        textInputView.backgroundColor = UIColor.whiteColor()
        
        //id
        id.frame = CGRect(x: textFieldLeftSpace, y: 0, width: textInputView.frame.width, height: textFieldHeight )
        id.font = inputViewFont
        id.placeholder = "邮箱／手机"
        let seperateLine1 = UIView(frame: CGRect(x: 0, y: textFieldHeight, width: textInputView.frame.width, height: 1))
        seperateLine1.backgroundColor = seperateLineColor
        textInputView.addSubview(seperateLine1)
        textInputView.addSubview(id)
        
        //auth code
        let authCodeTextW: CGFloat = textInputView.frame.width - textFieldLeftSpace - getAuthCodeBtnW
        authCode.frame = CGRECT(textFieldLeftSpace, textFieldHeight + 1, authCodeTextW, textFieldHeight)
        authCode.font = inputViewFont
        authCode.placeholder = "验证码"
        textInputView.addSubview(authCode)
        let getAuthBtn = UIButton(frame: CGRect(x: textInputView.frame.width - getAuthCodeBtnW, y: textFieldHeight + 1, width: getAuthCodeBtnW, height: textFieldHeight))
        getAuthBtn.setTitle("获取验证码", forState: UIControlState.Normal)
        getAuthBtn.setTitleColor(headerColor, forState: UIControlState.Normal)
        getAuthBtn.titleLabel?.font = getAuthCodeBtnFont
        getAuthBtn.addTarget(self, action: "getAuthCode:", forControlEvents: UIControlEvents.TouchUpInside)
        textInputView.addSubview(getAuthBtn)
        let seperateLine2 = UIView(frame: CGRect(x: 0, y: textFieldHeight*2 + 1, width: textInputView.frame.width, height: 1))
        seperateLine2.backgroundColor = seperateLineColor
        textInputView.addSubview(seperateLine2)
        
        //NICK name
        nick.frame = CGRect(x: textFieldLeftSpace, y: (textFieldHeight + 1)*2, width: textInputView.frame.width, height: textFieldHeight )
        nick.font = inputViewFont
        nick.placeholder = "昵称"
        let seperateLine3 = UIView(frame: CGRect(x: 0, y: (textFieldHeight + 1)*3 - 1, width: textInputView.frame.width, height: 1))
        seperateLine3.backgroundColor = seperateLineColor
        textInputView.addSubview(seperateLine3)
        textInputView.addSubview(nick)
        
        //password
        password.frame = CGRect(x: textFieldLeftSpace, y: (textFieldHeight + 1)*3, width: textInputView.frame.width, height: textFieldHeight)
        password.font = inputViewFont
        password.placeholder = "密码"
        textInputView.addSubview(password)
//        let seperateLine4: UIView = UIView(frame: CGRect(x: 0, y: (textFieldHeight + 1)*4 - 1, width: textInputView.frame.width, height: 1))
//        seperateLine4.backgroundColor = seperateLineColor
//        textInputView.addSubview(seperateLine4)
//        
//        //re enter password
//        reenterPassword.frame = CGRect(x: textFieldLeftSpace, y: (textFieldHeight + 1)*4, width: textInputView.frame.width, height: textFieldHeight)
//        reenterPassword.font = inputViewFont
//        reenterPassword.placeholder = "再次输入密码"
//        textInputView.addSubview(reenterPassword)
//        
        self.view.addSubview(textInputView)
        
        //sign up Btn
        let signUpBtn: UIButton = UIButton(frame: CGRect(x: loginBtnMargin, y: textInputView.frame.origin.y + textInputView.frame.height + 20, width: screenWidth - 2 * loginBtnMargin, height: loginBtnHeight))
        signUpBtn.backgroundColor =  UIColor.clearColor()
        let loginBtnBackgroundView = UIImageView(frame: CGRect(x: 0, y: 0, width: screenWidth - 2 * loginBtnMargin, height: loginBtnHeight))
        loginBtnBackgroundView.backgroundColor = UIColor.whiteColor()
        loginBtnBackgroundView.alpha = 0.5
        signUpBtn.addSubview(loginBtnBackgroundView)
        signUpBtn.setTitle("注册", forState: UIControlState.Normal)
        signUpBtn.titleLabel?.font = loginBtnFont
        signUpBtn.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        signUpBtn.layer.cornerRadius = 4
        signUpBtn.layer.masksToBounds = true
        signUpBtn.addTarget(self, action: "signUp:", forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(signUpBtn)
        
        //login btn
        let loginBtn: UIButton = UIButton(frame: CGRect(x: loginBtnMargin, y: signUpBtn.frame.origin.y + signUpBtn.frame.height + 10, width: screenWidth - 2 * loginBtnMargin, height: loginBtnHeight))
        loginBtn.backgroundColor =  UIColor.clearColor()
        loginBtn.setTitle("登录", forState: UIControlState.Normal)
        loginBtn.titleLabel?.font = loginBtnFont
        loginBtn.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        loginBtn.addTarget(self, action: "login:", forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(loginBtn)
        
    }
    
    func getAuthCode(sender: UIButton){
        if haalthyService.getAuthCode(id.text!) == false {
            print("获取验证码错误")
        }
    }
    
    func login(sender: UIButton){
        if publicService.checkIsEmail(id.text!) {
            profileSet.setObject(id.text!, forKey: emailNSUserData)
        }else if publicService.checkIsPhoneNumber(id.text!){
            profileSet.setObject(id.text!, forKey: phoneNSUserData)
        }
        
    }
    
    func signUp(sender: UIButton){
        
        self.performSegueWithIdentifier("signUpSucessfulSegue", sender: self)
    }
    
//    @IBOutlet weak var portrait: UIImageView!
//    
//    @IBOutlet weak var emailInput: UITextField!
//    @IBOutlet weak var passwordInput: UITextField!
//    @IBOutlet weak var passwordReInput: UITextField!
//    @IBOutlet weak var displayname: UITextField!
//    
//    var imagePicker = UIImagePickerController()
//    
//    var data :NSMutableData? = NSMutableData()
//    @IBAction func submit(sender: UIButton) {
//        //store username, password, email in NSUserData
//        print(passwordInput.text)
//        print(passwordReInput.text)
//        if passwordInput.text != passwordReInput.text {
//            let alert = UIAlertController(title: "提示", message: "密码输入不一致，请重新输入", preferredStyle: UIAlertControllerStyle.Alert)
//            alert.addAction(UIAlertAction(title: "确定", style: UIAlertActionStyle.Default, handler: nil))
//            self.presentViewController(alert, animated: true, completion: nil)
//        }else if emailInput.text == ""{
//            let alert = UIAlertController(title: "提示", message: "请输入邮箱／手机", preferredStyle: UIAlertControllerStyle.Alert)
//            alert.addAction(UIAlertAction(title: "确定", style: UIAlertActionStyle.Default, handler: nil))
//            self.presentViewController(alert, animated: true, completion: nil)
//        }else
//            if passwordInput.text == ""{
//                let alert = UIAlertController(title: "提示", message: "请输入密码", preferredStyle: UIAlertControllerStyle.Alert)
//                alert.addAction(UIAlertAction(title: "确定", style: UIAlertActionStyle.Default, handler: nil))
//                self.presentViewController(alert, animated: true, completion: nil)
//            }else{
//                
//                var usernameStr:String = String()
//                let publicService = PublicService()
//                print("passwordStr")
//                
//                let passwordStr = publicService.passwordEncode(passwordInput.text!)
//                
//                print(passwordStr)
//                
//                //save image
//                let selectedImage: UIImage = portrait.image!
//                
//                let fileManager = NSFileManager.defaultManager()
//                
//                let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
//                
//                let filePathToWrite = "\(paths)/" + imageFileName
//                
//                let imageData: NSData = UIImagePNGRepresentation(selectedImage)!
//                print(selectedImage.size.width, selectedImage.size.height)
//                let imageDataStr = imageData.base64EncodedStringWithOptions([])
//                
//                fileManager.createFileAtPath(filePathToWrite, contents: imageData, attributes: nil)
//                
//                let profileSet = NSUserDefaults.standardUserDefaults()
//                profileSet.setObject(emailInput.text, forKey: emailNSUserData)
//                profileSet.setObject(imageDataStr, forKey: imageNSUserData)
//                profileSet.setObject(displayname.text, forKey: displaynameUserData)
//                let keychainAccess = KeychainAccess()
//                let haalthyService = HaalthyService()
//                keychainAccess.setPasscode(usernameKeyChain, passcode: emailInput.text!)
//                keychainAccess.setPasscode(passwordKeyChain, passcode: passwordInput.text!)
//                
//                //upload UserInfo to Server
//                let addUserRespData = haalthyService.addUser("AY")
//                var returnStr = String()
//                let jsonResult = try? NSJSONSerialization.JSONObjectWithData(addUserRespData, options: NSJSONReadingOptions.MutableContainers)
//                if jsonResult is NSDictionary {
//                    returnStr = (jsonResult as! NSDictionary).objectForKey("status") as! String
//                }
//                print(returnStr)
//                let isReturnUsername = publicService.checkIsUsername(returnStr)
//
////                publicService.checkIsUsername(returnStr)
////                if returnStr != "create successful!"{
//                if !isReturnUsername{
//                    keychainAccess.deletePasscode(usernameKeyChain)
//                    keychainAccess.deletePasscode(passwordKeyChain)
//                }
//                if returnStr == "this email has been registed, please use another name" {
//                    let alert = UIAlertController(title: "提示", message: "此用户名已被注册，请使用其他用户名", preferredStyle: UIAlertControllerStyle.Alert)
//                    alert.addAction(UIAlertAction(title: "确定", style: UIAlertActionStyle.Default, handler: nil))
//                    self.presentViewController(alert, animated: true, completion: nil)
//                }
//                if returnStr == "this email has been registed, please login" {
//                    let alert = UIAlertController(title: "提示", message: "此邮箱/手机已被注册，请登录", preferredStyle: UIAlertControllerStyle.Alert)
//                    
//                    alert.addAction(UIAlertAction(title: "确定", style: UIAlertActionStyle.Default, handler: {(alert: UIAlertAction) in
//                        self.dismissViewControllerAnimated(true, completion: nil)
//                    }))
//                    self.presentViewController(alert, animated: true, completion: nil)
//                }
//                if isReturnUsername {
////                    usernameStr = NSString(data: haalthyService.getUsernameByEmail(), encoding: NSUTF8StringEncoding) as! String
//                    keychainAccess.setPasscode(usernameKeyChain, passcode: returnStr)
//                    let getAccessToken = GetAccessToken()
//                    getAccessToken.getAccessToken()
//                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
//                    let controller = storyboard.instantiateViewControllerWithIdentifier("MainEntry") as UIViewController
//                    self.presentViewController(controller, animated: true, completion: nil)
//                    
//                    haalthyService.updateUserTag(NSUserDefaults.standardUserDefaults().objectForKey(favTagsNSUserData) as! NSArray)
//                }
//        }
//    }
//    
//    func connection(connection: NSURLConnection!, didReceiveData data: NSData!){
//        self.data!.appendData(data)
//    }
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        portrait.image = UIImage(named: "Mario.jpg")
//        imagePicker.delegate = self
//        let tapImage = UITapGestureRecognizer(target: self, action: Selector("imageTapHandler:"))
//        portrait.userInteractionEnabled = true
//        portrait.addGestureRecognizer(tapImage)
//        
//        emailInput.delegate = self
////        usernameInput.delegate = self
//        passwordInput.delegate = self
//        submitBtn.layer.cornerRadius = 5
//        submitBtn.layer.masksToBounds = true
//    }
//
//    func imageTapHandler(recognizer: UITapGestureRecognizer){
//        imagePicker.allowsEditing = true //2
//        imagePicker.sourceType = .PhotoLibrary //3
//        presentViewController(imagePicker, animated: true, completion: nil)//4
//    }
//    
//    override func didReceiveMemoryWarning() {
//        super.didReceiveMemoryWarning()
//        // Dispose of any resources that can be recreated.
//    }
//    //MARK: Delegates
//    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
//        let chosenImage = info[UIImagePickerControllerOriginalImage] as! UIImage //2
//        var selectedImage = UIImage()
//        selectedImage = cropToSquare(image: chosenImage)
//        
//        let newSize = CGSizeMake(128.0, 128.0)
//        UIGraphicsBeginImageContext(newSize)
//        selectedImage.drawInRect(CGRectMake(0, 0, newSize.width, newSize.height))
//        portrait.image = UIGraphicsGetImageFromCurrentImageContext()
//        UIGraphicsEndImageContext()
//        dismissViewControllerAnimated(true, completion: nil) //5
//        
//    }
//    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
//        dismissViewControllerAnimated(true, completion: nil)
//    }
//    
//    func gestureRecognizer(_: UIGestureRecognizer,
//        shouldRecognizeSimultaneouslyWithGestureRecognizer:UIGestureRecognizer) -> Bool {
//            return true
//    }
//    
//    func textFieldShouldReturn(textField: UITextField) -> Bool{
//        textField.resignFirstResponder()
//        return true
//    }
}
