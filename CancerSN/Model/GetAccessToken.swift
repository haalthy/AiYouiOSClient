//
//  GetAccessToken.swift
//  CancerSN
//
//  Created by lily on 7/29/15.
//  Copyright (c) 2015 lily. All rights reserved.
//

import Foundation

class GetAccessToken: NSObject {
    
    func getAccessToken(){
        let profileSet = UserDefaults.standard
        let keychainAccess = KeychainAccess()

        if((keychainAccess.getPasscode(usernameKeyChain) != nil) && (keychainAccess.getPasscode(passwordKeyChain) != nil)){
            let usernameStr:String = keychainAccess.getPasscode(usernameKeyChain) as! String
            var passwordStr:String = keychainAccess.getPasscode(passwordKeyChain) as! String
            let publicService = PublicService()
            passwordStr = publicService.passwordEncode(passwordStr)
            
            let parameters = NSDictionary(objects: [usernameStr, passwordStr, "my-trusted-client", "password"], forKeys: ["username" as NSCopying, "password" as NSCopying, "client_id" as NSCopying, "grant_type" as NSCopying])
            let jsonResult = NetRequest.sharedInstance.GET_A(getOauthTokenURL, parameters: parameters as! Dictionary<String, AnyObject>)
            if (jsonResult.object(forKey: "access_token") != nil){
                let accessToken  = jsonResult.object(forKey: "access_token") as! String
                let refreshToken = jsonResult.object(forKey: "refresh_token") as! String
                profileSet.set(accessToken, forKey: accessNSUserData)
                profileSet.set(refreshToken, forKey: refreshNSUserData)
            }else if(jsonResult.object(forKey: "error") != nil) && ((jsonResult.object(forKey: "error") as! String) == "unauthorized"){
                profileSet.removeObject(forKey: accessNSUserData)
                profileSet.removeObject(forKey: refreshNSUserData)
            }
            else{
                profileSet.set(networkErrorCode, forKey: accessNSUserData)
//                profileSet.setObject(nil, forKey: refreshNSUserData)
            }
        }else{
            profileSet.removeObject(forKey: accessNSUserData)
            profileSet.removeObject(forKey: refreshNSUserData)
        }
    }

}
