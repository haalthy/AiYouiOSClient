//
//  HaalthyService.swift
//  CancerSN
//
//  Created by lily on 8/4/15.
//  Copyright (c) 2015 lily. All rights reserved.
//

import Foundation

class HaalthyService:NSObject{
    let getAccessToken = GetAccessToken()
    let keychainAccess = KeychainAccess()
    let publicService = PublicService()

    func addPost(post : NSDictionary)->Int{
        getAccessToken.getAccessToken()
        let accessToken = NSUserDefaults.standardUserDefaults().objectForKey(accessNSUserData)
        let urlPath:String = (addPostURL as String) + "?access_token=" + (accessToken as! String);
        
        let result: NSDictionary = NetRequest.sharedInstance.POST_A(urlPath, parameters: post as! Dictionary<String, AnyObject>)
        if ((result.count > 0) &&
            (result.objectForKey("result") as! Int) == 1) &&
            (result.objectForKey("content") is NSDictionary){
                return (result.objectForKey("content") as! NSDictionary).objectForKey("count") as! Int
        }else {
            return 0
        }
    }
    
    func addUser(userType:String)->NSDictionary{
        //upload UserInfo to Server
        let keychainAccess = KeychainAccess()
        let profileSet = NSUserDefaults.standardUserDefaults()
        
        var email = String()
        var username = String()
        var password = String()
        var displayname = String()
        var gender   = String()
        var isSmocking = Int()
        var pathological = String()
        var stage   = String()
        var age     = Int()
        var cancerType  = String()
        var metastasis  = String()
//        var image       = String()
        let imageInfo = NSMutableDictionary()
        var geneticMutation = String()
        var phone = String()
        if profileSet.objectForKey(emailNSUserData) != nil{
            email = (profileSet.objectForKey(emailNSUserData))! as! String
        }
        if profileSet.objectForKey(phoneNSUserData) != nil {
            phone = (profileSet.objectForKey(phoneNSUserData))! as! String
        }
        if keychainAccess.getPasscode(usernameKeyChain) != nil{
            username = (keychainAccess.getPasscode(usernameKeyChain))! as String
        }
        if keychainAccess.getPasscode(passwordKeyChain) != nil{
            password = (keychainAccess.getPasscode(passwordKeyChain))! as String
        }
        if profileSet.objectForKey(displaynameUserData) != nil{
            displayname = (profileSet.objectForKey(displaynameUserData))! as! String
        }else{
            displayname = username
        }
        if profileSet.objectForKey(genderNSUserData) != nil{
            gender = (profileSet.objectForKey(genderNSUserData))! as! String
        }
        if profileSet.objectForKey(smokingNSUserData) != nil{
            isSmocking = (profileSet.objectForKey(smokingNSUserData))! as! Int
        }
        if profileSet.objectForKey(pathologicalNSUserData) != nil{
            pathological = (profileSet.objectForKey(pathologicalNSUserData))! as! String
        }
        if profileSet.objectForKey(stageNSUserData) != nil{
            stage = (profileSet.objectForKey(stageNSUserData))! as! String
        }
        if profileSet.objectForKey(ageNSUserData) != nil{
            age = (profileSet.objectForKey(ageNSUserData))! as! Int
        }
        if profileSet.objectForKey(cancerTypeNSUserData) != nil {
            cancerType = (profileSet.objectForKey(cancerTypeNSUserData))! as! String
        }
        if profileSet.objectForKey(metastasisNSUserData) != nil{
            metastasis = (profileSet.objectForKey(metastasisNSUserData))! as! String
        }
        if profileSet.objectForKey(imageNSUserData) != nil{
            imageInfo.setObject(profileSet.objectForKey(imageNSUserData)!, forKey: "data")
            imageInfo.setObject("jpg", forKey: "type")
        }
        if profileSet.objectForKey(geneticMutationNSUserData) != nil{
            geneticMutation = profileSet.objectForKey(geneticMutationNSUserData)! as! String
        }
        let passwordStr = publicService.passwordEncode(password)
        let addUserBody = NSDictionary(objects: [email, passwordStr, gender, isSmocking, pathological, stage, age, cancerType, metastasis, imageInfo, userType, displayname, geneticMutation, username, phone, userType], forKeys: ["email", "password", "gender", "isSmoking", "pathological", "stage", "age", "cancerType", "metastasis","imageInfo", "userType", "displayname", "geneticMutation", "username", "phone", "userType"])
        return NetRequest.sharedInstance.POST_A(addNewUserURL, parameters: addUserBody as! Dictionary<String, AnyObject>)
    }
    
