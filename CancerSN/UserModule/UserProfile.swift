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
    
    func initVariables(_ userProfileDic: NSDictionary){
        username = userProfileDic.object(forKey: "username") as? String
        portraitUrl = userProfileDic.object(forKey: "imageURL") as? String
        email = userProfileDic.object(forKey: "email") as? String
        phone = userProfileDic.object(forKey: "phone") as? String
        nick = userProfileDic.object(forKey: "displayname") as? String
        gender = userProfileDic.object(forKey: "gender") as? String
        age = userProfileDic.object(forKey: "age") as? Int
        cancerType = userProfileDic.object(forKey: "cancerType") as? String
        pathological = userProfileDic.object(forKey: "pathological") as? String
        geneticMutation = userProfileDic.object(forKey: "geneticMutation") as? String
        stage = userProfileDic.object(forKey: "stage") as? String
        metastics = userProfileDic.object(forKey: "metastasis") as? String
    }
}
