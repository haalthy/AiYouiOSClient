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

func judgeIsAddCount(_ type: Int) {
    
    switch type {
        
    case 0:
        UserDefaults.standard.set(true, forKey: unreadCommentBadgeCount)
        break
    case 1:
        UserDefaults.standard.set(true, forKey: unreadMentionedBadgeCount)
        
        break
    case 2:
        UserDefaults.standard.set(true, forKey: unreadFollowBadgeCount)
        break
    default: break
        
    }

    // 发送添加红点通知
    RedBadgeManager.sharedInstance.sendAddRedDotBadgeNotification()
}

// MARK: 判断是否减少数量

func judgeIsDecCount(_ type: Int) {
    
    switch type {
        
    case 0:
        UserDefaults.standard.set(false, forKey: unreadCommentBadgeCount)
        break
    case 1:
        UserDefaults.standard.set(false, forKey: unreadMentionedBadgeCount)

        break
    case 2:
        UserDefaults.standard.set(false, forKey: unreadFollowBadgeCount)
        break
    default: break
        
    }
    
    RedBadgeManager.sharedInstance.sendAddRedDotBadgeNotification()
}

