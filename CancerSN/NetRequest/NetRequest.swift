//
//  NetRequest.swift
//  CancerSN
//
//  Created by lay on 15/12/26.
//  Copyright © 2015年 lily. All rights reserved.
//

import UIKit
import Foundation

// 获取数据成功 block
typealias successBlock = (content: AnyObject, message: String) -> Void
// 获取数据失败 block
typealias failedBlock = (content: AnyObject, message: String) -> Void


class NetRequest: NSObject {
    
    
    // MARK: - 单例模式
    class var sharedInstance: NetRequest {
        
        get {
            struct SingletonStruct {
                static var onceToken: dispatch_once_t = 0
                static var singleton: NetRequest? = nil
            }
            dispatch_once(&SingletonStruct.onceToken) { () -> Void in
                SingletonStruct.singleton = NetRequest()
            }
            
            // 得到变量
            return SingletonStruct.singleton!
        }
    }
    
    // MARK: - POST请求
    
    // MARK: include Params
    
    func POST(url: String, parameters: Dictionary<String, AnyObject>, success: successBlock, failed: failedBlock) {
    
        let manager = NetRequestManager(url: url, method: "POST", parameters: parameters) { (data, response, error) -> Void in
            
            self.getDataAndCheck(data, error, success, failed)
        }
        manager.netWorkFire()
    }
    
    // MARK: not Params
    
    func POST(url: String, success: successBlock, failed: failedBlock) {
    
        let manager = NetRequestManager(url: url, method: "POST") { (data, response, error) -> Void in
            
                self.getDataAndCheck(data, error, success, failed)
            }
        manager.netWorkFire()

    }
    
    // MARK: include token and Params
    
    func POST(url: String, isToken: Bool, parameters: Dictionary<String, AnyObject>, success: successBlock, failed: failedBlock) {
        
        if isToken == true {
        
            let manager = NetRequestManager(url: self.addTokenToURL(url), method: "POST", parameters: parameters) { (data, response, error) -> Void in
                
                self.getDataAndCheck(data, error, success, failed)
            }
            manager.netWorkFire()
        }
    }
    
    //同步POST请求
    // MARK: 同步GET请求, 带参数
//    
    func POST_A(url: String,  parameters: Dictionary<String, AnyObject>)-> NSDictionary {
        
        var session: NSURLSession = NSURLSession()
        var request: NSMutableURLRequest = NSMutableURLRequest()
        var task: NSURLSessionTask!
        var json: NSDictionary = NSDictionary()

        let semaphore = dispatch_semaphore_create(0)
        request = NSMutableURLRequest(URL: NSURL(string: url)!)
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.HTTPBody = try? NSJSONSerialization.dataWithJSONObject(parameters, options: NSJSONWritingOptions())
        // 网络配置
        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        // 设置请求超时时间
        config.timeoutIntervalForRequest = 30
        
        session = NSURLSession(configuration: config)

        task = session.dataTaskWithRequest(request, completionHandler: { (data, response, error) -> Void in
            
            // 返回任务结果
            if error == nil {
                do{
                // 解析json
                json = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as! NSDictionary
//                self.callbackWithResult(json, success: success, failed: failed)
                }catch let error as NSError {
                    print("Could not create audio player: \(error)")
                }
            }
            else {
                
//                failed(content: ["": ""], message: "网络异常")
            }
            
            dispatch_semaphore_signal(semaphore)
        })
        // 任务结束
        task.resume()
        
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
        return json
    }
//
    // MARK: - GET请求
    
    // MARK: include Params
    
    func GET(url: String, parameters: Dictionary<String, AnyObject>, success: successBlock, failed: failedBlock) {
        
        let manager = NetRequestManager(url: url, method: "GET", parameters: parameters) { (data, response, error) -> Void in
    
                self.getDataAndCheck(data, error, success, failed)
            
            }

        manager.netWorkFire()
    }
    
    // MARK: not Params
    
    func GET(url: String, success: successBlock, failed: failedBlock) {
        
        let manager = NetRequestManager(url: url, method: "GET") { (data, response, error) -> Void in
            
            self.getDataAndCheck(data, error, success, failed)
            
        }
        manager.netWorkFire()
        
    }
    
    //    MARK: 同步GET请求, by lily
    
    func GET_A(url: String,  parameters: Dictionary<String, AnyObject>) -> NSDictionary{
        
        
        var session: NSURLSession = NSURLSession()
        var request: NSMutableURLRequest = NSMutableURLRequest()
        var task: NSURLSessionTask!
        
        var json: NSDictionary = NSDictionary(object: -1000, forKey: "result")
        
        let semaphore = dispatch_semaphore_create(0)
        if parameters.count > 0 {
            request = NSMutableURLRequest(URL: NSURL(string: url + "?" + self.buildParameters(parameters))!)
        }else{
            request = NSMutableURLRequest(URL: NSURL(string: url)!)
        }
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        // 网络配置
        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        // 设置请求超时时间
        config.timeoutIntervalForRequest = 30
        
        session = NSURLSession(configuration: config)
        
        task = session.dataTaskWithRequest(request, completionHandler: { (data, response, error) -> Void in
            
            // 返回任务结果
            if error == nil {
                
                // 解析json
                print(NSString(data: data!, encoding: NSUTF8StringEncoding))
                json = try! NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as! NSDictionary
//                self.callbackWithResult(json, success: success, failed: failed)
                
            }
            else {
                print("网络异常")
//                HudProgressManager.sharedInstance.sh
//                failed(content: ["": ""], message: "网络异常")
            }
            
            dispatch_semaphore_signal(semaphore)
        })
        // 任务结束
        task.resume()
        
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
        return json
    }
    
    // MARK: 同步GET请求, 带参数
    
