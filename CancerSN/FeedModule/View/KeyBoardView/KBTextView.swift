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
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "textChange:", name:UITextViewTextDidChangeNotification, object: nil)
        
        self.autoresizesSubviews = false
        
        // 默认字体与颜色
        self.placeHolder = ""
<<<<<<< HEAD
        self.placeHolderColor = RGB(204, 204, 204)
=======
        self.placeHolderColor = UIColor.lightGrayColor()
        
>>>>>>> 266f95446ed409916b86b69ad9006f88524dc869
        self.layer.borderColor = kKBTextViewBoardColor.CGColor
        self.layer.borderWidth = kKBTextViewBoardWidth
        self.layer.cornerRadius = 4.0
        
<<<<<<< HEAD
        self.font = UIFont.systemFontOfSize(18)
        
=======
>>>>>>> 266f95446ed409916b86b69ad9006f88524dc869
    }

    required init?(coder aDecoder: NSCoder) {
        
        fatalError("init(coder:) has not been implemented")
    }
    
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
        
        if self.text == "" {
        
            var placeHolderRect: CGRect = CGRECT(0, 0, 0, 0)
<<<<<<< HEAD
            placeHolderRect.origin.y = 9
=======
            placeHolderRect.origin.y = 8
>>>>>>> 266f95446ed409916b86b69ad9006f88524dc869
            placeHolderRect.size.height = CGRectGetHeight(self.frame) - 8
            placeHolderRect.origin.x = 5
            placeHolderRect.size.width = CGRectGetWidth(self.frame) - 5
            
<<<<<<< HEAD
           // self.placeHolderColor!.set()
           
            let context: CGContextRef = UIGraphicsGetCurrentContext()!
            CGContextSetFillColorWithColor(context, self.placeHolderColor?.CGColor)

=======
            self.placeHolderColor!.set()
            
>>>>>>> 266f95446ed409916b86b69ad9006f88524dc869
            // 定义属性
            let paragraphStyle: NSMutableParagraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineBreakMode = NSLineBreakMode.ByWordWrapping
            paragraphStyle.alignment = NSTextAlignment.Left
            let dict = [NSFontAttributeName : UIFont.systemFontOfSize(16),
                NSParagraphStyleAttributeName : paragraphStyle.copy(),
            ]
            self.placeHolder?.drawInRect(placeHolderRect, withAttributes: dict)
            
<<<<<<< HEAD

        }
    }

=======
        }
    }


>>>>>>> 266f95446ed409916b86b69ad9006f88524dc869
    func textChange(noti: NSNotification) {
        
        self.setNeedsDisplay()
    }
    
    
    func setPlaceHolderText(text: String) {
    
        self.text = text
        self.setNeedsDisplay()
    }
}
