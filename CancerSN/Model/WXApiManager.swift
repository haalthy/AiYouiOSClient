//
//  WXApiManager.swift
//  CancerSN
//
//  Created by hui luo on 16/2/2016.
//  Copyright © 2016 lily. All rights reserved.
//

import Foundation

class WXApiManager: NSObject, WXApiDelegate {
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
        print("on resp")
        //        if ([resp isKindOfClass:[SendAuthResp class]]) {
        //            if (_delegate
        //            && [_delegate respondsToSelector:@selector(managerDidRecvAuthResponse:)]) {
        //                SendAuthResp *authResp = (SendAuthResp *)resp;
        //                [_delegate managerDidRecvAuthResponse:authResp];
        //            }
        //        }
        if resp.isKindOfClass(SendAuthResp) {
            let authResp = resp as! SendAuthResp
            let code: String = authResp.code
            let url = "https://api.weixin.qq.com/sns/oauth2/access_token?appid=" + WXAppID + "&secret=" + WXAppSecret + "&grant_type=authorization_code&code=" + code
            NetRequest.sharedInstance.GET_A(url, parameters: [:])
        }
    }

}