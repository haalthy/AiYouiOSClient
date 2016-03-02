//
//  UserCell.swift
//  CancerSN
//
//  Created by lay on 16/2/18.
//  Copyright © 2016年 lily. All rights reserved.
//

import UIKit

class UserCell: UITableViewCell {

    let getAccessToken = GetAccessToken()
    let keychainAccess = KeychainAccess()
    
    @IBOutlet weak var portraitImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var addBtn: UIButton!
    
    var userObj = UserModel(){
        didSet{
            updateUI()
        }
    }
    
    func updateUI(){
        portraitImage.addImageCache(userObj.imageURL!, placeHolder: "icon_profile")
        nameLabel.text = userObj.Displayname
        var userInfo: String = (userObj.Gender!) + " " + String(userObj.Age) + " " + userObj.CancerType!  + " " + userObj.Pathological! + " " + String(userObj.Stage) + " " + userObj.geneticMutation!
        infoLabel.text = userInfo
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
        self.addBtn.layer.borderColor = RGB(222, 228, 229).CGColor
        self.addBtn.layer.borderWidth = 2.0
        
        self.addBtn.addTarget(self, action: "addFollowing:", forControlEvents: UIControlEvents.TouchUpInside)
    }
    
    func addFollowing(sender: UIButton){
        getAccessToken.getAccessToken()
        let accessToken = NSUserDefaults.standardUserDefaults().objectForKey(accessNSUserData)
        let urlPath:String = (addFollowingURL as String) + "?access_token=" + (accessToken as! String);
        
        let requestBody = NSMutableDictionary()
        requestBody.setObject(userObj.Username!, forKey: "followingUser")
        requestBody.setObject(keychainAccess.getPasscode(usernameKeyChain)!, forKey: "username")
        
        NetRequest.sharedInstance.POST(urlPath, parameters: (requestBody as NSDictionary) as! Dictionary<String, AnyObject>,
            success: { (content , message) -> Void in
//                HudProgressManager.sharedInstance.showHudProgress(self, title: "已关注")
                sender.enabled = false
                let followedImageView = UIImageView(frame: CGRECT(0, 0, sender.frame.width, sender.frame.height))
                followedImageView.image = UIImage(named: "btn_Followed")
                sender.removeAllSubviews()
                sender.addSubview(followedImageView)
//                HudProgressManager.sharedInstance.dismissHud()
            }) { (content, message) -> Void in
//                HudProgressManager.sharedInstance.showHudProgress(self, title: "Oops，失败了，稍后再试:(")
//                HudProgressManager.sharedInstance.dismissHud()
        }
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
