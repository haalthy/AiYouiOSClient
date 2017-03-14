//
//  FeedTableViewCell.swift
//  CancerSN
//
//  Created by lily on 10/2/15.
//  Copyright (c) 2015 lily. All rights reserved.
//

import UIKit

protocol ImageTapDelegate {
    func imageTap(_ username: String)
}

protocol FeedBodyDelegate{
    func setFeedBodyHeight(_ height: CGFloat, indexpath: IndexPath)
}

class FeedTableViewCell: UITableViewCell {

    var imageTapDelegate: ImageTapDelegate?
    var feedBodyDelegate: FeedBodyDelegate?
    var width: CGFloat = 0
    var indexPath: IndexPath?
    var imageCountPerLine:Int = 3
    var isDetail:Bool = false
    
    var feed = NSDictionary(){
        didSet{

            //imageView
            let imageView = UIImageView(frame: CGRect(x: 10, y: 10, width: 32, height: 32))
            if((feed.value(forKey: "image") != nil) && (feed.value(forKey: "image") is NSNull) == false){
                let dataString = feed.value(forKey: "image") as! String
                let imageData: Data = Data(base64Encoded: dataString, options: NSData.Base64DecodingOptions(rawValue: 0))!
                imageView.image = UIImage(data: imageData)
            }else{
                imageView.image = UIImage(named: "Mario.jpg")
            }
            let tapImage = UITapGestureRecognizer(target: self, action: #selector(FeedTableViewCell.imageTapHandler(_:)))
            imageView.isUserInteractionEnabled = true
            imageView.addGestureRecognizer(tapImage)
            
            //username View
            let usernameLabelView = UILabel(frame: CGRect(x: 10 + 32 + 10, y: 10, width: self.width - 10 - 32 - 10 - 80, height: 20))
            usernameLabelView.font = UIFont(name: "Helvetica-Bold", size: 13.0)
            usernameLabelView.text = feed.value(forKey: "displayname") as? String
            
            //insert date View
            let insertDateLabelView = UILabel(frame: CGRect(x: self.width - 90, y: 10, width: 80, height: 20))
            insertDateLabelView.font = UIFont(name: "Helvetica", size: 12.0)
            let dateFormatter = DateFormatter()
            let insertedDate = Foundation.Date(timeIntervalSince1970: (feed.value(forKey: "dateInserted") as! Double)/1000 as TimeInterval)
            dateFormatter.dateFormat = "yyyy-MM-dd" // superset of OP's format
            let insertedDayStr = dateFormatter.string(from: insertedDate)
            let currentDayStr = dateFormatter.string(from: Foundation.Date())
            if(currentDayStr > insertedDayStr){
                dateFormatter.dateFormat = "MM-dd"
                insertDateLabelView.text = dateFormatter.string(from: insertedDate)
            }else{
                dateFormatter.dateFormat = "HH:mm"
                insertDateLabelView.text = dateFormatter.string(from: insertedDate)
            }
            insertDateLabelView.textAlignment = NSTextAlignment.right
            insertDateLabelView.textColor = UIColor.gray
            
            //
            
            //profile View
            let profileLabelView = UILabel(frame: CGRect(x: 10 + 32 + 10, y: 30, width: width - 10 - 32 - 10, height: 12))
            profileLabelView.font = UIFont(name: "Helvetica", size: 11.5)
            profileLabelView.text = feed.value(forKey: "patientProfile") as? String
            profileLabelView.textColor = UIColor.gray
            
            //feed type view
            var typeStr = String()
            if (feed.object(forKey: "type") != nil) && (feed.object(forKey: "type") is NSNull) == false{
                if (feed.object(forKey: "type") as!Int) == 0{
                    if (feed.object(forKey: "isBroadcast") as! Int) == 1 {
                        typeStr = "提出新问题"
                    }else{
                        typeStr = "分享心情"
                    }
                }
                if (feed.object(forKey: "type") as! Int) == 1{
                    typeStr = "添加治疗方案"
                }
                if (feed.object(forKey: "type") as! Int) == 2{
                    typeStr = "更新病友状态"
                }
            }
            let typeLabel = UILabel(frame: CGRect(x: 10, y: 50, width: 80, height: 25))
            typeLabel.text = typeStr
            typeLabel.backgroundColor = sectionHeaderColor
            typeLabel.font = UIFont(name: fontStr, size: 12.0)
            typeLabel.textAlignment = NSTextAlignment.center
            
            //feed body view
            let feedBody = UILabel(frame: CGRect(x: 10, y: 80, width: width - 20, height: 0))
            if (feed.object(forKey: "type") as! Int) != 1{
                feedBody.numberOfLines = 5
                if isDetail {
                    feedBody.numberOfLines = 0
                }
                feedBody.lineBreakMode = NSLineBreakMode.byCharWrapping
                feedBody.font = UIFont(name: "Helvetica", size: 13.0)
                feedBody.text = (feed.object(forKey: "body") as! String).replacingOccurrences(of: "*", with: " ", options: NSString.CompareOptions.literal, range: nil)
                feedBody.textColor = UIColor.black
                feedBody.sizeToFit()
            }else if (feed.object(forKey: "type") as! Int) == 1{
                let treatmentStr = feed.object(forKey: "body") as! String
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
                        dosageLabel.frame = CGRect(x: 100.0, y: treatmentY+5, width: feedBody.frame.width - 105, height: 0)
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
                    feedBody.addSubview(treatmentNameLabel)
                    feedBody.addSubview(dosageLabel)
                }
                feedBody.frame = CGRect(x: 10, y: 80, width: width - 20, height: treatmentY)
            }
            
            //postImage
            var feedBodyHeight: CGFloat = 0
            if (feed.value(forKey: "postImageList") != nil) && ((feed.value(forKey: "postImageList") is NSNull) == false) && ((feed.value(forKey: "postImageList") as! NSArray).count > 0){
                let postImageList = feed.value(forKey: "postImageList") as! NSArray
                var index:Int = 0
                let postSImageWidth:CGFloat = (width - 10)/3 - 10
                for postSImage in postImageList{
                    let postSImageX: CGFloat = 10 + CGFloat(index % imageCountPerLine)*CGFloat(postSImageWidth + 10)
                    let postSImageY = 5 + CGFloat(index/imageCountPerLine)*CGFloat(postSImageWidth + 5) + feedBody.frame.origin.y + feedBody.frame.height
                    let postSImageView = UIImageView(frame: CGRect(x: postSImageX, y: postSImageY, width: postSImageWidth, height: postSImageWidth))
                    if postSImage is String{
                        let dataString = postSImage as! String
                        let imageData: Data = Data(base64Encoded: dataString, options: NSData.Base64DecodingOptions(rawValue: 0))!
                        postSImageView.image = UIImage(data: imageData)
                    }else if postSImage is Data{
                        postSImageView.image = UIImage(data: postSImage as! Data)
                    }
                    self.addSubview(postSImageView)
                    index += 1
                }
                feedBodyHeight = feedBody.frame.height + postSImageWidth*CGFloat(postImageList.count/self.imageCountPerLine+1)
            }else{
                feedBodyHeight = feedBody.frame.height
            }
            feedBodyDelegate?.setFeedBodyHeight(feedBodyHeight, indexpath: indexPath!)
            
            //tagBody
            let tagLabel = UILabel(frame: CGRect(x: 10, y: 80 + feedBodyHeight + 10, width: width - 80, height: 20))
            
            if (feed.object(forKey: "tags") is NSNull) == false{
                tagLabel.font = UIFont(name: "Helvetica", size: 11.5)
                tagLabel.text = "tag:" + (feed.object(forKey: "tags") as! NSString).replacingOccurrences(of: "*", with: " ")
                tagLabel.textColor = UIColor.gray
                
            }
            //review View
            let reviewLabel = UILabel(frame: CGRect(x: 10 + tagLabel.frame.width, y: tagLabel.frame.origin.y, width: 60, height: 20))
            reviewLabel.font = UIFont(name: "Helvetica", size: 11.5)
            reviewLabel.textAlignment = NSTextAlignment.right
            reviewLabel.text = (feed.value(forKey: "countComments")! as AnyObject).stringValue + "评论"
            reviewLabel.textColor = UIColor.gray
            
            self.addSubview(imageView)
            self.addSubview(usernameLabelView)
            self.addSubview(insertDateLabelView)
            self.addSubview(profileLabelView)
            self.addSubview(feedBody)
            self.addSubview(tagLabel)
            self.addSubview(reviewLabel)
            self.addSubview(typeLabel)
        }
    }
    
    func imageTapHandler(_ sender: UITapGestureRecognizer){
        self.imageTapDelegate?.imageTap(feed["insertUsername"] as! String)
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
