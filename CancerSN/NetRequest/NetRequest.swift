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
typealias successBlock = (_ content: AnyObject, _ message: String) -> Void
// 获取数据失败 block
typealias failedBlock = (_ content: AnyObject, _ message: String) -> Void


class NetRequest: NSObject {
    
/*        private static var __once: () = { () -> Void in
                    SingletonStruct.singleton = NetRequest()
                }()
 */
    // MARK: - 单例模式
    //waiting for more research....
    class var sharedInstance: NetRequest {
        
        get {
            struct SingletonStruct {
                static var onceToken: Int = 0
                static var singleton: NetRequest? = nil
            }
            _ = { () -> Void in
                SingletonStruct.singleton = NetRequest()
            }()
            
            // 得到变量
            return SingletonStruct.singleton!
        }
    }

    // MARK: - POST请求
    
    // MARK: include Params
    
    func POST(_ url: String, parameters: Dictionary<String, AnyObject>, success: @escaping successBlock, failed: @escaping failedBlock) {
    
        let manager = NetRequestManager(url: url, method: "POST", parameters: parameters) { (data, response, error) -> Void in
            
            self.getDataAndCheck(data, error, success, failed)
        }
        manager.netWorkFire()
    }
    
    // MARK: not Params
    
    func POST(_ url: String, success: @escaping successBlock, failed: @escaping failedBlock) {
    
        let manager = NetRequestManager(url: url, method: "POST") { (data, response, error) -> Void in
            
                self.getDataAndCheck(data, error, success, failed)
            }
        manager.netWorkFire()

    }
    
    // MARK: include token and Params
    
    func POST(_ url: String, isToken: Bool, parameters: Dictionary<String, AnyObject>, success: @escaping successBlock, failed: @escaping failedBlock) {
        
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
    func POST_A(_ url: String,  parameters: Dictionary<String, AnyObject>)-> NSDictionary {
        var session: URLSession = URLSession()
        var request: NSMutableURLRequest = NSMutableURLRequest()
        var task: URLSessionTask!
        var json: NSDictionary = NSDictionary()

        let semaphore = DispatchSemaphore(value: 0)
        request = NSMutableURLRequest(url: URL(string: url)!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: JSONSerialization.WritingOptions())
        // 网络配置
        let config = URLSessionConfiguration.default
        // 设置请求超时时间
        config.timeoutIntervalForRequest = 30
        
        session = URLSession(configuration: config)
        
        task = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            // 返回任务结果
            if error == nil {
                do{
                    // 解析json
                    json = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
                    //                self.callbackWithResult(json, success: success, failed: failed)
                }catch let error as NSError {
                    print("ERROR: \(error)")
                }
            }
            else {
                json = NSDictionary(object: "content", forKey: "网络异常" as NSCopying)
                //                failed(content: ["": ""], message: "网络异常")
            }
            
            semaphore.signal()
            }
        )

        // 任务结束
        task.resume()
        
        semaphore.wait(timeout: DispatchTime.distantFuture)
        return json
    }
