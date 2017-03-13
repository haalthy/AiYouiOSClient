//
//  HudProgressManager.swift
//  CancerSN
//
//  Created by lay on 16/1/20.
//  Copyright © 2016年 lily. All rights reserved.
//

import Foundation

class HudProgressManager: NSObject, MBProgressHUDDelegate {

 //   waiting for more research
/*    private static var __once: () = { () -> Void in
                SingletonStruct.singleton = HudProgressManager()
            }()
*/
    
    var progressHUD: MBProgressHUD?
    
    // MARK: - 单例模式
    class var sharedInstance: HudProgressManager {
        
        get {
            struct SingletonStruct {
                static var onceToken: Int = 0
                static var singleton: HudProgressManager? = nil
            }
            _ = { () -> Void in
                SingletonStruct.singleton = HudProgressManager()
            }()

            // 得到变量
            return SingletonStruct.singleton!
        }
    }

    // MARK: 重写初始化方法
    
    override init() {
        super.init()
        self.progressHUD = MBProgressHUD()
    }
    
    // MARK: - 展示hud加载
    
    func showHudProgress(_ viewController: UIViewController, title: String) {
    
        if self.progressHUD == nil {
        
            self.progressHUD = MBProgressHUD.init(view: viewController.view)
        }
        viewController.view.addSubview(self.progressHUD!)
        self.progressHUD?.labelText = title
        self.progressHUD?.delegate = self
        self.progressHUD?.show(true)
    }
    
    // MARK: - 销毁hud
    
    func dismissHud() {
    
        self.progressHUD?.hide(true)
        self.progressHUD?.removeFromSuperview()
    }
    
    // MARK: - 展示成功hud
    
    func showSuccessHudProgress(_ viewController: UIViewController, title: String) {
    
        MBProgressHUD.hideAllHUDs(for: viewController.view, animated: true)
        let hud: MBProgressHUD = MBProgressHUD.init(view: viewController.view)
        viewController.view.addSubview(hud)
        hud.customView = UIImageView(image: UIImage(named: "37x-Checkmark.png"))
        hud.labelText = title
        hud.mode = .customView
        hud.delegate = self
        hud.show(true)
        hud.hide(true, afterDelay: 1.5)
    }
    
    // MARK: - 仅展示文字
    
    func showOnlyTextHudProgress(_ viewController: UIViewController, title: String) {
    
        MBProgressHUD.hideAllHUDs(for: viewController.view, animated: true)
        let hud: MBProgressHUD = MBProgressHUD.showAdded(to: viewController.view, animated: true)
        hud.labelText = title
        hud.mode = .text
        hud.margin = 10.0
        hud.removeFromSuperViewOnHide = true
        hud.hide(true, afterDelay: 2)

    }
    
    // Delegate
    
    func hudWasHidden(_ hud: MBProgressHUD!) {
        var hud = hud
        hud?.removeFromSuperview()
        hud = nil
        
    }
}
