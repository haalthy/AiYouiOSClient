//
//  UpdatePasswordViewController.swift
//  CancerSN
//
//  Created by lily on 2/10/16.
//  Copyright © 2016 lily. All rights reserved.
//

import UIKit

class UpdatePasswordViewController: UIViewController, UITextFieldDelegate {
    
    let textFieldHeight: CGFloat = 44
    let textFieldLineCount: Int = 2
    let textFieldLeftSpace: CGFloat = 15
    let getAuthCodeBtnW: CGFloat = 94
    var headerHeight: CGFloat = 0
    
    let password = UITextField()
    let reenterpassword = UITextField()
    
    let haalthyService = HaalthyService()
    let publicService = PublicService()
    let keychainAccess = KeychainAccess()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        headerHeight = UIApplication.shared.statusBarFrame.height + (self.navigationController?.navigationBar.frame.height)!
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
        let textInputView: UIView = UIView(frame: CGRect(x: 0, y: headerHeight, width: screenWidth, height: textFieldHeight * CGFloat(textFieldLineCount) + 2))
        textInputView.layer.cornerRadius = 4
        textInputView.backgroundColor = UIColor.white
        
        //pwd
        password.frame = CGRect(x: textFieldLeftSpace, y: 0, width: textInputView.frame.width, height: textFieldHeight )
        password.font = inputViewFont
        password.placeholder = "密码"
        password.delegate = self
        let seperateLine3 = UIView(frame: CGRect(x: 0, y: textFieldHeight + 1, width: textInputView.frame.width, height: 1))
        seperateLine3.backgroundColor = seperateLineColor
        textInputView.addSubview(seperateLine3)
        textInputView.addSubview(password)
        
        //password
        reenterpassword.frame = CGRect(x: textFieldLeftSpace, y: textFieldHeight + 1, width: textInputView.frame.width, height: textFieldHeight)
        reenterpassword.font = inputViewFont
        reenterpassword.placeholder = "请再次输入密码"
        reenterpassword.delegate = self
        textInputView.addSubview(reenterpassword)
        let seperateLine4 = UIView(frame: CGRect(x: 0, y: (textFieldHeight + 1)*2 - 1, width: textInputView.frame.width, height: 1))
        seperateLine4.backgroundColor = seperateLineColor
        textInputView.addSubview(seperateLine4)
        self.view.addSubview(textInputView)
        
    }
    
    @IBAction func resetPassword(_ sender: UIButton){
        if password.text != reenterpassword.text {
            let alert = UIAlertController(title: "提示", message: "密码输入不一致，请重新输入", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "确定", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }else{
            let passwordStr: String = publicService.passwordEncode(password.text!)

            if haalthyService.resetPassword(passwordStr) {
                print("密码重置成功！")
                keychainAccess.setPasscode(passwordKeyChain, passcode: password.text!)
            }else{
                print("密码重置失败，请稍候再试！")
            }
            //            self.dismissViewControllerAnimated(true, completion: nil)
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        textField.resignFirstResponder()
        return true
    }

}
