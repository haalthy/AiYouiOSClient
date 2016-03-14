//
//  ForgetPwdViewController.swift
//  CancerSN
//
//  Created by hui luo on 4/2/2016.
//  Copyright © 2016 lily. All rights reserved.
//

import UIKit

class ForgetPwdViewController: UIViewController, UITextFieldDelegate{

    let textFieldHeight: CGFloat = 44
    let textFieldLineCount: Int = 4
    let textFieldLeftSpace: CGFloat = 15
    let getAuthCodeBtnW: CGFloat = 94
    var headerHeight: CGFloat = 0
    
    let id = UITextField()
    let authCode = UITextField()
    let password = UITextField()
    let reenterpassword = UITextField()
    
    let haalthyService = HaalthyService()
    let publicService = PublicService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        headerHeight = 66
        initContentView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.navigationBar.hidden = false
    }
    
    func initContentView(){
        //textInputView
        let textInputView: UIView = UIView(frame: CGRect(x: 0, y: headerHeight, width: screenWidth, height: textFieldHeight * CGFloat(textFieldLineCount) + 4))
        textInputView.layer.cornerRadius = 4
        textInputView.backgroundColor = UIColor.whiteColor()
        
        //id
        id.frame = CGRect(x: textFieldLeftSpace, y: 0, width: textInputView.frame.width, height: textFieldHeight )
        id.font = inputViewFont
        id.placeholder = "邮箱／手机"
        id.delegate = self
        let seperateLine1 = UIView(frame: CGRect(x: 0, y: textFieldHeight, width: textInputView.frame.width, height: 1))
        seperateLine1.backgroundColor = seperateLineColor
        textInputView.addSubview(seperateLine1)
        textInputView.addSubview(id)
        
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
        
        //pwd
        password.frame = CGRect(x: textFieldLeftSpace, y: (textFieldHeight + 1)*2, width: textInputView.frame.width, height: textFieldHeight )
        password.font = inputViewFont
        password.placeholder = "密码"
        password.delegate = self
        password.secureTextEntry = true
        let seperateLine3 = UIView(frame: CGRect(x: 0, y: (textFieldHeight + 1)*3 - 1, width: textInputView.frame.width, height: 1))
        seperateLine3.backgroundColor = seperateLineColor
        textInputView.addSubview(seperateLine3)
        textInputView.addSubview(password)
        
        //password
        reenterpassword.frame = CGRect(x: textFieldLeftSpace, y: (textFieldHeight + 1)*3, width: textInputView.frame.width, height: textFieldHeight)
        reenterpassword.font = inputViewFont
        reenterpassword.placeholder = "请再次输入密码"
        reenterpassword.delegate = self
        reenterpassword.secureTextEntry = true
        textInputView.addSubview(reenterpassword)
        let seperateLine4 = UIView(frame: CGRect(x: 0, y: (textFieldHeight + 1)*4 - 1, width: textInputView.frame.width, height: 1))
        seperateLine4.backgroundColor = seperateLineColor
        textInputView.addSubview(seperateLine4)
        self.view.addSubview(textInputView)
        
        //sign up Btn
        let signUpBtn: UIButton = UIButton(frame: CGRect(x: loginBtnMargin, y: textInputView.frame.origin.y + textInputView.frame.height + 20, width: screenWidth - 2 * loginBtnMargin, height: loginBtnHeight))
        signUpBtn.backgroundColor =  headerColor
        signUpBtn.setTitle("重置密码", forState: UIControlState.Normal)
        signUpBtn.titleLabel?.font = loginBtnFont
        signUpBtn.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        signUpBtn.layer.cornerRadius = 4
        signUpBtn.layer.masksToBounds = true
        signUpBtn.addTarget(self, action: "resetPassword:", forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(signUpBtn)
    }
    
    func getAuthCode(sender: UIButton){
        HudProgressManager.sharedInstance.dismissHud()
        HudProgressManager.sharedInstance.showOnlyTextHudProgress(self, title: "正在发送验证码")
        let idStr: String = id.text!
        if haalthyService.getAuthCode(idStr) == false {
            HudProgressManager.sharedInstance.showOnlyTextHudProgress(self, title: "发送失败，稍后再试")
        }
        HudProgressManager.sharedInstance.dismissHud()

    }

    func resetPassword(sender: UIButton){
        if password.text != reenterpassword.text {
            let alert = UIAlertController(title: "提示", message: "密码输入不一致，请重新输入", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "确定", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }else{
            let passwordStr: String = publicService.passwordEncode(password.text!)
            let resetPwdRequest = NSDictionary(objects: [passwordStr, id.text!, authCode.text!], forKeys: ["password", "id", "authCode"])
            if haalthyService.resetPasswordWithCode(resetPwdRequest) {
                HudProgressManager.sharedInstance.showOnlyTextHudProgress(self, title: "密码重置成功，请重新登录！")
            }else{
                HudProgressManager.sharedInstance.showOnlyTextHudProgress(self, title: "密码重置失败，稍后再试！")

            }
            self.navigationController?.popViewControllerAnimated(true)
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool{
        textField.resignFirstResponder()
        return true
    }
}
