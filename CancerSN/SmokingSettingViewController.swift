//
//  SmokingSettingViewController.swift
//  CancerSN
//
//  Created by lily on 7/26/15.
//  Copyright (c) 2015 lily. All rights reserved.
//

import UIKit
protocol SmokingSettingVCDelegate{
    func updateSmoking(isSmoking: Int)
}
class SmokingSettingViewController: UIViewController{

    var isUpdate = false
    var smokingSettingVCDelegate: SmokingSettingVCDelegate?
    @IBOutlet weak var isSmoking: UIButton!
    @IBOutlet weak var noSmoking: UIButton!
    @IBOutlet weak var skipBtn: UIButton!
    
    @IBAction func skip(sender: UIButton) {
        self.performSegueWithIdentifier("selectMetastasisSegue", sender: self)
    }
    
    @IBAction func selectSmoking(sender: UIButton) {
        var selectedSmoking = smokingMapping.objectForKey((sender.titleLabel?.text)!)
        if isUpdate{
            smokingSettingVCDelegate?.updateSmoking(selectedSmoking as! Int)
            self.dismissViewControllerAnimated(true, completion: nil)
        }else{
            let profileSet = NSUserDefaults.standardUserDefaults()
            profileSet.setObject(selectedSmoking, forKey: smokingNSUserData)
            self.performSegueWithIdentifier("selectMetastasisSegue", sender: self)
        }
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
        if isUpdate{
            skipBtn.hidden = true
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
