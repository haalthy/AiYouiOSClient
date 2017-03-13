//
//  KBTextView.swift
//  CancerSN
//
//  Created by lay on 16/1/7.
//  Copyright © 2016年 lily. All rights reserved.
//

import UIKit

// 配置常量

// textView BoardWidth
let kKBTextViewBoardWidth: CGFloat = 1
// textView BoardColor
let kKBTextViewBoardColor: UIColor = RGB(227, 236, 236)

class KBTextView: UITextView {

    var placeHolder: NSString?
    var placeHolderColor: UIColor?
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        
        NotificationCenter.default.addObserver(self, selector: #selector(KBTextView.textChange(_:)), name:NSNotification.Name.UITextViewTextDidChange, object: nil)
        
        self.autoresizesSubviews = false
        
        // 默认字体与颜色
        self.placeHolder = ""
        self.placeHolderColor = RGB(204, 204, 204)
        self.layer.borderColor = kKBTextViewBoardColor.cgColor
        self.layer.borderWidth = kKBTextViewBoardWidth
        self.layer.cornerRadius = 4.0
        
        self.font = UIFont.systemFont(ofSize: 18)
        

    }

    required init?(coder aDecoder: NSCoder) {
        
        fatalError("init(coder:) has not been implemented")
    }
    
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
        
        if self.text == "" {
        
            var placeHolderRect: CGRect = CGRECT(0, 0, 0, 0)
            placeHolderRect.origin.y = 9

            placeHolderRect.size.height = self.frame.height - 8
            placeHolderRect.origin.x = 5
            placeHolderRect.size.width = self.frame.width - 5
            
           // self.placeHolderColor!.set()
           
//            let context: CGContextRef = UIGraphicsGetCurrentContext()!
//            CGContextSetFillColorWithColor(context, self.placeHolderColor?.CGColor)
            self.textColor = self.placeHolderColor

            // 定义属性
            let paragraphStyle: NSMutableParagraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineBreakMode = NSLineBreakMode.byWordWrapping
            paragraphStyle.alignment = NSTextAlignment.left
            let dict = [NSFontAttributeName : UIFont.systemFont(ofSize: 16),
                NSParagraphStyleAttributeName : paragraphStyle.copy(),
            ]
            self.placeHolder?.draw(in: placeHolderRect, withAttributes: dict)

        }
    }


    func textChange(_ noti: Notification) {
        
        self.setNeedsDisplay()
    }
    
    
    func setPlaceHolderText(_ text: String) {
    
        self.text = text
        self.setNeedsDisplay()
    }
}
