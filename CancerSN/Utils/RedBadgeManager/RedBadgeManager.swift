//
//  RedBadgeManager.swift
//  CancerSN
//
//  Created by lay on 16/3/9.
//  Copyright © 2016年 lily. All rights reserved.
//

import UIKit

class RedBadgeManager: NSObject {
    
/*    private static var __once: () = { () -> Void in
                
                SingletonStruct.singleton = RedBadgeManager()
            }()
    */
    class var sharedInstance: RedBadgeManager {
    
        get {
        
            struct SingletonStruct {
                
                static var onceToken: Int = 0
                static var singleton: RedBadgeManager? = nil
            }
            
            _ = { () -> Void in
                
                SingletonStruct.singleton = RedBadgeManager()
            }()
            
            return SingletonStruct.singleton!
        }
    }
    
    
    override init() {
        
        super.init()
        
    }
    
    // MARK: - 添加tabbarItem的红点
    
    func sendAddRedDotBadgeNotification() {
    
        let notify: Notification = Notification(name: Notification.Name(rawValue: addTabbarRedDotBadge), object: nil)
        NotificationCenter.default.post(notify)
    }
    
    // MARK: - 移除tabbarItem的红点
    
    func deleteAddRedDotBadgeNotification() {
    
        
        let notify: Notification = Notification(name: Notification.Name(rawValue: deleteTabbarRedDotBadge), object: nil)
        NotificationCenter.default.post(notify)
    }
}
