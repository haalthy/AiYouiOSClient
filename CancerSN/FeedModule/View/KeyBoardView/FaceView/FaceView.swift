//
//  FaceView.swift
//  CancerSN
//
//  Created by lay on 16/1/11.
//  Copyright © 2016年 lily. All rights reserved.
//

import UIKit

// 相关常理

// 按钮正常状态图片

func getBtnNormalPic(_ index: Int) -> String {

    let picsArr: Array<String> = ["emoji_recent_n", "emoji_face_n", "emoji_bell_n", "emoji_flower_n", "emoji_car_n", "emoji_backspace_n"]
    return picsArr[index]
}

// 按钮选中状态图片

func getBtnSelectedPic(_ index: Int) ->  String {

    let picsArr: Array<String> = ["emoji_recent_s", "emoji_face_s", "emoji_bell_s", "emoji_flower_s", "emoji_car_s", "emoji_backspace_s"]
    return picsArr[index]
}

// emoji图片的存储位置

func getEmojiPicLocation() -> String {

    let location: String = (NSHomeDirectory() as NSString).appendingPathComponent("tmp/emojiRecords.plist")
    return location
}

// 表情类别

func getFaceType(_ index: Int) -> String {

    let typeArr: Array<String> = ["People", "Objects", "Nature", "Places"]
    return typeArr[index]
}

// 声明代理

protocol FaceDelegate {
    
    // 添加表情代理
    func sendFaceSelected(_ face: String)
    
    // 删除表情代理
    func deleteFaceAction()
}


class FaceView: UIView, UIScrollViewDelegate {

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    
    // 相关变量
    
    var emojiScrollView: UIScrollView = UIScrollView()
    
    // 底部分类栏
    
    var bottomView: UIView = UIView()
    
    // pageControl
    
    var pageControl: UIPageControl = UIPageControl()
    
    // 当前选中的btn
    
    var selectedBtn: UIButton? = UIButton()
    
    // 代理
    
    var delegate: FaceDelegate?

