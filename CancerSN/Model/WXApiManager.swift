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
/*private static var __once: () = { () -> Void in
                SingletonStruct.singleton = WXApiManager()
            }()*/
//    var wxReturnDelegate: WXReturnDelegate?
    class var sharedInstance: WXApiManager {
        
        get {
            struct SingletonStruct {
                static var onceToken: Int = 0
                static var singleton: WXApiManager? = nil
            }
            _ = { () -> Void in
                SingletonStruct.singleton = WXApiManager()
            }()
            return SingletonStruct.singleton!
        }
    }
    
    func onReq(_ req: BaseReq!) {
        print("on req")
    }
    
    func onResp(_ resp: BaseResp!) {
    }

}
