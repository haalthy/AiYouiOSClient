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
    
    var session: NSURLSession!
    
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
        if (data["error"] as! String) == "invalid_token" {
            
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
    
    func getDataAndCheck(data: NSData, _ error: NSError!, _ success: successBlock, _ failed: failedBlock) {
    
        // 获取成功
        if error == nil {
            
            // 解析json
            let json = try! NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers) as! NSDictionary
            self.callbackWithResult(json, success: success, failed: failed)
            
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
}
