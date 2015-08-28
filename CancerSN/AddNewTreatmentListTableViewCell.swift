//
//  AddNewTreatmentListTableViewCell.swift
//  CancerSN
//
//  Created by lily on 8/23/15.
//  Copyright (c) 2015 lily. All rights reserved.
//

import UIKit

class AddNewTreatmentListTableViewCell: UITableViewCell {
    @IBOutlet weak var treatmentName: UILabel!
    @IBOutlet weak var dosageDescription: UITextField!
    
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