    func GET_A(url: String,  parameters: Dictionary<String, AnyObject>, success: successBlock, failed: failedBlock) {
    
        var session: NSURLSession = NSURLSession()
        var request: NSMutableURLRequest = NSMutableURLRequest()
        var task: NSURLSessionTask!
        
        let semaphore = dispatch_semaphore_create(0)
        request = NSMutableURLRequest(URL: NSURL(string: url + "?" + self.buildParameters(parameters))!)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")

        // 网络配置
        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        // 设置请求超时时间
        config.timeoutIntervalForRequest = 30
        
        session = NSURLSession(configuration: config)

        task = session.dataTaskWithRequest(request, completionHandler: { (data, response, error) -> Void in
            
            // 返回任务结果
            if error == nil {
            
                // 解析json
                let json = try! NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as! NSDictionary
                self.callbackWithResult(json, success: success, failed: failed)
                
            }
            else {
                
                failed(content: ["": ""], message: "网络异常")
            }
        
            dispatch_semaphore_signal(semaphore)
        })
        // 任务结束
        task.resume()

        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
    }
    
    // MARK: - 自定义
    
    // MARK: not Params
    
    func request(method: String, url: String,  success: successBlock, _ failed: failedBlock) {
        
        let manager = NetRequestManager(url: url, method: method) { (data, response, error) -> Void in
            
                self.getDataAndCheck(data, error, success, failed)
            
            }

        manager.netWorkFire()
    }
    
    // MARK: include Params

    func request(method: String, url: String,  parameters: Dictionary<String, AnyObject>, success: successBlock, failed: failedBlock) {
        
        let manager = NetRequestManager(url: url, method: method, parameters: parameters) { (data, response, error) -> Void in
            
            self.getDataAndCheck(data, error, success, failed)

        }
        manager.netWorkFire()
    }
    
    // MARK: - 解析协定结构体
    
    func callbackWithResult(data: NSDictionary, success: successBlock, failed: failedBlock) {
    
        // token无效
        if (data["error"] as? String) == "invalid_token" {
            
            // 回归主线程
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                failed(content: ["": ""], message: "token失效，请重新登录")
            })
            
            return;
        }

        // 判断返回结果是否正确
        if (data["result"] as! Int) == 1 {
        
            // 回归主线程
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                success(content: data["content"]!, message: "")
            })
        }
        else {
        
            // 回归主线程
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                failed(content: ["": ""], message: data["resultDesp"] as! String)
            })
        }
    }
    
    // MARK: - 异常处理及获取数据
    
    func getDataAndCheck(data: NSData?, _ error: NSError!, _ success: successBlock, _ failed: failedBlock) {
    
        // 获取成功
        if error == nil {
            
            // 解析json
            let json = try! NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as! NSDictionary
            if (json.objectForKey("result") != nil) && (json.objectForKey("content") != nil){
                self.callbackWithResult(json, success: success, failed: failed)
            }
            
        }
        else {
            // 回归主线程
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                failed(content: ["": ""], message: "网络异常")
            })
        }

    }
    
    // MARK: - 文件结构体
    
    struct File {
        let name: String!
        let url: NSURL!
        init(name: String, url: NSURL) {
            self.name = name
            self.url = url
        }
    }
    
    // MARK: - 动态拼接参数
    
    func buildParameters(parameters: [String : AnyObject]) -> String {
        
        var components: [(String, String)] = []
        for key in Array(parameters.keys).sort(<) {
            let value: AnyObject! = parameters[key]
            components += self.queryComponents(key, value)
        }
        return (components.map{"\($0)=\($1)"} as [String]).joinWithSeparator("&")
    }
    
    
    func queryComponents(key: String, _ value: AnyObject) -> [(String, String)] {
        var components: [(String, String)] = []
        if let dictionary = value as? [String: AnyObject] {
            for (nestedKey, value) in dictionary {
                components += queryComponents("\(key)[\(nestedKey)]", value)
            }
        } else if let array = value as? [AnyObject] {
            for value in array {
                components += queryComponents("\(key)", value)
            }
        } else {
            components.appendContentsOf([(escape(key), escape("\(value)"))])
        }
        
        return components
    }
    
    func escape(string: String) -> String {
        let generalDelimitersToEncode = ":#[]@" // does not include "?" or "/" due to RFC 3986 - Section 3.4
        let subDelimitersToEncode = "!$&'()*+,;="
        
        let allowedCharacterSet = NSCharacterSet.URLQueryAllowedCharacterSet().mutableCopy() as! NSMutableCharacterSet
        allowedCharacterSet.removeCharactersInString(generalDelimitersToEncode + subDelimitersToEncode)
        
        return string.stringByAddingPercentEncodingWithAllowedCharacters(allowedCharacterSet) ?? ""
    }
    
    // MARK: - 添加存储本地token
    
    func addTokenToURL(url: String) -> String {
        
        let getAccessToken = GetAccessToken()
        getAccessToken.getAccessToken()
        let accessToken = NSUserDefaults.standardUserDefaults().objectForKey(accessNSUserData)
        let urlPath:String = (url as String) + "?access_token=" + (accessToken as! String)
        return urlPath
        
    }
    
    // MARK: - 检测用户是否登录 
    
    func checkUserIsLogin() {
    
        let getAccessToken = GetAccessToken()
        getAccessToken.getAccessToken()
        let access_Token = NSUserDefaults.standardUserDefaults().objectForKey(accessNSUserData)
        if (access_Token != nil){
            //已经登陆
            //if(access_token == networkErrorCode) // networkErrorCode == -1000
            //{
                //网络异常    请稍候再试
                
           // }else{
                //正常登录
          //  }
      //  }else{
            //未登录或登录超时请重新登录
        }
    }

}
