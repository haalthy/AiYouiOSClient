//
//  SettingUsernameViewController.swift
//  CancerSN
//
//  Created by lily on 10/5/15.
//  Copyright (c) 2015 lily. All rights reserved.
//

import UIKit

protocol SettingUsernameVCDelegate{
    func updateDisplayname(displayname: String)
}

class SettingUsernameViewController: UIViewController, UITextFieldDelegate {
    var settingUsernameVCDelegate: SettingUsernameVCDelegate?
    @IBOutlet weak var displayname: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        displayname.delegate = self
        // Do any additional setup after loading the view.
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        settingUsernameVCDelegate?.updateDisplayname(displayname.text!)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        textField.resignFirstResponder()
        return true
    }
}
