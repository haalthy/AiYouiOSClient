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
class AppDelegate: UIResponder, UIApplicationDelegate, WXApiDelegate{

    var window: UIWindow?

    var tabVC: TabViewController = TabViewController()
    
    var profileSet = UserDefaults.standard
    let haalthyService = HaalthyService()
    let keychainAccess = KeychainAccess()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    
        if UIScreen.main.currentMode!.size.height == 568 {
        
            self.window = UIWindow(frame: CGRECT(0, 0, UIScreen.main.bounds.size.width, 568))
        }
        
        print(UIScreen.main.currentMode!.size)
        
        Growing.start(withAccountId: "81234af7e631c255")
        
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
        
        JPUSHService.setup(withOption: launchOptions, appKey: appKey, channel: channel, apsForProduction: isProduction)

        return true
    }
    
    // MARK: - init Navigation Bar
    
    func initNavigationBar() {
        
        // 定义navigation属性
        UINavigationBar.appearance().barTintColor = headerColor
        UINavigationBar.appearance().tintColor = UIColor.white
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.lightContent
        let dict = [NSFontAttributeName : UIFont.systemFont(ofSize: 20)]
        UINavigationBar.appearance().titleTextAttributes = dict
        UINavigationBar.appearance().barStyle = .black
    }
    
    // MARK: - 是否进入到主页界面
    
    func checkUserStatus() {
        if (UserDefaults.standard.object(forKey: favTagsNSUserData) == nil) || (UserDefaults.standard.object(forKey: favTagsNSUserData) as! NSArray).count == 0{
            let getAccessToken = GetAccessToken()
            getAccessToken.getAccessToken()
            let access_Token = UserDefaults.standard.object(forKey: accessNSUserData)
            if (access_Token == nil) || ((access_Token as! String) == "") {
                let storyboard = UIStoryboard(name: "Registeration", bundle: nil)
                let rootController = storyboard.instantiateViewController(withIdentifier: "LoginEntry") as! UINavigationController
                if self.window != nil {
                    self.window!.rootViewController = rootController
//                    rootController.isRootViewController = true
                }

            }
        }

    }

    func registerRemoteNotificaiton(_ application: UIApplication) {
        
        if String(validatingUTF8: UIDevice.current.systemVersion)! >= "8.0" {
        

        //application.registerUserNotificationSettings ( UIUserNotificationSettings (forTypes:  [UIUserNotificationType .Sound, UIUserNotificationType .Alert , UIUserNotificationType .Badge], categories:  nil ))
            
            JPUSHService.register(forRemoteNotificationTypes: UIUserNotificationType.badge.rawValue | UIUserNotificationType.badge.rawValue | UIUserNotificationType.alert.rawValue , categories: nil)
        }
        else {
            
            JPUSHService.register(forRemoteNotificationTypes: UIRemoteNotificationType.badge.rawValue | UIRemoteNotificationType.badge.rawValue | UIRemoteNotificationType.alert.rawValue , categories: nil)

        }
        
    }
    
    // MARK: - 获取deviceToken
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
        let token: NSString = NSString(format: "%@", deviceToken as CVarArg)
        
        JPUSHService.registerDeviceToken(deviceToken)
        
        let registrationID = JPUSHService.registrationID()
        
        if registrationID != nil || registrationID != ""  {
            self.submitRegistrationIDToServer(registrationID!)
        }
        
        UserDefaults.standard.setValue(registrationID, forKey:kDeviceToken)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
    }
    
    
    // MARK: 更新registrationID 
    
    func submitRegistrationIDToServer(_ registrationID: String) {
    
        
        let username = keychainAccess.getPasscode(usernameKeyChain)
        if username != nil {
        
            let paramtersDict: Dictionary<String, AnyObject> = ["userName" : username!, "fromUserName" : registrationID as AnyObject]
            NetRequest.sharedInstance.POST(pushIdURL, parameters: paramtersDict, success: { (content, message) -> Void in
                
                }, failed: { (content, message) -> Void in
                    
            })
        }

    }
    
    // MARK: - 跳转功能
    
    // MARK: 跳转到消息中心
    
    func enterMessageView(_ count: Int) {
    
        // 判断用户是否登录
        
        let keychainAccess = KeychainAccess()
        
        let profileSB: UIStoryboard = UIStoryboard(name: "User", bundle: nil)
        
        let postVC: PostsViewController = profileSB.instantiateViewController(withIdentifier: "PostView") as! PostsViewController
        postVC.username = keychainAccess.getPasscode(usernameKeyChain) as! String
        postVC.commentCount = count
        (self.tabVC.viewControllers![tabVC.curIndex] as! UINavigationController).pushViewController(postVC, animated: true)
    }
    
    // MARK: 跳转到关注
    
    func enterFollowView() {
    
        // 判断用户是否登录
        
        let profileSB: UIStoryboard = UIStoryboard(name: "User", bundle: nil)
        
        let followVC: UserFollowViewController = profileSB.instantiateViewController(withIdentifier: "FollowView") as! UserFollowViewController
        (self.tabVC.viewControllers![tabVC.curIndex] as! UINavigationController).pushViewController(followVC, animated: true)
    }
    
    // MARK: 跳转到@我的
    
    func enterMentionedView() {
    
        // 判断用户是否登录
        
        let profileSB: UIStoryboard = UIStoryboard(name: "User", bundle: nil)
        
        let mentionedVC: MentionedViewController = profileSB.instantiateViewController(withIdentifier: "MentionedView") as! MentionedViewController
        (self.tabVC.viewControllers![tabVC.curIndex] as! UINavigationController).pushViewController(mentionedVC, animated: true)
    }
    
    // MARK: 跳转到内容详情
    
    func enterFeedDetailView(_ feedId: Int) {
    
        let feedSB: UIStoryboard = UIStoryboard(name: "Feed", bundle: nil)
        
        let feedDetailVC: FeedDetailViewController = feedSB.instantiateViewController(withIdentifier: "FeedDetailView") as! FeedDetailViewController
        feedDetailVC.feedId = feedId

        (self.tabVC.viewControllers![tabVC.curIndex] as! UINavigationController).pushViewController(feedDetailVC, animated: true)
    }

    func application(_ application: UIApplication, didRegister notificationSettings: UIUserNotificationSettings) {
        
    }
    
    func application(_ application: UIApplication, handleActionWithIdentifier identifier: String?, forRemoteNotification userInfo: [AnyHashable: Any], completionHandler: @escaping () -> Void) {
        
        
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        
        JPUSHService.handleRemoteNotification(userInfo)
        
        print(userInfo)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        JPUSHService.handleRemoteNotification(userInfo)
        
        if application.applicationState == .active {
        
            self.judgeRemoteIsActive(userInfo)
        }
        else {
        
            self.judgeRemoteTypeFromParam(userInfo)

        }
        
    }
    
    func judgeRemoteIsActive(_ userInfo: [AnyHashable: Any]) {
    
        let type: String = userInfo["type"] as! String
        
        switch (type) {
            
        case "commented":
            

            let alertController = UIAlertController(title: "收到了新的评论，马上看看", message: nil, preferredStyle: .alert)
            
            let cancelAction = UIAlertAction(title: "取消", style: .cancel) { (action) in
            
            }
            alertController.addAction(cancelAction)
            let confirmAction = UIAlertAction(title: "查看", style: .default, handler: { (action) -> Void in
                
                self.enterMessageView(userInfo["count"] as! Int)
            })
            
            
            
            alertController.addAction(confirmAction)
            self.tabVC.viewControllers![self.tabVC.curIndex].present(alertController, animated: true, completion: nil)
            
            break
        case "followed":
            
            let alertController = UIAlertController(title: "收到了新的@我的，马上看看", message: nil, preferredStyle: .alert)
            
            let cancelAction = UIAlertAction(title: "取消", style: .cancel) { (action) in
                
            }
            alertController.addAction(cancelAction)
            let confirmAction = UIAlertAction(title: "查看", style: .default, handler: { (action) -> Void in
                
                self.enterMentionedView()
            })
            alertController.addAction(confirmAction)
            self.tabVC.viewControllers![self.tabVC.curIndex].present(alertController, animated: true, completion: nil)
            break
        case "mentioned":
            
            let alertController = UIAlertController(title: "收到了新的关注信息，马上看看", message: nil, preferredStyle: .alert)
            
            let cancelAction = UIAlertAction(title: "取消", style: .cancel) { (action) in
                
            }
            alertController.addAction(cancelAction)
            let confirmAction = UIAlertAction(title: "查看", style: .default, handler: { (action) -> Void in
                
                self.enterFollowView()
            })
            alertController.addAction(confirmAction)
            self.tabVC.viewControllers![self.tabVC.curIndex].present(alertController, animated: true, completion: nil)
            break
        case "feed":
            
            let alertController = UIAlertController(title: "收到了新的推荐，马上看看", message: nil, preferredStyle: .alert)
            
            let cancelAction = UIAlertAction(title: "取消", style: .cancel) { (action) in
                
            }
            alertController.addAction(cancelAction)
            let confirmAction = UIAlertAction(title: "查看", style: .default, handler: { (action) -> Void in
                
                self.enterFeedDetailView(userInfo["id"] as! Int)
            })
            alertController.addAction(confirmAction)
            self.tabVC.viewControllers![self.tabVC.curIndex].present(alertController, animated: true, completion: nil)
            break
            
        default:
            break
        }

    }
    
    func judgeRemoteTypeFromParam(_ userInfo: [AnyHashable: Any]) {
    
        let type: String = userInfo["type"] as! String
        
        switch (type) {
        
            case "commented":
            
                self.enterMessageView(userInfo["count"] as! Int)
            break
            case "followed":
                
                self.enterFollowView()
            break
            case "mentioned":
                
                self.enterMentionedView()
            break
            case "feed":
                
                self.enterFeedDetailView(userInfo["id"] as! Int)
            break
            
        default:
            break
        }
        
    }

    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        application.applicationIconBadgeNumber = 0
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        
        application.applicationIconBadgeNumber = 0
        application.cancelAllLocalNotifications()

    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        let keychainAccess: KeychainAccess = KeychainAccess()
        if (keychainAccess.getPasscode(accessNSUserData) != nil) && (keychainAccess.getPasscode(usernameKeyChain) != nil) && (keychainAccess.getPasscode(passwordKeyChain) != nil ){
            self.tabVC.getUnreadCommentCountFromServer()
            self.tabVC.getUnreadFollowCountFromServer()
            self.tabVC.getUnreadMentionedCountFromServer()
        }
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        self.saveContext()
    }

    // MARK: - Core Data stack
    
    lazy var applicationDocumentsDirectory: URL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "fili99.CancerSN" in the application's documents Application Support directory.
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count-1] 
        }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = Bundle.main.url(forResource: "CancerSN", withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
        }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        var coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.appendingPathComponent("CancerSN.sqlite")
        var error: NSError? = nil
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator!.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)
        } catch var error1 as NSError {
            error = error1
            coordinator = nil
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data" as AnyObject?
            dict[NSLocalizedFailureReasonErrorKey] = failureReason as AnyObject?
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
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        WXApi.handleOpen(url, delegate: self)
        return TencentOAuth.handleOpen(url)
    }
    
    func onResp(_ resp: BaseResp!) {
        if resp is SendAuthResp {
            let authResp = resp as! SendAuthResp
            if authResp.code != nil {
                let code: String = authResp.code
                let url = "https://api.weixin.qq.com/sns/oauth2/access_token?appid=" + WXAppID + "&secret=" + WXAppSecret + "&grant_type=authorization_code&code=" + code
                let result = NetRequest.sharedInstance.GET_A(url, parameters: [:])
                if (result.object(forKey: "access_token") != nil) &&  (result.object(forKey: "openid") != nil) {
                    let username = result.object(forKey: "openid") as! String
                    let password = result.object(forKey: "openid") as! String
                    let userType = "WC"
                    let keychainAccess = KeychainAccess()
                    keychainAccess.setPasscode(usernameKeyChain, passcode: username)
                    keychainAccess.setPasscode(passwordKeyChain, passcode: password)
                    profileSet.set(userType, forKey: userTypeUserData)
                    let getAccessToken = GetAccessToken()
                    getAccessToken.getAccessToken()

                    if profileSet.object(forKey: accessNSUserData) != nil {
                        let tabViewController : TabViewController = TabViewController()
                        
                        self.window!.rootViewController = tabViewController
                    }else{
                        let getWXUserInfoURL = "https://api.weixin.qq.com/sns/userinfo?access_token=" + (result.object(forKey: "access_token") as! String) + "&openid=" + (result.object(forKey: "openid") as! String)
                        let userinfo: NSDictionary = NetRequest.sharedInstance.GET_A(getWXUserInfoURL, parameters: [:])
                        profileSet.set(userinfo.object(forKey: "nickname") as! String, forKey: displaynameUserData)
                        if (userinfo.object(forKey: "sex") as! Int) == 1 {
                            profileSet.set("M", forKey: genderNSUserData)
                        }else{
                            profileSet.set("F", forKey: genderNSUserData)
                        }
                        let addUserResult: NSDictionary = haalthyService.addUser(userType)
                        if (addUserResult.object(forKey: "result") != nil) && (((addUserResult.object(forKey: "result") as! Int) == -4) || ((addUserResult.object(forKey: "result") as! Int) == 1)) {
                            getWXImage(userinfo.object(forKey: "headimgurl") as! String)
                            let storyboard = UIStoryboard(name: "Registeration", bundle: nil)
                            let rootController = storyboard.instantiateViewController(withIdentifier: "RegisterEntry") as! UINavigationController
                            if self.window != nil {
                                self.window!.rootViewController = rootController
                                //                    rootController.isRootViewController = true
                            }
//                            let genderSettingViewController : GenderSettingViewController = GenderSettingViewController()
//                            self.window!.rootViewController = genderSettingViewController
                            
                        }else{
                            keychainAccess.deletePasscode(passwordKeyChain)
                            keychainAccess.deletePasscode(usernameKeyChain)
                        }
                    }
                }
            }
        }
    }
    
    func getWXImage(_ urlPath: String){
        URLSession.shared.dataTask(with: URL(string: urlPath)!, completionHandler: {(data, response, error) -> Void in
            // 返回任务结果
            if (error == nil) && (data != nil) {
                let imageDataStr = data!.base64EncodedString(options: [])
                
                self.profileSet.set(imageDataStr, forKey: imageNSUserData)
                self.updatePortrait()
            }
        }).resume()
    }
    
    func updatePortrait(){
        let accessToken = UserDefaults.standard.object(forKey: accessNSUserData)
        if accessToken != nil {
            let urlPath:String = (updateUserURL as String) + "?access_token=" + (accessToken as! String);
            let url : URL = URL(string: urlPath)!
            let request = NSMutableURLRequest(url: url)
            request.httpMethod = "POST"
            let requestBody = NSMutableDictionary()
            requestBody.setValue(keychainAccess.getPasscode(usernameKeyChain), forKey: "username")
            
            if profileSet.object(forKey: imageNSUserData) != nil {
                let imageInfo = NSDictionary(objects: [(profileSet.object(forKey: imageNSUserData) as! String),"jpg"], forKeys: ["data" as NSCopying, "type" as NSCopying])
                requestBody.setValue(imageInfo, forKey: "imageInfo")
            }
            
            request.httpBody = try? JSONSerialization.data(withJSONObject: requestBody as NSDictionary, options: JSONSerialization.WritingOptions())
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            
            NetRequest.sharedInstance.POST(urlPath, parameters: (requestBody as NSDictionary) as! Dictionary<String, AnyObject>,success: { (content , message) -> Void in
                print("upload wx portrait sucessful")
            }) { (content, message) -> Void in
                print("failed")
            }
        }
    }

}

