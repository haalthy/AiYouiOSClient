//
//  WXApiManager.swift
//  CancerSN
//
//  Created by hui luo on 16/2/2016.
//  Copyright © 2016 lily. All rights reserved.
//

import Foundation

//protocol WXReturnDelegate {
//    func getWXAccessToken(result: String)
//}

class WXApiManager: NSObject, WXApiDelegate {
//    var wxReturnDelegate: WXReturnDelegate?
    class var sharedInstance: WXApiManager {
        
        get {
            struct SingletonStruct {
                static var onceToken: dispatch_once_t = 0
                static var singleton: WXApiManager? = nil
            }
            dispatch_once(&SingletonStruct.onceToken) { () -> Void in
                SingletonStruct.singleton = WXApiManager()
            }
            
            return SingletonStruct.singleton!
        }
    }
    
    func onReq(req: BaseReq!) {
        print("on req")
    }
    
    func onResp(resp: BaseResp!) {
    }

}