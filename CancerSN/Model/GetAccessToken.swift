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
        let error: NSErrorPointer=nil
        let keychainAccess = KeychainAccess()
        if((keychainAccess.getPasscode(usernameKeyChain) != nil) && (keychainAccess.getPasscode(passwordKeyChain) != nil)){
            let usernameStr:String = keychainAccess.getPasscode(usernameKeyChain) as! String
            print("get access token username")
            print(usernameStr)
            var passwordStr:String = keychainAccess.getPasscode(passwordKeyChain) as! String
            let publicService = PublicService()
            passwordStr = publicService.passwordEncode(passwordStr)
            var urlPath: String = getOauthTokenURL + "username=" + usernameStr + "&password=" + passwordStr
            urlPath = urlPath.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
            let url: NSURL = NSURL(string: urlPath)!
            let request: NSURLRequest = NSURLRequest(URL: url)
            let response: AutoreleasingUnsafeMutablePointer<NSURLResponse?> = nil
            
//            // Permananent, session, whatever.
//            NSURLCredential *credential = [NSURLCredential credentialWithUser:username password:password persistence: NSURLCredentialPersistencePermanent];
//            // Make sure that if the server you are accessing presents a realm, you set it here.
//            NSURLProtectionSpace *protectionSpace = [[NSURLProtectionSpace alloc] initWithHost:@"blah.com" port:0 protocol:@"http" realm:nil authenticationMethod:NSURLAuthenticationMethodHTTPBasic];
//            // Store it
//            [[NSURLCredentialStorage sharedCredentialStorage] setDefaultCredential:credential forProtectionSpace:protectionSpace];
            
            
            let getTokenResponseData = try? NSURLConnection.sendSynchronousRequest(request, returningResponse: response)
            let session = NSURLSession.sharedSession()
//            let httpsSession = NSURLSession(configuration: <#T##NSURLSessionConfiguration#>)
//
//            let task = session.dataTaskWithRequest(request, completionHandler: {(data, response, error)->Void in
//                
//                let str: NSString = NSString(data: data!, encoding: NSUTF8StringEncoding)!
//                
//                print(str)
//                var jsonResult: AnyObject?
//                do {
//                    jsonResult = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers)
//                } catch let error1 as NSError {
//                    jsonResult = nil
//                }
//                let accessToken  = jsonResult?.objectForKey("access_token")
//                let refreshToken = jsonResult?.objectForKey("refresh_token")
//                profileSet.setObject(accessToken, forKey: accessNSUserData)
//                profileSet.setObject(refreshToken, forKey: refreshNSUserData)
//                
//            })
            if getTokenResponseData != nil {
                var jsonResult: AnyObject?
                do {
                    jsonResult = try NSJSONSerialization.JSONObjectWithData(getTokenResponseData!, options: NSJSONReadingOptions.MutableContainers)
                } catch let error1 as NSError {
                    error.memory = error1
                    jsonResult = nil
                }
                let accessToken  = jsonResult?.objectForKey("access_token")
                let refreshToken = jsonResult?.objectForKey("refresh_token")
                profileSet.setObject(accessToken, forKey: accessNSUserData)
                profileSet.setObject(refreshToken, forKey: refreshNSUserData)
            }
        }else{
            profileSet.setObject(nil, forKey: accessNSUserData)
            profileSet.setObject(nil, forKey: refreshNSUserData)
        }
    }

}
