//
//  GenderSettingViewController.swift
//  CancerSN
//
//  Created by lily on 7/23/15.
//  Copyright (c) 2015 lily. All rights reserved.
//

import UIKit

class GenderSettingViewController: UIViewController {
    
    @IBOutlet weak var skip: UIButton!
    @IBOutlet weak var maleSelect: UIButton!
    @IBOutlet weak var femaleSelect: UIButton!
    @IBAction func SelectGender(sender: UIButton) {
        let profileSet = NSUserDefaults.standardUserDefaults()
        profileSet.setObject(genderMapping.objectForKey((sender.titleLabel?.text)!), forKey: genderNSUserData)
    }
    
    override func viewDidLoad() {
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
        
            skip.layer.cornerRadius = 5
        skip.layer.masksToBounds = true
        skip.backgroundColor = textColor
        skip.titleLabel?.textColor = UIColor.whiteColor()
    }
    
    override func viewWillAppear(animated: Bool) {
         super.viewWillAppear(animated)
        self.navigationController?.navigationBar.hidden = false

    }
}
