//
//  RedBadgeManager.swift
//  CancerSN
//
//  Created by lay on 16/3/9.
//  Copyright © 2016年 lily. All rights reserved.
//

import UIKit

class RedBadgeManager: NSObject {
    
    class var sharedInstance: RedBadgeManager {
    
        get {
        
            struct SingletonStruct {
                
                static var onceToken: dispatch_once_t = 0
                static var singleton: RedBadgeManager? = nil
            }
            
            dispatch_once(&SingletonStruct.onceToken) { () -> Void in
                
                SingletonStruct.singleton = RedBadgeManager()
            }
            
            return SingletonStruct.singleton!
        }
    }
    
    
    override init() {
        
        super.init()
        
    }
    
    // MARK: - 添加tabbarItem的红点
    
    func sendAddRedDotBadgeNotification() {
    
        let notify: NSNotification = NSNotification(name: addTabbarRedDotBadge, object: nil)
        NSNotificationCenter.defaultCenter().postNotification(notify)
    }
    
    // MARK: - 移除tabbarItem的红点
    
    func deleteAddRedDotBadgeNotification() {
    
        
        let notify: NSNotification = NSNotification(name: deleteTabbarRedDotBadge, object: nil)
        NSNotificationCenter.defaultCenter().postNotification(notify)
    }
}
