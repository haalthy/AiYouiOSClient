//
//  SearchTypeBtn.swift
//  CancerSN
//
//  Created by lay on 16/2/18.
//  Copyright © 2016年 lily. All rights reserved.
//

import UIKit

let kHeightRatio: CGFloat = 0.25

class SearchTypeBtn: UIButton {

    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        
        
    }
    
    //
    
    override func titleRect(forContentRect contentRect: CGRect) -> CGRect {
      
        let rect: CGRect = CGRECT(0, contentRect.size.width, contentRect.size.width, contentRect.size.height * kHeightRatio)
        return rect
    }
    
    override func imageRect(forContentRect contentRect: CGRect) -> CGRect {
        
        let rect: CGRect = CGRECT(0, 0, contentRect.size.width, contentRect.size.height * (1 - kHeightRatio))
        return rect
    }

    

}
