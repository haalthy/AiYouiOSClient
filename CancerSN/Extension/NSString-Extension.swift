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

    // 动态计算字符串长度

    func sizeWithFont(font: UIFont, maxSize: CGSize) -> CGSize {
    
        
        let paragraphStyle: NSMutableParagraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = NSLineBreakMode.ByWordWrapping

        let dict = [NSFontAttributeName : font,
            NSParagraphStyleAttributeName : paragraphStyle.copy()
        ]
                
        let str = self as NSString
        
        let size: CGSize = str.boundingRectWithSize(maxSize, options:.UsesLineFragmentOrigin, attributes: dict, context: nil).size

        return size
    }
}