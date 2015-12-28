//
//  NSString-Extension.swift
//  CancerSN
//
//  Created by lay on 15/12/28.
//  Copyright © 2015年 lily. All rights reserved.
//

import Foundation

extension String {

    // 动态计算字符串长度

    func sizeWithFont(font: UIFont, maxSize: CGSize) -> CGSize {
    
        let dict = [NSFontAttributeName : font]
        
        let size: CGSize = self.boundingRectWithSize(maxSize, options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: dict, context: nil).size

        return size
    }
}