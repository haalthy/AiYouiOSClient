//
//  KeyBoardView.swift
//  CancerSN
//
//  Created by lay on 16/1/6.
//  Copyright © 2016年 lily. All rights reserved.
//

import UIKit

// 配置常量

// 底部textView高度
let kKeyBoardTextViewHeight: CGFloat = 36.0
// textView背景色
let kKeyBoardTextViewBgColor: UIColor = UIColor.whiteColor()
// 横向间隔
let kHorizontalPadding: CGFloat = 8.0
// 纵向间隔
let kVerticalPadding: CGFloat = 9.0
// text左间隔
let kTextViewLeftMargin: CGFloat = 16.0
// text右间隔
let kTextViewRightMargin: CGFloat = 16.0

// viewColor
let kKeyBoardColor: UIColor = RGB(242, 248, 248)
// viewBoardColor
let kKeyBoardWColor: UIColor = RGB(211, 211, 211)

let kKeyBoardFaceBtnWidth: CGFloat = 25

class KeyBoardView: UIView, UITextViewDelegate {

    override init(frame: CGRect) {
        
        super.init(frame: frame)
        
        
        self.setContentView()
        self.setLayoutView()
        
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }

    // MARK - 设置view内容
    
    func setContentView() {
    
        self.backgroundColor = kKeyBoardColor
        self.layer.borderWidth = 1.0
        self.layer.borderColor = kKeyBoardWColor.CGColor
        
        // 添加点击事件
        self.userInteractionEnabled = true
    }
    
    // MARK:
    
    func setLayoutView() {
    
        // 评论内容textView
        let textView: KBTextView = KBTextView()
        textView.frame = CGRECT(kTextViewLeftMargin, kVerticalPadding, self.frame.size.width - kTextViewLeftMargin - kTextViewRightMargin - kKeyBoardFaceBtnWidth, kKeyBoardTextViewHeight)
        textView.returnKeyType = UIReturnKeyType.Send
        textView.scrollEnabled = false
        textView.backgroundColor = kKeyBoardTextViewBgColor
        textView.delegate = self
        self.addSubview(textView)
        
        // 标签按钮
        let faceBtn: UIButton = UIButton(type: UIButtonType.Custom)
        faceBtn.frame = CGRECT(CGRectGetMaxX(textView.frame) + kTextViewRightMargin, kVerticalPadding, kKeyBoardFaceBtnWidth, kKeyBoardFaceBtnWidth)
        faceBtn.setBackgroundImage(UIImage(named: ""), forState: UIControlState.Normal)
        faceBtn.setBackgroundImage(UIImage(named: ""), forState: UIControlState.Selected)
        faceBtn.addTarget(self, action: "willShowFaceView:", forControlEvents: UIControlEvents.TouchUpInside)
        self.addSubview(faceBtn)
        
    }
    
    // MARK: - 功能方法
    
    func willShowFaceView(btn: UIButton) {
    
        
    }

}
