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
        let profileSet = NSUserDefaults.standardUserDefaults()
        let keychainAccess = KeychainAccess()

        if((keychainAccess.getPasscode(usernameKeyChain) != nil) && (keychainAccess.getPasscode(passwordKeyChain) != nil)){
            let usernameStr:String = keychainAccess.getPasscode(usernameKeyChain) as! String
            var passwordStr:String = keychainAccess.getPasscode(passwordKeyChain) as! String
            let publicService = PublicService()
            passwordStr = publicService.passwordEncode(passwordStr)
            
            let parameters = NSDictionary(objects: [usernameStr, passwordStr, "my-trusted-client", "password"], forKeys: ["username", "password", "client_id", "grant_type"])
            let jsonResult = NetRequest.sharedInstance.GET_A(getOauthTokenURL, parameters: parameters as! Dictionary<String, AnyObject>)
            if (jsonResult.objectForKey("access_token") != nil){
                let accessToken  = jsonResult.objectForKey("access_token")
                let refreshToken = jsonResult.objectForKey("refresh_token")
                profileSet.setObject(accessToken, forKey: accessNSUserData)
                profileSet.setObject(refreshToken, forKey: refreshNSUserData)
            }else if(jsonResult.objectForKey("error") != nil) && ((jsonResult.objectForKey("error") as! String) == "unauthorized"){
                profileSet.setObject(nil, forKey: accessNSUserData)
                profileSet.setObject(nil, forKey: refreshNSUserData)
            }
            else{
                profileSet.setObject(networkErrorCode, forKey: accessNSUserData)
//                profileSet.setObject(nil, forKey: refreshNSUserData)
            }
        }else{
            profileSet.setObject(nil, forKey: accessNSUserData)
            profileSet.setObject(nil, forKey: refreshNSUserData)
        }
    }

}
