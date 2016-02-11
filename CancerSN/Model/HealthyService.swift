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

    func addPost(post : NSDictionary)->NSData{
        var accessToken = NSUserDefaults.standardUserDefaults().objectForKey(accessNSUserData)
//        if accessToken == nil {
            getAccessToken.getAccessToken()
            accessToken = NSUserDefaults.standardUserDefaults().objectForKey(accessNSUserData)
//        }
        let urlPath:String = (addPostURL as String) + "?access_token=" + (accessToken as! String);
        let url : NSURL = NSURL(string: urlPath)!
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        let response: AutoreleasingUnsafeMutablePointer<NSURLResponse?> = nil
        request.HTTPBody = try? NSJSONSerialization.dataWithJSONObject(post, options: NSJSONWritingOptions())
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        let addPostRespData = try? NSURLConnection.sendSynchronousRequest(request, returningResponse: response)
        return addPostRespData!
    }
    
    func addUser(userType:String)->NSDictionary{
        //upload UserInfo to Server
        let keychainAccess = KeychainAccess()
        let profileSet = NSUserDefaults.standardUserDefaults()
        
        var email: String?
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
        var imageInfo = NSMutableDictionary()
        var geneticMutation = String()
        var phone: String?
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
//            image = (profileSet.objectForKey(imageNSUserData))! as! String
        }
        if profileSet.objectForKey(geneticMutationNSUserData) != nil{
            geneticMutation = profileSet.objectForKey(geneticMutationNSUserData)! as! String
        }
        let passwordStr = publicService.passwordEncode(password)
        let addUserBody = NSDictionary(objects: [email!, passwordStr, gender, isSmocking, pathological, stage, age, cancerType, metastasis, imageInfo, userType, displayname, geneticMutation, username, phone!], forKeys: ["email", "password", "gender", "isSmoking", "pathological", "stage", "age", "cancerType", "metastasis","imageInfo", "userType", "displayname", "geneticMutation", "username", "phone"])
        let addUserUrl = NSURL(string: addNewUserURL)
        let request: NSMutableURLRequest = NSMutableURLRequest(URL: addUserUrl!)
        request.HTTPMethod = "POST"
        request.HTTPBody = try? NSJSONSerialization.dataWithJSONObject(addUserBody, options:  NSJSONWritingOptions())
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        return NetRequest.sharedInstance.POST_A(addNewUserURL, parameters: addUserBody as! Dictionary<String, AnyObject>)
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
        if (result?.count == 0) || (result!.objectForKey("result") as! Int) != 1 {
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
        if (result!.objectForKey("result") as! Int) != 1 {
            return false
        }
        return true
    }
    
    func getFeeds(latestFetchTimestamp: Int)->NSData?{
        getAccessToken.getAccessToken()
        let accessToken = NSUserDefaults.standardUserDefaults().objectForKey(accessNSUserData)
        if accessToken == nil{
            let url:NSURL = NSURL(string: getBroadcastsByTagsURL)!
            let request = NSMutableURLRequest(URL: url)
            request.HTTPMethod = "POST"
            let requestBody = NSMutableDictionary()
            requestBody.setValue(latestFetchTimestamp, forKey: "begin")
            requestBody.setValue(Int(NSDate().timeIntervalSince1970*1000), forKey: "end")
            if NSUserDefaults.standardUserDefaults().objectForKey(favTagsNSUserData) != nil{
                requestBody.setObject(NSUserDefaults.standardUserDefaults().objectForKey(favTagsNSUserData)!, forKey: "tags")
            }
            request.HTTPBody = try? NSJSONSerialization.dataWithJSONObject(requestBody, options: NSJSONWritingOptions())
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            let inputStr: NSString = NSString(data: request.HTTPBody!, encoding: NSUTF8StringEncoding)!
            return try? NSURLConnection.sendSynchronousRequest(request,returningResponse: nil)
        }else{
            let urlPath:String = (getFeedsURL as String) + "?access_token=" + (accessToken as! String);
            let url : NSURL = NSURL(string: urlPath)!
            let request = NSMutableURLRequest(URL: url)
            request.HTTPMethod = "POST"
            var profileSet = NSUserDefaults.standardUserDefaults()
            let requestBody = NSMutableDictionary()
            requestBody.setValue(latestFetchTimestamp, forKey: "begin")
            requestBody.setValue(Int(NSDate().timeIntervalSince1970*1000), forKey: "end")
            requestBody.setValue(keychainAccess.getPasscode(usernameKeyChain), forKey: "username")
            request.HTTPBody = try? NSJSONSerialization.dataWithJSONObject(requestBody, options: NSJSONWritingOptions())
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            let inputStr: NSString = NSString(data: request.HTTPBody!, encoding: NSUTF8StringEncoding)!
            let returndata = try? NSURLConnection.sendSynchronousRequest(request,returningResponse: nil)
            print(NSString(data: returndata!, encoding: NSUTF8StringEncoding))
            return try? NSURLConnection.sendSynchronousRequest(request,returningResponse: nil)
        }
    }
    
    func getPreviousFeeds(endTimestamp: Int, count: Int)-> NSData?{
        getAccessToken.getAccessToken()
        let accessToken = NSUserDefaults.standardUserDefaults().objectForKey(accessNSUserData)
        if accessToken == nil{
            let url:NSURL = NSURL(string: getBroadcastsByTagsURL)!
            let request = NSMutableURLRequest(URL: url)
            request.HTTPMethod = "POST"
            let requestBody = NSMutableDictionary()
            requestBody.setValue(endTimestamp, forKey: "end")
            requestBody.setValue(0, forKey: "begin")
            requestBody.setValue(count, forKey: "count")
            if NSUserDefaults.standardUserDefaults().objectForKey(favTagsNSUserData) != nil{
                requestBody.setObject(NSUserDefaults.standardUserDefaults().objectForKey(favTagsNSUserData)!, forKey: "tags")
            }
            request.HTTPBody = try? NSJSONSerialization.dataWithJSONObject(requestBody, options: NSJSONWritingOptions())
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            return try? NSURLConnection.sendSynchronousRequest(request,returningResponse: nil)
        }else{
            let urlPath:String = (getFeedsURL as String) + "?access_token=" + (accessToken as! String);
            print(urlPath)
            let url : NSURL = NSURL(string: urlPath)!
            let request = NSMutableURLRequest(URL: url)
            request.HTTPMethod = "POST"
            var profileSet = NSUserDefaults.standardUserDefaults()
            let requestBody = NSMutableDictionary()
            requestBody.setValue(endTimestamp, forKey: "end")
            requestBody.setValue(0, forKey: "begin")
            requestBody.setValue(count, forKey: "count")
            requestBody.setValue(keychainAccess.getPasscode(usernameKeyChain), forKey: "username")
            request.HTTPBody = try? NSJSONSerialization.dataWithJSONObject(requestBody, options: NSJSONWritingOptions())
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            return try? NSURLConnection.sendSynchronousRequest(request,returningResponse: nil)
        }
    }
    
    func getTreatments(username : String)->NSData{
        let urlPath: String = (getTreatmentsURL as String) + username
        let url : NSURL = NSURL(string: urlPath)!
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        let requestBody = NSMutableDictionary()
        requestBody.setValue(username, forKey: "username")
        request.HTTPBody = try? NSJSONSerialization.dataWithJSONObject(requestBody, options: NSJSONWritingOptions())
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        return try! NSURLConnection.sendSynchronousRequest(request,returningResponse: nil)
    }
    
    func getTreatmentFormat()->NSData{
        let url:NSURL = NSURL(string: getTreatmentformatURL)!
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        return try! NSURLConnection.sendSynchronousRequest(request,returningResponse: nil)
    }
    
    func getPatientStatusFormat()->NSData{
        let url:NSURL = NSURL(string: getPatientStatusFormatURL)!
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        return try! NSURLConnection.sendSynchronousRequest(request,returningResponse: nil)
    }
    
    func addTreatment(treatmentList:NSArray)->NSData{
        var accessToken = NSUserDefaults.standardUserDefaults().objectForKey(accessNSUserData)
        if accessToken == nil {
            getAccessToken.getAccessToken()
            accessToken = NSUserDefaults.standardUserDefaults().objectForKey(accessNSUserData)
        }
        let urlPath:String = (addTreatmentURL as String) + "?access_token=" + (accessToken as! String);
        let url : NSURL = NSURL(string: urlPath)!
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        let response: AutoreleasingUnsafeMutablePointer<NSURLResponse?> = nil
        let requestBody = NSMutableDictionary()
        requestBody.setObject(treatmentList, forKey: "treatments")
        requestBody.setObject(keychainAccess.getPasscode(usernameKeyChain)!, forKey: "insertUsername")
        request.HTTPBody = try? NSJSONSerialization.dataWithJSONObject(requestBody, options: NSJSONWritingOptions())
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        let addTreatmentRespData = try? NSURLConnection.sendSynchronousRequest(request, returningResponse: response)
        return addTreatmentRespData!
    }
    
    func addPatientStatus(patientStatus:NSDictionary, clinicReport:NSDictionary)->NSData{
        var accessToken = NSUserDefaults.standardUserDefaults().objectForKey(accessNSUserData)
        if accessToken == nil {
            getAccessToken.getAccessToken()
            accessToken = NSUserDefaults.standardUserDefaults().objectForKey(accessNSUserData)
        }
        let urlPath:String = (addPatientStatusURL as String) + "?access_token=" + (accessToken as! String);
        let url : NSURL = NSURL(string: urlPath)!
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        let response: AutoreleasingUnsafeMutablePointer<NSURLResponse?> = nil
        let requestBody = NSMutableDictionary()
        requestBody.setValue(patientStatus, forKey: "patientStatus")
        requestBody.setValue(clinicReport, forKey: "clinicReport")
        requestBody.setValue(keychainAccess.getPasscode(usernameKeyChain), forKey: "insertUsername")
        request.HTTPBody = try? NSJSONSerialization.dataWithJSONObject(requestBody as NSDictionary, options: NSJSONWritingOptions())
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        print(NSString(data: request.HTTPBody!, encoding: NSUTF8StringEncoding))
        let addPatientStatusRespData = try? NSURLConnection.sendSynchronousRequest(request, returningResponse: response)
        print(NSString(data: addPatientStatusRespData!, encoding: NSUTF8StringEncoding))
        return addPatientStatusRespData!
    }
    
    func getMyProfile()->NSData?{
        getAccessToken.getAccessToken()
        let accessToken = NSUserDefaults.standardUserDefaults().objectForKey(accessNSUserData)
        if accessToken == nil {
            return nil
        }
        let urlPath:String = (getMyProfileURL as String) + "?access_token=" + (accessToken as! String);
        let url : NSURL = NSURL(string: urlPath)!
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "GET"
        let response: AutoreleasingUnsafeMutablePointer<NSURLResponse?> = nil
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        let getProfileRespData = try? NSURLConnection.sendSynchronousRequest(request, returningResponse: response)
        return getProfileRespData!
    }
    
    func getSuggestUserByTags(tagList:NSArray, rangeBegin: Int, rangeEnd: Int)->NSData?{
        getAccessToken.getAccessToken()
        var accessToken = NSUserDefaults.standardUserDefaults().objectForKey(accessNSUserData)
        let url:NSURL = NSURL(string: getSuggestUserByTagsURL)!
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        let requestBody = NSDictionary(objects: [tagList, rangeBegin, rangeEnd], forKeys: ["tags", "rangeBegin", "rangeEnd"])
        request.HTTPBody = try? NSJSONSerialization.dataWithJSONObject(requestBody, options: NSJSONWritingOptions())
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        let getSuggestUserByTagsData = try? NSURLConnection.sendSynchronousRequest(request, returningResponse: nil)
        return getSuggestUserByTagsData
    }
    
    func getSuggestUserByProfile(rangeBegin: Int, rangeEnd: Int)->NSData?{
        getAccessToken.getAccessToken()
        let accessToken = NSUserDefaults.standardUserDefaults().objectForKey(accessNSUserData)
        let url:NSURL = NSURL(string: getSuggestUserByProfileURL + "?access_token=" + (accessToken as! String))!
        print(getSuggestUserByProfileURL + "?access_token=" + (accessToken as! String))
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        let requestBody = NSDictionary(objects: [rangeBegin, rangeEnd, keychainAccess.getPasscode(usernameKeyChain) as! String], forKeys: ["beginIndex","endIndex", "username"])
        request.HTTPBody = try? NSJSONSerialization.dataWithJSONObject(requestBody, options: NSJSONWritingOptions())
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        let getSuggestUserByProfileData = try? NSURLConnection.sendSynchronousRequest(request, returningResponse: nil)
        return getSuggestUserByProfileData
    }
    
    func addFollowing(username:String)->NSData{
        getAccessToken.getAccessToken()
        let accessToken = NSUserDefaults.standardUserDefaults().objectForKey(accessNSUserData) as! String
        let urlPath: String = addFollowingURL + "/" + username + "?access_token=" + accessToken
        let url: NSURL = NSURL(string: urlPath)!
        let request: NSMutableURLRequest = NSMutableURLRequest(URL: url)
        let requestBody = NSMutableDictionary()
        requestBody.setObject(username, forKey: "followingUser")
        requestBody.setObject(keychainAccess.getPasscode(usernameKeyChain)!, forKey: "username")
        request.HTTPBody = try? NSJSONSerialization.dataWithJSONObject(requestBody, options: NSJSONWritingOptions())
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        return (try? NSURLConnection.sendSynchronousRequest(request, returningResponse: nil))!
    }
    
    func getUserFavTags()->NSData?{
        getAccessToken.getAccessToken()
        if NSUserDefaults.standardUserDefaults().objectForKey(accessNSUserData) == nil {
            return nil
        }
        let accessToken = NSUserDefaults.standardUserDefaults().objectForKey(accessNSUserData) as! String
        let urlPath:String = getUserFavTagsURL + "?access_token=" + accessToken
        let url:NSURL = NSURL(string: urlPath)!
        let request: NSMutableURLRequest = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.HTTPBody = (keychainAccess.getPasscode(usernameKeyChain) as! String).dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        return (try? NSURLConnection.sendSynchronousRequest(request, returningResponse: nil))!
    }
    
    func getUserDetail(username:String)->NSData?{
        getAccessToken.getAccessToken()
        if NSUserDefaults.standardUserDefaults().objectForKey(accessNSUserData) == nil{
            return nil
        }
        let accessToken = NSUserDefaults.standardUserDefaults().objectForKey(accessNSUserData) as! String
        let urlPath:String = getUserDetailURL + "?access_token=" + accessToken
        let url:NSURL = NSURL(string: urlPath)!
        let request: NSMutableURLRequest = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        let requestBody = NSMutableDictionary()
        requestBody.setValue(username, forKey: "username")
        request.HTTPBody = try? NSJSONSerialization.dataWithJSONObject(requestBody, options: NSJSONWritingOptions())
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        return (try? NSURLConnection.sendSynchronousRequest(request, returningResponse: nil))
    }
    
    func getClinicReportFormat()->NSData{
        let url:NSURL = NSURL(string: getClinicReportFormatURL)!
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        let requestBody = NSMutableDictionary()
        requestBody.setValue(keychainAccess.getPasscode(usernameKeyChain), forKey: "username")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.HTTPBody = try? NSJSONSerialization.dataWithJSONObject(requestBody, options: NSJSONWritingOptions())
        return try! NSURLConnection.sendSynchronousRequest(request,returningResponse: nil)
    }
    
    func getPostsByUsername(username:String)->NSData{
        getAccessToken.getAccessToken()
        let accessToken = NSUserDefaults.standardUserDefaults().objectForKey(accessNSUserData) as! String
        let urlPath:String = getPostsByUsernameURL + "/" + username + "?access_token=" + accessToken
        let url:NSURL = NSURL(string: urlPath)!
        let request: NSMutableURLRequest = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        return (try? NSURLConnection.sendSynchronousRequest(request, returningResponse: nil))!
    }
    
    func getAccessToken(username: String, password: String)->NSData{
        var urlPath: String = getOauthTokenURL + "username=" + username + "&password=" + password
        urlPath = urlPath.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        let url: NSURL = NSURL(string: urlPath)!
        let request: NSURLRequest = NSURLRequest(URL: url)
        return try! NSURLConnection.sendSynchronousRequest(request, returningResponse: nil)
    }
    
    func resetPassword(newPassword: String)->Bool{
        getAccessToken.getAccessToken()
        let accessToken = NSUserDefaults.standardUserDefaults().objectForKey(accessNSUserData) as! String
        let urlPath:String = resetPasswordURL + "?access_token=" + accessToken
        let requestBody = NSDictionary(object: newPassword, forKey: "password")
//        requestBody.setValue(newPassword, forKey: "password")
        let result = NetRequest.sharedInstance.POST_A(urlPath, parameters: requestBody as! Dictionary<String, AnyObject>)
        if (result.count == 0) || (result.objectForKey("result") as! Int) != 1 {
            return false
        }
        return true
    }
    
    func resetPasswordWithCode(requestBody: NSDictionary)->Bool{
        let urlPath:String = resetPasswordWithCodeURL
        let result = NetRequest.sharedInstance.POST_A(urlPath, parameters: requestBody as! Dictionary<String, AnyObject>)
        if (result.count == 0) || (result.objectForKey("result") as! Int) != 1 {
            return false
        }
        return true
    }
    
    func getFollowingUsers(username: String)->NSData?{
        getAccessToken.getAccessToken()
        if NSUserDefaults.standardUserDefaults().objectForKey(accessNSUserData) == nil {
            return nil
        }
        let accessToken = NSUserDefaults.standardUserDefaults().objectForKey(accessNSUserData) as! String
        let urlPath:String = getFollowingUserURL + "/" + username + "?access_token=" + accessToken
        let url:NSURL = NSURL(string: urlPath)!
        let request: NSMutableURLRequest = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        let requestBody = NSMutableDictionary()
        requestBody.setValue(username, forKey: "username")
        request.HTTPBody = try? NSJSONSerialization.dataWithJSONObject(requestBody, options: NSJSONWritingOptions())

        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        return try? NSURLConnection.sendSynchronousRequest(request, returningResponse: nil)
    }
    
    func getFollowerUsers(username: String)->NSData?{
        getAccessToken.getAccessToken()
        if NSUserDefaults.standardUserDefaults().objectForKey(accessNSUserData) == nil {
            return nil
        }
        let accessToken = NSUserDefaults.standardUserDefaults().objectForKey(accessNSUserData) as! String
        let urlPath:String = getFollowerUserURL + "/" + username + "?access_token=" + accessToken
        let url:NSURL = NSURL(string: urlPath)!
        let request: NSMutableURLRequest = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        let requestBody = NSMutableDictionary()
        requestBody.setValue(username, forKey: "username")
        request.HTTPBody = try? NSJSONSerialization.dataWithJSONObject(requestBody, options: NSJSONWritingOptions())
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        return try? NSURLConnection.sendSynchronousRequest(request, returningResponse: nil)
    }
    
    func getCommentsByUsername(username: String)-> NSData?{
        getAccessToken.getAccessToken()
        if NSUserDefaults.standardUserDefaults().objectForKey(accessNSUserData) == nil {
            return nil
        }
        let accessToken = NSUserDefaults.standardUserDefaults().objectForKey(accessNSUserData) as! String
        let urlPath:String = getCommentsByUsernameURL + "/" + username + "?access_token=" + accessToken
        let url:NSURL = NSURL(string: urlPath)!
        let request: NSMutableURLRequest = NSMutableURLRequest(URL: url)
        let requestBody = NSMutableDictionary()
        requestBody.setValue(username, forKey: "username")
        request.HTTPBody = try? NSJSONSerialization.dataWithJSONObject(requestBody, options: NSJSONWritingOptions())
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        return try? NSURLConnection.sendSynchronousRequest(request, returningResponse: nil)
    }
    
    func addComment(postID:Int, body:String)->NSData?{
        getAccessToken.getAccessToken()
        let accessToken = NSUserDefaults.standardUserDefaults().objectForKey(accessNSUserData)
        if accessToken == nil {
            return nil
        }
        let urlPath:String = (addCommentsURL as String) + "?access_token=" + (accessToken as! String);
        let url : NSURL = NSURL(string: urlPath)!
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        let requestBody = NSMutableDictionary()
        requestBody.setValue(postID, forKey: "postID")
        requestBody.setValue(body, forKey: "body")
        requestBody.setValue(keychainAccess.getPasscode(usernameKeyChain), forKey: "insertUsername")
        request.HTTPBody = try? NSJSONSerialization.dataWithJSONObject(requestBody, options: NSJSONWritingOptions())
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        return try? NSURLConnection.sendSynchronousRequest(request, returningResponse: nil)
    }
    
    func getTagList()->NSData? {
        let urlPath: String = getTagListURL
        let url: NSURL = NSURL(string: urlPath)!
        let request: NSURLRequest = NSURLRequest(URL: url)
        let response: AutoreleasingUnsafeMutablePointer<NSURLResponse?> = nil
        return try? NSURLConnection.sendSynchronousRequest(request, returningResponse: response)
    }
    
    func updateUserTag(selectedTags: NSArray)->NSData{
        let getAccessToken: GetAccessToken = GetAccessToken()
        getAccessToken.getAccessToken()
        let accessToken: AnyObject? = NSUserDefaults.standardUserDefaults().objectForKey(accessNSUserData)
        let url: NSURL = NSURL(string: updateFavTagsURL + "?access_token=" + (accessToken as! String))!
        let request: NSMutableURLRequest = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        let tagListDic = NSMutableDictionary()
        tagListDic.setValue(selectedTags, forKey: "tags")
        tagListDic.setValue(keychainAccess.getPasscode(usernameKeyChain), forKey: "username")
        request.HTTPBody = try? NSJSONSerialization.dataWithJSONObject(tagListDic, options: NSJSONWritingOptions())
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        let response: AutoreleasingUnsafeMutablePointer<NSURLResponse?> = nil
        return try! NSURLConnection.sendSynchronousRequest(request, returningResponse: response)
    }
    
    func updateUser(updateUserInfo: NSDictionary)->NSData{
        let getAccessToken: GetAccessToken = GetAccessToken()
        getAccessToken.getAccessToken()
        let accessToken = NSUserDefaults.standardUserDefaults().objectForKey(accessNSUserData)
        let url: NSURL = NSURL(string: updateUserURL + "?access_token=" + (accessToken as! String))!
        let request: NSMutableURLRequest = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.HTTPBody = try? NSJSONSerialization.dataWithJSONObject(updateUserInfo, options: NSJSONWritingOptions())
        print(NSString(data: (request.HTTPBody)!, encoding: NSUTF8StringEncoding)!)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
//        if updateUserInfo.objectForKey("image") is String{
//            println(updateUserInfo.objectForKey("image"))
//        }
        let response: AutoreleasingUnsafeMutablePointer<NSURLResponse?> = nil
        return try! NSURLConnection.sendSynchronousRequest(request, returningResponse: response)
    }
    
    func deleteFromSuggestedUser(username: String)->NSData{
        let getAccessToken: GetAccessToken = GetAccessToken()
        getAccessToken.getAccessToken()
        let accessToken = NSUserDefaults.standardUserDefaults().objectForKey(accessNSUserData)
        let url: NSURL = NSURL(string: deleteFromSuggestedUserURL + "/" + username + "?access_token=" + (accessToken as! String))!
        let request: NSMutableURLRequest = NSMutableURLRequest(URL: url)
        let requestBody = NSMutableDictionary()
        requestBody.setObject(username, forKey: "username")
        requestBody.setObject(keychainAccess.getPasscode(usernameKeyChain)!, forKey: "suggestedUsername")
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        return try! NSURLConnection.sendSynchronousRequest(request, returningResponse: nil)
    }
    
    func getUpdatedPostCount(latestFetchTimestamp:Int)->NSData?{
        getAccessToken.getAccessToken()
        let accessToken = NSUserDefaults.standardUserDefaults().objectForKey(accessNSUserData)
        if accessToken == nil{
            let url:NSURL = NSURL(string: getBroadcastsByTagsCountURL)!
            let request = NSMutableURLRequest(URL: url)
            request.HTTPMethod = "POST"
            let requestBody = NSMutableDictionary()
            requestBody.setValue(latestFetchTimestamp, forKey: "begin")
            print(latestFetchTimestamp)
            requestBody.setValue(Int(NSDate().timeIntervalSince1970*1000), forKey: "end")
            if NSUserDefaults.standardUserDefaults().objectForKey(favTagsNSUserData) != nil{
                requestBody.setObject(NSUserDefaults.standardUserDefaults().objectForKey(favTagsNSUserData)!, forKey: "tags")
            }
            request.HTTPBody = try? NSJSONSerialization.dataWithJSONObject(requestBody, options: NSJSONWritingOptions())
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            return try? NSURLConnection.sendSynchronousRequest(request,returningResponse: nil)
        }else{
            let urlPath:String = (getUpdatedPostCountURL as String) + "?access_token=" + (accessToken as! String);
            let url : NSURL = NSURL(string: urlPath)!
            let request = NSMutableURLRequest(URL: url)
            request.HTTPMethod = "POST"
            var profileSet = NSUserDefaults.standardUserDefaults()
            let requestBody = NSMutableDictionary()
            requestBody.setValue(latestFetchTimestamp, forKey: "begin")
            requestBody.setValue(Int(NSDate().timeIntervalSince1970*1000), forKey: "end")
            requestBody.setValue(keychainAccess.getPasscode(usernameKeyChain), forKey: "username")
            request.HTTPBody = try? NSJSONSerialization.dataWithJSONObject(requestBody, options: NSJSONWritingOptions())
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            return try? NSURLConnection.sendSynchronousRequest(request,returningResponse: nil)
        }
    }
    
    func updateTreatment(treatment: NSDictionary)->NSData?{
        getAccessToken.getAccessToken()
        let accessToken = NSUserDefaults.standardUserDefaults().objectForKey(accessNSUserData)
        if accessToken != nil{
            let urlPath:String = (updateTreatmentURL as String) + "?access_token=" + (accessToken as! String);
            let url : NSURL = NSURL(string: urlPath)!
            let request = NSMutableURLRequest(URL: url)
            request.HTTPMethod = "POST"
            request.HTTPBody = try? NSJSONSerialization.dataWithJSONObject(treatment, options: NSJSONWritingOptions())
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            let response: AutoreleasingUnsafeMutablePointer<NSURLResponse?> = nil
            return try! NSURLConnection.sendSynchronousRequest(request, returningResponse: response)
        }else{
            return nil
        }
    }
    
    func deleteTreatment(treatment: NSDictionary)->NSData?{
        getAccessToken.getAccessToken()
        let accessToken = NSUserDefaults.standardUserDefaults().objectForKey(accessNSUserData)
        if accessToken != nil{
            let urlPath:String = (deleteTreatmentURL as String) + "?access_token=" + (accessToken as! String);
            let url : NSURL = NSURL(string: urlPath)!
            let request = NSMutableURLRequest(URL: url)
            request.HTTPMethod = "POST"
            request.HTTPBody = try? NSJSONSerialization.dataWithJSONObject(treatment, options: NSJSONWritingOptions())
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            let response: AutoreleasingUnsafeMutablePointer<NSURLResponse?> = nil
            return try! NSURLConnection.sendSynchronousRequest(request, returningResponse: response)
        }else{
            return nil
        }
    }
    
    func increaseNewFollowCount(username: String)->NSData?{
        getAccessToken.getAccessToken()
        let accessToken = NSUserDefaults.standardUserDefaults().objectForKey(accessNSUserData)
        if accessToken != nil{
            let urlPath:String = (increaseNewFollowCountURL as String) + "/" + username + "?access_token=" + (accessToken as! String);
            let url : NSURL = NSURL(string: urlPath)!
            let request = NSMutableURLRequest(URL: url)
            request.HTTPMethod = "GET"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            let response: AutoreleasingUnsafeMutablePointer<NSURLResponse?> = nil
            return try! NSURLConnection.sendSynchronousRequest(request, returningResponse: response)
        }else{
            return nil
        }
    }
    
    func refreshNewFollowCount()->NSData?{
        getAccessToken.getAccessToken()
        let accessToken = NSUserDefaults.standardUserDefaults().objectForKey(accessNSUserData)
        if accessToken != nil{
            let urlPath:String = (refreshNewFollowCountURL as String) + "?access_token=" + (accessToken as! String);
            let url : NSURL = NSURL(string: urlPath)!
            let request = NSMutableURLRequest(URL: url)
            request.HTTPMethod = "GET"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            let response: AutoreleasingUnsafeMutablePointer<NSURLResponse?> = nil
            return try! NSURLConnection.sendSynchronousRequest(request, returningResponse: response)
        }else{
            return nil
        }
    }
    
    func selectNewFollowCount()->NSData?{
        getAccessToken.getAccessToken()
        let accessToken = NSUserDefaults.standardUserDefaults().objectForKey(accessNSUserData)
        if accessToken != nil{
            let urlPath:String = (selectNewFollowCountURL as String) + "?access_token=" + (accessToken as! String);
            let url : NSURL = NSURL(string: urlPath)!
            let request = NSMutableURLRequest(URL: url)
            request.HTTPMethod = "GET"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            let response: AutoreleasingUnsafeMutablePointer<NSURLResponse?> = nil
            return try? NSURLConnection.sendSynchronousRequest(request, returningResponse: response)
        }else{
            return nil
        }
    }
    
    func isFollowingUser(username: String)->NSData?{
        getAccessToken.getAccessToken()
        let accessToken = NSUserDefaults.standardUserDefaults().objectForKey(accessNSUserData)
        if accessToken != nil{
            let urlPath:String = (isFollowingUserURL as String) + "/" + username + "?access_token=" + (accessToken as! String);
            let url : NSURL = NSURL(string: urlPath)!
            let request = NSMutableURLRequest(URL: url)
            let requestBody = NSMutableDictionary()
            requestBody.setObject(username, forKey: "followingUser")
            requestBody.setObject(keychainAccess.getPasscode(usernameKeyChain)!, forKey: "username")
            request.HTTPBody = try? NSJSONSerialization.dataWithJSONObject(requestBody, options: NSJSONWritingOptions())
            request.HTTPMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            let response: AutoreleasingUnsafeMutablePointer<NSURLResponse?> = nil
            return try! NSURLConnection.sendSynchronousRequest(request, returningResponse: response)
        }else{
            return nil
        }
    }
    
    func getUnreadMentionedPostCount()->NSData?{
        getAccessToken.getAccessToken()
        let accessToken = NSUserDefaults.standardUserDefaults().objectForKey(accessNSUserData)
        if accessToken != nil{
            let urlPath:String = (getUnreadMentionedPostCountURL as String) + "?access_token=" + (accessToken as! String);
            let url : NSURL = NSURL(string: urlPath)!
            let request = NSMutableURLRequest(URL: url)
            request.HTTPMethod = "POST"
            let requestBody = NSMutableDictionary()
            requestBody.setValue(keychainAccess.getPasscode(usernameKeyChain), forKey: "username")
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            request.HTTPBody = try? NSJSONSerialization.dataWithJSONObject(requestBody, options: NSJSONWritingOptions())
            let response: AutoreleasingUnsafeMutablePointer<NSURLResponse?> = nil
            return try! NSURLConnection.sendSynchronousRequest(request, returningResponse: response)
        }else{
            return nil
        }
    }
    
    func getMentionedPostList(endTimestamp: Int, count: Int)->NSData?{
        getAccessToken.getAccessToken()
        let accessToken = NSUserDefaults.standardUserDefaults().objectForKey(accessNSUserData)
        if accessToken != nil{
            let urlPath:String = (getMentionedPostListURL as String) + "?access_token=" + (accessToken as! String)
            let url : NSURL = NSURL(string: urlPath)!
            let request = NSMutableURLRequest(URL: url)
            request.HTTPMethod = "POST"
            let requestBody = NSMutableDictionary()
            requestBody.setValue(endTimestamp, forKey: "end")
            requestBody.setValue(0, forKey: "begin")
            requestBody.setValue(count, forKey: "count")
            requestBody.setValue(keychainAccess.getPasscode(usernameKeyChain), forKey: "username")
            request.HTTPBody = try? NSJSONSerialization.dataWithJSONObject(requestBody, options: NSJSONWritingOptions())
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            let response: AutoreleasingUnsafeMutablePointer<NSURLResponse?> = nil
            return try! NSURLConnection.sendSynchronousRequest(request, returningResponse: response)
        }else{
            return nil
        }
    }
    
    func markMentionedPostAsRead()->NSData?{
        getAccessToken.getAccessToken()
        let accessToken = NSUserDefaults.standardUserDefaults().objectForKey(accessNSUserData)
        if accessToken != nil{
            let urlPath:String = (markMentionedPostAsReadURL as String) + "?access_token=" + (accessToken as! String);
            let url : NSURL = NSURL(string: urlPath)!
            let request = NSMutableURLRequest(URL: url)
            request.HTTPMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            let requestBody = NSMutableDictionary()
            requestBody.setValue(keychainAccess.getPasscode(usernameKeyChain), forKey: "username")
            request.HTTPBody = try? NSJSONSerialization.dataWithJSONObject(requestBody, options: NSJSONWritingOptions())
            let response: AutoreleasingUnsafeMutablePointer<NSURLResponse?> = nil
            return try! NSURLConnection.sendSynchronousRequest(request, returningResponse: response)
        }else{
            return nil
        }
    }
    
    func sendSyncGetCommentListRequest(postID: Int)->NSData{
        let url : NSURL = NSURL(string: getCommentListByPostURL+((postID as NSNumber).stringValue))!
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "GET"
        let response: AutoreleasingUnsafeMutablePointer<NSURLResponse?> = nil
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        let getCommentsRespData = try? NSURLConnection.sendSynchronousRequest(request, returningResponse: response)
        return getCommentsRespData!
    }
    
    func getPostById(postID: Int)->NSData{
        let url : NSURL = NSURL(string: getPostByIdURL+((postID as NSNumber).stringValue))!
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "GET"
        let response: AutoreleasingUnsafeMutablePointer<NSURLResponse?> = nil
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        let getPostByIdRespData = try? NSURLConnection.sendSynchronousRequest(request, returningResponse: response)
        let str: NSString = NSString(data: getPostByIdRespData!, encoding: NSUTF8StringEncoding)!
        return getPostByIdRespData!
    }
    
    func getUsername(email:String)-> String{
        var username: String = ""
        getAccessToken.getAccessToken()
        let accessToken = NSUserDefaults.standardUserDefaults().objectForKey(accessNSUserData)
        if accessToken != nil{
//            getAccessToken.getAccessToken()
//            accessToken = NSUserDefaults.standardUserDefaults().objectForKey(accessNSUserData)
//        }else{
            let urlPath: String = getUsernameURL + "?access_token=" + (accessToken as! String)
            let parameters = NSDictionary(object: email, forKey: "username")
            let jsonResult: NSDictionary = NetRequest.sharedInstance.POST_A(urlPath, parameters: parameters as! Dictionary<String, AnyObject>)
            if (jsonResult.objectForKey("result") != nil) && (jsonResult.objectForKey("result") as! Int == 1) && (jsonResult.objectForKey("content") != nil) {
                username = ((jsonResult ).objectForKey("content") as! NSDictionary).objectForKey("result") as! String
            }
        }
        return username
    }

    func queryPostBody(query:String)->NSData?{
        var urlPath: String = queryPostBodyURL + query
        var url: NSURL = NSURL(string: urlPath)!
        var request: NSMutableURLRequest = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        var response: AutoreleasingUnsafeMutablePointer<NSURLResponse?> = nil
        return try? NSURLConnection.sendSynchronousRequest(request, returningResponse: response)
    }

    func getUsersByDisplayname(getMentionedUsernamesRequest: NSDictionary)->NSData?{
        var accessToken = NSUserDefaults.standardUserDefaults().objectForKey(accessNSUserData)
        if accessToken == nil{
            getAccessToken.getAccessToken()
            accessToken = NSUserDefaults.standardUserDefaults().objectForKey(accessNSUserData)
        }
        let urlPath: String = getUsersByDisplaynameURL + "?access_token=" + (accessToken as! String)
        let url: NSURL = NSURL(string: urlPath)!
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        let response: AutoreleasingUnsafeMutablePointer<NSURLResponse?> = nil
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.HTTPBody = try? NSJSONSerialization.dataWithJSONObject(getMentionedUsernamesRequest, options: NSJSONWritingOptions())
        let getUsersByDisplaynameRespData = try? NSURLConnection.sendSynchronousRequest(request, returningResponse: response)
        return getUsersByDisplaynameRespData
    }
}

