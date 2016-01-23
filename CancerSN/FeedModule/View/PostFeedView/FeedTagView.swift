//
//  FeedTagView.swift
//  CancerSN
//
//  Created by lay on 15/12/29.
//  Copyright © 2015年 lily. All rights reserved.
//

import UIKit

class FeedTagView: UIView {

    // MARK: - 配置常量
    
    // tag border color
    let kTagBorderColor: UIColor = RGB(153, 153, 153)
    
    // tag text color
    let kTagTextColor: UIColor = RGB(51, 51, 51)

    // text font size
    let kTagFont: UIFont = UIFont.systemFontOfSize(16)
    
    // tag 字符串数组
    var tagArr: [String]?
    
    init(frame: CGRect, highTag: [String]) {
       
        super.init(frame: frame)
        
        self.tagArr = highTag
        // 添加tag
        self.addSubTagLabel()
    }

    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
        fatalError("init(coder:) has not been implemented")
        
    }

    override func layoutSubviews() {
        
        super.layoutSubviews()
        
        let tagCount = self.subviews.count
        
        for var i = 0; i < tagCount; i++ {
            
            let label = self.subviews[i]
            
            var x: CGFloat = 0
            if i == 0 {
                x = 0
            }
            else {
                x = CGRectGetMaxX(self.subviews[i - 1].frame) + 8.0
            }
            let y: CGFloat = 0
            let w: CGFloat = (self.tagArr![i].sizeWithFont(kTagFont, maxSize: CGSizeMake((CGFloat.max, CGFloat.max)))).width + 6
            let h: CGFloat = 24
            
            label.frame = CGRECT(x, y, w, h)
        }
    }
    
    // MARK: - 添加tag label
    
    func addSubTagLabel() {
    
        if tagArr!.count != 0 {
        
            for var i = 0; i < tagArr!.count; i++ {
                
                let tagLabel: UILabel = UILabel()
                tagLabel.text = tagArr![i]
                tagLabel.layer.cornerRadius = 4.0
                tagLabel.layer.borderWidth = 1.0
                tagLabel.layer.borderColor = kTagBorderColor.CGColor
                tagLabel.textColor = kTagTextColor
                tagLabel.font = kTagFont
                tagLabel.textAlignment = NSTextAlignment.Center
                self.addSubview(tagLabel)
                
            }
        }
    }
}