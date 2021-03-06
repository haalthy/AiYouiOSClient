//
//  UserCell.swift
//  CancerSN
//
//  Created by lay on 16/2/18.
//  Copyright © 2016年 lily. All rights reserved.
//

import UIKit

protocol UserVCDelegate{
    func unlogin()
}

class UserCell: UITableViewCell {
    
    var userVCDelegate: UserVCDelegate?

    let getAccessToken = GetAccessToken()
    let keychainAccess = KeychainAccess()
    
    @IBOutlet weak var portraitImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var addBtn: UIButton!
    
    var isFollowing: Bool = false
    
    var userObj = UserModel(){
        didSet{
            updateUI()
        }
    }
    
    func updateUI(){
        let imageURL = userObj.imageURL + "@80h_80w_1e"
        portraitImage.backgroundColor = UIColor.white
        portraitImage.addImageCache(imageURL, placeHolder: "defaultUserImage")
        nameLabel.text = userObj.displayname
        var userInfo: String = ""
        if userObj.gender != "<null>" {
            userInfo += (userObj.gender) + " "
        }
        if userObj.age != 0 {
            userInfo += String(userObj.age) + " "
        }
        if userObj.cancerType != "<null>" {
            userInfo += userObj.cancerType  + " "
        }
        if userObj.pathological != "<null>" {
            userInfo += userObj.pathological + " "
        }
        if userObj.stage != "<null>" {
            userInfo += userObj.stage + " "
        }
        if userObj.geneticMutation != "<null>" {
            userInfo += userObj.geneticMutation
        }
        infoLabel.text = userInfo
        let addFollowingImage = UIImageView(image: UIImage(named: "btn_addFollowing"))
        self.addBtn.removeAllSubviews()
        self.addBtn.addSubview(addFollowingImage)
        self.addBtn.isEnabled = true
        if userObj.isFollowedByCurrentUser == 1 {
//            self.addBtn.hidden = true
            self.addBtn.isEnabled = false
            let followedImageView = UIImageView(frame: CGRECT(0, 0, self.addBtn.frame.width, self.addBtn.frame.height))
            followedImageView.image = UIImage(named: "btn_Followed")
            self.addBtn.removeAllSubviews()
            self.addBtn.addSubview(followedImageView)
        }else{
            self.addBtn.isHidden = false
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.initContentView()
    }
    
    // MARK: - 初始化相关view
    
    func initContentView() {
        
        self.portraitImage.layer.cornerRadius = self.portraitImage.frame.width / 2
        self.portraitImage.clipsToBounds = true
        
        self.addBtn.layer.cornerRadius = 4.0
        self.addBtn.layer.borderColor = RGB(222, 228, 229).cgColor
        self.addBtn.layer.borderWidth = 2.0
        self.addBtn.addTarget(self, action: #selector(UserCell.addFollowing(_:)), for: UIControlEvents.touchUpInside)
    }
    
    func addFollowing(_ sender: UIButton){
        userObj.isFollowedByCurrentUser = 1
        getAccessToken.getAccessToken()
        let accessToken = UserDefaults.standard.object(forKey: accessNSUserData)
        if accessToken != nil {
            let urlPath:String = (addFollowingURL as String) + "?access_token=" + (accessToken as! String);
            
            let requestBody = NSMutableDictionary()
            requestBody.setObject(userObj.username, forKey: "followingUser" as NSCopying)
            requestBody.setObject(keychainAccess.getPasscode(usernameKeyChain)!, forKey: "username" as NSCopying)
            sender.isEnabled = false
            let followedImageView = UIImageView(frame: CGRECT(0, 0, sender.frame.width, sender.frame.height))
            followedImageView.image = UIImage(named: "btn_Followed")
            sender.removeAllSubviews()
            sender.addSubview(followedImageView)
            NetRequest.sharedInstance.POST(urlPath, parameters: (requestBody as NSDictionary) as! Dictionary<String, AnyObject>,
                success: { (content , message) -> Void in
                    //                HudProgressManager.sharedInstance.showHudProgress(self, title: "已关注")
                    
                    //                HudProgressManager.sharedInstance.dismissHud()
                }) { (content, message) -> Void in
                    //                HudProgressManager.sharedInstance.showHudProgress(self, title: "Oops，失败了，稍后再试:(")
                    //                HudProgressManager.sharedInstance.dismissHud()
            }
        }else{
            userVCDelegate?.unlogin()
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