    func updateUser()->NSDictionary {
        //upload UserInfo to Server
        let keychainAccess = KeychainAccess()
        let profileSet = NSUserDefaults.standardUserDefaults()
        
        var gender   = String()
        var age     = Int()
        var cancerType  = String()
        var pathological = String()
        
        var stage   = String()
        var metastasis  = String()
        var geneticMutation = String()
        
        if profileSet.objectForKey(genderNSUserData) != nil{
            gender = (profileSet.objectForKey(genderNSUserData))! as! String
        }
        if profileSet.objectForKey(pathologicalNSUserData) != nil{
            pathological = (profileSet.objectForKey(pathologicalNSUserData))! as! String
        }
        if profileSet.objectForKey(stageNSUserData) != nil{
            stage = (profileSet.objectForKey(stageNSUserData))! as! String
        }
        if profileSet.objectForKey(ageNSUserData) != nil{
            age = (profileSet.objectForKey(ageNSUserData))! as! Int
        }
        if profileSet.objectForKey(cancerTypeNSUserData) != nil {
            cancerType = (profileSet.objectForKey(cancerTypeNSUserData))! as! String
        }
        if profileSet.objectForKey(metastasisNSUserData) != nil{
            metastasis = (profileSet.objectForKey(metastasisNSUserData))! as! String
        }
        if profileSet.objectForKey(geneticMutationNSUserData) != nil{
            geneticMutation = profileSet.objectForKey(geneticMutationNSUserData)! as! String
        }
        
        getAccessToken.getAccessToken()
        let accessToken = NSUserDefaults.standardUserDefaults().objectForKey(accessNSUserData)
        if accessToken != nil {
            let urlPath:String = (updateUserURL as String) + "?access_token=" + (accessToken as! String);
            let url : NSURL = NSURL(string: urlPath)!
            let request = NSMutableURLRequest(URL: url)
            request.HTTPMethod = "POST"
            let requestBody = NSDictionary(objects: [gender, age, cancerType, pathological, stage, metastasis, geneticMutation, keychainAccess.getPasscode(usernameKeyChain)!], forKeys: ["gender", "age", "cancerType", "pathological", "stage", "metastasis", "geneticMutation", "username"])
            
            request.HTTPBody = try? NSJSONSerialization.dataWithJSONObject(requestBody as NSDictionary, options: NSJSONWritingOptions())
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            
            return NetRequest.sharedInstance.POST_A(urlPath, parameters: (requestBody as NSDictionary) as! Dictionary<String, AnyObject>)
            
            
        }else{
            return NSDictionary()
        }
        
    }
    
    func getAuthCode(id: String)->Bool{
        let requestBody = NSDictionary(object: id, forKey: "eMail")
        var result: NSDictionary?

        if publicService.checkIsEmail(id) {
            result = NetRequest.sharedInstance.POST_A(getEmailAuthCodeURL, parameters: requestBody as! Dictionary<String, AnyObject>)
            print("请查收邮箱")
        }else if publicService.checkIsPhoneNumber(id){
            result = NetRequest.sharedInstance.POST_A(getPhoneAuthCodeURL, parameters: requestBody as! Dictionary<String, AnyObject>)
            print("请查收手机短信")
        }else{
            return false
        }
        if (result == nil) || (result?.count == 0) || ((result!.objectForKey("result") != nil) && (result!.objectForKey("result") as! Int) != 1) {
            return false
        }
        return true
    }
    
