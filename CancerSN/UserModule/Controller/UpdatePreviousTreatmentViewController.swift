//
//  UpdatePreviousTreatmentViewController.swift
//  CancerSN
//
//  Created by lily on 8/23/15.
//  Copyright (c) 2015 lily. All rights reserved.
//

import UIKit

class UpdatePreviousTreatmentViewController: UIViewController {
    
    var haalthyService = HaalthyService()
    var treatment = NSDictionary()
    @IBOutlet weak var dosage: UITextField!
    @IBOutlet weak var treatmentName: UILabel!
    @IBAction func continuePreviousTreatment(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func stopPreviousTreatment(sender: UIButton) {
        let updatedTreatment: NSMutableDictionary = treatment.mutableCopy() as! NSMutableDictionary
        updatedTreatment.setObject(Int(NSDate().timeIntervalSince1970)*1000, forKey: "endDate")
        haalthyService.updateTreatment(updatedTreatment)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        treatmentName.text = treatment.objectForKey("treatmentName") as? String
        dosage.text = treatment.objectForKey("dosage") as? String
        self.preferredContentSize = CGSizeMake(360, 350)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
