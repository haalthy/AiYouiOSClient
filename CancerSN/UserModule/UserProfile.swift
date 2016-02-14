//
//  UserProfile.swift
//  CancerSN
//
//  Created by lily on 2/10/16.
//  Copyright © 2016 lily. All rights reserved.
//

import Foundation

class UserProfile: NSObject {
    var username : String?
    var portraitUrl : String?
    var email : String?
    var phone : String?
    var nick: String?
    var gender: String?
    var age: Int?
    var cancerType: String?
    var pathological: String?
    var geneticMutation: String?
    var stage: String?
    var metastics: String?
    var portraitData: String?
//    var userProfileDic = NSDictionary(){
//        didSet{
//            initVariables()
//        }
//    }
    
    func initVariables(userProfileDic: NSDictionary){
        username = userProfileDic.objectForKey("username") as? String
        portraitUrl = userProfileDic.objectForKey("imageURL") as? String
        email = userProfileDic.objectForKey("email") as? String
        phone = userProfileDic.objectForKey("phone") as? String
        nick = userProfileDic.objectForKey("displayname") as? String
        gender = userProfileDic.objectForKey("gender") as? String
        age = userProfileDic.objectForKey("age") as? Int
        cancerType = userProfileDic.objectForKey("cancerType") as? String
        pathological = userProfileDic.objectForKey("pathological") as? String
        geneticMutation = userProfileDic.objectForKey("geneticMutation") as? String
        stage = userProfileDic.objectForKey("stage") as? String
        metastics = userProfileDic.objectForKey("metastasis") as? String
    }
}
