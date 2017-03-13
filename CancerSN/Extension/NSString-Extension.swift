//
//  NSString-Extension.swift
//  CancerSN
//
//  Created by lay on 15/12/28.
//  Copyright © 2015年 lily. All rights reserved.
//

import Foundation
import UIKit

extension String {

    static func intToString(_ intValue: Int) -> String {
        
        return String(format: "%i", intValue)
    }
    
    // 动态计算字符串长度

    func sizeWithFont(_ font: UIFont, maxSize: CGSize) -> CGSize {
    
        
        let paragraphStyle: NSMutableParagraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = NSLineBreakMode.byWordWrapping

        let dict = [NSFontAttributeName : font,
            NSParagraphStyleAttributeName : paragraphStyle.copy()
        ]
                
        let str = self as NSString
        
        let size: CGSize = str.boundingRect(with: maxSize, options:.usesLineFragmentOrigin, attributes: dict, context: nil).size

        return size
    }
    
    }
