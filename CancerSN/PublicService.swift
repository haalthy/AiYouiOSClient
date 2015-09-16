//
//  PublicService.swift
//  CancerSN
//
//  Created by lily on 9/10/15.
//  Copyright (c) 2015 lily. All rights reserved.
//

import Foundation

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
        return userProfileStr
    }
    
    func logOutAccount(){
        var keychain = KeychainAccess()
        keychain.deletePasscode(usernameKeyChain)
        keychain.deletePasscode(passwordKeyChain)
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
}