    override init(frame: CGRect) {
        
        super.init(frame: frame)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 初始化view
    
    func initContentView() {
        
        // scrollView
        
        
        
    }
    
    // MARK: - 创建表情view
    
    func createEmojiKeyBoard() {
    
        
        emojiScrollView.frame = CGRECT(0 , 0, SCREEN_WIDTH, 180)
        emojiScrollView.contentSize = CGSize(width: SCREEN_WIDTH * 29, height: 180)
        emojiScrollView.isScrollEnabled = false
        emojiScrollView.isPagingEnabled = true
        self.addSubview(emojiScrollView)
        
        // 底部分类栏
        bottomView.frame = CGRECT(0, 200, SCREEN_WIDTH, 35)
        bottomView.backgroundColor = UIColor.white
        self.addSubview(bottomView)
        
        // 添加按钮
        self.addBtnToBottomView()
        
        // pageControl
        pageControl.frame = CGRECT(0, 180, SCREEN_WIDTH, 20)
        pageControl.center = CGPoint(x: SCREEN_WIDTH / 2, y: 180)
        pageControl.numberOfPages = 5
        pageControl.currentPage = 0
        pageControl.currentPageIndicatorTintColor = RGB(85, 85, 85)
        pageControl.pageIndicatorTintColor = RGB(170, 170, 170)
        self.addSubview(pageControl)
        
        // 发送按钮
        let sendBtn: UIButton = UIButton(type: .custom)
        sendBtn.frame = CGRECT(SCREEN_WIDTH - 47, 170, 47, 30)
        sendBtn.setTitle("发送", for: UIControlState())
        self.addSubview(sendBtn)
        
        // 获取表情路径
        let pathStr: String = Bundle.main.path(forResource: "EmojisList", ofType: "plist")!
        // 获取表情文件
        let emojiDict: NSDictionary = NSDictionary(contentsOfFile: pathStr)!
        
        let numArr: Array<Int> = [1, 18, 23, 28]
        // 添加表情scrollView
        for i in 0 ..< 4 {
        
            let emojiType: String = getFaceType(i)
            let emojiArr: NSArray = emojiDict[emojiType] as! NSArray
            
            // 显示最新使用过的表情
            self.showUsedEmoji()
            
            let scrollView: UIScrollView = UIScrollView()
            scrollView.frame = CGRECT(CGFloat(numArr[i] * Int(SCREEN_WIDTH)), 0, SCREEN_WIDTH, 180)
            scrollView.delegate = self
            scrollView.tag = 2000 + i
            scrollView.isPagingEnabled = true
            scrollView.showsHorizontalScrollIndicator = false
            emojiScrollView.addSubview(scrollView)
            
            self.emojiLayout(scrollView, emojiArr: emojiArr)
        }
        
        // 默认选中表情
        self.chooseEmojiTypeAction(selectedBtn!)
        
    }
    
    // MARK: 表情布局
    
    func emojiLayout(_ scrollView: UIScrollView, emojiArr: NSArray) {
    
        let pageCount: Int = (emojiArr.count + 23) / 24
        
        for i in 0 ..< emojiArr.count {
        
            let emojiWidth = (SCREEN_WIDTH - 250) / 7 + 30
            // 行数
            let row = (i / 8) % 3
            // 列数
            let col = (i + 1) % 8 == 0 ? 8 : (i + 1) % 8
            
            let pageIndex = i / 24
            
            let emojiX = 5 + (col - 1) * Int(emojiWidth) + pageIndex * Int(SCREEN_WIDTH)
            let emojiLabel: UILabel = UILabel()
            emojiLabel.frame = CGRECT(CGFloat(emojiX), CGFloat(15 + row * 50), 30, 30)
            emojiLabel.font = UIFont.systemFont(ofSize: 30)
            emojiLabel.text = emojiArr[i] as? String
            emojiLabel.isUserInteractionEnabled = true
            
            scrollView.addSubview(emojiLabel)
            
            scrollView.contentSize = CGSize(width: SCREEN_WIDTH * CGFloat(pageCount), height: 180)
            
            // 添加点击事件
            let gesture = UITapGestureRecognizer(target: self, action: #selector(FaceView.addEmojiAction(_:)))
            emojiLabel.addGestureRecognizer(gesture)
        }
    }
    
    // MARK: 添加按钮
    
    func addBtnToBottomView() {
    
        let btnWidth: CGFloat = SCREEN_WIDTH / 6
        
        for i in 0 ..< 6 {
            
            let bottomBtn: UIButton = UIButton(type: .custom)
            bottomBtn.frame = CGRECT(CGFloat(i) * btnWidth, 0, btnWidth, 33)
            bottomBtn.backgroundColor = RGB(224, 224, 224)
            bottomBtn.setImage(UIImage(named: getBtnNormalPic(i)), for: UIControlState())
            
            if i == 1 {
            
                self.selectedBtn = bottomBtn
            }
            
            bottomBtn.tag = 100 + i
            bottomBtn.addTarget(self, action: #selector(FaceView.chooseEmojiTypeAction(_:)), for: .touchUpInside)
            bottomView.addSubview(bottomBtn)
        }
    }
    
    // MARK: 选中表情类别
    
    func chooseEmojiTypeAction(_ btn: UIButton) {
    
        // 退格
        if btn.tag == 105 {
        
            // 删除操作
            self.delegate?.deleteFaceAction()
            return
        }
        
        switch btn.tag {
        
        
        case 100:
            
            pageControl.numberOfPages = 0
            self.emojiScrollView.scrollRectToVisible(CGRECT(0, 0, SCREEN_WIDTH, 200), animated: false)
            break
        case 101:
            
            pageControl.numberOfPages = 8
            
            let scrollView: UIScrollView = emojiScrollView.viewWithTag(2000) as! UIScrollView
            if scrollView.isKind(of: UIScrollView.self) {
                let pageNum: Int = Int(scrollView.contentOffset.x / SCREEN_WIDTH)
                pageControl.currentPage = pageNum
            }
            self.emojiScrollView.scrollRectToVisible(CGRECT(SCREEN_WIDTH, 0, SCREEN_WIDTH, 200), animated: false)

            break
            
        case 102:
            
            pageControl.numberOfPages = 10
            
            let scrollView: UIScrollView = emojiScrollView.viewWithTag(2001) as! UIScrollView
            if scrollView.isKind(of: UIScrollView.self) {
                let pageNum: Int = Int(scrollView.contentOffset.x / SCREEN_WIDTH)
                pageControl.currentPage = pageNum
            }
            self.emojiScrollView.scrollRectToVisible(CGRECT(18 * SCREEN_WIDTH, 0, SCREEN_WIDTH, 200), animated: false)
            
            break
            
        case 103:
            
            pageControl.numberOfPages = 5
            
            let scrollView: UIScrollView = emojiScrollView.viewWithTag(2002) as! UIScrollView
            if scrollView.isKind(of: UIScrollView.self) {
                let pageNum: Int = Int(scrollView.contentOffset.x / SCREEN_WIDTH)
                pageControl.currentPage = pageNum
            }
            self.emojiScrollView.scrollRectToVisible(CGRECT(23 * SCREEN_WIDTH, 0, SCREEN_WIDTH, 200), animated: false)
            
            break
            
        case 104:
            
            pageControl.numberOfPages = 5
            
            let scrollView: UIScrollView = emojiScrollView.viewWithTag(2003) as! UIScrollView
            if scrollView.isKind(of: UIScrollView.self) {
                let pageNum: Int = Int(scrollView.contentOffset.x / SCREEN_WIDTH)
                pageControl.currentPage = pageNum
            }
            self.emojiScrollView.scrollRectToVisible(CGRECT(28 * SCREEN_WIDTH, 0, SCREEN_WIDTH, 200), animated: false)
            
            break


        default:
            break
        }
        
        // 设置btn样式
        self.setBtnPattern(btn)
    }
    
    // MARK: 按钮样式设置
    
    func setBtnPattern(_ btn: UIButton) {
    
        if btn.tag == 100 {
        
            pageControl.isHidden = true
        }
        
        else {
        
            pageControl.isHidden = false
        }
        
        if selectedBtn != nil {
        
            selectedBtn?.setImage(UIImage(named: getBtnNormalPic(selectedBtn!.tag - 100)), for: UIControlState())
            selectedBtn?.backgroundColor = RGB(224, 224, 224)
        }
        
        btn.setImage(UIImage(named: getBtnSelectedPic(btn.tag - 100)), for: UIControlState())
        
        selectedBtn = btn
        
    }
    
    // MARK: 发送评论
    
    func sendAction() {
    
        
    }
    
    // MARK: 添加表情
    
    func addEmojiAction(_ gesture: UIGestureRecognizer) {
    
        if gesture.state == UIGestureRecognizerState.ended {
        
            let label: UILabel = gesture.view as! UILabel
            
            // 调用delegate 添加表情
            self.delegate?.sendFaceSelected(label.text!)
            
            if label.tag < 1000 {
                
                self.recordUsedEmoji(label.text!)
            }
        }
    }
    
    // MARK: 显示用户用过的表情
    
    func showUsedEmoji() {
    
        print(getEmojiPicLocation())
        
        let emojiArr: NSMutableArray? = NSMutableArray(contentsOfFile: getEmojiPicLocation())
        
        if emojiArr == nil {
        
            return
        }
        
        for i in 0 ..< emojiArr!.count {
            
            // 行数
            let row = i / 8
            // 列数
            let col = (i + 1) % 8 == 0 ? 8 : (i + 1) % 8
            
            let emojiWidth = (SCREEN_WIDTH - 250) / 7 + 30
            
            var emojiLabel: UILabel? = emojiScrollView.viewWithTag(1000 + i) as? UILabel
            
            if emojiLabel == nil {
            
                emojiLabel = UILabel()
                emojiLabel?.frame = CGRect(x: 5 + CGFloat(col - 1) * emojiWidth, y: 15 + CGFloat(row * 50), width: 30, height: 30)
                emojiLabel?.tag = 1000 + i
            }
            
            if emojiLabel?.gestureRecognizers?.count == 0 {
            
                let gesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "")
                emojiLabel?.isUserInteractionEnabled = true
                emojiLabel?.addGestureRecognizer(gesture)
                //gesture.delegate = self
            }
            
            emojiLabel?.text = emojiArr![i] as? String
            emojiLabel?.font = UIFont.systemFont(ofSize: 30)
            
            emojiScrollView.addSubview(emojiLabel!)
        }
    }
    
    // MARK: 记录用户用过的表情
    
    func recordUsedEmoji(_ emojiStr: String) {
    
     
        var emojiArr: NSMutableArray? = NSMutableArray(contentsOfFile: getEmojiPicLocation())
        if emojiArr == nil {
        
            emojiArr = NSMutableArray()
        }
        
        // 最近使用只保存24个，也就是最多一页！
        if emojiArr!.count == 24 {
            
            emojiArr!.remove(emojiArr!.firstObject!)
        }
        
        if emojiArr!.contains(emojiStr) {
            
            emojiArr!.remove(emojiStr)
        }
        
        emojiArr!.insert(emojiStr, at: 0)
        
        emojiArr!.write(toFile: getEmojiPicLocation(), atomically: true)
        
        self.performSelector(onMainThread: #selector(FaceView.showUsedEmoji), with: nil, waitUntilDone: true)
    }
    
    
    // MARK: - UIScrollView Delegate
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let curPage = scrollView.contentOffset.x / SCREEN_WIDTH
        
        self.pageControl.currentPage = Int(curPage)
    }
}
