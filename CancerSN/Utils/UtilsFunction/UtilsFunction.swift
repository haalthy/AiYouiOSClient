//
//  UtilsFunction.swift
//  CancerSN
//
//  Created by lay on 15/12/28.
//  Copyright © 2015年 lily. All rights reserved.
//

import Foundation
import UIKit


// MARK: 判断是否增加数量

func judgeIsAddCount(type: Int) {
    
    switch type {
        
    case 0:
        NSUserDefaults.standardUserDefaults().setBool(true, forKey: unreadCommentBadgeCount)
        break
    case 1:
        NSUserDefaults.standardUserDefaults().setBool(true, forKey: unreadMentionedBadgeCount)
        
        break
    case 2:
        NSUserDefaults.standardUserDefaults().setBool(true, forKey: unreadFollowBadgeCount)
        break
    default: break
        
    }

    // 发送添加红点通知
    RedBadgeManager.sharedInstance.sendAddRedDotBadgeNotification()
}

// MARK: 判断是否减少数量

func judgeIsDecCount(type: Int) {
    
    switch type {
        
    case 0:
        NSUserDefaults.standardUserDefaults().setBool(false, forKey: unreadCommentBadgeCount)
        break
    case 1:
        NSUserDefaults.standardUserDefaults().setBool(false, forKey: unreadMentionedBadgeCount)

        break
    case 2:
        NSUserDefaults.standardUserDefaults().setBool(false, forKey: unreadFollowBadgeCount)
        break
    default: break
        
    }
    
    RedBadgeManager.sharedInstance.sendAddRedDotBadgeNotification()
}

