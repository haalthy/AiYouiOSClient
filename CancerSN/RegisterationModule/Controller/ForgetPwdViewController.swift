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
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = false
    }
    
    func initContentView(){
        //textInputView
        let textInputView: UIView = UIView(frame: CGRect(x: 0, y: headerHeight, width: screenWidth, height: textFieldHeight * CGFloat(textFieldLineCount) + 4))
        textInputView.layer.cornerRadius = 4
        textInputView.backgroundColor = UIColor.white
        
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
        getAuthBtn.setTitle("获取验证码", for: UIControlState())
        getAuthBtn.setTitleColor(headerColor, for: UIControlState())
        getAuthBtn.titleLabel?.font = getAuthCodeBtnFont
        getAuthBtn.addTarget(self, action: #selector(ForgetPwdViewController.getAuthCode(_:)), for: UIControlEvents.touchUpInside)
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
        password.isSecureTextEntry = true
        let seperateLine3 = UIView(frame: CGRect(x: 0, y: (textFieldHeight + 1)*3 - 1, width: textInputView.frame.width, height: 1))
        seperateLine3.backgroundColor = seperateLineColor
        textInputView.addSubview(seperateLine3)
        textInputView.addSubview(password)
        
        //password
        reenterpassword.frame = CGRect(x: textFieldLeftSpace, y: (textFieldHeight + 1)*3, width: textInputView.frame.width, height: textFieldHeight)
        reenterpassword.font = inputViewFont
        reenterpassword.placeholder = "请再次输入密码"
        reenterpassword.delegate = self
        reenterpassword.isSecureTextEntry = true
        textInputView.addSubview(reenterpassword)
        let seperateLine4 = UIView(frame: CGRect(x: 0, y: (textFieldHeight + 1)*4 - 1, width: textInputView.frame.width, height: 1))
        seperateLine4.backgroundColor = seperateLineColor
        textInputView.addSubview(seperateLine4)
        self.view.addSubview(textInputView)
        
        //sign up Btn
        let signUpBtn: UIButton = UIButton(frame: CGRect(x: loginBtnMargin, y: textInputView.frame.origin.y + textInputView.frame.height + 20, width: screenWidth - 2 * loginBtnMargin, height: loginBtnHeight))
        signUpBtn.backgroundColor =  headerColor
        signUpBtn.setTitle("重置密码", for: UIControlState())
        signUpBtn.titleLabel?.font = loginBtnFont
        signUpBtn.setTitleColor(UIColor.white, for: UIControlState())
        signUpBtn.layer.cornerRadius = 4
        signUpBtn.layer.masksToBounds = true
        signUpBtn.addTarget(self, action: #selector(ForgetPwdViewController.resetPassword(_:)), for: UIControlEvents.touchUpInside)
        self.view.addSubview(signUpBtn)
    }
    
    func getAuthCode(_ sender: UIButton){
        HudProgressManager.sharedInstance.dismissHud()
        HudProgressManager.sharedInstance.showOnlyTextHudProgress(self, title: "正在发送验证码")
        let idStr: String = id.text!
        if haalthyService.getAuthCode(idStr) == false {
            HudProgressManager.sharedInstance.showOnlyTextHudProgress(self, title: "发送失败，稍后再试")
        }
        HudProgressManager.sharedInstance.dismissHud()

    }

    func resetPassword(_ sender: UIButton){
        if password.text != reenterpassword.text {
            let alert = UIAlertController(title: "提示", message: "密码输入不一致，请重新输入", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "确定", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }else{
            let passwordStr: String = publicService.passwordEncode(password.text!)
            let resetPwdRequest = NSDictionary(objects: [passwordStr, id.text!, authCode.text!], forKeys: ["password" as NSCopying, "id" as NSCopying, "authCode" as NSCopying])
            if haalthyService.resetPasswordWithCode(resetPwdRequest) {
                HudProgressManager.sharedInstance.showOnlyTextHudProgress(self, title: "密码重置成功，请重新登录！")
            }else{
                HudProgressManager.sharedInstance.showOnlyTextHudProgress(self, title: "密码重置失败，稍后再试！")

            }
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        textField.resignFirstResponder()
        return true
    }
}
