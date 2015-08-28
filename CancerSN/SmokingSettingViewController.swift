//
//  SmokingSettingViewController.swift
//  CancerSN
//
//  Created by lily on 7/26/15.
//  Copyright (c) 2015 lily. All rights reserved.
//

import UIKit

class SmokingSettingViewController: UIViewController{

    @IBOutlet weak var isSmoking: UIButton!
    @IBOutlet weak var noSmoking: UIButton!
    @IBOutlet weak var skipBtn: UIButton!
    
    @IBAction func selectSmoking(sender: UIButton) {
        let profileSet = NSUserDefaults.standardUserDefaults()
        var selectedSmoking = smokingMapping.objectForKey((sender.titleLabel?.text)!)
        profileSet.setObject(selectedSmoking, forKey: smokingNSUserData)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        isSmoking.setTitle("是", forState: .Normal)
        noSmoking.setTitle("否", forState: .Normal)
        skipBtn.layer.cornerRadius = 5
        skipBtn.layer.masksToBounds = true
        
        isSmoking.titleLabel?.textColor = textColor
        isSmoking.layer.cornerRadius = 5
        isSmoking.layer.backgroundColor = UIColor.whiteColor().CGColor
        isSmoking.layer.borderColor = textColor.CGColor
        isSmoking.layer.borderWidth = 2.0
        
        noSmoking.titleLabel?.textColor = textColor
        noSmoking.layer.cornerRadius = 5
        noSmoking.layer.backgroundColor = UIColor.whiteColor().CGColor
        noSmoking.layer.borderColor = textColor.CGColor
        noSmoking.layer.borderWidth = 2.0
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
