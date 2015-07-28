//
//  GenderSettingViewController.swift
//  CancerSN
//
//  Created by lily on 7/23/15.
//  Copyright (c) 2015 lily. All rights reserved.
//

import UIKit

class GenderSettingViewController: UIViewController {
    
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
    }
    
    override func viewWillAppear(animated: Bool) {
         super.viewWillAppear(animated)
        self.navigationController?.navigationBar.hidden = false

    }
}
