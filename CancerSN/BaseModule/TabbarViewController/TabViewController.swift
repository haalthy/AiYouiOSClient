//
//  TabViewController.swift
//  CancerSN
//
//  Created by lay on 15/12/17.
//  Copyright © 2015年 lily. All rights reserved.
//

import UIKit

class TabViewController: UITabBarController,UINavigationControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

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
        let storyboard = UIStoryboard(name: "Add", bundle: nil)
        let popoverContent = storyboard.instantiateViewControllerWithIdentifier("AddEntry")
        let nav = UINavigationController(rootViewController: popoverContent)
        nav.modalPresentationStyle = UIModalPresentationStyle.Popover
        let popover = nav.popoverPresentationController
//        popoverContent.preferredContentSize = CGSizeMake(100,100)
//        popover!.delegate = self
//        popover!.sourceView = self.view
//        popover!.sourceRect = CGRectMake(300,0,0,0)
//        popover?.permittedArrowDirections = UIPopoverArrowDirection.Up
        
        self.presentViewController(nav, animated: true, completion: nil)
    }
    
    // MARK: - set TabBar attributes
    
    func setTabBarAttributes() {
    
       // UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: tabBarItemNormalColor], forState:.Normal)
        //UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: mainColor], forState:.Selected)
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
