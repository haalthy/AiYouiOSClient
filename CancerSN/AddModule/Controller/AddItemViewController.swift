//
//  AddItemViewController.swift
//  CancerSN
//
//  Created by lily on 8/4/15.
//  Copyright (c) 2015 lily. All rights reserved.
//

import UIKit

class AddItemViewController: UIViewController {

//    var isBroadcast : Int = 0
//    let profileSet = NSUserDefaults.standardUserDefaults()
//
    @IBOutlet weak var blurView: UIView!
    var isDismiss : Bool = false
//
//    
//    @IBAction func addPatientStatusSegue(sender: UIButton) {
//        isDismiss = true
//    }
//    
//    @IBAction func addTreatmentSegue(sender: UIButton) {
//        isDismiss = true
//        self.performSegueWithIdentifier("addTreatmentSegue", sender: self)
//
//    }
//    @IBAction func addBroadcast(sender: UIButton) {
//        if profileSet.objectForKey(accessNSUserData) == nil{
//            let storyboard = UIStoryboard(name: "Main", bundle: nil)
//            let controller = storyboard.instantiateViewControllerWithIdentifier("LoginEntry") as UIViewController
//            
//            self.presentViewController(controller, animated: true, completion: nil)
//        }else{
//            self.isBroadcast = 1
//            isDismiss = true
//            self.performSegueWithIdentifier("addPostSegue", sender: nil)
//        }
//    }
//    
//    @IBAction func addPrivatePost(sender: UIButton) {
//        if profileSet.objectForKey(accessNSUserData) == nil{
//            let storyboard = UIStoryboard(name: "Main", bundle: nil)
//            let controller = storyboard.instantiateViewControllerWithIdentifier("LoginEntry") as UIViewController
//            
//            self.presentViewController(controller, animated: true, completion: nil)
//        }
//        self.isBroadcast = 0
//        isDismiss = true
//        self.performSegueWithIdentifier("addPostSegue", sender: nil)
//    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.modalPresentationStyle = .Custom
        
//        self.preferredContentSize = CGSizeMake(180, 180)
//        self.blurView.frame = CGRECT(0, 0, UIScreen.mainScreen().bounds.width, UIScreen.mainScreen().bounds.height)
//        view.backgroundColor = UIColor.clearColor()
//        var blurEffect = UIBlurEffect(style: UIBlurEffectStyle.ExtraLight)
//        var blurEffectView = UIVisualEffectView(effect: blurEffect)
//        blurEffectView.frame =  CGRECT(0, 0, UIScreen.mainScreen().bounds.width, UIScreen.mainScreen().bounds.height)
//        
//        let blurView = UIView(frame: CGRECT(0, 0, UIScreen.mainScreen().bounds.width, UIScreen.mainScreen().bounds.height))
//        blurView.backgroundColor = UIColor.redColor()
//        blurView.addSubview(blurEffectView)
//        
//        self.view.addSubview(blurView)
    }
    
//    @IBAction func cancel(sender: UIButton) {
//        self.dismissViewControllerAnimated(true, completion: nil)
//    }
//    
    
//    func updateBlur() {
//        //为了避免在截图的时候截到选项界面，因此先要确保选项界面必须是隐藏状态。
//        optionsContainerView.hidden = true
//        //创建一个新的ImageContext来绘制截图，你没有必要去渲染一个完整分辨率的高清截图，使用ImageContext可以节约掉不少的计算量
//        UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, true, 1)
//        //将StoryViewController中的界面绘制到ImageContext中去，因为你需要确保选项界面是隐藏状态因此你需要等待屏幕刷新后才能绘制
//        self.view.drawViewHierarchyInRect(self.view.bounds, afterScreenUpdates: true)
//        //将ImageContext放入一个UIImage内然后清理掉这个ImageContext
//        let screenshot = UIGraphicsGetImageFromCurrentImageContext()
//        UIGraphicsEndImageContext()
//    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.navigationBar.hidden = true
        self.tabBarController?.tabBar.hidden = true
        self.navigationController?.navigationBar.hidden = true
        let getAccessToken: GetAccessToken = GetAccessToken()
        getAccessToken.getAccessToken()
        if isDismiss {
            self.dismissViewControllerAnimated(false, completion: nil)
        }
    }
//
//    
//    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//        if segue.identifier == "addPostSegue" {
//            (segue.destinationViewController as! AddPostViewController).isBroadcast = self.isBroadcast
//        }
//    }
//    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.hidden = false
        self.navigationController?.navigationBar.hidden = false
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
