//
//  NetRequestManager.swift
//  CancerSN
//
//  Created by lay on 15/12/27.
//  Copyright © 2015年 lily. All rights reserved.
//

import UIKit

class NetRequestManager: NSObject {

    var session: NSURLSession!
    let url: String! // 网络请求链接
    var request: NSMutableURLRequest!
    var task: NSURLSessionTask!
    
    let method: String! // 请求方法
    let parameters: Dictionary<String, AnyObject> // 请求参数
    let callback: (data: NSData!, response: NSURLResponse!, error: NSError!) -> Void // 返回值
    //let files: Array<File> // 图片传输
    
    
    init(url: String, method: String, parameters:Dictionary<String, AnyObject> = Dictionary<String, AnyObject>(), callback: (data: NSData!, response: NSURLResponse!, error: NSError!) -> Void) {
        
        self.url = url
        self.request = NSMutableURLRequest(URL: NSURL(string: url)!)
        self.method = method
        self.parameters = parameters
        self.callback = callback

        super.init()
        
        // 相关网络请求配置
        
        // 网络配置
        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        // 设置请求超时时间
        config.timeoutIntervalForRequest = 30
        
        self.session = NSURLSession(configuration: config)
        
    }
    
    // MARK: - 网络请求
    
    func netWorkFire() {
        
        buildRequest()
        buildRequestBody()
        buildTask()
    }
    
    // MARK: 建立请求
    
    func buildRequest() {
        
        // GET 方法
        if self.method == "GET" && parameters.count > 0 {
            self.request = NSMutableURLRequest(URL: NSURL(string: self.url + "?" + buildParameters(self.parameters))!)
        }
        
        self.request.HTTPMethod = self.method
        
        if self.parameters.count > 0 {
            
            //self.request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            self.request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            self.request.addValue("application/json", forHTTPHeaderField: "Accept")
        }
    }
    
    // MARK: 建立body
    
    func buildRequestBody() {
        
        if self.parameters.count > 0 && self.method != "GET" {
            
            do {
                // 建立FTTPBody
                let jsonData:NSData! = try NSJSONSerialization.dataWithJSONObject(                 self.parameters, options: NSJSONWritingOptions())
                self.request.HTTPBody = jsonData
            }
            catch {
            
                print("error")
            }
            //self.request.HTTPBody = buildParameters(self.parameters).dataUsingEncoding(NSUTF8StringEncoding)!
        }
    }
    
    // MARK: 建立任务
    
    func buildTask() {
    
        task = session.dataTaskWithRequest(self.request, completionHandler: { (data, response, error) -> Void in
            
            // 返回任务结果
            self.callback(data: data, response: response, error: error)
        })
        // 任务结束
        task.resume()
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

}
