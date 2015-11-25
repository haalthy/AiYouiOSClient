//
//  PatientStatusTableViewCell.swift
//  CancerSN
//
//  Created by lily on 9/4/15.
//  Copyright (c) 2015 lily. All rights reserved.
//

import UIKit

class PatientStatusTableViewCell: UITableViewCell {
    
    @IBOutlet weak var patientStatusDetail: UILabel!

    @IBOutlet weak var patientStatusDate: UILabel!
    
    var patientStatus=NSDictionary(){
        didSet{
            updateUI()
        }
    }
    
    func updateUI(){
        let insertedDate = NSDate(timeIntervalSince1970: (patientStatus.objectForKey("insertedDate") as! Double)/1000 as NSTimeInterval)
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yy/MM/dd" // superset of OP's format
        let insertedDateStr = dateFormatter.stringFromDate(insertedDate)
        patientStatusDate.text = insertedDateStr
        let patientStatusStr = (patientStatus.objectForKey("statusDesc") as! String)
        let clinicReportStr = (patientStatus.objectForKey("clinicReport") as! String)
        var patientsDetailStr = patientStatusStr + clinicReportStr
        patientsDetailStr = patientsDetailStr.stringByReplacingOccurrencesOfString("*", withString: " ")
        patientStatusDetail.text = patientsDetailStr as String
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
