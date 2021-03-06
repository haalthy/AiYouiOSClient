//
//  TabViewController.swift
//  CancerSN
//
//  Created by lay on 15/12/17.
//  Copyright © 2015年 lily. All rights reserved.
//

import UIKit

class TabViewController: UITabBarController,UINavigationControllerDelegate {

    var screenWidth = CGFloat()
    var screenHeight = CGFloat()
    var blurView = UIView()
    
    let keychainAccess = KeychainAccess()
    let getAccessToken = GetAccessToken()
    var curIndex: Int = 0
    
    var redDotBadge: UIView = UIView()

    override func viewDidLoad() {
        super.viewDidLoad()
        screenWidth = UIScreen.main.bounds.width
        screenHeight = UIScreen.main.bounds.height
        // Do any additional setup after loading the view.
        self.loadTabItems()
    }
    
    func loadTabItems() {
    
        let feedSB : UIStoryboard = UIStoryboard.init(name: "Feed", bundle: nil)
        
        let feedItem = feedSB.instantiateInitialViewController() as! UINavigationController
        feedItem.delegate = self
        feedItem.tabBarItem = UITabBarItem.init(title: "智囊团", image: UIImage(named: "icon_home"), selectedImage: UIImage(named: "icon_homeSelected"))
        feedItem.tabBarItem.tag = 0
        
        let postVC = PostViewController()
        postVC.tabBarItem = UITabBarItem.init()
        postVC.tabBarItem.tag = 1
        postVC.tabBarItem.isEnabled = false
        
        let profile : UIStoryboard = UIStoryboard.init(name: "User", bundle: nil)
        
        let profileItem  = profile.instantiateInitialViewController() as! UINavigationController
        profileItem.delegate = self
        profileItem.tabBarItem = UITabBarItem.init(title: "我的奇迹", image: UIImage(named: "icon_profile"), selectedImage: UIImage(named: "icon_profileSelected"))
        profileItem.tabBarItem.tag = 2
        
        self.viewControllers = [feedItem, postVC, profileItem]
        
        // 加载post按钮
        
        self.addPostBtn()
        
        // 设置tabbar属性
        
        self.setTabBarAttributes()
        
        // 初始化通知
        
        self.initNotification()
        
        // 初始化加红点状态（个数）
        if (keychainAccess.getPasscode(accessNSUserData) != nil) && (keychainAccess.getPasscode(usernameKeyChain) != nil) && (keychainAccess.getPasscode(passwordKeyChain) != nil ){
            
            UserDefaults.standard.set(false, forKey: unreadCommentBadgeCount)
            
            UserDefaults.standard.set(false, forKey: unreadFollowBadgeCount)
            
            UserDefaults.standard.set(false, forKey: unreadMentionedBadgeCount)
            
            self.getUnreadCommentCountFromServer()
            self.getUnreadFollowCountFromServer()
            self.getUnreadMentionedCountFromServer()
        }
    }
    
    // MARK: - 添加中间postBtn
    
    func addPostBtn() {
    
        let postBtn = UIButton.init(type: UIButtonType.custom)
        
        let barSize : CGSize = self.tabBar.frame.size;
        postBtn.frame = CGRect(x: 0, y: 0, width: barSize.height, height: barSize.height)
        postBtn.center = CGPoint(x: barSize.width * 0.5, y: barSize.height * 0.5)
        postBtn.layer.cornerRadius = 0.3
        
        postBtn.setBackgroundImage(UIImage(named: "btn_post"), for: UIControlState() )
        self.tabBar .addSubview(postBtn)
        
        postBtn.addTarget(self, action: #selector(TabViewController.addPost), for: UIControlEvents.touchUpInside)
        
    }
    
    func addPost(){
        var topVC = UIApplication.shared.keyWindow?.rootViewController
        while topVC?.presentedViewController != nil {
            topVC = topVC?.presentedViewController
        }
        //add blur view
        blurView.frame = CGRECT(0, 0, UIScreen.main.bounds.width, UIScreen.main.bounds.height)
        blurView.backgroundColor = UIColor.clear
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.extraLight)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = CGRECT(0, 0, UIScreen.main.bounds.width, UIScreen.main.bounds.height)
        blurView.addSubview(blurEffectView)

        //add transparent View
        let transparentView = UIView(frame: CGRECT(0, 0, UIScreen.main.bounds.width, UIScreen.main.bounds.height))
        transparentView.alpha = 0.6
        blurView.addSubview(transparentView)
        topVC?.view.addSubview(blurView)
        //add Button
        blurView.addSubview(addBtn("addTreatmentBtn"))
        blurView.addSubview(addBtn("addStatusBtn"))
        blurView.addSubview(addBtn("addQuestionBtn"))
        blurView.addSubview(addBtn("addMoodBtn"))
        blurView.addSubview(addBtn("cancelBtn"))
        
        blurView.addSubview(addLabel("addTreatmentBtn"))
        blurView.addSubview(addLabel("addStatusBtn"))
        blurView.addSubview(addLabel("addQuestionBtn"))
        blurView.addSubview(addLabel("addMoodBtn"))
    }
    
