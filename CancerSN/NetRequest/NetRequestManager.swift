//
//  NetRequestManager.swift
//  CancerSN
//
//  Created by lay on 15/12/27.
//  Copyright © 2015年 lily. All rights reserved.
//

import UIKit

class NetRequestManager: NSObject {

    var session: URLSession!
    let url: String! // 网络请求链接
    var request: NSMutableURLRequest!
    var task: URLSessionTask!
    
    let method: String! // 请求方法
    let parameters: Dictionary<String, AnyObject> // 请求参数
    let callback: (_ data: Data?, _ response: URLResponse?, _ error: Error?) -> Void // 返回值
    //let files: Array<File> // 图片传输
    
    
    init(url: String, method: String, parameters:Dictionary<String, AnyObject> = Dictionary<String, AnyObject>(), callback: @escaping (_ data: Data?, _ response: URLResponse?, _ error: Error?) -> Void) {
        
        self.url = url
        self.request = NSMutableURLRequest(url: URL(string: url)!)
        self.method = method
        self.parameters = parameters
        self.callback = callback

        super.init()
        
        // 相关网络请求配置
        
        // 网络配置
        let config = URLSessionConfiguration.default
        // 设置请求超时时间
        config.timeoutIntervalForRequest = 30
        
        self.session = URLSession(configuration: config)
        
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
            self.request = NSMutableURLRequest(url: URL(string: self.url + "?" + buildParameters(self.parameters))!)
        }
        
        self.request.httpMethod = self.method
        
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
                // 建立HTTPBody
                let jsonData:Data! = try JSONSerialization.data(                 withJSONObject: self.parameters, options: JSONSerialization.WritingOptions())
                self.request.httpBody = jsonData
            }
            catch {
            
            }
            //self.request.HTTPBody = buildParameters(self.parameters).dataUsingEncoding(NSUTF8StringEncoding)!
        }
    }
    
    // MARK: 建立任务
    
    func buildTask() {
    
        task = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            
            // 返回任务结果
            //waiting for researh
            self.callback(data, response, error)
        })
        // 任务结束
        task.resume()
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

}
