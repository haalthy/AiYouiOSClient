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
        var error: NSErrorPointer=nil
        let keychainAccess = KeychainAccess()
        if((keychainAccess.getPasscode(usernameKeyChain) != nil)&&(keychainAccess.getPasscode(passwordKeyChain) != nil)){
            let usernameStr:String = keychainAccess.getPasscode(usernameKeyChain) as! String
            let passwordStr:String = keychainAccess.getPasscode(passwordKeyChain) as! String
            var urlPath: String = getOauthTokenURL + "username=" + usernameStr + "&password=" + passwordStr
            urlPath = urlPath.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
            let url: NSURL = NSURL(string: urlPath)!
            let request: NSURLRequest = NSURLRequest(URL: url)
            var response: AutoreleasingUnsafeMutablePointer<NSURLResponse?> = nil
            let getTokenResponseData = NSURLConnection.sendSynchronousRequest(request, returningResponse: response, error: nil)
            var jsonResult = NSJSONSerialization.JSONObjectWithData(getTokenResponseData!, options: NSJSONReadingOptions.MutableContainers, error: error)
            var accessToken  = jsonResult?.objectForKey("access_token")
            var refreshToken = jsonResult?.objectForKey("refresh_token")
            let profileSet = NSUserDefaults.standardUserDefaults()
            profileSet.setObject(accessToken, forKey: accessNSUserData)
            profileSet.setObject(refreshToken, forKey: refreshNSUserData)
        }
    }

}
