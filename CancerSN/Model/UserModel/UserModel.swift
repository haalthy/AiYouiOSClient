//
//  UserModel.swift
//  CancerSN
//
//  Created by lay on 15/12/25.
//  Copyright © 2015年 lily. All rights reserved.
//

import UIKit

@objc(UserModel)

class UserModel: D3Model {

    var displayname: String = ""
    var age: Int = 0
    var metastasis: String = ""
    var isSmoking: Int = 0
    var id: String = ""
    var email: String = ""
    var geneticMutation: String = ""
    var username: String = ""
    var gender: String = ""
    var pathological: String = ""
    var stage: String = ""
    var cancerType: String = ""
    var imageURL: String = ""
    var _version_: Int64 = 0
    var isFollowedByCurrentUser: Int = 0
    
}
