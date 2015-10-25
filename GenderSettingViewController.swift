//
//  GenderSettingViewController.swift
//  CancerSN
//
//  Created by lily on 7/23/15.
//  Copyright (c) 2015 lily. All rights reserved.
//

import UIKit

protocol GenderSettingVCDelegate{
    func updateGender(gender: String)
}

class GenderSettingViewController: UIViewController {
    var isUpdate = false
    var genderSettingVCDelegate: GenderSettingVCDelegate?
    @IBOutlet weak var skipBtn: UIButton!
    @IBOutlet weak var maleSelect: UIButton!
    @IBOutlet weak var femaleSelect: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBAction func SelectGender(sender: UIButton) {
        if isUpdate {
            genderSettingVCDelegate?.updateGender(genderMapping.objectForKey((sender.titleLabel?.text)!) as! String)
            self.dismissViewControllerAnimated(true, completion: nil)
        }else{
            let profileSet = NSUserDefaults.standardUserDefaults()
        profileSet.setObject(genderMapping.objectForKey((sender.titleLabel?.text)!), forKey: genderNSUserData)
            self.performSegueWithIdentifier("selectAgeSegue", sender: self)
        }
    }
    @IBAction func skip(sender: UIButton) {
        self.performSegueWithIdentifier("selectAgeSegue", sender: self)
    }
    
    override func viewDidLoad() {
        if isUpdate {
            titleLabel.hidden = true
        }
        super.viewDidLoad()
        maleSelect.titleLabel?.text = "男"
        femaleSelect.titleLabel?.text = "女"

        maleSelect.layer.borderColor = textColor.CGColor
        maleSelect.layer.borderWidth = 2.0
        maleSelect.layer.cornerRadius = 5
        maleSelect.layer.masksToBounds = true
        maleSelect.backgroundColor = UIColor.whiteColor()
        maleSelect.titleLabel?.textColor = textColor
        
        femaleSelect.layer.borderColor = textColor.CGColor
        femaleSelect.layer.borderWidth = 2.0
        femaleSelect.layer.cornerRadius = 5
        femaleSelect.layer.masksToBounds = true
        femaleSelect.backgroundColor = UIColor.whiteColor()
        femaleSelect.titleLabel?.textColor = textColor
        
//            skip.layer.cornerRadius = 5
//        skip.layer.masksToBounds = true
//        skip.backgroundColor = textColor
        skipBtn.titleLabel?.textColor = UIColor.whiteColor()
        if isUpdate{
            skipBtn.hidden = true
        }
    }
    
    override func viewWillAppear(animated: Bool) {
         super.viewWillAppear(animated)
        self.navigationController?.navigationBar.hidden = false

    }
}
