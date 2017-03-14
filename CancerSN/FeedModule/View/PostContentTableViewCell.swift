//
//  PostContentTableViewCell.swift
//  CancerSN
//
//  Created by lily on 8/2/15.
//  Copyright (c) 2015 lily. All rights reserved.
//

import UIKit

class PostContentTableViewCell: UITableViewCell {
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var userPortrait: UIImageView!
    
    var postContent = UILabel()
    
    @IBOutlet weak var countComments: UILabel!
    @IBOutlet weak var userProfile: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var tagsLabel: UILabel!
    
    @IBOutlet weak var type: UILabel!
    var post: NSDictionary = NSDictionary(){
        didSet{
            updateUI()
        }
    }
    
    func updateUI(){
        username.text = post.object(forKey: "insertUsername") as? String
        if (post.object(forKey: "type") as! Int) != 1{
            postContent.text = post.object(forKey: "body") as? String
        }else{
            postContent.text = nil
            let treatmentStr = post.object(forKey: "body") as! String
            let treatmentList: NSMutableArray = NSMutableArray(array: treatmentStr.components(separatedBy: "**"))
            for treatment in treatmentList {
                var treatmentItemStr:String = treatment as! String
                
                treatmentItemStr = treatmentItemStr.replacingOccurrences(of: "*", with: "", options:  NSString.CompareOptions.literal, range: nil)
                if (treatmentItemStr as NSString).length == 0{
                    treatmentList.remove(treatment)
                }
            }
            var treatmentY:CGFloat = 0
            for treatment in treatmentList {
                var treatmentItemStr:String = treatment as! String
                
                if (treatmentItemStr as NSString).length == 0{
                    break
                }
                if treatmentItemStr.substring(with: (treatmentItemStr.startIndex ..< treatmentItemStr.characters.index(treatmentItemStr.startIndex, offsetBy: 1))) == "*" {
                    treatmentItemStr = treatmentItemStr.substring(from: treatmentStr.characters.index(treatmentStr.startIndex, offsetBy: 1))
                }
                let treatmentNameAndDosage = treatmentItemStr.components(separatedBy: "*")
                let treatmentName = treatmentNameAndDosage[0] as! String
                var treatmentDosage = String()
                var treatmentNameLabel = UILabel()
                let dosageLabel = UILabel()
                treatmentNameLabel = UILabel(frame: CGRect(x: 0.0, y: treatmentY, width: 90.0, height: 28.0))
                treatmentNameLabel.text = treatmentName
                treatmentNameLabel.font = UIFont(name: "Helvetica-Bold", size: 13.0)
                treatmentNameLabel.layer.cornerRadius = 5
                treatmentNameLabel.backgroundColor = tabBarColor
                treatmentNameLabel.textColor = mainColor
                treatmentNameLabel.layer.masksToBounds = true
                treatmentNameLabel.layer.borderColor = mainColor.cgColor
                treatmentNameLabel.layer.borderWidth = 1.0
                treatmentNameLabel.textAlignment = NSTextAlignment.center
                if treatmentNameAndDosage.count > 1{
                    treatmentDosage = treatmentNameAndDosage[1] as! String
                    dosageLabel.frame = CGRect(x: 100.0, y: treatmentY+5, width: postContent.frame.width - 105, height: 0)
                    dosageLabel.text = treatmentDosage
                    dosageLabel.font = UIFont(name: "Helvetica-Bold", size: 12.0)
                    dosageLabel.numberOfLines = 0
                    dosageLabel.sizeToFit()
                    let height:CGFloat = dosageLabel.frame.height > treatmentNameLabel.frame.height ? dosageLabel.frame.height : treatmentNameLabel.frame.height
                    treatmentY += height + 5
                    dosageLabel.textColor = mainColor
                }else{
                    treatmentY += 30
                }
                postContent.addSubview(treatmentNameLabel)
                postContent.addSubview(dosageLabel)
            }
            postContent.frame = CGRect(x: 10, y: 80, width: UIScreen.main.bounds.width - 20, height: treatmentY)
            self.addSubview(postContent)
        }
        countComments.text = (post.object(forKey: "countComments") as! NSNumber).stringValue + " reviews"
        if ((post.object(forKey: "image") is NSNull) == false && (post.object(forKey: "image") != nil)){
            let dataString = post.value(forKey: "image") as! String
            userPortrait.image = UIImage(data: Data(base64Encoded: dataString, options: NSData.Base64DecodingOptions(rawValue: 0))!)
        }
        userProfile.text = post.value(forKey: "patientProfile") as? String
        //feed type view
        var typeStr = String()
        if (post.object(forKey: "type") != nil) && (post.object(forKey: "type") is NSNull) == false{
            if (post.object(forKey: "type") as!Int) == 0{
                if (post.object(forKey: "isBroadcast") as! Int) == 1 {
                    typeStr = "提出新问题"
                }else{
                    typeStr = "分享心情"
                }
            }
            if (post.object(forKey: "type") as! Int) == 1{
                typeStr = "添加治疗方案"
            }
            if (post.object(forKey: "type") as! Int) == 2{
                typeStr = "更新病友状态"
            }
        }
        type.text = typeStr
        if (post.object(forKey: "tags") is NSNull) == false{
            tagsLabel.text = "tag:" + (post.object(forKey: "tags") as! NSString).replacingOccurrences(of: "*", with: " ")
        }else{
            tagsLabel.text = ""
        }
        
        //insert date View
        let dateFormatter = DateFormatter()
        let insertedDate = Foundation.Date(timeIntervalSince1970: (post.value(forKey: "dateInserted") as! Double)/1000 as TimeInterval)
        dateFormatter.dateFormat = "yyyy-MM-dd" // superset of OP's format
        let insertedDayStr = dateFormatter.string(from: insertedDate)
        let currentDayStr = dateFormatter.string(from: Foundation.Date())
        if(currentDayStr > insertedDayStr){
            dateFormatter.dateFormat = "MM-dd"
            date.text = dateFormatter.string(from: insertedDate)
        }else{
            dateFormatter.dateFormat = "HH:mm"
            date.text = dateFormatter.string(from: insertedDate)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
