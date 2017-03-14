//
//  ContactsTableViewCell.swift
//  CancerSN
//
//  Created by hui luo on 14/2/2016.
//  Copyright © 2016 lily. All rights reserved.
//

import UIKit

protocol CheckedBtnDelegate {
    func checked(_ displayname: String)
    func unchecked(_ displayname: String)
}

class ContactsTableViewCell: UITableViewCell {

    var checkBtnDelegate: CheckedBtnDelegate?
    let checkBtnLeftSpace: CGFloat = 15
    let checkBtnTopSpace: CGFloat = 20
    let checkBtnLength: CGFloat = 20
    let checkBtnBorderWidth: CGFloat = 1
    let checkBtnBorderColor: UIColor = UIColor.init(red: 221 / 255, green: 221 / 255, blue: 224 / 255, alpha: 1)
    let checkedBtnBackgroundColor : UIColor = headerColor
    
    let portraitLeftSpace: CGFloat = 50
    let portraitTopSpace: CGFloat = 10
    let portraitLength: CGFloat = 40
    
    let nameLabelLeftSpace: CGFloat = 105
    let nameLabelFont: UIFont = UIFont.systemFont(ofSize: 14)
    let nameLabelTextColor = defaultTextColor
    
    let checkBtn = UIButton()
    
    var userObj = UserProfile() {
        didSet{
            updateUI()
        }
    }
    
    func updateUI(){
        //checkBtn
        checkBtn.frame = CGRect(x: checkBtnLeftSpace, y: checkBtnTopSpace, width: checkBtnLength, height: checkBtnLength)
        checkBtn.layer.borderColor = checkBtnBorderColor.cgColor
        checkBtn.layer.borderWidth = checkBtnBorderWidth
        checkBtn.layer.cornerRadius = checkBtnLength / 2
        checkBtn.layer.masksToBounds = true
        checkBtn.addTarget(self, action: #selector(ContactsTableViewCell.checkedUser(_:)), for: UIControlEvents.touchUpInside)
        checkBtn.backgroundColor = UIColor.white
        self.addSubview(checkBtn)
        
        //portraitImage
        let portraitImageView = UIImageView(frame: CGRECT(portraitLeftSpace, portraitTopSpace, portraitLength, portraitLength))
        portraitImageView.layer.cornerRadius = portraitLength / 2
        portraitImageView.layer.masksToBounds = true
        if(userObj.portraitUrl != nil){
            let url : URL = URL(string: userObj.portraitUrl!)!
            let imageData = try? Data(contentsOf: url)
            if imageData != nil {
                portraitImageView.image = UIImage(data: imageData!)
            }else{
                portraitImageView.backgroundColor = imageViewBackgroundColor
            }
        }
        self.addSubview(portraitImageView)
        
        //nameLabel
        let nameLabel = UILabel(frame: CGRect(x: nameLabelLeftSpace, y: 0, width: self.frame.width - nameLabelLeftSpace, height: self.frame.height))
        nameLabel.text = userObj.nick
        nameLabel.font = nameLabelFont
        nameLabel.textColor = nameLabelTextColor
        self.addSubview(nameLabel)
        
    }
    
    func checkedUser(_ sender: UIButton){
        if sender.backgroundColor != checkedBtnBackgroundColor {
            sender.backgroundColor = checkedBtnBackgroundColor
            let checkedImgView = UIImageView(frame: CGRect(x: 5, y: 5, width: checkBtnLength - 10, height: checkBtnLength - 10))
            checkedImgView.image = UIImage(named: "btn_checked")
            checkedImgView.contentMode = UIViewContentMode.scaleAspectFit
            checkBtn.addSubview(checkedImgView)
            checkBtnDelegate?.checked(userObj.nick!)
        }else {
            sender.backgroundColor = UIColor.white
            sender.removeAllSubviews()
            checkBtnDelegate?.unchecked(userObj.nick!)
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
