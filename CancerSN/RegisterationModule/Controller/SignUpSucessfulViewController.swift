//
//  SignUpSucessfulViewController.swift
//  CancerSN
//
//  Created by hui luo on 4/2/2016.
//  Copyright © 2016 lily. All rights reserved.
//

import UIKit

class SignUpSucessfulViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        initContentView()
    }
    
    func initContentView(){
        let backgroudImgView = UIImageView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight))
        backgroudImgView.image = UIImage(named: "img_background")
        self.view.addSubview(backgroudImgView)
        
        //add title
        let sucessfulLabel = UILabel(frame: CGRect(x: 0, y: 160, width: screenWidth, height: 24))
        sucessfulLabel.text = "恭喜您注册成功"
        sucessfulLabel.font = UIFont.systemFontOfSize(24)
        sucessfulLabel.textColor = UIColor.whiteColor()
        sucessfulLabel.textAlignment = NSTextAlignment.Center
        self.view.addSubview(sucessfulLabel)
        
        //add login button
        let loginBtn = UIButton(frame: CGRect(x: 0, y: 200, width: screenWidth, height: 44))
        loginBtn.backgroundColor = UIColor.clearColor()
        loginBtn.setTitle("立即发现", forState: UIControlState.Normal)
        loginBtn.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        loginBtn.titleLabel?.font = UIFont.systemFontOfSize(15)
        loginBtn.addTarget(self, action: "start:", forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(loginBtn)
    }
    
    func start(sender: UIButton){
        let tabViewController : TabViewController = TabViewController()
        self.presentViewController(tabViewController, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
