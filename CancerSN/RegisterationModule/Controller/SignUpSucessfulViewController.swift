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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }
    
    func initContentView(){
        let backgroudImgView = UIImageView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight))
        backgroudImgView.image = UIImage(named: "img_background")
        self.view.addSubview(backgroudImgView)
        
        //add title
        let sucessfulLabel = UILabel(frame: CGRect(x: 0, y: 160, width: screenWidth, height: 24))
        sucessfulLabel.text = "恭喜您注册成功"
        sucessfulLabel.font = UIFont.systemFont(ofSize: 24)
        sucessfulLabel.textColor = UIColor.white
        sucessfulLabel.textAlignment = NSTextAlignment.center
        self.view.addSubview(sucessfulLabel)
        
        //add login button
        let loginBtn = UIButton(frame: CGRect(x: 0, y: 200, width: screenWidth, height: 44))
        loginBtn.backgroundColor = UIColor.clear
        loginBtn.setTitle("立即发现", for: UIControlState())
        loginBtn.setTitleColor(UIColor.white, for: UIControlState())
        loginBtn.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        loginBtn.addTarget(self, action: #selector(SignUpSucessfulViewController.start(_:)), for: UIControlEvents.touchUpInside)
        self.view.addSubview(loginBtn)
    }
    
    func start(_ sender: UIButton){
        let tabViewController : TabViewController = TabViewController()
        self.present(tabViewController, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
