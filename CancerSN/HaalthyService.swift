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
        println(urlPath)
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
    
    func addUser()->NSData{
        //upload UserInfo to Server
        let keychainAccess = KeychainAccess()
        let profileSet = NSUserDefaults.standardUserDefaults()
        
        var email    = String()
        var username = String()
        var password = String()
        var gender   = String()
        var isSmocking = Int()
        var pathological = String()
        var stage   = Int()
        var age     = Int()
        var cancerType  = String()
        var metastasis  = String()
        var image       = String()
        if profileSet.objectForKey(emailNSUserData) != nil{
            email = (profileSet.objectForKey(emailNSUserData))! as! String
        }
        if keychainAccess.getPasscode(usernameKeyChain) != nil{
            username = (keychainAccess.getPasscode(usernameKeyChain))! as! String
        }
        if keychainAccess.getPasscode(passwordKeyChain) != nil{
            password = (keychainAccess.getPasscode(passwordKeyChain))! as! String
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
//        var addUserBody = NSDictionary(objects: [(profileSet.objectForKey(emailNSUserData))!, (keychainAccess.getPasscode(usernameKeyChain))!, (keychainAccess.getPasscode(passwordKeyChain))!, (profileSet.objectForKey(genderNSUserData))!, (profileSet.objectForKey(smokingNSUserData))!, (profileSet.objectForKey(pathologicalNSUserData))!, (profileSet.objectForKey(stageNSUserData))!, (profileSet.objectForKey(ageNSUserData))!, (profileSet.objectForKey(cancerTypeNSUserData))!, (profileSet.objectForKey(metastasisNSUserData))!,(profileSet.objectForKey(imageNSUserData))!], forKeys: ["email", "username","password", "gender", "isSmoking", "pathological", "stage", "age", "cancerType", "metastasis","image"])
        var addUserBody = NSDictionary(objects: [email, username, password, gender, isSmocking, pathological, stage, age, cancerType, metastasis, image], forKeys: ["email", "username","password", "gender", "isSmoking", "pathological", "stage", "age", "cancerType", "metastasis","image"])
        let addUserUrl = NSURL(string: addNewUserURL)
        let request: NSMutableURLRequest = NSMutableURLRequest(URL: addUserUrl!)
        request.HTTPMethod = "POST"
        request.HTTPBody = NSJSONSerialization.dataWithJSONObject(addUserBody, options:  NSJSONWritingOptions.allZeros, error: nil)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        return NSURLConnection.sendSynchronousRequest(request,returningResponse: nil,error: nil)!
//        var connection: NSURLConnection = NSURLConnection(request: request, delegate: self, startImmediately: true)!
    }
    
    func getFeeds(latestFetchTimestamp:Int)->NSData{
        getAccessToken.getAccessToken()
        let accessToken = NSUserDefaults.standardUserDefaults().objectForKey(accessNSUserData)
        let urlPath:String = (getFeedsURL as String) + "?access_token=" + (accessToken as! String);
        println(urlPath)
        let url : NSURL = NSURL(string: urlPath)!
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        var profileSet = NSUserDefaults.standardUserDefaults()
        var requestBody = NSMutableDictionary()
//        if((profileSet.objectForKey(latestFeedsUpdateTimestamp)) != nil){
//            requestBody.setValue(Int((profileSet.objectForKey(latestFeedsUpdateTimestamp) as! Float)*1000), forKey: "begin")
//        }else{
//            requestBody.setValue(0, forKey: "begin")
//        }
        println(latestFetchTimestamp)
        requestBody.setValue(latestFetchTimestamp, forKey: "begin")
        println(NSDate().timeIntervalSince1970)
        println(Int(NSDate().timeIntervalSince1970*100000))
        requestBody.setValue(Int(NSDate().timeIntervalSince1970*100000), forKey: "end")
        request.HTTPBody = NSJSONSerialization.dataWithJSONObject(requestBody, options: NSJSONWritingOptions.allZeros, error: nil)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        return NSURLConnection.sendSynchronousRequest(request,returningResponse: nil,error: nil)!
    }
    
    func getTreatments(username : String)->NSData{
        let urlPath = getTreatmentsURL + "/{" + username + "}"
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
        println(urlPath)
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
        
        let str: NSString = NSString(data: addTreatmentRespData!, encoding: NSUTF8StringEncoding)!
        println(str)
        let inputStr: NSString = NSString(data: request.HTTPBody!, encoding: NSUTF8StringEncoding)!
        println(inputStr)
        return addTreatmentRespData!
    }
    
    func addPatientStatus(patientStatus:NSDictionary, clinicReport:NSDictionary)->NSData{
        var accessToken = NSUserDefaults.standardUserDefaults().objectForKey(accessNSUserData)
        if accessToken == nil {
            getAccessToken.getAccessToken()
            accessToken = NSUserDefaults.standardUserDefaults().objectForKey(accessNSUserData)
        }
        let urlPath:String = (addPatientStatusURL as String) + "?access_token=" + (accessToken as! String);
        println(urlPath)
        let url : NSURL = NSURL(string: urlPath)!
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        var response: AutoreleasingUnsafeMutablePointer<NSURLResponse?> = nil
        var requestBody = NSMutableDictionary()
        requestBody.setValue(patientStatus, forKey: "patientStatus")
        requestBody.setValue(clinicReport, forKey: "clinicReport")
//        let inputStr: NSString = NSString(data: requestBody, encoding: NSUTF8StringEncoding)!
//        println(inputStr)
        request.HTTPBody = NSJSONSerialization.dataWithJSONObject(requestBody as NSDictionary, options: NSJSONWritingOptions.allZeros, error: nil)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        var addPatientStatusRespData = NSURLConnection.sendSynchronousRequest(request, returningResponse: response, error: nil)
        
        let str: NSString = NSString(data: addPatientStatusRespData!, encoding: NSUTF8StringEncoding)!
        println(str)
//        let inputStr: NSString = NSString(data: request.HTTPBody!, encoding: NSUTF8StringEncoding)!
//        println(inputStr)
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
        
        let str: NSString = NSString(data: getProfileRespData!, encoding: NSUTF8StringEncoding)!
        println(str)
        return getProfileRespData!
    }
    
    func getSuggestUserByTags(tagList:NSArray, rangeBegin: Int, rangeEnd: Int)->NSData{
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
        let inputStr: NSString = NSString(data: request.HTTPBody!, encoding: NSUTF8StringEncoding)!
        println(getSuggestUserByTagsURL)
        println(inputStr)
        return getSuggestUserByTagsData!
    }
    
    func getSuggestUserByProfile(rangeBegin: Int, rangeEnd: Int)->NSData{
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
        return getSuggestUserByProfileData!
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
        println(urlPath)
        var url:NSURL = NSURL(string: urlPath)!
        var request: NSMutableURLRequest = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        return (NSURLConnection.sendSynchronousRequest(request, returningResponse: nil, error: nil))!
    }
    
    func getUserDetail(username:String)->NSData{
        getAccessToken.getAccessToken()
        var accessToken = NSUserDefaults.standardUserDefaults().objectForKey(accessNSUserData) as! String
        let urlPath:String = getUserDetailURL + "/" + username + "?access_token=" + accessToken
        println(urlPath)
        var url:NSURL = NSURL(string: urlPath)!
        var request: NSMutableURLRequest = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        return (NSURLConnection.sendSynchronousRequest(request, returningResponse: nil, error: nil))!
    }
    
    func getClinicReportFormat()->NSData{
        let url:NSURL = NSURL(string: getClinicReportFormatURL)!
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        return NSURLConnection.sendSynchronousRequest(request,returningResponse: nil,error: nil)!
    }
}