//
    // MARK: - GET请求
    
    // MARK: include Params
    
    func GET(_ url: String, parameters: Dictionary<String, AnyObject>, success: @escaping successBlock, failed: @escaping failedBlock) {
        
        let manager = NetRequestManager(url: url, method: "GET", parameters: parameters) { (data, response, error) -> Void in
    
                self.getDataAndCheck(data, error, success, failed)
            
            }

        manager.netWorkFire()
    }
    
    // MARK: not Params
    
    func GET(_ url: String, success: @escaping successBlock, failed: @escaping failedBlock) {
        
        let manager = NetRequestManager(url: url, method: "GET") { (data, response, error) -> Void in
            
            self.getDataAndCheck(data, error, success, failed)
            
        }
        manager.netWorkFire()
        
    }
    
    //    MARK: 同步GET请求, by lily
    
    func GET_A(_ url: String,  parameters: Dictionary<String, AnyObject>) -> NSDictionary{
        
        
        var session: URLSession = URLSession()
        var request: NSMutableURLRequest = NSMutableURLRequest()
        var task: URLSessionTask!
        
        var json: NSDictionary = NSDictionary(object: -1000, forKey: "result" as NSCopying)
        
        let semaphore = DispatchSemaphore(value: 0)
        if parameters.count > 0 {
            request = NSMutableURLRequest(url: URL(string: url + "?" + self.buildParameters(parameters))!)
        }else{
            request = NSMutableURLRequest(url: URL(string: url)!)
        }
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        // 网络配置
        let config = URLSessionConfiguration.default
        // 设置请求超时时间
        config.timeoutIntervalForRequest = 30
        
        session = URLSession(configuration: config)
        
        task = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            
            // 返回任务结果
            if error == nil {
                
                // 解析json
                if data != nil {
                    json = try! JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
                }
                
            }
            else {
//                HudProgressManager.sharedInstance.sh
//                failed(content: ["": ""], message: "网络异常")
            }
            
            semaphore.signal()
        })
        // 任务结束
        task.resume()
        
        semaphore.wait(timeout: DispatchTime.distantFuture)
        return json
    }
    
    // MARK: 同步GET请求, 带参数
    
    func GET_A(_ url: String,  parameters: Dictionary<String, AnyObject>, success: @escaping successBlock, failed: @escaping failedBlock) {
    
        var session: URLSession = URLSession()
        var request: NSMutableURLRequest = NSMutableURLRequest()
        var task: URLSessionTask!
        
        let semaphore = DispatchSemaphore(value: 0)
        request = NSMutableURLRequest(url: URL(string: url + "?" + self.buildParameters(parameters))!)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")

        // 网络配置
        let config = URLSessionConfiguration.default
        // 设置请求超时时间
        config.timeoutIntervalForRequest = 30
        
        session = URLSession(configuration: config)

        task = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            
            // 返回任务结果
            if error == nil {
            
                // 解析json
                let json = try! JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
                self.callbackWithResult(json, success: success, failed: failed)
                
            }
            else {
                
                failed("" as AnyObject, "网络异常")
            }
        
            semaphore.signal()
        })
        // 任务结束
        task.resume()

        semaphore.wait(timeout: DispatchTime.distantFuture)
    }
    
    // MARK: - 自定义
    
    // MARK: not Params
    
    func request(_ method: String, url: String,  success: @escaping successBlock, _ failed: @escaping failedBlock) {
        
        let manager = NetRequestManager(url: url, method: method) { (data, response, error) -> Void in
            
                self.getDataAndCheck(data, error, success, failed)
            
            }

        manager.netWorkFire()
    }
    
    // MARK: include Params

    func request(_ method: String, url: String,  parameters: Dictionary<String, AnyObject>, success: @escaping successBlock, failed: @escaping failedBlock) {
        
        let manager = NetRequestManager(url: url, method: method, parameters: parameters) { (data, response, error) -> Void in
            
            self.getDataAndCheck(data, error, success, failed)

        }
        manager.netWorkFire()
    }
    
    // MARK: - 解析协定结构体
    
    func callbackWithResult(_ data: NSDictionary, success: @escaping successBlock, failed: @escaping failedBlock) {
    
        // token无效
        if (data["error"] as? String) == "invalid_token" {
            
            // 回归主线程
            DispatchQueue.main.async(execute: { () -> Void in
                failed("" as AnyObject, "token失效，请重新登录")
            })
            
            return;
        }

        // 判断返回结果是否正确
        if (data["result"] as! Int) == 1 {
        
            // 回归主线程
            DispatchQueue.main.async(execute: { () -> Void in
                success(data["content"]! as AnyObject, "")
            })
        }
        else {
        
            // 回归主线程
            DispatchQueue.main.async(execute: { () -> Void in
                failed("" as AnyObject, data["resultDesp"] as! String)
            })
        }
    }
    
    // MARK: - 异常处理及获取数据
    
    func getDataAndCheck(_ data: Data?, _ error: Error!, _ success: @escaping successBlock, _ failed: @escaping failedBlock) {
    
        // 获取成功
        if error == nil {
            
            // 解析json
            let json = try! JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
            if (json.object(forKey: "result") != nil) && (json.object(forKey: "content") != nil){
                self.callbackWithResult(json, success: success, failed: failed)
            }
            
        }
        else {
            // 回归主线程
            DispatchQueue.main.async(execute: { () -> Void in
                failed("" as AnyObject, "网络异常")
            })
        }

    }
    
    // MARK: - 文件结构体
    
    struct File {
        let name: String!
        let url: URL!
        init(name: String, url: URL) {
            self.name = name
            self.url = url
        }
    }
    
    // MARK: - 动态拼接参数
    
    func buildParameters(_ parameters: [String : AnyObject]) -> String {
        
        var components: [(String, String)] = []
        for key in Array(parameters.keys).sorted(by: <) {
            let value: AnyObject! = parameters[key]
            components += self.queryComponents(key, value)
        }
        return (components.map{"\($0)=\($1)"} as [String]).joined(separator: "&")
    }
    
    
    func queryComponents(_ key: String, _ value: AnyObject) -> [(String, String)] {
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
            components.append(contentsOf: [(escape(key), escape("\(value)"))])
        }
        
        return components
    }
    
    func escape(_ string: String) -> String {
        let generalDelimitersToEncode = ":#[]@" // does not include "?" or "/" due to RFC 3986 - Section 3.4
        let subDelimitersToEncode = "!$&'()*+,;="
        
        let allowedCharacterSet = (CharacterSet.urlQueryAllowed as NSCharacterSet).mutableCopy() as! NSMutableCharacterSet
        allowedCharacterSet.removeCharacters(in: generalDelimitersToEncode + subDelimitersToEncode)
        
        return string.addingPercentEncoding(withAllowedCharacters: allowedCharacterSet as CharacterSet) ?? ""
    }
    
    // MARK: - 添加存储本地token
    
    func addTokenToURL(_ url: String) -> String {
        
        let getAccessToken = GetAccessToken()
        getAccessToken.getAccessToken()
        let accessToken = UserDefaults.standard.object(forKey: accessNSUserData)
        let urlPath:String = (url as String) + "?access_token=" + (accessToken as! String)
        return urlPath
        
    }
    
    // MARK: - 检测用户是否登录 
    
    func checkUserIsLogin() {
    
        let getAccessToken = GetAccessToken()
        getAccessToken.getAccessToken()
        let access_Token = UserDefaults.standard.object(forKey: accessNSUserData)
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
