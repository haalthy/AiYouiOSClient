//
//  NetRequest.swift
//  CancerSN
//
//  Created by lay on 15/12/26.
//  Copyright © 2015年 lily. All rights reserved.
//

import UIKit
import Foundation

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
    
    func POST(url: String, parameters: Dictionary<String, AnyObject>, callback: (data: NSData!, response: NSURLResponse!, error: NSError!) -> Void) {
    
        let manager = NetRequestManager(url: url, method: "POST", parameters: parameters, callback: callback)
        manager.netWorkFire()
    }
    
    // MARK: not Params
    
    func POST(url: String, callback: (data: NSData!, response: NSURLResponse!, error: NSError!) -> Void) {
    
        let manager = NetRequestManager(url: url, method: "POST", callback: callback)
        manager.netWorkFire()

    }
    
    // MARK: - GET请求
    
    // MARK: include Params
    
    func GET(url: String, parameters: Dictionary<String, AnyObject>, callback: (data: NSData!, response: NSURLResponse!, error: NSError!) -> Void) {
        
        let manager = NetRequestManager(url: url, method: "GET", parameters: parameters, callback: callback)
        manager.netWorkFire()
    }
    
    // MARK: not Params
    
    func GET(url: String, callback: (data: NSData!, response: NSURLResponse!, error: NSError!) -> Void) {
        
        let manager = NetRequestManager(url: url, method: "GET", callback: callback)
        manager.netWorkFire()
        
    }
    
    // MARK: - 自定义
    
    // MARK: include Params
    
    static func request(method: String, url: String, callback: (data: NSData!, response: NSURLResponse!, error: NSError!) -> Void) {
        
        let manager = NetRequestManager(url: url, method: method, callback: callback)
        manager.netWorkFire()
    }
    
    // MARK: include Params

    static func request(method: String, url: String, parameters: Dictionary<String, AnyObject>, callback: (data: NSData!, response: NSURLResponse!, error: NSError!) -> Void) {
        
        let manager = NetRequestManager(url: url, method: method, parameters: parameters, callback: callback)
        manager.netWorkFire()
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
