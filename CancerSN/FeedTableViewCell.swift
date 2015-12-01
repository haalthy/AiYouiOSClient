//
//  FeedTableViewCell.swift
//  CancerSN
//
//  Created by lily on 10/2/15.
//  Copyright (c) 2015 lily. All rights reserved.
//

import UIKit

protocol ImageTapDelegate {
    func imageTap(username: String)
}

protocol FeedBodyDelegate{
    func setFeedBodyHeight(height: CGFloat, indexpath: NSIndexPath)
}

class FeedTableViewCell: UITableViewCell {

    var imageTapDelegate: ImageTapDelegate?
    var feedBodyDelegate: FeedBodyDelegate?
    var width: CGFloat = 0
    var indexPath: NSIndexPath?
    var imageCountPerLine:Int = 3
    var isDetail:Bool = false
    
    var feed = NSDictionary(){
        didSet{

            //imageView
            let imageView = UIImageView(frame: CGRectMake(10, 10, 32, 32))
            if((feed.valueForKey("image") != nil) && (feed.valueForKey("image") is NSNull) == false){
                let dataString = feed.valueForKey("image") as! String
                let imageData: NSData = NSData(base64EncodedString: dataString, options: NSDataBase64DecodingOptions(rawValue: 0))!
                imageView.image = UIImage(data: imageData)
            }else{
                imageView.image = UIImage(named: "Mario.jpg")
            }
            let tapImage = UITapGestureRecognizer(target: self, action: Selector("imageTapHandler:"))
            imageView.userInteractionEnabled = true
            imageView.addGestureRecognizer(tapImage)
            
            //username View
            let usernameLabelView = UILabel(frame: CGRectMake(10 + 32 + 10, 10, self.width - 10 - 32 - 10 - 80, 20))
            usernameLabelView.font = UIFont(name: "Helvetica-Bold", size: 13.0)
            usernameLabelView.text = feed.valueForKey("displayname") as? String
            
            //insert date View
            let insertDateLabelView = UILabel(frame: CGRectMake(self.width - 90, 10, 80, 20))
            insertDateLabelView.font = UIFont(name: "Helvetica", size: 12.0)
            let dateFormatter = NSDateFormatter()
            let insertedDate = NSDate(timeIntervalSince1970: (feed.valueForKey("dateInserted") as! Double)/1000 as NSTimeInterval)
            dateFormatter.dateFormat = "yyyy-MM-dd" // superset of OP's format
            let insertedDayStr = dateFormatter.stringFromDate(insertedDate)
            let currentDayStr = dateFormatter.stringFromDate(NSDate())
            if(currentDayStr > insertedDayStr){
                dateFormatter.dateFormat = "MM-dd"
                insertDateLabelView.text = dateFormatter.stringFromDate(insertedDate)
            }else{
                dateFormatter.dateFormat = "HH:mm"
                insertDateLabelView.text = dateFormatter.stringFromDate(insertedDate)
            }
            insertDateLabelView.textAlignment = NSTextAlignment.Right
            insertDateLabelView.textColor = UIColor.grayColor()
            
            //
            
            //profile View
            let profileLabelView = UILabel(frame: CGRectMake(10 + 32 + 10, 30, width - 10 - 32 - 10, 12))
            profileLabelView.font = UIFont(name: "Helvetica", size: 11.5)
            profileLabelView.text = feed.valueForKey("patientProfile") as? String
            profileLabelView.textColor = UIColor.grayColor()
            
            //feed type view
            var typeStr = String()
            if (feed.objectForKey("type") != nil) && (feed.objectForKey("type") is NSNull) == false{
                if (feed.objectForKey("type") as!Int) == 0{
                    if (feed.objectForKey("isBroadcast") as! Int) == 1 {
                        typeStr = "提出新问题"
                    }else{
                        typeStr = "分享心情"
                    }
                }
                if (feed.objectForKey("type") as! Int) == 1{
                    typeStr = "添加治疗方案"
                }
                if (feed.objectForKey("type") as! Int) == 2{
                    typeStr = "更新病友状态"
                }
            }
            let typeLabel = UILabel(frame: CGRectMake(10, 50, 80, 25))
            typeLabel.text = typeStr
            typeLabel.backgroundColor = sectionHeaderColor
            typeLabel.font = UIFont(name: fontStr, size: 12.0)
            typeLabel.textAlignment = NSTextAlignment.Center
            
            //feed body view
            let feedBody = UILabel(frame: CGRectMake(10, 80, width - 20, 0))
            if (feed.objectForKey("type") as! Int) != 1{
                feedBody.numberOfLines = 5
                if isDetail {
                    feedBody.numberOfLines = 0
                }
                feedBody.lineBreakMode = NSLineBreakMode.ByCharWrapping
                feedBody.font = UIFont(name: "Helvetica", size: 13.0)
                feedBody.text = (feed.objectForKey("body") as! String).stringByReplacingOccurrencesOfString("*", withString: " ", options: NSStringCompareOptions.LiteralSearch, range: nil)
                feedBody.textColor = UIColor.blackColor()
                feedBody.sizeToFit()
            }else if (feed.objectForKey("type") as! Int) == 1{
                let treatmentStr = feed.objectForKey("body") as! String
                let treatmentList: NSMutableArray = NSMutableArray(array: treatmentStr.componentsSeparatedByString("**"))
                for treatment in treatmentList {
                    var treatmentItemStr:String = treatment as! String
                    
                    treatmentItemStr = treatmentItemStr.stringByReplacingOccurrencesOfString("*", withString: "", options:  NSStringCompareOptions.LiteralSearch, range: nil)
                    if (treatmentItemStr as NSString).length == 0{
                        treatmentList.removeObject(treatment)
                    }
                }
                var treatmentY:CGFloat = 0
                for treatment in treatmentList {
                    var treatmentItemStr:String = treatment as! String
                    
                    if (treatmentItemStr as NSString).length == 0{
                        break
                    }
                    if treatmentItemStr.substringWithRange(Range(start: treatmentItemStr.startIndex, end: treatmentItemStr.startIndex.advancedBy(1))) == "*" {
                        treatmentItemStr = treatmentItemStr.substringFromIndex(treatmentStr.startIndex.advancedBy(1))
                    }
                    let treatmentNameAndDosage:NSArray = treatmentItemStr.componentsSeparatedByString("*")
                    let treatmentName = treatmentNameAndDosage[0] as! String
                    var treatmentDosage = String()
                    var treatmentNameLabel = UILabel()
                    let dosageLabel = UILabel()
                    treatmentNameLabel = UILabel(frame: CGRectMake(0.0, treatmentY, 90.0, 28.0))
                    treatmentNameLabel.text = treatmentName
                    treatmentNameLabel.font = UIFont(name: "Helvetica-Bold", size: 13.0)
                    treatmentNameLabel.layer.cornerRadius = 5
                    treatmentNameLabel.backgroundColor = tabBarColor
                    treatmentNameLabel.textColor = mainColor
                    treatmentNameLabel.layer.masksToBounds = true
                    treatmentNameLabel.layer.borderColor = mainColor.CGColor
                    treatmentNameLabel.layer.borderWidth = 1.0
                    treatmentNameLabel.textAlignment = NSTextAlignment.Center
                    if treatmentNameAndDosage.count > 1{
                        treatmentDosage = treatmentNameAndDosage[1] as! String
                        dosageLabel.frame = CGRectMake(100.0, treatmentY+5, feedBody.frame.width - 105, 0)
                        dosageLabel.text = treatmentDosage
                        dosageLabel.font = UIFont(name: "Helvetica-Bold", size: 12.0)
                        dosageLabel.numberOfLines = 0
                        dosageLabel.sizeToFit()
                        var height:CGFloat = dosageLabel.frame.height > treatmentNameLabel.frame.height ? dosageLabel.frame.height : treatmentNameLabel.frame.height
                        treatmentY += height + 5
                        dosageLabel.textColor = mainColor
                    }else{
                        treatmentY += 30
                    }
                    feedBody.addSubview(treatmentNameLabel)
                    feedBody.addSubview(dosageLabel)
                }
                feedBody.frame = CGRectMake(10, 80, width - 20, treatmentY)
            }
            
            //postImage
            var feedBodyHeight: CGFloat = 0
            if (feed.valueForKey("postImageList") != nil) && ((feed.valueForKey("postImageList") is NSNull) == false) && ((feed.valueForKey("postImageList") as! NSArray).count > 0){
                let postImageList = feed.valueForKey("postImageList") as! NSArray
                var index:Int = 0
                let postSImageWidth:CGFloat = (width - 10)/3 - 10
                for postSImage in postImageList{
                    let postSImageX: CGFloat = 10 + CGFloat(index % imageCountPerLine)*CGFloat(postSImageWidth + 10)
                    let postSImageY = 5 + CGFloat(index/imageCountPerLine)*CGFloat(postSImageWidth + 5) + feedBody.frame.origin.y + feedBody.frame.height
                    let postSImageView = UIImageView(frame: CGRectMake(postSImageX, postSImageY, postSImageWidth, postSImageWidth))
                    if postSImage is String{
                        let dataString = postSImage as! String
                        let imageData: NSData = NSData(base64EncodedString: dataString, options: NSDataBase64DecodingOptions(rawValue: 0))!
                        postSImageView.image = UIImage(data: imageData)
                    }else if postSImage is NSData{
                        postSImageView.image = UIImage(data: postSImage as! NSData)
                    }
                    self.addSubview(postSImageView)
                    index++
                }
                feedBodyHeight = feedBody.frame.height + postSImageWidth*CGFloat(postImageList.count/self.imageCountPerLine+1)
            }else{
                feedBodyHeight = feedBody.frame.height
            }
            feedBodyDelegate?.setFeedBodyHeight(feedBodyHeight, indexpath: indexPath!)
            
            //tagBody
            let tagLabel = UILabel(frame: CGRectMake(10, 80 + feedBodyHeight + 10, width - 80, 20))
            
            if (feed.objectForKey("tags") is NSNull) == false{
                tagLabel.font = UIFont(name: "Helvetica", size: 11.5)
                tagLabel.text = "tag:" + (feed.objectForKey("tags") as! NSString).stringByReplacingOccurrencesOfString("*", withString: " ")
                tagLabel.textColor = UIColor.grayColor()
                
            }
            //review View
            let reviewLabel = UILabel(frame: CGRectMake(10 + tagLabel.frame.width, tagLabel.frame.origin.y, 60, 20))
            reviewLabel.font = UIFont(name: "Helvetica", size: 11.5)
            reviewLabel.textAlignment = NSTextAlignment.Right
            reviewLabel.text = feed.valueForKey("countComments")!.stringValue + "评论"
            reviewLabel.textColor = UIColor.grayColor()
            
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
    
    func imageTapHandler(sender: UITapGestureRecognizer){
        
        print(feed["insertUsername"])
        self.imageTapDelegate?.imageTap(feed["insertUsername"] as! String)
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