    func checkAuthCode(checkAuthRequest: NSDictionary)->Bool{
        var result: NSDictionary?
        let id: String = checkAuthRequest.objectForKey("eMail") as! String
        if publicService.checkIsEmail(id) {
            result = NetRequest.sharedInstance.POST_A(checkEmailAuthCodeURL, parameters: checkAuthRequest as! Dictionary<String, AnyObject>)
        }else if publicService.checkIsPhoneNumber(id){
            result = NetRequest.sharedInstance.POST_A(checkPhoneAuthCodeURL, parameters: checkAuthRequest as! Dictionary<String, AnyObject>)
        }else{
            return false
        }
        if (result == nil) || ((result!.objectForKey("result") != nil) && (result!.objectForKey("result") as! Int) != 1) {
            return false
        }
        return true
    }
    
    func getUserFavTags()->NSArray{
        getAccessToken.getAccessToken()
        if NSUserDefaults.standardUserDefaults().objectForKey(accessNSUserData) == nil {
            return []
        }
        let accessToken = NSUserDefaults.standardUserDefaults().objectForKey(accessNSUserData) as! String
        let urlPath:String = getUserFavTagsURL + "?access_token=" + accessToken
        let content = NetRequest.sharedInstance.POST_A(urlPath, parameters: ["username" : keychainAccess.getPasscode(usernameKeyChain)! as String ]).objectForKey("content")
        if content != nil {
            return content as! NSArray
        }else {
            return NSArray()
        }
//        return content
    }
    
    
    func resetPassword(newPassword: String)->Bool{
        getAccessToken.getAccessToken()
        let accessToken = NSUserDefaults.standardUserDefaults().objectForKey(accessNSUserData) as! String
        let urlPath:String = resetPasswordURL + "?access_token=" + accessToken
        let requestBody = NSDictionary(object: newPassword, forKey: "password")
//        requestBody.setValue(newPassword, forKey: "password")
        let result = NetRequest.sharedInstance.POST_A(urlPath, parameters: requestBody as! Dictionary<String, AnyObject>)
        if (result.count == 0) || (result.objectForKey("result") == nil) || (result.objectForKey("result") as! Int) != 1 {
            return false
        }
        return true
    }
    
    func resetPasswordWithCode(requestBody: NSDictionary)->Bool{
        let urlPath:String = resetPasswordWithCodeURL
        let result = NetRequest.sharedInstance.POST_A(urlPath, parameters: requestBody as! Dictionary<String, AnyObject>)
        if (result.count == 0) || (result.objectForKey("result") == nil) || (result.objectForKey("result") as! Int) != 1 {
            return false
        }
        return true
    }
    
    func getFollowingUsers(username: String)->NSArray{
        getAccessToken.getAccessToken()
        if NSUserDefaults.standardUserDefaults().objectForKey(accessNSUserData) == nil {
            return []
        }
        let accessToken = NSUserDefaults.standardUserDefaults().objectForKey(accessNSUserData) as! String
        let urlPath:String = getFollowingUserURL + "?access_token=" + accessToken
        let requestBody = NSMutableDictionary()
        requestBody.setValue(username, forKey: "username")
        let result = NetRequest.sharedInstance.POST_A(urlPath, parameters: requestBody as! Dictionary<String, AnyObject>)
        if (result.objectForKey("content") != nil) &&  (result.objectForKey("result") != nil) && ((result.objectForKey("result") as! Int) == 1) &&  (result.objectForKey("content") is NSArray){
            return result.objectForKey("content") as! NSArray
        }else{
            return []
        }
    }
    
