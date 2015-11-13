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

    func addPost(post : NSDictionary)->NSData{
        var accessToken = NSUserDefaults.standardUserDefaults().objectForKey(accessNSUserData)
        if accessToken == nil {
            getAccessToken.getAccessToken()
            accessToken = NSUserDefaults.standardUserDefaults().objectForKey(accessNSUserData)
        }
        let urlPath:String = (addPostURL as String) + "?access_token=" + (accessToken as! String);
        let url : NSURL = NSURL(string: urlPath)!
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        var response: AutoreleasingUnsafeMutablePointer<NSURLResponse?> = nil
        request.HTTPBody = NSJSONSerialization.dataWithJSONObject(post, options: NSJSONWritingOptions.allZeros, error: nil)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        var addPostRespData = NSURLConnection.sendSynchronousRequest(request, returningResponse: response, error: nil)
        return addPostRespData!
    }
    
    func addUser(userType:String)->NSData{
        //upload UserInfo to Server
        let keychainAccess = KeychainAccess()
        let profileSet = NSUserDefaults.standardUserDefaults()
        
        var email    = String()
        var username = String()
        var password = String()
        var displayname = String()
        var gender   = String()
        var isSmocking = Int()
        var pathological = String()
        var stage   = Int()
        var age     = Int()
        var cancerType  = String()
        var metastasis  = String()
        var image       = String()
        var geneticMutation = String()
        if profileSet.objectForKey(emailNSUserData) != nil{
            email = (profileSet.objectForKey(emailNSUserData))! as! String
        }
        if keychainAccess.getPasscode(usernameKeyChain) != nil{
            username = (keychainAccess.getPasscode(usernameKeyChain))! as! String
        }
        if keychainAccess.getPasscode(passwordKeyChain) != nil{
            password = (keychainAccess.getPasscode(passwordKeyChain))! as! String
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
            stage = (profileSet.objectForKey(stageNSUserData))! as! Int
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
            image = (profileSet.objectForKey(imageNSUserData))! as! String
        }
        if profileSet.objectForKey(geneticMutationNSUserData) != nil{
            geneticMutation = profileSet.objectForKey(geneticMutationNSUserData)! as! String
        }
        var addUserBody = NSDictionary(objects: [email, username, password, gender, isSmocking, pathological, stage, age, cancerType, metastasis, image, userType, displayname, geneticMutation], forKeys: ["email", "username","password", "gender", "isSmoking", "pathological", "stage", "age", "cancerType", "metastasis","image", "userType", "displayname", "geneticMutation"])
        let addUserUrl = NSURL(string: addNewUserURL)
        let request: NSMutableURLRequest = NSMutableURLRequest(URL: addUserUrl!)
        request.HTTPMethod = "POST"
        request.HTTPBody = NSJSONSerialization.dataWithJSONObject(addUserBody, options:  NSJSONWritingOptions.allZeros, error: nil)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        return NSURLConnection.sendSynchronousRequest(request,returningResponse: nil,error: nil)!
//        var connection: NSURLConnection = NSURLConnection(request: request, delegate: self, startImmediately: true)!
    }
    
    func getFeeds(latestFetchTimestamp: Int)->NSData?{
        getAccessToken.getAccessToken()
        let accessToken = NSUserDefaults.standardUserDefaults().objectForKey(accessNSUserData)
        if accessToken == nil{
            let url:NSURL = NSURL(string: getBroadcastsByTagsURL)!
            let request = NSMutableURLRequest(URL: url)
            request.HTTPMethod = "POST"
            var requestBody = NSMutableDictionary()
            requestBody.setValue(latestFetchTimestamp, forKey: "begin")
            requestBody.setValue(Int(NSDate().timeIntervalSince1970*1000), forKey: "end")
            if NSUserDefaults.standardUserDefaults().objectForKey(favTagsNSUserData) != nil{
                requestBody.setObject(NSUserDefaults.standardUserDefaults().objectForKey(favTagsNSUserData)!, forKey: "tags")
            }
            request.HTTPBody = NSJSONSerialization.dataWithJSONObject(requestBody, options: NSJSONWritingOptions.allZeros, error: nil)
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            let inputStr: NSString = NSString(data: request.HTTPBody!, encoding: NSUTF8StringEncoding)!
            return NSURLConnection.sendSynchronousRequest(request,returningResponse: nil,error: nil)
        }else{
            let urlPath:String = (getFeedsURL as String) + "?access_token=" + (accessToken as! String);
            let url : NSURL = NSURL(string: urlPath)!
            let request = NSMutableURLRequest(URL: url)
            request.HTTPMethod = "POST"
            var profileSet = NSUserDefaults.standardUserDefaults()
            var requestBody = NSMutableDictionary()
            requestBody.setValue(latestFetchTimestamp, forKey: "begin")
            requestBody.setValue(Int(NSDate().timeIntervalSince1970*1000), forKey: "end")
            request.HTTPBody = NSJSONSerialization.dataWithJSONObject(requestBody, options: NSJSONWritingOptions.allZeros, error: nil)
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            return NSURLConnection.sendSynchronousRequest(request,returningResponse: nil,error: nil)
        }
    }
    
    func getPreviousFeeds(endTimestamp: Int, count: Int)-> NSData?{
        getAccessToken.getAccessToken()
        let accessToken = NSUserDefaults.standardUserDefaults().objectForKey(accessNSUserData)
        if accessToken == nil{
            let url:NSURL = NSURL(string: getBroadcastsByTagsURL)!
            let request = NSMutableURLRequest(URL: url)
            request.HTTPMethod = "POST"
            var requestBody = NSMutableDictionary()
            requestBody.setValue(endTimestamp, forKey: "end")
            requestBody.setValue(0, forKey: "begin")
            requestBody.setValue(count, forKey: "count")
            if NSUserDefaults.standardUserDefaults().objectForKey(favTagsNSUserData) != nil{
                requestBody.setObject(NSUserDefaults.standardUserDefaults().objectForKey(favTagsNSUserData)!, forKey: "tags")
            }
            request.HTTPBody = NSJSONSerialization.dataWithJSONObject(requestBody, options: NSJSONWritingOptions.allZeros, error: nil)
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            return NSURLConnection.sendSynchronousRequest(request,returningResponse: nil,error: nil)
        }else{
            let urlPath:String = (getFeedsURL as String) + "?access_token=" + (accessToken as! String);
            println(urlPath)
            let url : NSURL = NSURL(string: urlPath)!
            let request = NSMutableURLRequest(URL: url)
            request.HTTPMethod = "POST"
            var profileSet = NSUserDefaults.standardUserDefaults()
            var requestBody = NSMutableDictionary()
            requestBody.setValue(endTimestamp, forKey: "end")
            requestBody.setValue(0, forKey: "begin")
            requestBody.setValue(count, forKey: "count")
            request.HTTPBody = NSJSONSerialization.dataWithJSONObject(requestBody, options: NSJSONWritingOptions.allZeros, error: nil)
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            return NSURLConnection.sendSynchronousRequest(request,returningResponse: nil,error: nil)
        }
    }
    
    func getTreatments(username : String)->NSData{
        let urlPath: String = (getTreatmentsURL as String) + username
        let url : NSURL = NSURL(string: urlPath)!
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        return NSURLConnection.sendSynchronousRequest(request,returningResponse: nil,error: nil)!
    }
    
    func getTreatmentFormat()->NSData{
        let url:NSURL = NSURL(string: getTreatmentformatURL)!
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        return NSURLConnection.sendSynchronousRequest(request,returningResponse: nil,error: nil)!
    }
    
    func getPatientStatusFormat()->NSData{
        let url:NSURL = NSURL(string: getPatientStatusFormatURL)!
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        return NSURLConnection.sendSynchronousRequest(request,returningResponse: nil,error: nil)!
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
        var response: AutoreleasingUnsafeMutablePointer<NSURLResponse?> = nil
        var treatments = NSMutableDictionary()
        treatments.setObject(treatmentList, forKey: "treatments")
        request.HTTPBody = NSJSONSerialization.dataWithJSONObject(treatments, options: NSJSONWritingOptions.allZeros, error: nil)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        var addTreatmentRespData = NSURLConnection.sendSynchronousRequest(request, returningResponse: response, error: nil)
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
        var response: AutoreleasingUnsafeMutablePointer<NSURLResponse?> = nil
        var requestBody = NSMutableDictionary()
        requestBody.setValue(patientStatus, forKey: "patientStatus")
        requestBody.setValue(clinicReport, forKey: "clinicReport")

        request.HTTPBody = NSJSONSerialization.dataWithJSONObject(requestBody as NSDictionary, options: NSJSONWritingOptions.allZeros, error: nil)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        var addPatientStatusRespData = NSURLConnection.sendSynchronousRequest(request, returningResponse: response, error: nil)
        return addPatientStatusRespData!
    }
    
    func getMyProfile()->NSData?{
        getAccessToken.getAccessToken()
        var accessToken = NSUserDefaults.standardUserDefaults().objectForKey(accessNSUserData)
        if accessToken == nil {
            return nil
        }
        let urlPath:String = (getMyProfileURL as String) + "?access_token=" + (accessToken as! String);
        let url : NSURL = NSURL(string: urlPath)!
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "GET"
        var response: AutoreleasingUnsafeMutablePointer<NSURLResponse?> = nil
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        var getProfileRespData = NSURLConnection.sendSynchronousRequest(request, returningResponse: response, error: nil)
        return getProfileRespData!
    }
    
    func getSuggestUserByTags(tagList:NSArray, rangeBegin: Int, rangeEnd: Int)->NSData?{
        getAccessToken.getAccessToken()
        var accessToken = NSUserDefaults.standardUserDefaults().objectForKey(accessNSUserData)
        let url:NSURL = NSURL(string: getSuggestUserByTagsURL)!
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        var requestBody = NSDictionary(objects: [tagList, rangeBegin, rangeEnd], forKeys: ["tags", "rangeBegin", "rangeEnd"])
        request.HTTPBody = NSJSONSerialization.dataWithJSONObject(requestBody, options: NSJSONWritingOptions.allZeros, error: nil)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        var getSuggestUserByTagsData = NSURLConnection.sendSynchronousRequest(request, returningResponse: nil, error: nil)
        return getSuggestUserByTagsData
    }
    
    func getSuggestUserByProfile(rangeBegin: Int, rangeEnd: Int)->NSData?{
        getAccessToken.getAccessToken()
        var accessToken = NSUserDefaults.standardUserDefaults().objectForKey(accessNSUserData)
        let url:NSURL = NSURL(string: getSuggestUserByProfileURL + "?access_token=" + (accessToken as! String))!
        println(getSuggestUserByProfileURL + "?access_token=" + (accessToken as! String))
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        var requestBody = NSDictionary(objects: [rangeBegin, rangeEnd], forKeys: ["beginIndex","endIndex"])
        request.HTTPBody = NSJSONSerialization.dataWithJSONObject(requestBody, options: NSJSONWritingOptions.allZeros, error: nil)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        var getSuggestUserByProfileData = NSURLConnection.sendSynchronousRequest(request, returningResponse: nil, error: nil)
        return getSuggestUserByProfileData
    }
    
    func addFollowing(username:String)->NSData{
        getAccessToken.getAccessToken()
        var accessToken = NSUserDefaults.standardUserDefaults().objectForKey(accessNSUserData) as! String
        let urlPath: String = addFollowingURL + "/" + username + "?access_token=" + accessToken
        var url: NSURL = NSURL(string: urlPath)!
        var request: NSMutableURLRequest = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        return (NSURLConnection.sendSynchronousRequest(request, returningResponse: nil, error: nil))!
    }
    
    func getUserFavTags()->NSData?{
        getAccessToken.getAccessToken()
        if NSUserDefaults.standardUserDefaults().objectForKey(accessNSUserData) == nil {
            return nil
        }
        var accessToken = NSUserDefaults.standardUserDefaults().objectForKey(accessNSUserData) as! String
        let urlPath:String = getUserFavTagsURL + "?access_token=" + accessToken
        var url:NSURL = NSURL(string: urlPath)!
        var request: NSMutableURLRequest = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        return (NSURLConnection.sendSynchronousRequest(request, returningResponse: nil, error: nil))!
    }
    
    func getUserDetail(username:String)->NSData?{
        getAccessToken.getAccessToken()
        if NSUserDefaults.standardUserDefaults().objectForKey(accessNSUserData) == nil{
            return nil
        }
        var accessToken = NSUserDefaults.standardUserDefaults().objectForKey(accessNSUserData) as! String
        let urlPath:String = getUserDetailURL + "/" + username + "?access_token=" + accessToken
        var url:NSURL = NSURL(string: urlPath)!
        var request: NSMutableURLRequest = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        return (NSURLConnection.sendSynchronousRequest(request, returningResponse: nil, error: nil))
    }
    
    func getClinicReportFormat()->NSData{
        let url:NSURL = NSURL(string: getClinicReportFormatURL)!
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        return NSURLConnection.sendSynchronousRequest(request,returningResponse: nil,error: nil)!
    }
    
    func getPostsByUsername(username:String)->NSData{
        getAccessToken.getAccessToken()
        var accessToken = NSUserDefaults.standardUserDefaults().objectForKey(accessNSUserData) as! String
        let urlPath:String = getPostsByUsernameURL + "/" + username + "?access_token=" + accessToken
        let url:NSURL = NSURL(string: urlPath)!
        var request: NSMutableURLRequest = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        return (NSURLConnection.sendSynchronousRequest(request, returningResponse: nil, error: nil))!
    }
    
    func getAccessToken(username: String, password: String)->NSData{
        var urlPath: String = getOauthTokenURL + "username=" + username + "&password=" + password
        urlPath = urlPath.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        var url: NSURL = NSURL(string: urlPath)!
        var request: NSURLRequest = NSURLRequest(URL: url)
        return NSURLConnection.sendSynchronousRequest(request, returningResponse: nil, error: nil)!
    }
    
    func resetPassword(newPassword: String)->NSData?{
        getAccessToken.getAccessToken()
        var accessToken = NSUserDefaults.standardUserDefaults().objectForKey(accessNSUserData) as! String
        let urlPath:String = resetPasswordURL + "?access_token=" + accessToken
        let url:NSURL = NSURL(string: urlPath)!
//        var requestBody = NSMutableDictionary()
        var request: NSMutableURLRequest = NSMutableURLRequest(URL: url)
//        requestBody.setValue(newPassword, forKey: "password")
        request.HTTPBody = newPassword.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        return NSURLConnection.sendSynchronousRequest(request, returningResponse: nil, error: nil)
    }
    
    func getFollowingUsers(username: String)->NSData?{
        getAccessToken.getAccessToken()
        if NSUserDefaults.standardUserDefaults().objectForKey(accessNSUserData) == nil {
            return nil
        }
        var accessToken = NSUserDefaults.standardUserDefaults().objectForKey(accessNSUserData) as! String
        let urlPath:String = getFollowingUserURL + "/" + username + "?access_token=" + accessToken
        let url:NSURL = NSURL(string: urlPath)!
        var request: NSMutableURLRequest = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        return NSURLConnection.sendSynchronousRequest(request, returningResponse: nil, error: nil)
    }
    
    func getFollowerUsers(username: String)->NSData?{
        getAccessToken.getAccessToken()
        if NSUserDefaults.standardUserDefaults().objectForKey(accessNSUserData) == nil {
            return nil
        }
        var accessToken = NSUserDefaults.standardUserDefaults().objectForKey(accessNSUserData) as! String
        let urlPath:String = getFollowerUserURL + "/" + username + "?access_token=" + accessToken
        let url:NSURL = NSURL(string: urlPath)!
        var request: NSMutableURLRequest = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        return NSURLConnection.sendSynchronousRequest(request, returningResponse: nil, error: nil)
    }
    
    func getCommentsByUsername(username: String)-> NSData?{
        getAccessToken.getAccessToken()
        if NSUserDefaults.standardUserDefaults().objectForKey(accessNSUserData) == nil {
            return nil
        }
        var accessToken = NSUserDefaults.standardUserDefaults().objectForKey(accessNSUserData) as! String
        let urlPath:String = getCommentsByUsernameURL + "/" + username + "?access_token=" + accessToken
        let url:NSURL = NSURL(string: urlPath)!
        var request: NSMutableURLRequest = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        return NSURLConnection.sendSynchronousRequest(request, returningResponse: nil, error: nil)
    }
    
    func addComment(postID:Int, body:String)->NSData?{
        getAccessToken.getAccessToken()
        var accessToken = NSUserDefaults.standardUserDefaults().objectForKey(accessNSUserData)
        if accessToken == nil {
            return nil
        }
        let urlPath:String = (addCommentsURL as String) + "?access_token=" + (accessToken as! String);
        let url : NSURL = NSURL(string: urlPath)!
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        var requestBody = NSMutableDictionary()
        requestBody.setValue(postID, forKey: "postID")
        requestBody.setValue(body, forKey: "body")
        request.HTTPBody = NSJSONSerialization.dataWithJSONObject(requestBody, options: NSJSONWritingOptions.allZeros, error: nil)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        return NSURLConnection.sendSynchronousRequest(request, returningResponse: nil, error: nil)
    }
    
    func getTagList()->NSData? {
        let urlPath: String = getTagListURL
        var url: NSURL = NSURL(string: urlPath)!
        var request: NSURLRequest = NSURLRequest(URL: url)
        var response: AutoreleasingUnsafeMutablePointer<NSURLResponse?> = nil
        return NSURLConnection.sendSynchronousRequest(request, returningResponse: response, error: nil)
    }
    
    func updateUserTag(selectedTags: NSArray)->NSData{
        let getAccessToken: GetAccessToken = GetAccessToken()
        getAccessToken.getAccessToken()
        let accessToken: AnyObject? = NSUserDefaults.standardUserDefaults().objectForKey(accessNSUserData)
        var url: NSURL = NSURL(string: updateFavTagsURL + "?access_token=" + (accessToken as! String))!
        var request: NSMutableURLRequest = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        var tagListDic = NSMutableDictionary()
        tagListDic.setValue(selectedTags, forKey: "tags")
        request.HTTPBody = NSJSONSerialization.dataWithJSONObject(tagListDic, options: NSJSONWritingOptions.allZeros, error: nil)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        var response: AutoreleasingUnsafeMutablePointer<NSURLResponse?> = nil
        return NSURLConnection.sendSynchronousRequest(request, returningResponse: response, error: nil)!
    }
    
    func updateUser(updateUserInfo: NSDictionary)->NSData{
        let getAccessToken: GetAccessToken = GetAccessToken()
        getAccessToken.getAccessToken()
        let accessToken = NSUserDefaults.standardUserDefaults().objectForKey(accessNSUserData)
        var url: NSURL = NSURL(string: updateUserURL + "?access_token=" + (accessToken as! String))!
        var request: NSMutableURLRequest = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.HTTPBody = NSJSONSerialization.dataWithJSONObject(updateUserInfo, options: NSJSONWritingOptions.allZeros, error: nil)
        println(NSString(data: (request.HTTPBody)!, encoding: NSUTF8StringEncoding)!)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
//        if updateUserInfo.objectForKey("image") is String{
//            println(updateUserInfo.objectForKey("image"))
//        }
        var response: AutoreleasingUnsafeMutablePointer<NSURLResponse?> = nil
        return NSURLConnection.sendSynchronousRequest(request, returningResponse: response, error: nil)!
    }
    
    func deleteFromSuggestedUser(username: String)->NSData{
        let getAccessToken: GetAccessToken = GetAccessToken()
        getAccessToken.getAccessToken()
        let accessToken = NSUserDefaults.standardUserDefaults().objectForKey(accessNSUserData)
        var url: NSURL = NSURL(string: deleteFromSuggestedUserURL + "/" + username + "?access_token=" + (accessToken as! String))!
        var request: NSMutableURLRequest = NSMutableURLRequest(URL: url)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        return NSURLConnection.sendSynchronousRequest(request, returningResponse: nil, error: nil)!
    }
    
    func getUpdatedPostCount(latestFetchTimestamp:Int)->NSData?{
        getAccessToken.getAccessToken()
        let accessToken = NSUserDefaults.standardUserDefaults().objectForKey(accessNSUserData)
        if accessToken == nil{
            let url:NSURL = NSURL(string: getBroadcastsByTagsCountURL)!
            let request = NSMutableURLRequest(URL: url)
            request.HTTPMethod = "POST"
            var requestBody = NSMutableDictionary()
            requestBody.setValue(latestFetchTimestamp, forKey: "begin")
            println(latestFetchTimestamp)
            requestBody.setValue(Int(NSDate().timeIntervalSince1970*1000), forKey: "end")
            if NSUserDefaults.standardUserDefaults().objectForKey(favTagsNSUserData) != nil{
                requestBody.setObject(NSUserDefaults.standardUserDefaults().objectForKey(favTagsNSUserData)!, forKey: "tags")
            }
            request.HTTPBody = NSJSONSerialization.dataWithJSONObject(requestBody, options: NSJSONWritingOptions.allZeros, error: nil)
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            return NSURLConnection.sendSynchronousRequest(request,returningResponse: nil,error: nil)
        }else{
            let urlPath:String = (getUpdatedPostCountURL as String) + "?access_token=" + (accessToken as! String);
            let url : NSURL = NSURL(string: urlPath)!
            let request = NSMutableURLRequest(URL: url)
            request.HTTPMethod = "POST"
            var profileSet = NSUserDefaults.standardUserDefaults()
            var requestBody = NSMutableDictionary()
            requestBody.setValue(latestFetchTimestamp, forKey: "begin")
            requestBody.setValue(Int(NSDate().timeIntervalSince1970*1000), forKey: "end")
            request.HTTPBody = NSJSONSerialization.dataWithJSONObject(requestBody, options: NSJSONWritingOptions.allZeros, error: nil)
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            return NSURLConnection.sendSynchronousRequest(request,returningResponse: nil,error: nil)
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
            request.HTTPBody = NSJSONSerialization.dataWithJSONObject(treatment, options: NSJSONWritingOptions.allZeros, error: nil)
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            var response: AutoreleasingUnsafeMutablePointer<NSURLResponse?> = nil
            return NSURLConnection.sendSynchronousRequest(request, returningResponse: response, error: nil)!
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
            request.HTTPBody = NSJSONSerialization.dataWithJSONObject(treatment, options: NSJSONWritingOptions.allZeros, error: nil)
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            var response: AutoreleasingUnsafeMutablePointer<NSURLResponse?> = nil
            return NSURLConnection.sendSynchronousRequest(request, returningResponse: response, error: nil)!
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
            var response: AutoreleasingUnsafeMutablePointer<NSURLResponse?> = nil
            return NSURLConnection.sendSynchronousRequest(request, returningResponse: response, error: nil)!
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
            var response: AutoreleasingUnsafeMutablePointer<NSURLResponse?> = nil
            return NSURLConnection.sendSynchronousRequest(request, returningResponse: response, error: nil)!
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
            var response: AutoreleasingUnsafeMutablePointer<NSURLResponse?> = nil
            return NSURLConnection.sendSynchronousRequest(request, returningResponse: response, error: nil)
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
            request.HTTPMethod = "GET"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            var response: AutoreleasingUnsafeMutablePointer<NSURLResponse?> = nil
            return NSURLConnection.sendSynchronousRequest(request, returningResponse: response, error: nil)!
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
            request.HTTPMethod = "GET"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            var response: AutoreleasingUnsafeMutablePointer<NSURLResponse?> = nil
            return NSURLConnection.sendSynchronousRequest(request, returningResponse: response, error: nil)!
        }else{
            return nil
        }
    }
    
    func getMentionedPostList(endTimestamp: Int, count: Int)->NSData?{
        getAccessToken.getAccessToken()
        let accessToken = NSUserDefaults.standardUserDefaults().objectForKey(accessNSUserData)
        if accessToken != nil{
            let urlPath:String = (getMentionedPostListURL as String) + "?access_token=" + (accessToken as! String);
            let url : NSURL = NSURL(string: urlPath)!
            let request = NSMutableURLRequest(URL: url)
            request.HTTPMethod = "POST"
            var requestBody = NSMutableDictionary()
            requestBody.setValue(endTimestamp, forKey: "end")
            requestBody.setValue(0, forKey: "begin")
            requestBody.setValue(count, forKey: "count")
            request.HTTPBody = NSJSONSerialization.dataWithJSONObject(requestBody, options: NSJSONWritingOptions.allZeros, error: nil)
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            var response: AutoreleasingUnsafeMutablePointer<NSURLResponse?> = nil
            return NSURLConnection.sendSynchronousRequest(request, returningResponse: response, error: nil)!
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
            request.HTTPMethod = "GET"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            var response: AutoreleasingUnsafeMutablePointer<NSURLResponse?> = nil
            return NSURLConnection.sendSynchronousRequest(request, returningResponse: response, error: nil)!
        }else{
            return nil
        }
    }
    
    func sendSyncGetCommentListRequest(postID: Int)->NSData{
        let url : NSURL = NSURL(string: getCommentListByPostURL+((postID as! NSNumber).stringValue))!
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "GET"
        var response: AutoreleasingUnsafeMutablePointer<NSURLResponse?> = nil
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        var getCommentsRespData = NSURLConnection.sendSynchronousRequest(request, returningResponse: response, error: nil)
        return getCommentsRespData!
    }
    
    func getPostById(postID: Int)->NSData{
        let url : NSURL = NSURL(string: getPostByIdURL+((postID as! NSNumber).stringValue))!
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "GET"
        var response: AutoreleasingUnsafeMutablePointer<NSURLResponse?> = nil
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        var getPostByIdRespData = NSURLConnection.sendSynchronousRequest(request, returningResponse: response, error: nil)
        let str: NSString = NSString(data: getPostByIdRespData!, encoding: NSUTF8StringEncoding)!
        return getPostByIdRespData!
    }
}