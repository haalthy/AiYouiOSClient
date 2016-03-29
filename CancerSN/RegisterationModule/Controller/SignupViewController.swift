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
    
    var portraitImgStr = String()
    let appIconImageView = UIImageView()
    let portraitBtn = UIButton()
    let id: UITextField = UITextField()
    let authCode: UITextField = UITextField()
    let nick: UITextField = UITextField()
    let password: UITextField = UITextField()
    let reenterPassword: UITextField = UITextField()
    
    let haalthyService = HaalthyService()
    let keychainAccess = KeychainAccess()
    let publicService = PublicService()
    let profileSet = NSUserDefaults.standardUserDefaults()
    
    var imagePicker = UIImagePickerController()
    
    func cropToSquare(image originalImage: UIImage) -> UIImage {
        // Create a copy of the image without the imageOrientation property so it is in its native orientation (landscape)
        let contextImage: UIImage = UIImage(CGImage: originalImage.CGImage!)
        
        // Get the size of the contextImage
        let contextSize: CGSize = contextImage.size
        
        let posX: CGFloat
        let posY: CGFloat
        let width: CGFloat
        let height: CGFloat
        
        // Check to see which length is the longest and create the offset based on that length, then set the width and height of our rect
        if contextSize.width > contextSize.height {
            posX = ((contextSize.width - contextSize.height) / 2)
            posY = 0
            width = contextSize.height
            height = contextSize.height
        } else {
            posX = 0
            posY = ((contextSize.height - contextSize.width) / 2)
            width = contextSize.width
            height = contextSize.width
        }
        
        let rect: CGRect = CGRectMake(posX, posY, width, height)
        
        // Create bitmap image from context using the rect
        let imageRef: CGImageRef = CGImageCreateWithImageInRect(contextImage.CGImage, rect)!
        
        // Create a new image based on the imageRef and rotate back to the original orientation
        let image: UIImage = UIImage(CGImage: imageRef, scale: originalImage.scale, orientation: originalImage.imageOrientation)
        
        return image
    }
    
    override func viewDidLoad() {
        print(screenHeight)
        initVariables()
        initContentView()
    }
    
    func initVariables(){
        imagePicker.delegate = self
        imagePicker.allowsEditing = true //2
        imagePicker.sourceType = .PhotoLibrary //
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.navigationBar.hidden = true
    }
    
    func initContentView(){
        if screenHeight < 600 {
            inputViewTopSpace = 150
        }
        let backgroudImgView = UIImageView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight))
        backgroudImgView.image = UIImage(named: "img_background")
        self.view.addSubview(backgroudImgView)
        //portrait view
        let appIconLeftSpace: CGFloat = (screenWidth - appIconLength)/2
        appIconImageView.frame = CGRECT(0, 0, appIconLength, appIconLength)
        appIconImageView.image = UIImage(named: "defaultUserImage")
        portraitBtn.backgroundColor = UIColor.whiteColor()
        portraitBtn.layer.cornerRadius = appIconLength/2
        portraitBtn.layer.masksToBounds = true
        portraitBtn.frame = CGRECT(appIconLeftSpace, appIconTopSpace, appIconLength, appIconLength)
        portraitBtn.addTarget(self, action: "selectImage:", forControlEvents: UIControlEvents.TouchUpInside)
        portraitBtn.addSubview(appIconImageView)
        self.view.addSubview(portraitBtn)
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
        id.delegate = self
        
        //auth code
        let authCodeTextW: CGFloat = textInputView.frame.width - textFieldLeftSpace - getAuthCodeBtnW
        authCode.frame = CGRECT(textFieldLeftSpace, textFieldHeight + 1, authCodeTextW, textFieldHeight)
        authCode.font = inputViewFont
        authCode.placeholder = "验证码"
        authCode.delegate = self
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
        
        let seperateLineVertical = UIView(frame: CGRect(x: textInputView.frame.width - getAuthCodeBtnW, y: textFieldHeight + 1, width: 1, height: textFieldHeight))
        seperateLineVertical.backgroundColor = seperateLineColor
        textInputView.addSubview(seperateLineVertical)
        
        //NICK name
        nick.frame = CGRect(x: textFieldLeftSpace, y: (textFieldHeight + 1)*2, width: textInputView.frame.width, height: textFieldHeight )
        nick.font = inputViewFont
        nick.placeholder = "昵称"
        let seperateLine3 = UIView(frame: CGRect(x: 0, y: (textFieldHeight + 1)*3 - 1, width: textInputView.frame.width, height: 1))
        seperateLine3.backgroundColor = seperateLineColor
        textInputView.addSubview(seperateLine3)
        textInputView.addSubview(nick)
        nick.delegate = self
        
        //password
        password.frame = CGRect(x: textFieldLeftSpace, y: (textFieldHeight + 1)*3, width: textInputView.frame.width, height: textFieldHeight)
        password.font = inputViewFont
        password.placeholder = "密码"
        textInputView.addSubview(password)
        password.secureTextEntry = true
        password.delegate = self
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
        
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "tapDismiss")
        self.view.addGestureRecognizer(tapGesture)
    }
    
    func tapDismiss(){
        self.view.endEditing(true)
    }
    
    func selectImage(sender: UIButton){
        presentViewController(imagePicker, animated: true, completion: nil)//4
        //MARK: Delegates
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        let chosenImage = info[UIImagePickerControllerOriginalImage] as! UIImage //2

        var selectedImage = UIImage()
        selectedImage = cropToSquare(image: chosenImage)
        
        let newSize = CGSizeMake(300, 300)
        UIGraphicsBeginImageContext(newSize)
        selectedImage.drawInRect(CGRectMake(0, 0, newSize.width, newSize.height))
        appIconImageView.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        dismissViewControllerAnimated(true, completion: nil) //5
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool{
        textField.resignFirstResponder()
        return true
    }
    func getAuthCode(sender: UIButton){
        let idStr: String = id.text!
        HudProgressManager.sharedInstance.showOnlyTextHudProgress(self, title: "发送验证码")
        if haalthyService.getAuthCode(idStr) == false {
            HudProgressManager.sharedInstance.dismissHud()
            HudProgressManager.sharedInstance.showOnlyTextHudProgress(self, title: "获取验证码错误")
            HudProgressManager.sharedInstance.dismissHud()
        }else{
            HudProgressManager.sharedInstance.dismissHud()
        }
    }
    
    func login(sender: UIButton){
        let storyboard = UIStoryboard(name: "Registeration", bundle: nil)
        let loginViewController = storyboard.instantiateViewControllerWithIdentifier("Login")
        self.presentViewController(loginViewController, animated: true, completion: nil)
    }
    
    func signUp(sender: UIButton){
        if publicService.checkIsEmail(id.text!) {
            profileSet.setObject(id.text!, forKey: emailNSUserData)
            profileSet.setObject(nil, forKey: phoneNSUserData)
        }else if publicService.checkIsPhoneNumber(id.text!){
            profileSet.setObject(id.text!, forKey: phoneNSUserData)
            profileSet.setObject(nil, forKey: emailNSUserData)
        }
        let getAuthRequest = NSDictionary(objects: [id.text!, authCode.text!], forKeys: ["eMail", "authCode"])
        
        if haalthyService.checkAuthCode(getAuthRequest) {
            profileSet.setObject(nick.text!, forKey: displaynameUserData)
            let selectedImageData: NSData = UIImagePNGRepresentation(appIconImageView.image!)!
            portraitImgStr = selectedImageData.base64EncodedStringWithOptions([])
            profileSet.setObject(portraitImgStr, forKey: imageNSUserData)
            keychainAccess.setPasscode(passwordKeyChain, passcode: password.text!)
            let result = haalthyService.addUser("AY")
            if (result.count > 0) && (result.objectForKey("result") as! Int) == 1 {
                keychainAccess.setPasscode(passwordKeyChain, passcode: password.text!)
                keychainAccess.setPasscode(usernameKeyChain, passcode: (result.objectForKey("content") as! NSDictionary).objectForKey("result") as! String)
                if (profileSet.objectForKey(favTagsNSUserData) != nil) &&
                    (profileSet.objectForKey(favTagsNSUserData) is NSArray){
                        haalthyService.updateUserTag(profileSet.objectForKey(favTagsNSUserData) as! NSArray)
                }
                self.performSegueWithIdentifier("signUpSucessfulSegue", sender: self)
            }else{
                    HudProgressManager.sharedInstance.showOnlyTextHudProgress(self, title: result.objectForKey("resultDesp") as! String)
                    HudProgressManager.sharedInstance.dismissHud()
            }
        }else{
            HudProgressManager.sharedInstance.showOnlyTextHudProgress(self, title: "验证码错误")
            HudProgressManager.sharedInstance.dismissHud()
        }
    }
}