    func updateUserTag(selectedTags: NSArray){
        getAccessToken.getAccessToken()
        let accessToken: AnyObject? = NSUserDefaults.standardUserDefaults().objectForKey(accessNSUserData)
        
        if accessToken != nil{
            let urlPath: String = updateFavTagsURL + "?access_token=" + (accessToken as! String)
            let parameters = NSDictionary(objects: [keychainAccess.getPasscode(usernameKeyChain)!,selectedTags], forKeys: ["username", "tags"])
            NetRequest.sharedInstance.POST(urlPath, parameters: parameters as! Dictionary<String, AnyObject>,
                success: { (content , message) -> Void in
                    
                }) { (content, message) -> Void in
            }
        }
    }
    
    func updateTreatment(treatment: NSDictionary)->Int{
        getAccessToken.getAccessToken()
        var ret: Int = 0
        let accessToken = NSUserDefaults.standardUserDefaults().objectForKey(accessNSUserData)
        if accessToken != nil{
            let urlPath:String = (updateTreatmentURL as String) + "?access_token=" + (accessToken as! String);
            let result: NSDictionary = NetRequest.sharedInstance.POST_A(urlPath, parameters: treatment as! Dictionary<String, AnyObject>)
            if result.objectForKey("result") != nil {
                ret = result.objectForKey("result") as! Int
            }else{
                ret = 0
            }
        }
        return ret
    }
    
    func deleteTreatment(treatment: NSDictionary)->Int{
        getAccessToken.getAccessToken()
        var ret: Int = 0
        let accessToken = NSUserDefaults.standardUserDefaults().objectForKey(accessNSUserData)
        if accessToken != nil{
            let urlPath:String = (deleteTreatmentURL as String) + "?access_token=" + (accessToken as! String);
            let result: NSDictionary = NetRequest.sharedInstance.POST_A(urlPath, parameters: treatment as! Dictionary<String, AnyObject>)
            if result.objectForKey("result") != nil {
                ret = result.objectForKey("result") as! Int
            }else {
                ret = 0
            }
            
        }
        return ret
    }
    
    func getUsername(email:String)-> String{
        var username: String = ""
        getAccessToken.getAccessToken()
        let accessToken = NSUserDefaults.standardUserDefaults().objectForKey(accessNSUserData)
        if accessToken != nil{
            let urlPath: String = getUsernameURL + "?access_token=" + (accessToken as! String)
            let parameters = NSDictionary(object: email, forKey: "username")
            let jsonResult: NSDictionary = NetRequest.sharedInstance.POST_A(urlPath, parameters: parameters as! Dictionary<String, AnyObject>)
            if (jsonResult.objectForKey("result") != nil) && (jsonResult.objectForKey("result") as! Int == 1) && (jsonResult.objectForKey("content") != nil) {
                username = ((jsonResult ).objectForKey("content") as! NSDictionary).objectForKey("result") as! String
            }
        }
        return username
    }

    func getUsersByDisplayname(getMentionedUsernamesRequest: NSDictionary)->NSArray{
        getAccessToken.getAccessToken()
        let accessToken = NSUserDefaults.standardUserDefaults().objectForKey(accessNSUserData)
        let urlPath: String = getUsersByDisplaynameURL + "?access_token=" + (accessToken as! String)

        let result = NetRequest.sharedInstance.POST_A(urlPath, parameters: getMentionedUsernamesRequest as! Dictionary<String, AnyObject>)
        if (result.objectForKey("result") != nil) && ((result.objectForKey("result") as! Int) == 1) &&  (result.objectForKey("content") is NSArray){
            return result.objectForKey("content") as! NSArray
        }else{
            return []
        }
    }
    
    func getClinicTrailList() -> NSArray{
        let result: NSDictionary = NetRequest.sharedInstance.GET_A(getClinicTrailListURL,  parameters: [:])
        if (result.objectForKey("content") != nil) && (result.objectForKey("content") is NSArray){
            return result.objectForKey("content") as! NSArray
        }else{
            return []
        }
    }
    
}

