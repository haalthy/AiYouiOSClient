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
    
    @IBAction func selectSmoking(sender: UIButton) {
        let profileSet = NSUserDefaults.standardUserDefaults()
        var selectedSmoking = smokingMapping.objectForKey((sender.titleLabel?.text)!)
        profileSet.setObject(selectedSmoking, forKey: smokingNSUserData)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        isSmoking.setTitle("是", forState: .Normal)
        noSmoking.setTitle("否", forState: .Normal)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
