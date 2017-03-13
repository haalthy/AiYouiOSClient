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
    let profileSet = UserDefaults.standard
    
    var imagePicker = UIImagePickerController()
    
    func cropToSquare(image originalImage: UIImage) -> UIImage {
        // Create a copy of the image without the imageOrientation property so it is in its native orientation (landscape)
        let contextImage: UIImage = UIImage(cgImage: originalImage.cgImage!)
        
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
        
        let rect: CGRect = CGRect(x: posX, y: posY, width: width, height: height)
        
        // Create bitmap image from context using the rect
        let imageRef: CGImage = contextImage.cgImage!.cropping(to: rect)!
        
        // Create a new image based on the imageRef and rotate back to the original orientation
        let image: UIImage = UIImage(cgImage: imageRef, scale: originalImage.scale, orientation: originalImage.imageOrientation)
        
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
        imagePicker.sourceType = .photoLibrary //
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = true
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
        portraitBtn.backgroundColor = UIColor.white
        portraitBtn.layer.cornerRadius = appIconLength/2
        portraitBtn.layer.masksToBounds = true
        portraitBtn.frame = CGRECT(appIconLeftSpace, appIconTopSpace, appIconLength, appIconLength)
        portraitBtn.addTarget(self, action: #selector(SignupViewController.selectImage(_:)), for: UIControlEvents.touchUpInside)
        portraitBtn.addSubview(appIconImageView)
        self.view.addSubview(portraitBtn)
        //textInputView
        let textInputView: UIView = UIView(frame: CGRect(x: inputViewMargin, y: inputViewTopSpace, width: screenWidth - inputViewMargin * 2, height: textFieldHeight * CGFloat(textFieldLineCount) + 4))
        textInputView.layer.cornerRadius = 4
        textInputView.backgroundColor = UIColor.white
        
        //id
        id.frame = CGRect(x: textFieldLeftSpace, y: 0, width: textInputView.frame.width, height: textFieldHeight )
        id.font = inputViewFont
        id.placeholder = "邮箱／手机"
        id.returnKeyType = UIReturnKeyType.done
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
        authCode.returnKeyType = UIReturnKeyType.done
        textInputView.addSubview(authCode)
        let getAuthBtn = UIButton(frame: CGRect(x: textInputView.frame.width - getAuthCodeBtnW, y: textFieldHeight + 1, width: getAuthCodeBtnW, height: textFieldHeight))
        getAuthBtn.setTitle("获取验证码", for: UIControlState())
        getAuthBtn.setTitleColor(headerColor, for: UIControlState())
        getAuthBtn.titleLabel?.font = getAuthCodeBtnFont
        getAuthBtn.addTarget(self, action: #selector(SignupViewController.getAuthCode(_:)), for: UIControlEvents.touchUpInside)
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
        nick.returnKeyType = UIReturnKeyType.done
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
        password.isSecureTextEntry = true
        password.delegate = self
        password.returnKeyType = UIReturnKeyType.done
       
        self.view.addSubview(textInputView)
        
        //sign up Btn
        let signUpBtn: UIButton = UIButton(frame: CGRect(x: loginBtnMargin, y: textInputView.frame.origin.y + textInputView.frame.height + 20, width: screenWidth - 2 * loginBtnMargin, height: loginBtnHeight))
        signUpBtn.backgroundColor =  UIColor.clear
        let loginBtnBackgroundView = UIImageView(frame: CGRect(x: 0, y: 0, width: screenWidth - 2 * loginBtnMargin, height: loginBtnHeight))
        loginBtnBackgroundView.backgroundColor = UIColor.white
        loginBtnBackgroundView.alpha = 0.5
        signUpBtn.addSubview(loginBtnBackgroundView)
        signUpBtn.setTitle("注册", for: UIControlState())
        signUpBtn.titleLabel?.font = loginBtnFont
        signUpBtn.setTitleColor(UIColor.white, for: UIControlState())
        signUpBtn.layer.cornerRadius = 4
        signUpBtn.layer.masksToBounds = true
        signUpBtn.addTarget(self, action: #selector(SignupViewController.signUp(_:)), for: UIControlEvents.touchUpInside)

        self.view.addSubview(signUpBtn)
        
        //login btn
        let loginBtn: UIButton = UIButton(frame: CGRect(x: loginBtnMargin, y: signUpBtn.frame.origin.y + signUpBtn.frame.height + 10, width: screenWidth - 2 * loginBtnMargin, height: loginBtnHeight))
        loginBtn.backgroundColor =  UIColor.clear
        loginBtn.setTitle("登录", for: UIControlState())
        loginBtn.titleLabel?.font = loginBtnFont
        loginBtn.setTitleColor(UIColor.white, for: UIControlState())
        loginBtn.addTarget(self, action: #selector(SignupViewController.login(_:)), for: UIControlEvents.touchUpInside)
        self.view.addSubview(loginBtn)
        
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(SignupViewController.tapDismiss))
        self.view.addGestureRecognizer(tapGesture)
    }
    
    func tapDismiss(){
        self.view.endEditing(true)
    }
    
    func selectImage(_ sender: UIButton){
        present(imagePicker, animated: true, completion: nil)//4
        //MARK: Delegates
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        let chosenImage = info[UIImagePickerControllerOriginalImage] as! UIImage //2

        var selectedImage = UIImage()
        selectedImage = cropToSquare(image: chosenImage)
        
        let newSize = CGSize(width: 300, height: 300)
        UIGraphicsBeginImageContext(newSize)
        selectedImage.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        appIconImageView.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        dismiss(animated: true, completion: nil) //5
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        textField.resignFirstResponder()
        return true
    }
    func getAuthCode(_ sender: UIButton){
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
    
    func login(_ sender: UIButton){
        let storyboard = UIStoryboard(name: "Registeration", bundle: nil)
        let loginViewController = storyboard.instantiateViewController(withIdentifier: "Login")
        self.present(loginViewController, animated: true, completion: nil)
    }
    
    func signUp(_ sender: UIButton){
        if publicService.checkIsEmail(id.text!) {
            profileSet.set(id.text!, forKey: emailNSUserData)
            profileSet.removeObject(forKey: phoneNSUserData)
        }else if publicService.checkIsPhoneNumber(id.text!){
            profileSet.set(id.text!, forKey: phoneNSUserData)
            profileSet.removeObject(forKey: emailNSUserData)
        }
        let getAuthRequest = NSDictionary(objects: [id.text!, authCode.text!], forKeys: ["eMail" as NSCopying, "authCode" as NSCopying])
        
        if haalthyService.checkAuthCode(getAuthRequest) {
            profileSet.set(nick.text!, forKey: displaynameUserData)
            let selectedImageData: Data = UIImagePNGRepresentation(appIconImageView.image!)!
            portraitImgStr = selectedImageData.base64EncodedString(options: [])
            profileSet.set(portraitImgStr, forKey: imageNSUserData)
            keychainAccess.setPasscode(passwordKeyChain, passcode: password.text!)
            let result = haalthyService.addUser("AY")
            profileSet.set(userTypeUserData, forKey: "AY")
            if (result.count > 0) && (result.object(forKey: "result") as! Int) == 1 {
                keychainAccess.setPasscode(passwordKeyChain, passcode: password.text!)
                keychainAccess.setPasscode(usernameKeyChain, passcode: (result.object(forKey: "content") as! NSDictionary).object(forKey: "result") as! String)
//                if (profileSet.objectForKey(favTagsNSUserData) != nil) &&
//                    (profileSet.objectForKey(favTagsNSUserData) is NSArray){
//                        haalthyService.updateUserTag(profileSet.objectForKey(favTagsNSUserData) as! NSArray)
//                }
                self.performSegue(withIdentifier: "signUpQestionsSegue", sender: self)
            }else{
                keychainAccess.deletePasscode(passwordKeyChain)
                HudProgressManager.sharedInstance.showOnlyTextHudProgress(self, title: result.object(forKey: "resultDesp") as! String)
                HudProgressManager.sharedInstance.dismissHud()
            }
        }else{
            HudProgressManager.sharedInstance.showOnlyTextHudProgress(self, title: "验证码错误")
            HudProgressManager.sharedInstance.dismissHud()
        }
    }
}
