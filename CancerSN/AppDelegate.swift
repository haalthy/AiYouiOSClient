//
//  AppDelegate.swift
//  CancerSN
//
//  Created by lily on 7/20/15.
//  Copyright (c) 2015 lily. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    var tabVC: TabViewController = TabViewController()

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        let publicSerice = PublicService()
        print(publicSerice.passwordEncode("password"))
//        let keychainAccess = KeychainAccess()
//        keychainAccess.setPasscode(usernameKeyChain, passcode: "AY1455509990925.619")
//        keychainAccess.setPasscode(passwordKeyChain, passcode: "password")
        
        // Override point for customization after application launch.
        WXApi.registerApp(WXAppID)
        let tabViewController : TabViewController = TabViewController()
        self.window!.rootViewController = tabViewController
        
        self.tabVC = tabViewController
        // 初始化导航栏
        self.initNavigationBar()
        
        self.window!.makeKeyAndVisible()
        checkUserStatus()
        screenHeight = (self.window?.bounds.height)!
        screenWidth = (self.window?.bounds.width)!
        

        // 注册远程通知
        
        self.registerRemoteNotificaiton(application)
        
        JPUSHService.setupWithOption(launchOptions, appKey: appKey, channel: channel, apsForProduction: isProduction)

        return true
    }
    
    // MARK: - init Navigation Bar
    
    func initNavigationBar() {
        
        // 定义navigation属性
        UINavigationBar.appearance().barTintColor = headerColor
        UINavigationBar.appearance().tintColor = UIColor.whiteColor()
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent
        let dict = [NSFontAttributeName : UIFont.systemFontOfSize(20)]
        UINavigationBar.appearance().titleTextAttributes = dict
        UINavigationBar.appearance().barStyle = .Black
    }
    
    // MARK: - 是否进入到主页界面
    
    func checkUserStatus() {

        let keychainAccess = KeychainAccess()

        if (NSUserDefaults.standardUserDefaults().objectForKey(favTagsNSUserData) == nil) || (NSUserDefaults.standardUserDefaults().objectForKey(favTagsNSUserData) as! NSArray).count == 0{
//            keychainAccess.deletePasscode(usernameKeyChain)
//            keychainAccess.deletePasscode(passwordKeyChain)
            let getAccessToken = GetAccessToken()
            getAccessToken.getAccessToken()
            let access_Token = NSUserDefaults.standardUserDefaults().objectForKey(accessNSUserData)
            if (access_Token == nil) || ((access_Token as! String) == "") {
                let storyboard = UIStoryboard(name: "Registeration", bundle: nil)
                let rootController = storyboard.instantiateViewControllerWithIdentifier("LoginEntry") as! UINavigationController
                if self.window != nil {
                    self.window!.rootViewController = rootController
//                    rootController.isRootViewController = true
                }

            }
        }

    }

    func registerRemoteNotificaiton(application: UIApplication) {
    
        
        if Float(UIDevice.currentDevice().systemVersion)! >= 8.0 {
        

        application.registerUserNotificationSettings ( UIUserNotificationSettings (forTypes:  [UIUserNotificationType .Sound, UIUserNotificationType .Alert , UIUserNotificationType .Badge], categories:  nil ))
        }
        else {
        
        application.registerForRemoteNotificationTypes ([UIRemoteNotificationType.Alert, UIRemoteNotificationType.Sound, UIRemoteNotificationType.Badge])

        }
        
    }
    
    // MARK: - 获取deviceToken
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        
        let token: NSString = NSString(format: "%@", deviceToken)
        
        JPUSHService.registerDeviceToken(deviceToken)
        
        let registrationID = JPUSHService.registrationID()
        
        print(registrationID)
        
        if registrationID != nil {
        
            self.submitRegistrationIDToServer(registrationID)
        }
        
        NSUserDefaults.standardUserDefaults().setValue(registrationID, forKey:kDeviceToken)
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        print(error)
    }
    
    
    // MARK: 更新registrationID 
    
    func submitRegistrationIDToServer(registrationID: String) {
    
        let keychainAccess = KeychainAccess()
        
        let username = keychainAccess.getPasscode(usernameKeyChain)
        if username != nil {
        
            let paramtersDict: Dictionary<String, AnyObject> = ["userName" : username!, "fromUserName" : registrationID]
            NetRequest.sharedInstance.POST(pushIdURL, parameters: paramtersDict, success: { (content, message) -> Void in
                
                }, failed: { (content, message) -> Void in
                    
            })
        }

    }
    
    // MARK: - 跳转功能
    
    // MARK: 跳转到消息中心
    
    func enterMessageView() {
    
        // 判断用户是否登录
        
        let keychainAccess = KeychainAccess()
        
        let profileSB: UIStoryboard = UIStoryboard(name: "User", bundle: nil)
        
        let postVC: PostsViewController = profileSB.instantiateViewControllerWithIdentifier("PostView") as! PostsViewController
        postVC.username = keychainAccess.getPasscode(usernameKeyChain) as! String
        postVC.commentCount = 0
        (self.tabVC.viewControllers![tabVC.curIndex] as! UINavigationController).pushViewController(postVC, animated: true)
    }
    
    // MARK: 跳转到关注
    
    func enterFollowView() {
    
        // 判断用户是否登录
        
        let profileSB: UIStoryboard = UIStoryboard(name: "User", bundle: nil)
        
        let followVC: UserFollowViewController = profileSB.instantiateViewControllerWithIdentifier("FollowView") as! UserFollowViewController
        (self.tabVC.viewControllers![tabVC.curIndex] as! UINavigationController).pushViewController(followVC, animated: true)
    }
    
    // MARK: 跳转到@我的
    
    func enterMentionedView() {
    
        // 判断用户是否登录
        
        let profileSB: UIStoryboard = UIStoryboard(name: "User", bundle: nil)
        
        let mentionedVC: MentionedViewController = profileSB.instantiateViewControllerWithIdentifier("MentionedView") as! MentionedViewController
        (self.tabVC.viewControllers![tabVC.curIndex] as! UINavigationController).pushViewController(mentionedVC, animated: true)
    }
    
    // MARK: 跳转到内容详情
    
    func enterFeedDetailView() {
    
        let feedSB: UIStoryboard = UIStoryboard(name: "Feed", bundle: nil)
        
        let feedDetailVC: FeedDetailViewController = feedSB.instantiateViewControllerWithIdentifier("FeedDetailView") as! FeedDetailViewController
        feedDetailVC.feedId = 0

        (self.tabVC.viewControllers![tabVC.curIndex] as! UINavigationController).pushViewController(feedDetailVC, animated: true)
    }

    func application(application: UIApplication, didRegisterUserNotificationSettings notificationSettings: UIUserNotificationSettings) {
        
    }
    
    func application(application: UIApplication, handleActionWithIdentifier identifier: String?, forRemoteNotification userInfo: [NSObject : AnyObject], completionHandler: () -> Void) {
        
        
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        
        JPUSHService.handleRemoteNotification(userInfo)
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject], fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        
        JPUSHService.handleRemoteNotification(userInfo)

    }
    
    

    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        application.applicationIconBadgeNumber = 0
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        
        application.applicationIconBadgeNumber = 0
        application.cancelAllLocalNotifications()

    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        self.saveContext()
    }

    // MARK: - Core Data stack
    
    lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "fili99.CancerSN" in the application's documents Application Support directory.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1] 
        }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = NSBundle.mainBundle().URLForResource("CancerSN", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
        }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        var coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("CancerSN.sqlite")
        var error: NSError? = nil
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator!.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil)
        } catch var error1 as NSError {
            error = error1
            coordinator = nil
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason
            dict[NSUnderlyingErrorKey] = error
            error = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(error), \(error!.userInfo)")
            abort()
        } catch {
            fatalError()
        }
        
        return coordinator
        }()
    
    lazy var managedObjectContext: NSManagedObjectContext? = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        if coordinator == nil {
            return nil
        }
        var managedObjectContext = NSManagedObjectContext()
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
        }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        if let moc = self.managedObjectContext {
            var error: NSError? = nil
            if moc.hasChanges {
                do {
                    try moc.save()
                } catch let error1 as NSError {
                    error = error1
                    // Replace this implementation with code to handle the error appropriately.
                    // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    NSLog("Unresolved error \(error), \(error!.userInfo)")
                    abort()
                }
            }
        }
    }

    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        WXApi.handleOpenURL(url, delegate: WXApiManager.sharedInstance)
        return TencentOAuth.HandleOpenURL(url)
        
    }
    
    func onReq(req: BaseReq!) {
        print("on req")
    }
    
    func application(application: UIApplication, handleOpenURL url: NSURL) -> Bool {
        WXApi.handleOpenURL(url, delegate: WXApiManager.sharedInstance)
        return TencentOAuth.HandleOpenURL(url)
    }
    
    func onResp(resp: BaseResp!) {
        print("on resp")
//        if ([resp isKindOfClass:[SendAuthResp class]]) {
//            if (_delegate
//            && [_delegate respondsToSelector:@selector(managerDidRecvAuthResponse:)]) {
//                SendAuthResp *authResp = (SendAuthResp *)resp;
//                [_delegate managerDidRecvAuthResponse:authResp];
//            }
//        }
        if resp.isKindOfClass(SendAuthResp) {
            
        }
    }
}

