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
let kKeyBoardTextViewBgColor: UIColor = UIColor.white
// 横向间隔
let kHorizontalPadding: CGFloat = 8.0
// 纵向间隔
let kVerticalPadding: CGFloat = 7.0
// text左间隔
let kTextViewLeftMargin: CGFloat = 14.0
// text右间隔
let kTextViewRightMargin: CGFloat = 12.0

// viewColor
let kKeyBoardColor: UIColor = RGB(242, 248, 248)
// viewBoardColor
let kKeyBoardWColor: UIColor = RGB(211, 211, 211)

let kKeyBoardFaceBtnWidth: CGFloat = 30

protocol KeyBoardDelegate {
    // 发送评论
    func sendCommentAction(_ commentStr: String)
}

class KeyBoardView: UIView, UITextViewDelegate, FaceDelegate {
    
    // 定义变量
    var faceView: FaceView?
    var activeView: UIView?
    var textView: KBTextView = KBTextView()

    // 代理
    var delegate: KeyBoardDelegate?

    override init(frame: CGRect) {
        
        super.init(frame: frame)
        
        
        self.setContentView()
        self.setLayoutView()
        self.initNaitfication()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }


    // MARK - 设置view内容
    
    func setContentView() {
    
        self.backgroundColor = kKeyBoardColor
        self.layer.borderWidth = 1.0
        self.layer.borderColor = kKeyBoardWColor.cgColor
        
        // 添加点击事件
        self.isUserInteractionEnabled = true
    }
    
    // MARK: - 初始化通知
    
    func initNaitfication() {
    
        NotificationCenter.default.addObserver(self, selector: #selector(KeyBoardView.keyboardWillChangeFrame(_:)), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
    }
    
    // MARK: - 设置键盘布局
    
    func setLayoutView() {
    
        // 评论内容textView
        textView.frame = CGRECT(kTextViewLeftMargin, kVerticalPadding, self.frame.size.width - kTextViewLeftMargin - kTextViewRightMargin - kKeyBoardFaceBtnWidth - 8, kKeyBoardTextViewHeight)
        textView.returnKeyType = UIReturnKeyType.send
       // textView.scrollEnabled = false

        textView.backgroundColor = kKeyBoardTextViewBgColor
        textView.delegate = self
        self.addSubview(textView)
        
        // 标签按钮
        let faceBtn: UIButton = UIButton(type: UIButtonType.custom)
        faceBtn.frame = CGRECT(textView.frame.maxX + kTextViewRightMargin, kVerticalPadding + 3, kKeyBoardFaceBtnWidth, kKeyBoardFaceBtnWidth)
        faceBtn.setBackgroundImage(UIImage(named: "btn_emoji"), for: UIControlState())
        faceBtn.setBackgroundImage(UIImage(named: "btn_publish_keyboard_a"), for: UIControlState.selected)
        faceBtn.addTarget(self, action: #selector(KeyBoardView.willShowFaceView(_:)), for: UIControlEvents.touchUpInside)
        self.addSubview(faceBtn)
        
        // 添加表情View
        if self.faceView == nil {
        
            self.faceView = FaceView()
            self.faceView?.frame = CGRECT(0, 0, SCREEN_WIDTH, 235)
            self.faceView?.createEmojiKeyBoard()
            self.faceView?.backgroundColor = UIColor.white
            self.faceView?.delegate = self
            self.faceView?.autoresizingMask = UIViewAutoresizing.flexibleTopMargin
        }
        

    }
    
    // MARK: - 功能方法
    
    // MARK: 展示表情view
    
    func willShowFaceView(_ btn: UIButton) {
        
        btn.isSelected = !btn.isSelected
        
        if btn.isSelected == true {
        
            self.textView.inputView = self.faceView
            self.textView.reloadInputViews()
            self.textView.becomeFirstResponder()
        }
        else {
        
            self.textView.inputView = nil
            self.reloadInputViews()
            self.textView.resignFirstResponder()
            self.textView.becomeFirstResponder()
        }
    }
    
    // MARK: 取消键盘
    
    func tapDismiss() {
        
        self.textView.resignFirstResponder()
    }
    
    // MARK: 改变键盘frame
    
    func keyboardWillChangeFrame(_ noti: Notification) {
    
        let userInfo: NSDictionary = noti.userInfo! as NSDictionary
        let endFrame: CGRect = (userInfo[UIKeyboardFrameEndUserInfoKey]! as AnyObject).cgRectValue
        // 动画时间
        let duration: TimeInterval = userInfo[UIKeyboardAnimationDurationUserInfoKey] as! TimeInterval
        //var viewCurve: UIViewAnimationCurve = userInfo[UIKeyboardAnimationCurveUserInfoKey] as Int
        
        // 动画
        let animations = {
        
            () -> Void in
            
            // 改变frame
            var frame: CGRect = self.frame
            frame.origin.y = endFrame.origin.y - self.bounds.size.height
            self.frame = frame
        }
        
        let completion = {
        
            (finished: Bool) -> Void in
        }
        
        UIView.animate(withDuration: duration, delay: 0.0, options: UIViewAnimationOptions.beginFromCurrentState, animations: animations, completion: completion)
        
    }
    
    // MARK: 设置placeHolder
    
    func setPlaceHolderText(_ text: String) {
        
        self.textView.placeHolder = text as NSString?
    }
    
    // MARK: 设置placeHolder颜色
    
    func setPlaceHolderTextColor(_ color: UIColor) {
        self.textView.placeHolderColor = color
    }
    
    // MARK: - 添加表情代理
    
    func sendFaceSelected(_ face: String) {
        
        self.textView.insertText(face)
    }
    
    // MARK: 删除表情
    
    func deleteFaceAction() {
        
        self.textView.deleteBackward()
    }
    
    
    // MARK: - UITextView Delegate
    
    func textViewDidBeginEditing(_ textView: UITextView) {
//        self.showBottomView(nil)
    }
    
    func textViewDidChange(_ textView: UITextView) {
     
        // 设置placeHolder
        if textView.text == "" {
            self.textView.setPlaceHolderText(textView.text)
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        if text == "\n" {
        
            if self.delegate != nil {
            
                // 发送评论
                self.delegate?.sendCommentAction(self.textView.text)
                self.textView.text = ""
                
                // 设置placeHolder
                self.textView.setPlaceHolderText(textView.text)
            }
            return false
        }
        return true
    }
}