    func addBtn(_ btnName: String)->UIButton{
        if screenWidth < 350 {
            //btn1
             btn1LeftSpace = CGFloat(55)
            //btn2
             btn2LeftSpace = CGFloat(107)
            //btn3
             btn3RightSpace = CGFloat(107)
            //btn4
             btn4RightSpace = CGFloat(55)
        }
        let btn = UIButton()
//        btn.backgroundColor = headerColor
        let backgroundImgView = UIImageView()
        if btnName == "addTreatmentBtn"{
            btn.frame = CGRect(x: btn1LeftSpace, y: screenHeight - btn1ButtomSpace - addBtnW, width: addBtnW, height: addBtnW)
            backgroundImgView.image = UIImage(named: "btn_addTreatment")
            btn.addTarget(self, action: #selector(TabViewController.addTreatment(_:)), for: UIControlEvents.touchUpInside)
            btn.backgroundColor = UIColor.init(red: 64 / 255, green: 125 / 255, blue: 201 / 255, alpha: 1)
            backgroundImgView.frame = CGRECT(10, 10, btn.frame.width - 20, btn.frame.height - 20)
        }else if btnName == "addStatusBtn" {
            btn.frame = CGRect(x: btn2LeftSpace, y: screenHeight - btn2ButtomSpace - addBtnW, width: addBtnW, height: addBtnW)
            backgroundImgView.image = UIImage(named: "btn_addStatus")
            btn.addTarget(self, action: #selector(TabViewController.addStatus(_:)), for: UIControlEvents.touchUpInside)
            btn.backgroundColor = UIColor.init(red: 61 / 255, green: 208 / 255, blue: 221 / 255, alpha: 1)
            backgroundImgView.frame = CGRECT(10, 10, btn.frame.width - 20, btn.frame.height - 20)
        }else if btnName == "addQuestionBtn" {
            btn.frame = CGRect(x: screenWidth - btn3RightSpace - addBtnW, y: screenHeight - btn3ButtomSpace - addBtnW, width: addBtnW, height: addBtnW)
            backgroundImgView.image = UIImage(named: "btn_addQuestion")
            btn.addTarget(self, action: #selector(TabViewController.addQuestion(_:)), for: UIControlEvents.touchUpInside)
            btn.backgroundColor = UIColor.init(red: 89 / 255, green: 200 / 255, blue: 121 / 255, alpha: 1)
            backgroundImgView.frame = CGRECT(10, 10, btn.frame.width - 20, btn.frame.height - 20)
        }else if btnName == "addMoodBtn" {
            btn.frame = CGRect(x: screenWidth - btn4RightSpace - addBtnW, y: screenHeight - btn4ButtomSpace - addBtnW, width: addBtnW, height: addBtnW)
            backgroundImgView.image = UIImage(named: "btn_addMood")
            btn.addTarget(self, action: #selector(TabViewController.addMood(_:)), for: UIControlEvents.touchUpInside)
            btn.backgroundColor = UIColor.init(red: 255 / 255, green: 173 / 255, blue: 56 / 255, alpha: 1)
            backgroundImgView.frame = CGRECT(10, 10, btn.frame.width - 20, btn.frame.height - 20)
        }else if btnName == "cancelBtn" {
            let cancelBtnMargin: CGFloat = 2
            let cancelBtnX: CGFloat = (screenWidth - cancelBtnW)/2.0
            btn.frame = CGRect(x: cancelBtnX - cancelBtnMargin, y: screenHeight - cancelBtnButtomSpace - cancelBtnW - cancelBtnMargin, width: cancelBtnW + cancelBtnMargin * 2, height: cancelBtnW + cancelBtnMargin * 2)
            backgroundImgView.frame = CGRECT(cancelBtnMargin + cancelBtnW/4, cancelBtnMargin + cancelBtnW/4, cancelBtnW/2, cancelBtnW/2)
            backgroundImgView.image = UIImage(named: "btn_cancelAdd")
            btn.backgroundColor = textInputViewPlaceholderColor
            btn.addTarget(self, action: #selector(TabViewController.cancel(_:)), for: UIControlEvents.touchUpInside)
        }
        btn.layer.cornerRadius = btn.frame.width/2
        btn.layer.masksToBounds = true
        backgroundImgView.contentMode = UIViewContentMode.scaleAspectFit
        btn.addSubview(backgroundImgView)
        return btn
    }
    
    func addLabel(_ labelname: String)->UILabel{
        let lbl = UILabel()
        lbl.textColor = UIColor.init(red: 151 / 255, green: 151 / 255, blue: 151 / 255, alpha: 1)
        lbl.font = UIFont.systemFont(ofSize: 9)
        if labelname == "addTreatmentBtn"{
            lbl.frame = CGRect(x: btn1LeftSpace, y: screenHeight - btn1ButtomSpace + 5, width: addBtnW, height: 10)
            lbl.text = "治疗方案"
        }else if labelname == "addStatusBtn" {
            lbl.frame = CGRect(x: btn2LeftSpace, y: screenHeight - btn2ButtomSpace + 5, width: addBtnW, height: 10)
            lbl.text = "病人状态"
        }else if labelname == "addQuestionBtn" {
            lbl.frame = CGRect(x: screenWidth - btn3RightSpace - addBtnW, y: screenHeight - btn3ButtomSpace + 5, width: addBtnW, height: 10)
            lbl.text = "提出问题"
        }else if labelname == "addMoodBtn" {
            lbl.frame = CGRect(x: screenWidth - btn4RightSpace - addBtnW, y: screenHeight - btn4ButtomSpace + 5, width: addBtnW, height: 10)
            lbl.text = "发表心得"
        }

        return lbl
    }
    
    func addTreatment(_ sender: UIButton){
        blurView.removeFromSuperview()
        let storyboard = UIStoryboard(name: "Add", bundle: nil)
        let addViewController = storyboard.instantiateViewController(withIdentifier: "AddTreatment")
        self.present(addViewController, animated: true, completion: nil)
    }
    
    func addStatus(_ sender: UIButton){
        //
        blurView.removeFromSuperview()
        let storyboard = UIStoryboard(name: "Add", bundle: nil)
        let addViewController = storyboard.instantiateViewController(withIdentifier: "AddPatientStatus")
        self.present(addViewController, animated: true, completion: nil)
    }
    
    func addQuestion(_ sender: UIButton){
        blurView.removeFromSuperview()
        //AddPost
        let storyboard = UIStoryboard(name: "Add", bundle: nil)
        let addViewController = storyboard.instantiateViewController(withIdentifier: "AddPost") as! AddPostNavigationViewController
        addViewController.isQuestion = true
        self.present(addViewController, animated: true, completion: nil)
    }
    
    func addMood(_ sender: UIButton){
        blurView.removeFromSuperview()
        //AddPost
        let storyboard = UIStoryboard(name: "Add", bundle: nil)
        let addViewController = storyboard.instantiateViewController(withIdentifier: "AddPost") as! AddPostNavigationViewController
        addViewController.isQuestion = false
        self.present(addViewController, animated: true, completion: nil)
    }
    
    func cancel(_ sender: UIButton){
        blurView.removeFromSuperview()
    }
    // MARK: - set TabBar attributes
    
    func setTabBarAttributes() {
        UITabBar.appearance().tintColor = mainColor
        UITabBar.appearance().barTintColor = tabBarColor
        
        let tabbarFrame: CGRect = self.tabBar.frame
        
        let itemWidth = tabbarFrame.width / 3
        let x = itemWidth / 2 + 10
        let y = tabbarFrame.height / 3 - 5
        // 添加红点view
        self.redDotBadge.frame = CGRECT(x, y, 5, 5)
        self.tabBar.addSubview(self.redDotBadge)
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        
        self.curIndex = item.tag
    }
    
    // MARK: - Navigation 
    
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        
        let rootVC: UIViewController = navigationController.viewControllers[0]
        if rootVC != viewController {
        
            viewController.navigationItem.leftBarButtonItem = UIBarButtonItem.init(image: UIImage(named: "btn_back"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(TabViewController.callback))
        }
    }
    
    // MARK: 返回方法
    
    func callback() {
    
        (self.viewControllers![self.selectedIndex] as! UINavigationController).popViewController(animated: true)
    }
    
    // MARK: - 初始化通知
    
    func initNotification() {
    
        NotificationCenter.default.addObserver(self, selector: #selector(TabViewController.showRedDotBadge), name: NSNotification.Name(rawValue: addTabbarRedDotBadge), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(TabViewController.deleteRedDotBadge), name: NSNotification.Name(rawValue: deleteTabbarRedDotBadge), object: nil)
    }
    
    // MARK: 展示智囊圈badge
    
    func showRedDotBadge() {
    
        let isComment: Bool = UserDefaults.standard.bool(forKey: unreadCommentBadgeCount)
        
        let isFollow: Bool = UserDefaults.standard.bool(forKey: unreadFollowBadgeCount)
        
        let isMentioned: Bool = UserDefaults.standard.bool(forKey: unreadMentionedBadgeCount)
        
        if isComment || isFollow || isMentioned {
        
            //self.tabBar.items![0].badgeValue = ""
            self.redDotBadge.showBadge(withShowType: .up)
        
        }
        else {
        
            self.deleteRedDotBadge()
        }
        
    }
    
    // MARK: 删除智囊圈badge
    
    func deleteRedDotBadge() {
    
       // self.tabBar.items![0].badgeValue = nil
        self.redDotBadge.clearBadge()
    }
    
    // MARK: - 网络请求
    
    // MARK: 获取未读@我的数量
    
    func getUnreadMentionedCountFromServer() {
        
        NetRequest.sharedInstance.POST(getNewMentionedCountURL , isToken: false, parameters: [ "username" : keychainAccess.getPasscode(usernameKeyChain)!], success: { (content, message) -> Void in
            
            let dict: NSDictionary = content as! NSDictionary
            
            if dict["count"] as! Int > 0 {
                
                judgeIsAddCount(1)
            }
            else {
                judgeIsDecCount(1)
            }
            
            }) { (content, message) -> Void in
                
        }
    }
    
    
    // MARK: 获取未读关注的数量
    
    func getUnreadFollowCountFromServer() {
        
        NetRequest.sharedInstance.POST(getNewFollowCountURL , isToken: false, parameters: [ "username" : keychainAccess.getPasscode(usernameKeyChain)!], success: { (content, message) -> Void in
            
            let dict: NSDictionary = content as! NSDictionary
            
            if dict["count"] as! Int > 0 {
                
                judgeIsAddCount(2)
            }
            else {
                judgeIsDecCount(2)
            }
            
            
            }) { (content, message) -> Void in
                
        }
    }
    
    // 获取未读评论的数量
    
    func getUnreadCommentCountFromServer() {
        
        NetRequest.sharedInstance.POST(getNewCommentCountURL , isToken: false, parameters: [ "username" : keychainAccess.getPasscode(usernameKeyChain)!], success: { (content, message) -> Void in
            
            let dict: NSDictionary = content as! NSDictionary
            
            if dict["count"] as! Int > 0 {
                
                judgeIsAddCount(0)
            }
            else {
                
                judgeIsDecCount(0)
            }
            }) { (content, message) -> Void in
                
        }
        
    }

    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
