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

    func addPost(_ post : NSDictionary)->Int{
        getAccessToken.getAccessToken()
        let accessToken = UserDefaults.standard.object(forKey: accessNSUserData)
        let urlPath:String = (addPostURL as String) + "?access_token=" + (accessToken as! String);
        
        let result: NSDictionary = NetRequest.sharedInstance.POST_A(urlPath, parameters: post as! Dictionary<String, AnyObject>)
        if ((result.count > 0) &&
            (result.object(forKey: "result") as! Int) == 1) &&
            (result.object(forKey: "content") is NSDictionary){
                return (result.object(forKey: "content") as! NSDictionary).object(forKey: "count") as! Int
        }else {
            return 0
        }
    }
    
    func addUser(_ userType:String)->NSDictionary{
        //upload UserInfo to Server
        let keychainAccess = KeychainAccess()
        let profileSet = UserDefaults.standard
        
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
        if profileSet.object(forKey: emailNSUserData) != nil{
            email = (profileSet.object(forKey: emailNSUserData))! as! String
        }
        if profileSet.object(forKey: phoneNSUserData) != nil {
            phone = (profileSet.object(forKey: phoneNSUserData))! as! String
        }
        if keychainAccess.getPasscode(usernameKeyChain) != nil{
            username = (keychainAccess.getPasscode(usernameKeyChain))! as String
        }
        if keychainAccess.getPasscode(passwordKeyChain) != nil{
            password = (keychainAccess.getPasscode(passwordKeyChain))! as String
        }
        if profileSet.object(forKey: displaynameUserData) != nil{
            displayname = (profileSet.object(forKey: displaynameUserData))! as! String
        }else{
            displayname = username
        }
        if profileSet.object(forKey: genderNSUserData) != nil{
            gender = (profileSet.object(forKey: genderNSUserData))! as! String
        }
        if profileSet.object(forKey: smokingNSUserData) != nil{
            isSmocking = (profileSet.object(forKey: smokingNSUserData))! as! Int
        }
        if profileSet.object(forKey: pathologicalNSUserData) != nil{
            pathological = (profileSet.object(forKey: pathologicalNSUserData))! as! String
        }
        if profileSet.object(forKey: stageNSUserData) != nil{
            stage = (profileSet.object(forKey: stageNSUserData))! as! String
        }
        if profileSet.object(forKey: ageNSUserData) != nil{
            age = (profileSet.object(forKey: ageNSUserData))! as! Int
        }
        if profileSet.object(forKey: cancerTypeNSUserData) != nil {
            cancerType = (profileSet.object(forKey: cancerTypeNSUserData))! as! String
        }
        if profileSet.object(forKey: metastasisNSUserData) != nil{
            metastasis = (profileSet.object(forKey: metastasisNSUserData))! as! String
        }
        if profileSet.object(forKey: imageNSUserData) != nil{
            imageInfo.setObject(profileSet.object(forKey: imageNSUserData)!, forKey: "data" as NSCopying)
            imageInfo.setObject("jpg", forKey: "type" as NSCopying)
        }
        if profileSet.object(forKey: geneticMutationNSUserData) != nil{
            geneticMutation = profileSet.object(forKey: geneticMutationNSUserData)! as! String
        }
        let passwordStr = publicService.passwordEncode(password)
        let addUserBody = NSDictionary(objects: [email, passwordStr, gender, isSmocking, pathological, stage, age, cancerType, metastasis, imageInfo, userType, displayname, geneticMutation, username, phone, userType], forKeys: ["email" as NSCopying, "password" as NSCopying, "gender" as NSCopying, "isSmoking" as NSCopying, "pathological" as NSCopying, "stage" as NSCopying, "age" as NSCopying, "cancerType" as NSCopying, "metastasis" as NSCopying,"imageInfo" as NSCopying, "userType" as NSCopying, "displayname" as NSCopying, "geneticMutation" as NSCopying, "username" as NSCopying, "phone" as NSCopying, "userType" as NSCopying])
        return NetRequest.sharedInstance.POST_A(addNewUserURL, parameters: addUserBody as! Dictionary<String, AnyObject>)
    }
    
    func updateUser()->NSDictionary {
        //upload UserInfo to Server
        let keychainAccess = KeychainAccess()
        let profileSet = UserDefaults.standard
        
        var gender   = String()
        var age     = Int()
        var cancerType  = String()
        var pathological = String()
        
        var stage   = String()
        var metastasis  = String()
        var geneticMutation = String()
        
        if profileSet.object(forKey: genderNSUserData) != nil{
            gender = (profileSet.object(forKey: genderNSUserData))! as! String
        }
        if profileSet.object(forKey: pathologicalNSUserData) != nil{
            pathological = (profileSet.object(forKey: pathologicalNSUserData))! as! String
        }
        if profileSet.object(forKey: stageNSUserData) != nil{
            stage = (profileSet.object(forKey: stageNSUserData))! as! String
        }
        if profileSet.object(forKey: ageNSUserData) != nil{
            age = (profileSet.object(forKey: ageNSUserData))! as! Int
        }
        if profileSet.object(forKey: cancerTypeNSUserData) != nil {
            cancerType = (profileSet.object(forKey: cancerTypeNSUserData))! as! String
        }
        if profileSet.object(forKey: metastasisNSUserData) != nil{
            metastasis = (profileSet.object(forKey: metastasisNSUserData))! as! String
        }
        if profileSet.object(forKey: geneticMutationNSUserData) != nil{
            geneticMutation = profileSet.object(forKey: geneticMutationNSUserData)! as! String
        }
        
        getAccessToken.getAccessToken()
        let accessToken = UserDefaults.standard.object(forKey: accessNSUserData)
        if accessToken != nil {
            let urlPath:String = (updateUserURL as String) + "?access_token=" + (accessToken as! String);
            let url : URL = URL(string: urlPath)!
            let request = NSMutableURLRequest(url: url)
            request.httpMethod = "POST"
            let requestBody = NSDictionary(objects: [gender, age, cancerType, pathological, stage, metastasis, geneticMutation, keychainAccess.getPasscode(usernameKeyChain)!], forKeys: ["gender" as NSCopying, "age" as NSCopying, "cancerType" as NSCopying, "pathological" as NSCopying, "stage" as NSCopying, "metastasis" as NSCopying, "geneticMutation" as NSCopying, "username" as NSCopying])
            
            request.httpBody = try? JSONSerialization.data(withJSONObject: requestBody as NSDictionary, options: JSONSerialization.WritingOptions())
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            
            return NetRequest.sharedInstance.POST_A(urlPath, parameters: (requestBody as NSDictionary) as! Dictionary<String, AnyObject>)
            
            
        }else{
            return NSDictionary()
        }
        
    }
    
    func getAuthCode(_ id: String)->Bool{
        let requestBody = NSDictionary(object: id, forKey: "eMail" as NSCopying)
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
        if (result == nil) || (result?.count == 0) || ((result!.object(forKey: "result") != nil) && (result!.object(forKey: "result") as! Int) != 1) {
            return false
        }
        return true
    }
    
    func checkAuthCode(_ checkAuthRequest: NSDictionary)->Bool{
        var result: NSDictionary?
        let id: String = checkAuthRequest.object(forKey: "eMail") as! String
        if publicService.checkIsEmail(id) {
            result = NetRequest.sharedInstance.POST_A(checkEmailAuthCodeURL, parameters: checkAuthRequest as! Dictionary<String, AnyObject>)
        }else if publicService.checkIsPhoneNumber(id){
            result = NetRequest.sharedInstance.POST_A(checkPhoneAuthCodeURL, parameters: checkAuthRequest as! Dictionary<String, AnyObject>)
        }else{
            return false
        }
        if (result == nil) || ((result!.object(forKey: "result") != nil) && (result!.object(forKey: "result") as! Int) != 1) {
            return false
        }
        return true
    }
    
    func getUserFavTags()->NSArray{
        getAccessToken.getAccessToken()
        if UserDefaults.standard.object(forKey: accessNSUserData) == nil {
            return []
        }
        let accessToken = UserDefaults.standard.object(forKey: accessNSUserData) as! String
        let urlPath:String = getUserFavTagsURL + "?access_token=" + accessToken
        let content = NetRequest.sharedInstance.POST_A(urlPath, parameters: ["username" : keychainAccess.getPasscode(usernameKeyChain)! as AnyObject ]).object(forKey: "content")
        if content != nil {
            return content as! NSArray
        }else {
            return NSArray()
        }
//        return content
    }
    
    
    func resetPassword(_ newPassword: String)->Bool{
        getAccessToken.getAccessToken()
        let accessToken = UserDefaults.standard.object(forKey: accessNSUserData) as! String
        let urlPath:String = resetPasswordURL + "?access_token=" + accessToken
        let requestBody = NSDictionary(object: newPassword, forKey: "password" as NSCopying)
//        requestBody.setValue(newPassword, forKey: "password")
        let result = NetRequest.sharedInstance.POST_A(urlPath, parameters: requestBody as! Dictionary<String, AnyObject>)
        if (result.count == 0) || (result.object(forKey: "result") == nil) || (result.object(forKey: "result") as! Int) != 1 {
            return false
        }
        return true
    }
    
    func resetPasswordWithCode(_ requestBody: NSDictionary)->Bool{
        let urlPath:String = resetPasswordWithCodeURL
        let result = NetRequest.sharedInstance.POST_A(urlPath, parameters: requestBody as! Dictionary<String, AnyObject>)
        if (result.count == 0) || (result.object(forKey: "result") == nil) || (result.object(forKey: "result") as! Int) != 1 {
            return false
        }
        return true
    }
    
    func getFollowingUsers(_ username: String)->NSArray{
        getAccessToken.getAccessToken()
        if UserDefaults.standard.object(forKey: accessNSUserData) == nil {
            return []
        }
        let accessToken = UserDefaults.standard.object(forKey: accessNSUserData) as! String
        let urlPath:String = getFollowingUserURL + "?access_token=" + accessToken
        let requestBody = NSMutableDictionary()
        requestBody.setValue(username, forKey: "username")
        let result = NetRequest.sharedInstance.POST_A(urlPath, parameters: requestBody as! Dictionary<String, AnyObject>)
        if (result.object(forKey: "content") != nil) &&  (result.object(forKey: "result") != nil) && ((result.object(forKey: "result") as! Int) == 1) &&  (result.object(forKey: "content") is NSArray){
            return result.object(forKey: "content") as! NSArray
        }else{
            return []
        }
    }
    
    func updateUserTag(_ selectedTags: NSArray){
        getAccessToken.getAccessToken()
        let accessToken: AnyObject? = UserDefaults.standard.object(forKey: accessNSUserData) as AnyObject?
        
        if accessToken != nil{
            let urlPath: String = updateFavTagsURL + "?access_token=" + (accessToken as! String)
            let parameters = NSDictionary(objects: [keychainAccess.getPasscode(usernameKeyChain)!,selectedTags], forKeys: ["username" as NSCopying, "tags" as NSCopying])
            NetRequest.sharedInstance.POST(urlPath, parameters: parameters as! Dictionary<String, AnyObject>,
                success: { (content , message) -> Void in
                    
                }) { (content, message) -> Void in
            }
        }
    }
    
    func updateTreatment(_ treatment: NSDictionary)->Int{
        getAccessToken.getAccessToken()
        var ret: Int = 0
        let accessToken = UserDefaults.standard.object(forKey: accessNSUserData)
        if accessToken != nil{
            let urlPath:String = (updateTreatmentURL as String) + "?access_token=" + (accessToken as! String);
            let result: NSDictionary = NetRequest.sharedInstance.POST_A(urlPath, parameters: treatment as! Dictionary<String, AnyObject>)
            if result.object(forKey: "result") != nil {
                ret = result.object(forKey: "result") as! Int
            }else{
                ret = 0
            }
        }
        return ret
    }
    
    func deleteTreatment(_ treatment: NSDictionary)->Int{
        getAccessToken.getAccessToken()
        var ret: Int = 0
        let accessToken = UserDefaults.standard.object(forKey: accessNSUserData)
        if accessToken != nil{
            let urlPath:String = (deleteTreatmentURL as String) + "?access_token=" + (accessToken as! String);
            let result: NSDictionary = NetRequest.sharedInstance.POST_A(urlPath, parameters: treatment as! Dictionary<String, AnyObject>)
            if result.object(forKey: "result") != nil {
                ret = result.object(forKey: "result") as! Int
            }else {
                ret = 0
            }
            
        }
        return ret
    }
    
    func getUsername(_ email:String)-> String{
        var username: String = ""
        getAccessToken.getAccessToken()
        let accessToken = UserDefaults.standard.object(forKey: accessNSUserData)
        if accessToken != nil{
            let urlPath: String = getUsernameURL + "?access_token=" + (accessToken as! String)
            let parameters = NSDictionary(object: email, forKey: "username" as NSCopying)
            let jsonResult: NSDictionary = NetRequest.sharedInstance.POST_A(urlPath, parameters: parameters as! Dictionary<String, AnyObject>)
            if (jsonResult.object(forKey: "result") != nil) && (jsonResult.object(forKey: "result") as! Int == 1) && (jsonResult.object(forKey: "content") != nil) {
                username = ((jsonResult ).object(forKey: "content") as! NSDictionary).object(forKey: "result") as! String
            }
        }
        return username
    }

    func getUsersByDisplayname(_ getMentionedUsernamesRequest: NSDictionary)->NSArray{
        getAccessToken.getAccessToken()
        let accessToken = UserDefaults.standard.object(forKey: accessNSUserData)
        let urlPath: String = getUsersByDisplaynameURL + "?access_token=" + (accessToken as! String)

        let result = NetRequest.sharedInstance.POST_A(urlPath, parameters: getMentionedUsernamesRequest as! Dictionary<String, AnyObject>)
        if (result.object(forKey: "result") != nil) && ((result.object(forKey: "result") as! Int) == 1) &&  (result.object(forKey: "content") is NSArray){
            return result.object(forKey: "content") as! NSArray
        }else{
            return []
        }
    }
    
    func getClinicTrailList() -> NSArray{
        let result: NSDictionary = NetRequest.sharedInstance.GET_A(getClinicTrailListURL,  parameters: [:])
        if (result.object(forKey: "content") != nil) && (result.object(forKey: "content") is NSArray){
            return result.object(forKey: "content") as! NSArray
        }else{
            return []
        }
    }
    
}

