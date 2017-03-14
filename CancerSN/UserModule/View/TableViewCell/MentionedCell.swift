//
//  MentionedCell.swift
//  CancerSN
//
//  Created by lay on 16/3/1.
//  Copyright © 2016年 lily. All rights reserved.
//

import UIKit

// tag border color
let kMentionedTagBorderColor: UIColor = RGB(153, 153, 153)

// tag text color
let kMentionedTagTextColor: UIColor = RGB(51, 51, 51)


class MentionedCell: UITableViewCell {

    
    
    @IBOutlet weak var portraitImage: UIImageView!
    
    @IBOutlet weak var showImage: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var bodyLabel: UILabel!
    
    @IBOutlet weak var typeLabel: UILabel!
    
    @IBOutlet weak var tagLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.initContentView()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func initContentView() {
    
        self.portraitImage.layer.cornerRadius = self.portraitImage.frame.width / 2
        self.portraitImage.clipsToBounds = true

    }
    
    func setContentViewAction(_ feedModel: PostFeedStatus) {
        let imageURL = (feedModel.portraitURL) + "@80h_80w_1e"
        self.portraitImage.addImageCache(imageURL, placeHolder: placeHolderStr)
        self.nameLabel.text = feedModel.displayname
        self.bodyLabel.text = self.getMentionedAndBody(feedModel.body)
        self.typeLabel.text = getFeedTypeName(feedModel.type, isBroadcast: feedModel.isBroadcast)
        
        self.showContentViewForType(feedModel.type, feedModel: feedModel)
    }
    
    func setContentViewForUserComment(_ commentModel: UserCommentModel) {
    
        let imageURL = (commentModel.imageURL) + "@40h_40w_1e"
        self.portraitImage.addImageCache(imageURL, placeHolder: placeHolderStr)
        self.nameLabel.text = commentModel.displayname
        self.bodyLabel.text = self.getMentionedAndBody(commentModel.body)
        self.typeLabel.text = getFeedTypeName(commentModel.postType, isBroadcast: commentModel.isBroadcast)
        
        self.showContentViewForUserComment(commentModel)
    }
    
    // MARK: - 功能方法
    
    func getMentionedAndBody(_ body: String) -> String {
    
        let bodyArr: Array<String> = body.components(separatedBy: " ")
        
        var resultStr: String = ""
        
        
        for i in 0 ..< bodyArr.count {
        
            let str: NSString = NSString(string: bodyArr[i])
            
            if str == "" {
                continue
            }
            
            if str.substring(to: 1) == "@" {
                
                let mentionedStr: NSMutableAttributedString = NSMutableAttributedString(string: bodyArr[i])
                mentionedStr.addAttribute(NSForegroundColorAttributeName, value: RGB(111, 111, 111).cgColor, range: NSRange.init(location: 0, length: str.length))
                resultStr = resultStr + " " + String(describing: mentionedStr)

            }
            else {
                resultStr = resultStr + " " + bodyArr[i]
            }
            
        }
        return resultStr
        
    }
    
    // MARK: 不同类别，展示不同数据
    
    func showContentViewForType(_ type: Int, feedModel: PostFeedStatus) {
    
        
        if type == 0 && feedModel.isBroadcast == 1 || (type == 0 && feedModel.isBroadcast == 0) {
        
            self.tagLabel.isHidden = true
            self.showImage.isHidden = false
            
            let picArr: Array<String> = ((feedModel.imageURL).components(separatedBy: ";"))
            let imageURL = picArr[0] + "@100h_100w_1e"
            self.showImage.addImageCache(imageURL, placeHolder: placeHolderStr)
        }
        else if type == 1 {
        
            self.tagLabel.isHidden = false
            self.showImage.isHidden = true
            
            self.tagLabel.layer.cornerRadius = 1.0
            self.tagLabel.layer.borderWidth = 1.0
            self.tagLabel.layer.borderColor = kMentionedTagBorderColor.cgColor
            self.tagLabel.textColor = kMentionedTagTextColor
            let highTagsArr: [String] = feedModel.highlight.components(separatedBy: " ")
            self.tagLabel.text = highTagsArr[0]
        }
        
        else if type == 2 {
        
            self.tagLabel.isHidden = false
            self.showImage.isHidden = true
            let tagArr: Array<String> = feedModel.tags.components(separatedBy: "，")
            self.tagLabel.text = "“" + tagArr[0] + "”"

        }
    }
    
    // MARK: - 显示不同的用户评论列表数据
    
    func showContentViewForUserComment(_ commentModel: UserCommentModel) {
    
        
        if (commentModel.postImageURL as NSString).length > 0 {
        
            self.tagLabel.isHidden = true
            self.showImage.isHidden = false
            let picArr: Array<String> = ((commentModel.postImageURL).components(separatedBy: ";"))
            let imageURL = picArr[0] + "@100h_100w_1e"
            self.showImage.addImageCache(imageURL, placeHolder: placeHolderStr)
        }
        else {
            self.tagLabel.isHidden = false
            self.showImage.isHidden = true
            self.tagLabel.text = "“" + commentModel.postBody + "”"
        
        }

    }
}
