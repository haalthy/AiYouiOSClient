//
//  AddPatientStatusTableViewCell.swift
//  CancerSN
//
//  Created by lily on 8/25/15.
//  Copyright (c) 2015 lily. All rights reserved.
//

import UIKit

class AddPatientStatusTableViewCell: UITableViewCell {

    @IBOutlet weak var patientStatusName: UILabel!
    @IBOutlet weak var patientStatusDesc: UITextField!
    
    @IBOutlet weak var cancel: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
