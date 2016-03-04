//
//  PostTableViewCell.swift
//  CancerSN
//
//  Created by hui luo on 24/2/2016.
//  Copyright © 2016 lily. All rights reserved.
//

import UIKit

class PostTableViewCell: UITableViewCell {
    //frame 设定
    let dayLabelLeftSpace:CGFloat = 15
    let dayLabelTopSpace:CGFloat = 17
    let dayLabelWidth:CGFloat = 22
    let dayLabelHeight:CGFloat = 18
    let dayLabelFont: UIFont = UIFont.systemFontOfSize(18)
    
    let monthTopSpace: CGFloat = 22
    let monthLabelFont: UIFont = UIFont.systemFontOfSize(10)
    
    let postContentTopSpace: CGFloat = 15
    let postContentLeftSpace: CGFloat = 80
    let postContentRightSpace: CGFloat = 5
    let postContentButtomSpace: CGFloat = 15
    
    let postLabelTopSpace: CGFloat = 0
    let postLabelLeftSpace: CGFloat = 10
    let postLabelFont: UIFont = UIFont.systemFontOfSize(14)
    
    let postImageLength: CGFloat = 50
    
    
    let dayLabel = UILabel()
    let monthLabel = UILabel()
    let postContent = UIView()
    
    //day and month
    var day: String = ""
    var month: String = ""
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    var post = PostFeedStatus() {
        didSet{
            updateUI()
        }
    }
    
    func getDayAndMonth(dateInserted: NSDate){
        let calendar = NSCalendar.currentCalendar()
        let dateComponents = calendar.components([NSCalendarUnit.Day, NSCalendarUnit.Month], fromDate: dateInserted)
        day = String(dateComponents.day)
        if dateComponents.day < 10 {
            day = "0" + day
        }
        switch dateComponents.month{
        case 1:
            month = "一月"
            break
        case 2:
            month = "二月"
            break
        case 3:
            month = "三月"
            break
        case 4:
            month = "四月"
            break
        case 5:
            month = "五月"
            break
        case 6:
            month = "六月"
            break
        case 7:
            month = "七月"
            break
        case 8:
            month = "八月"
            break
        case 9:
            month = "九月"
            break
        case 10:
            month = "十月"
            break
        case 11:
            month = "十一月"
            break
        case 12:
            month = "十二月"
            break
        default:
            break
        }
    }
    
    func updateUI(){
        self.removeAllSubviews()
        let dateInserted = NSDate.createDate(post.dateInserted / 1000)
        getDayAndMonth(dateInserted!)
        //add day label
        dayLabel.frame = CGRect(x: dayLabelLeftSpace, y: dayLabelTopSpace, width: dayLabelWidth, height: dayLabelHeight)
        dayLabel.text = day
        dayLabel.font = dayLabelFont
        self.addSubview(dayLabel)
        
        //add Month Label
        let monthLabelSize = month.sizeWithFont(monthLabelFont, maxSize: CGSize(width: 50, height: 50))
        monthLabel.frame = CGRECT(dayLabelLeftSpace + dayLabel.frame.width, monthTopSpace, monthLabelSize.width, monthLabelSize.height)
        monthLabel.text = month
        monthLabel.font = monthLabelFont
        self.addSubview(monthLabel)
        
        //post Content
        let postLabel = UILabel()
        let postContentWidth = screenWidth - postContentLeftSpace - postContentRightSpace
        if post.hasImage > 0 {
            postContent.frame = CGRect(x: postContentLeftSpace, y: postContentTopSpace, width: postContentWidth, height: postImageLength)
            let postImageView = UIImageView(frame: CGRECT(0, 0, postImageLength, postImageLength))
            if post.imageURL != "" {
                let localImageList = post.imageURL.componentsSeparatedByString(";")
                if (localImageList.count > 0) && (localImageList[0] != ""){
                    let imageURL = localImageList[0] + "@100h_100w_1e"
                    postImageView.addImageCache(imageURL, placeHolder: placeHolderStr)
                }
                postContent.addSubview(postImageView)
                
                let postLabelSize = post.body.sizeWithFont(postLabelFont, maxSize: CGSize(width: postContent.frame.width - postImageLength - postLabelLeftSpace * 2, height: 36))
                postLabel.frame = CGRect(x: postImageLength + postLabelLeftSpace, y: postLabelTopSpace, width: postContentWidth - postImageLength - postLabelLeftSpace*2, height: postLabelSize.height)
                postLabel.text = post.body
                postLabel.numberOfLines = 2
                postLabel.lineBreakMode = NSLineBreakMode.ByTruncatingTail
                postLabel.sizeToFit()
                postContent.backgroundColor = UIColor.init(red: 242/255, green: 248/255, blue: 248/255, alpha: 1)
            }
        }else{
            let postLabelSize = post.body.sizeWithFont(postLabelFont, maxSize: CGSize(width: postContentWidth - postLabelLeftSpace * 2, height: 36))
            postLabel.frame = CGRect(x: postLabelLeftSpace, y: postLabelTopSpace, width: postContentWidth - postLabelLeftSpace*2, height: postLabelSize.height)
            postLabel.text = post.body
            postLabel.numberOfLines = 2
            postLabel.lineBreakMode = NSLineBreakMode.ByTruncatingTail
            postLabel.sizeToFit()
            
            postContent.frame = CGRECT(postContentLeftSpace, postContentTopSpace, postContentWidth, postLabelSize.height + postLabelTopSpace * 2)

        }
        postLabel.textColor = defaultTextColor
        postLabel.font = postLabelFont
        postContent.addSubview(postLabel)
        self.addSubview(postContent)
        //add seperate Line
        let seperateLine = UIView(frame: CGRect(x: 0, y: postContent.frame.origin.y + postContent.frame.height + 14, width: screenWidth, height: 1))
        seperateLine.backgroundColor = seperateLineColor
        self.addSubview(seperateLine)
        
    }
}
