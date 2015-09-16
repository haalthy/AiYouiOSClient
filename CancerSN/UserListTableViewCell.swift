//
//  UserListTableViewCell.swift
//  CancerSN
//
//  Created by lily on 7/22/15.
//  Copyright (c) 2015 lily. All rights reserved.
//

import UIKit
import CoreData

protocol UserListDelegate {
    func performLoginSegue()
}

class UserListTableViewCell: UITableViewCell {
    
    var delegate : UserListDelegate?
    
    var hiddenFollowButton = Bool()

    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var usernameDisplay: UILabel!
    @IBOutlet weak var userProfileDisplay: UILabel!
    
    @IBOutlet weak var userFollowers: UILabel!
    
    var addFollowingResponseData : NSMutableData? = nil
    var getTokenResponseData : NSMutableData? = nil
    @IBOutlet weak var addFollowingBtn: UIButton!
    
    @IBAction func addFollowing(sender: AnyObject) {
        let profileSet = NSUserDefaults.standardUserDefaults()
        if profileSet.objectForKey(accessNSUserData) != nil{
            var haalthyService = HaalthyService()
            var addFollowingData = haalthyService.addFollowing(usernameDisplay.text!)
            var jsonResult = NSJSONSerialization.JSONObjectWithData(addFollowingData, options: NSJSONReadingOptions.MutableContainers, error: nil)
        }else{
            self.delegate?.performLoginSegue()
        }
        addFollowingBtn.enabled = false
        addFollowingBtn.titleLabel?.text = "已关注"
        addFollowingBtn.layer.borderColor = UIColor.lightGrayColor().CGColor
    }
    
    var user=NSDictionary(){
        didSet{
            updateUI()
        }
    }
    
    func updateUI(){
        if((user["image"] is NSNull) == false){
            let dataString = user["image"] as! String
            let imageData: NSData = NSData(base64EncodedString: dataString, options: NSDataBase64DecodingOptions(0))!
            
            userImage.image = UIImage(data: imageData)
        }
        
        usernameDisplay.text = user["username"] as? String
        
        var userProfileStr : String
        var gender = user["gender"] as! String
        var displayGender:String = ""
        if(gender == "M"){
            displayGender = "男"
        }else if(gender == "F"){
            displayGender = "女"
        }
        var age = String()
        var stage = String()
        var cancerType = String()
        var pathological = String()
        
        if user["age"] != nil{
            age = (user["age"] as! NSNumber).stringValue
        }
//        var pathological = user["pathological"] as! String
        if (user["stage"] != nil) && !(user["stage"] is NSNull) {
            var stageStr = user["stage"]! as! String
            var stages = stageMapping.allKeysForObject(stageStr.toInt()!) as NSArray
            if stages.count > 0 {
                stage = stages[0] as! String
            }
        }
        
        if (user["cancerType"] != nil) && !(user["cancerType"] is NSNull) {
            var cancerKeysForObject = cancerTypeMapping.allKeysForObject(user["cancerType"]!)
            if cancerKeysForObject.count > 0 {
                cancerType = (cancerKeysForObject)[0] as! String
            }
        }
        
        if user["pathological"] != nil && !(user["pathological"] is NSNull){
            var pathologicalKeysForObject = pathologicalMapping.allKeysForObject(user["pathological"]!)
            if pathologicalKeysForObject.count > 0 {
                pathological = pathologicalKeysForObject[0] as! String
            }
        }
        
        userProfileStr = displayGender + " " + age + "岁 " + cancerType + " " + pathological + " " + stage + "期"
        
        userProfileDisplay.text = userProfileStr
        
        userFollowers.text = (user["followCount"] as! NSNumber).stringValue + "关注"

    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
//        if !hiddenFollowButton{
//            addFollowingBtn.layer.cornerRadius = 5
//            addFollowingBtn.layer.borderWidth = 2.0
//            addFollowingBtn.layer.borderColor = mainColor.CGColor
//            addFollowingBtn.layer.masksToBounds = true
//            addFollowingBtn.backgroundColor = UIColor.whiteColor()
//            addFollowingBtn.titleLabel?.textColor = mainColor
//        }
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
