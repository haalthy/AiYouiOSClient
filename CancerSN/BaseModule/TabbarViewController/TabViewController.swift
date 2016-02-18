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
    override func viewDidLoad() {
        super.viewDidLoad()
        screenWidth = UIScreen.mainScreen().bounds.width
        screenHeight = UIScreen.mainScreen().bounds.height
        // Do any additional setup after loading the view.
        self.loadTabItems()
    }
    
    func loadTabItems() {
    
        let feedSB : UIStoryboard = UIStoryboard.init(name: "Feed", bundle: nil)
        
        let feedItem = feedSB.instantiateInitialViewController() as! UINavigationController
        feedItem.delegate = self
        feedItem.tabBarItem = UITabBarItem.init(title: "智囊团", image: UIImage(named: "icon_home"), selectedImage: UIImage(named: "icon_homeSelected"))
        
        let postVC = PostViewController()
        postVC.tabBarItem = UITabBarItem.init()
        postVC.tabBarItem.enabled = false
        
        let profile : UIStoryboard = UIStoryboard.init(name: "User", bundle: nil)
        
        let profileItem  = profile.instantiateInitialViewController() as! UINavigationController
        profileItem.delegate = self
        profileItem.tabBarItem = UITabBarItem.init(title: "我的奇迹", image: UIImage(named: "icon_profile"), selectedImage: UIImage(named: "icon_profileSelected"))
        
        self.viewControllers = [feedItem, postVC, profileItem]
        
        // 加载post按钮
        
        self.addPostBtn()
        
        // 设置tabbar属性
        
        self.setTabBarAttributes()
    }
    
    // MARK: - 添加中间postBtn
    
    func addPostBtn() {
    
        let postBtn = UIButton.init(type: UIButtonType.Custom)
        
        let barSize : CGSize = self.tabBar.frame.size;
        postBtn.frame = CGRectMake(0, 0, barSize.height, barSize.height)
        postBtn.center = CGPointMake(barSize.width * 0.5, barSize.height * 0.5)
        postBtn.layer.cornerRadius = 0.3
        
        postBtn.setBackgroundImage(UIImage(named: "btn_post"), forState: UIControlState.Normal )
        self.tabBar .addSubview(postBtn)
        
        postBtn.addTarget(self, action: "addPost", forControlEvents: UIControlEvents.TouchUpInside)
        
    }
    
    func addPost(){
        var topVC = UIApplication.sharedApplication().keyWindow?.rootViewController
        while topVC?.presentedViewController != nil {
            topVC = topVC?.presentedViewController
        }
        //add blur view
        blurView.frame = CGRECT(0, 0, UIScreen.mainScreen().bounds.width, UIScreen.mainScreen().bounds.height)
        blurView.backgroundColor = UIColor.clearColor()
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.ExtraLight)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = CGRECT(0, 0, UIScreen.mainScreen().bounds.width, UIScreen.mainScreen().bounds.height)
        blurView.addSubview(blurEffectView)

        //add transparent View
        let transparentView = UIView(frame: CGRECT(0, 0, UIScreen.mainScreen().bounds.width, UIScreen.mainScreen().bounds.height))
        transparentView.alpha = 0.6
        blurView.addSubview(transparentView)
        topVC?.view.addSubview(blurView)
        //add Button
        blurView.addSubview(addBtn("addTreatmentBtn"))
        blurView.addSubview(addBtn("addStatusBtn"))
        blurView.addSubview(addBtn("addQuestionBtn"))
        blurView.addSubview(addBtn("addMoodBtn"))
        blurView.addSubview(addBtn("cancelBtn"))
    }
    
    func addBtn(btnName: String)->UIButton{
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
        btn.backgroundColor = headerColor
        let backgroundImgView = UIImageView()
        if btnName == "addTreatmentBtn"{
            btn.frame = CGRect(x: btn1LeftSpace, y: screenHeight - btn1ButtomSpace - addBtnW, width: addBtnW, height: addBtnW)
            backgroundImgView.image = UIImage(named: "btn_addTreatment")
            btn.addTarget(self, action: "addTreatment:", forControlEvents: UIControlEvents.TouchUpInside)

        }else if btnName == "addStatusBtn" {
            btn.frame = CGRect(x: btn2LeftSpace, y: screenHeight - btn2ButtomSpace - addBtnW, width: addBtnW, height: addBtnW)
            backgroundImgView.image = UIImage(named: "btn_addStatus")
            btn.addTarget(self, action: "addStatus:", forControlEvents: UIControlEvents.TouchUpInside)
        }else if btnName == "addQuestionBtn" {
            btn.frame = CGRect(x: screenWidth - btn3RightSpace - addBtnW, y: screenHeight - btn3ButtomSpace - addBtnW, width: addBtnW, height: addBtnW)
            backgroundImgView.image = UIImage(named: "btn_addQuestion")
            btn.addTarget(self, action: "addQuestion:", forControlEvents: UIControlEvents.TouchUpInside)
        }else if btnName == "addMoodBtn" {
            btn.frame = CGRect(x: screenWidth - btn4RightSpace - addBtnW, y: screenHeight - btn4ButtomSpace - addBtnW, width: addBtnW, height: addBtnW)
            backgroundImgView.image = UIImage(named: "btn_addMood")
            btn.addTarget(self, action: "addMood:", forControlEvents: UIControlEvents.TouchUpInside)
        }else if btnName == "cancelBtn" {
            let cancelBtnX: CGFloat = (screenWidth - cancelBtnW)/2.0
            btn.frame = CGRect(x: cancelBtnX, y: screenHeight - cancelBtnButtomSpace - cancelBtnW, width: cancelBtnW, height: cancelBtnW)
            backgroundImgView.image = UIImage(named: "btn_cancelAdd")
            btn.backgroundColor = UIColor.clearColor()
            btn.addTarget(self, action: "cancel:", forControlEvents: UIControlEvents.TouchUpInside)
        }
        btn.layer.cornerRadius = btn.frame.width/2
        btn.layer.masksToBounds = true
        backgroundImgView.frame = CGRECT(10, 10, btn.frame.width - 20, btn.frame.height - 20)
        backgroundImgView.contentMode = UIViewContentMode.ScaleAspectFit
        btn.addSubview(backgroundImgView)
        return btn
    }
    
    func addTreatment(sender: UIButton){
        blurView.removeFromSuperview()
        let storyboard = UIStoryboard(name: "Add", bundle: nil)
        let addViewController = storyboard.instantiateViewControllerWithIdentifier("AddTreatment")
        self.presentViewController(addViewController, animated: true, completion: nil)
    }
    
    func addStatus(sender: UIButton){
        //
        blurView.removeFromSuperview()
        let storyboard = UIStoryboard(name: "Add", bundle: nil)
        let addViewController = storyboard.instantiateViewControllerWithIdentifier("AddPatientStatus")
        self.presentViewController(addViewController, animated: true, completion: nil)
    }
    
    func addQuestion(sender: UIButton){
        blurView.removeFromSuperview()
        //AddPost
        let storyboard = UIStoryboard(name: "Add", bundle: nil)
        let addViewController = storyboard.instantiateViewControllerWithIdentifier("AddPost") as! AddPostNavigationViewController
        addViewController.isQuestion = true
        self.presentViewController(addViewController, animated: true, completion: nil)
    }
    
    func addMood(sender: UIButton){
        blurView.removeFromSuperview()
        //AddPost
        let storyboard = UIStoryboard(name: "Add", bundle: nil)
        let addViewController = storyboard.instantiateViewControllerWithIdentifier("AddPost") as! AddPostNavigationViewController
        addViewController.isQuestion = false
        self.presentViewController(addViewController, animated: true, completion: nil)
    }
    
    func cancel(sender: UIButton){
        blurView.removeFromSuperview()
    }
    // MARK: - set TabBar attributes
    
    func setTabBarAttributes() {
        UITabBar.appearance().tintColor = mainColor
        UITabBar.appearance().barTintColor = tabBarColor

    }
    
    // MARK: - Navigation 
    
    func navigationController(navigationController: UINavigationController, willShowViewController viewController: UIViewController, animated: Bool) {
        
        let rootVC: UIViewController = navigationController.viewControllers[0]
        if rootVC != viewController {
        
            viewController.navigationItem.leftBarButtonItem = UIBarButtonItem.init(image: UIImage(named: "btn_back"), style: UIBarButtonItemStyle.Plain, target: self, action: "callback")
        }
    }
    
    // MARK: 返回方法
    
    func callback() {
    
        (self.viewControllers![self.selectedIndex] as! UINavigationController).popViewControllerAnimated(true)
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
