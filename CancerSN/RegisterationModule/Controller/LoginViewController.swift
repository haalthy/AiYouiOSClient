//
//  LoginViewController.swift
//  CancerSN
//
//  Created by lily on 7/28/15.
//  Copyright (c) 2015 lily. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate, TencentSessionDelegate {
    
    //global variable
    var screenWidth: CGFloat = 0
    var screenHeight: CGFloat = 0

    var password = UITextField()
    var username = UITextField()
    
    let profileSet = NSUserDefaults.standardUserDefaults()
    var data:NSMutableData?  = nil
    var haalthyService = HaalthyService()
    var isRootViewController = true
    var tencentOAuth:TencentOAuth? = nil
    let keychainAccess = KeychainAccess()
    let getAccessToken = GetAccessToken()
    
    override func viewDidLoad() {
        initVariables()
        initContentView()
    }
    
    func initVariables(){
        screenWidth = UIScreen.mainScreen().bounds.width
        screenHeight = UIScreen.mainScreen().bounds.height
    }
    
    func initContentView(){
        let btnMargin: CGFloat = 15
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
        let textInputView: UIView = UIView(frame: CGRect(x: inputViewMargin, y: inputViewTopSpace, width: screenWidth - inputViewMargin * 2, height: inputViewHeight))
        textInputView.layer.cornerRadius = 4
        textInputView.backgroundColor = UIColor.whiteColor()
        username.frame = CGRect(x: 15, y: 0, width: textInputView.frame.width, height: textInputView.frame.height/2 )
        username.font = inputViewFont
        username.placeholder = "邮箱／手机"
        username.delegate = self
        textInputView.addSubview(username)
        password.frame = CGRect(x: 15, y: textInputView.frame.height/2, width: textInputView.frame.width, height: textInputView.frame.height/2)
        password.font = inputViewFont
        password.placeholder = "密码"
        password.secureTextEntry = true
        password.delegate = self
        textInputView.addSubview(password)
        let seperateLine: UIView = UIView(frame: CGRect(x: 0, y: textInputView.frame.height/2, width: textInputView.frame.width, height: 0.5))
        seperateLine.backgroundColor = seperateLineColor
        textInputView.addSubview(seperateLine)
        self.view.addSubview(textInputView)
        
        //loginBtn
        let loginBtn: UIButton = UIButton(frame: CGRect(x: loginBtnMargin, y: loginBtnTopSpace, width: screenWidth - 2 * loginBtnMargin, height: loginBtnHeight))
        loginBtn.backgroundColor =  UIColor.clearColor()
        let loginBtnBackgroundView = UIImageView(frame: CGRect(x: 0, y: 0, width: screenWidth - 2 * loginBtnMargin, height: loginBtnHeight))
        loginBtnBackgroundView.backgroundColor = UIColor.whiteColor()
        loginBtnBackgroundView.alpha = 0.5
        loginBtn.addSubview(loginBtnBackgroundView)
        loginBtn.setTitle("登录", forState: UIControlState.Normal)
        loginBtn.titleLabel?.font = loginBtnFont
        loginBtn.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        loginBtn.layer.cornerRadius = 4
        loginBtn.layer.masksToBounds = true
        loginBtn.addTarget(self, action: "login:", forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(loginBtn)
        
        //registerationBtn
        let registerationBtn = UIButton(frame: CGRect(x: registerationBtnLeftSpace, y: registerationBtnTopSpace - btnMargin, width: registerationBtnWidth, height: registerationBtnHeight + btnMargin * 2))
        registerationBtn.backgroundColor = UIColor.clearColor()
        registerationBtn.setTitle("注册账号", forState: UIControlState.Normal)
        registerationBtn.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        registerationBtn.titleLabel?.font = registerationBtnFont
        registerationBtn.addTarget(self, action: "signUp:", forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(registerationBtn)
        
        //forget password Btn
        let forgetPwdBtn = UIButton(frame: CGRect(x: screenWidth - forgetBtnWidth - forgetBtnRightSpace, y: forgetBtnTopSpace -  btnMargin, width: registerationBtnWidth, height: registerationBtnHeight + btnMargin * 2))
        forgetPwdBtn.backgroundColor = UIColor.clearColor()
        forgetPwdBtn.setTitle("忘记密码", forState: UIControlState.Normal)
        forgetPwdBtn.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        forgetPwdBtn.titleLabel?.font = forgetBtnFont
        forgetPwdBtn.addTarget(self, action: "resetPassword", forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(forgetPwdBtn)
        
        //seperate Line
        let seperateLineTopSpace = forgetPwdBtn.frame.origin.y + forgetPwdBtn.frame.height + (screenHeight - (forgetPwdBtn.frame.origin.y + forgetPwdBtn.frame.height) - lookaroundBtnBtmSpace - lookaroundBtnHeight - otherLoginBtnLength - otherLoginBtnTopSpace) / 2
        let seperateLineWithOtherLogin = UIImageView(frame: CGRect(x: (screenWidth - seperateLineWidth)/2, y: seperateLineTopSpace, width: seperateLineWidth, height: 1))
        seperateLineWithOtherLogin.image = UIImage(named: "img_seperateLine")
        self.view.addSubview(seperateLineWithOtherLogin)
        
        //wechat Login
        let wechatLoginBtnLeftSpace: CGFloat = (screenWidth - (otherLoginBtnLength * 2 + otherLoginBtnSpace)) / 2
        let wechatLoginBtn = UIButton(frame: CGRect(x: wechatLoginBtnLeftSpace, y: seperateLineTopSpace + otherLoginBtnTopSpace, width: otherLoginBtnLength, height: otherLoginBtnLength))
        wechatLoginBtn.layer.cornerRadius = otherLoginBtnLength/2
        wechatLoginBtn.layer.masksToBounds = true
        let wechatLoginImgView = UIImageView(frame: CGRect(x: 0, y: 0, width: otherLoginBtnLength, height: otherLoginBtnLength))
        wechatLoginImgView.image = UIImage(named: "btn_wechat")
        wechatLoginBtn.addSubview(wechatLoginImgView)
        wechatLoginBtn.addTarget(self, action: "loginViaWechat:", forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(wechatLoginBtn)
        
        //qq Login
        let qqLoginBtnRgithSpace = wechatLoginBtnLeftSpace
        let qqLoginBtn = UIButton(frame: CGRect(x: screenWidth - qqLoginBtnRgithSpace - otherLoginBtnLength, y: seperateLineTopSpace + otherLoginBtnTopSpace, width: otherLoginBtnLength, height: otherLoginBtnLength))
        qqLoginBtn.layer.cornerRadius = otherLoginBtnLength/2
        wechatLoginBtn.layer.masksToBounds = true
        let qqLoginImgView = UIImageView(frame: CGRect(x: 0, y: 0, width: otherLoginBtnLength, height: otherLoginBtnLength))
        qqLoginImgView.image = UIImage(named: "btn_qq")
        qqLoginBtn.addSubview(qqLoginImgView)
        qqLoginBtn.addTarget(self, action: "loginViaQQ:", forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(qqLoginBtn)
        
        //look around
        
        let lookaroundBtn = UIButton(frame: CGRect(x: (screenWidth - lookaroundBtnWidth)/2, y: screenHeight - lookaroundBtnBtmSpace - lookaroundBtnHeight - btnMargin, width: lookaroundBtnWidth, height: lookaroundBtnHeight + btnMargin * 2))
        lookaroundBtn.backgroundColor = UIColor.clearColor()
        lookaroundBtn.setTitle("随便逛逛看最新的治疗方案", forState: UIControlState.Normal)
        lookaroundBtn.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        lookaroundBtn.titleLabel?.font = lookaroundBtnFont
        lookaroundBtn.addTarget(self, action: "ignore:", forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(lookaroundBtn)
        
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "tapDismiss")
        self.view.addGestureRecognizer(tapGesture)
    }
    
    func tapDismiss(){
        self.view.endEditing(true)
    }
    
    func resetPassword(){
        self.performSegueWithIdentifier("resetPwdSegue", sender: self)
    }
    
    @IBAction func loginViaQQ(sender: UIButton) {
        self.tencentOAuth = TencentOAuth(appId: qqAppID, andDelegate: self)
        let permissions = [kOPEN_PERMISSION_GET_INFO,kOPEN_PERMISSION_GET_USER_INFO,kOPEN_PERMISSION_GET_SIMPLE_USER_INFO]
        tencentOAuth!.authorize(permissions, inSafari: false)
    }
    
    @IBAction func loginViaWechat(sender: UIButton) {
//        SendAuthReq* req =[[[SendAuthReq alloc ] init ] autorelease ];
//        req.scope = @"snsapi_userinfo" ;
//        req.state = @"123" ;
        //第三方向微信终端发送一个SendAuthReq消息结构
//        [WXApi sendReq:req];
        
        let req: SendAuthReq = SendAuthReq()
        req.scope = "snsapi_userinfo"
        req.state = "123"
        WXApi.sendReq(req)
    }
    
    func signUp(sender: UIButton) {
        profileSet.setObject(aiyouUserType, forKey: userTypeUserData)
        self.performSegueWithIdentifier("signUpQestionsSegue", sender: self)
    }
    
    func tencentDidLogin(){
        tencentOAuth!.getUserInfo()
    }
    
    func tencentDidNotLogin(cancelled: Bool) {
        print("登录失败了")
    }
    
    //无网络
    func tencentDidNotNetWork() {
        print("没有网络")
    }
    
    func getQQImage(urlPath: String){
        NSURLSession.sharedSession().dataTaskWithURL(NSURL(string: urlPath)!, completionHandler: {(data, response, error) -> Void in
            // 返回任务结果
            if (error == nil) && (data != nil) {
                let imageDataStr = data!.base64EncodedStringWithOptions([])
                
                self.profileSet.setObject(imageDataStr, forKey: imageNSUserData)
            }
        }).resume()
    }
    
    func getUserInfoResponse(response: APIResponse!) {
        let openId = tencentOAuth!.openId
        let resp: NSDictionary = response.jsonResponse
        
        print(resp.objectForKey("nickname"))
        print(resp.objectForKey("figureurl_2"))
        keychainAccess.setPasscode(usernameKeyChain, passcode: openId)
        keychainAccess.setPasscode(passwordKeyChain, passcode: openId)
        getAccessToken.getAccessToken()
        if profileSet.objectForKey(accessNSUserData) == nil {
            profileSet.setObject("", forKey: emailNSUserData)
            getQQImage(resp.objectForKey("figureurl_2") as! String)
            profileSet.setObject(resp.objectForKey("nickname"), forKey: displaynameUserData)
            profileSet.setObject(qqUserType, forKey: userTypeUserData)
            let keychainAccess = KeychainAccess()
            keychainAccess.setPasscode(usernameKeyChain, passcode: openId)
            keychainAccess.setPasscode(passwordKeyChain, passcode: openId)
            self.performSegueWithIdentifier("signUpQestionsSegue", sender: self)
        }else{
            let tabViewController : TabViewController = TabViewController()
            self.presentViewController(tabViewController, animated: true, completion: nil)
        }
    }
    
    func userLogin(var usernameStr: String, passwordStr: String)->Bool{
        let publicService = PublicService()
        keychainAccess.setPasscode(usernameKeyChain, passcode: usernameStr)
        keychainAccess.setPasscode(passwordKeyChain, passcode: passwordStr)
        let hudProcessManager = HudProgressManager.sharedInstance
        hudProcessManager.showHudProgress(self, title: "登录中")
        if publicService.checkIsEmail(usernameStr) || publicService.checkIsPhoneNumber(usernameStr) {
            usernameStr = haalthyService.getUsername(usernameStr)
        }else{
            hudProcessManager.showOnlyTextHudProgress(self, title: "请输入正确的手机/邮箱")
            hudProcessManager.dismissHud()
            return false
        }
        if (usernameStr != "no user in database") && (usernameStr != ""){
            hudProcessManager.dismissHud()
            keychainAccess.setPasscode(usernameKeyChain, passcode: usernameStr)
            if NSUserDefaults.standardUserDefaults().objectForKey(kDeviceToken) != nil {
                let registrationID = NSUserDefaults.standardUserDefaults().objectForKey(kDeviceToken) as! String
                
                let paramtersDict: Dictionary<String, AnyObject> = ["userName" : usernameStr, "fromUserName" : registrationID]
                NetRequest.sharedInstance.POST(pushIdURL, parameters: paramtersDict, success: { (content, message) -> Void in
                    
                    }, failed: { (content, message) -> Void in
                        
                })
            }
            return true
        }
        else{
            keychainAccess.deletePasscode(usernameKeyChain)
            keychainAccess.deletePasscode(passwordKeyChain)
            hudProcessManager.showOnlyTextHudProgress(self, title: "您的用户名或密码输错，请重新输入")
            hudProcessManager.dismissHud()
            return false
        }
    }
    
    private func checkIsUsername(str: String) -> Bool{
        do {
            // - 1、创建规则
            let pattern = "[A-Z][A-Z][0-9]{13}.[0-9]{3}"
            // - 2、创建正则表达式对象
            let regex = try NSRegularExpression(pattern: pattern, options: NSRegularExpressionOptions.CaseInsensitive)
            // - 3、开始匹配
            let res = regex.matchesInString(str, options: NSMatchingOptions(rawValue: 0), range: NSMakeRange(0, str.characters.count))
            
            if res.count>0{
                return true
            }else{
                return false
            }
        }
        catch {
            print(error)
            return false
        }
    }
    
    func login(sender: UIButton) {
        let usernameStr = username.text
        let passwordStr = password.text
        
        let loginSucessful = userLogin(usernameStr!, passwordStr: passwordStr!)
        if isRootViewController && loginSucessful{
            let tabViewController : TabViewController = TabViewController()
            self.presentViewController(tabViewController, animated: true, completion: nil)
        }else if loginSucessful{
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    func forgetPassword(sender: UIButton) {
        
    }
    
    func ignore(sender: UIButton) {
        let storyboard = UIStoryboard(name: "Registeration", bundle: nil)
        let controller = storyboard.instantiateViewControllerWithIdentifier("TagEntry") as! FeedTagsViewController
        controller.islookAround = true
//        controller.isFirstTagSelection = true
        self.presentViewController(controller, animated: true, completion: nil)
    }
    
    func cancel(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.navigationBar.hidden = true
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.navigationController?.navigationBar.hidden = false
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
