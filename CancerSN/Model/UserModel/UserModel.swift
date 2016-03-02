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

    var Displayname: String = ""
    var Age: Int = 0
    var metastasis: String = ""
    var IsSmoking: Int = 0
    var id: String = ""
    var Email: String = ""
    var geneticMutation: String = ""
    var Username: String = ""
    var Gender: String = ""
    var Pathological: String = ""
    var Stage: String = ""
    var CancerType: String = ""
    var imageURL: String = ""
    var _version_: Int64 = 0
    
}
