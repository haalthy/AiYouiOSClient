//
//  PublicService.swift
//  CancerSN
//
//  Created by lily on 9/10/15.
//  Copyright (c) 2015 lily. All rights reserved.
//

import Foundation
import UIKit

class PublicService:NSObject{
    func getProfileStrByDictionary(user:NSDictionary)->String{
        
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
//            var stageStr = user["stage"]! as! Int
            var stages = stageMapping.allKeysForObject(user["stage"]! as! Int) as NSArray
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
        return userProfileStr
    }
    
    func logOutAccount(){
        var keychain = KeychainAccess()
        keychain.deletePasscode(usernameKeyChain)
        keychain.deletePasscode(passwordKeyChain)
        println(keychain.getPasscode(usernameKeyChain))
        println(keychain.getPasscode(passwordKeyChain))
        var profileSet = NSUserDefaults.standardUserDefaults()
        profileSet.removeObjectForKey(favTagsNSUserData)
        profileSet.removeObjectForKey(genderNSUserData)
        profileSet.removeObjectForKey(ageNSUserData)
        profileSet.removeObjectForKey(cancerTypeNSUserData)
        profileSet.removeObjectForKey(pathologicalNSUserData)
        profileSet.removeObjectForKey(stageNSUserData)
        profileSet.removeObjectForKey(smokingNSUserData)
        profileSet.removeObjectForKey(metastasisNSUserData)
        profileSet.removeObjectForKey(emailNSUserData)
        profileSet.removeObjectForKey(accessNSUserData)
        profileSet.removeObjectForKey(refreshNSUserData)
    }
    
    func cropToSquare(image originalImage: UIImage) -> UIImage {
        // Create a copy of the image without the imageOrientation property so it is in its native orientation (landscape)
        let contextImage: UIImage = UIImage(CGImage: originalImage.CGImage)!
        
        // Get the size of the contextImage
        let contextSize: CGSize = contextImage.size
        
        let posX: CGFloat
        let posY: CGFloat
        let width: CGFloat
        let height: CGFloat
        
        // Check to see which length is the longest and create the offset based on that length, then set the width and height of our rect
        if contextSize.width > contextSize.height {
            posX = ((contextSize.width - contextSize.height) / 2)
            posY = 0
            width = contextSize.height
            height = contextSize.height
        } else {
            posX = 0
            posY = ((contextSize.height - contextSize.width) / 2)
            width = contextSize.width
            height = contextSize.width
        }
        
        let rect: CGRect = CGRectMake(posX, posY, width, height)
        
        // Create bitmap image from context using the rect
        let imageRef: CGImageRef = CGImageCreateWithImageInRect(contextImage.CGImage, rect)
        
        // Create a new image based on the imageRef and rotate back to the original orientation
        let image: UIImage = UIImage(CGImage: imageRef, scale: originalImage.scale, orientation: originalImage.imageOrientation)!
        
        return image
    }
    
    func formatButton(sender: UIButton, title: String){
        sender.backgroundColor = UIColor.whiteColor()
        sender.setTitle(title, forState: UIControlState.Normal)
        sender.setTitleColor(mainColor, forState: UIControlState.Normal)
        sender.layer.cornerRadius = 5.0
        sender.layer.borderColor = mainColor.CGColor
        sender.layer.borderWidth = 1.0
    }
    
}