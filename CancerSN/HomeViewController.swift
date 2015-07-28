//
//  HomeViewController.swift
//  CancerSN
//
//  Created by lily on 7/20/15.
//  Copyright (c) 2015 lily. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
  //      self.performSegueWithIdentifier("showTagsSegue", sender: nil);
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated);
//        var keychainAccess = KeychainAccess();
        
//        keychainAccess.setPasscode("haalthyIdentifier", passcode:"test");
        
        var keychainAccess = KeychainAccess()
        var username = keychainAccess.getPasscode(usernameKeyChain)
        var password = keychainAccess.getPasscode(passwordKeyChain)
        println(username)
        println(password)
        
        if((username != nil) && (password != nil)){
            //show feeds
//            keychainAccess.deletePasscode(usernameKeyChain)
//            keychainAccess.deletePasscode(passwordKeyChain)
//            self.performSegueWithIdentifier("showSuggestUsersSegue", sender: nil)
        }else{
            self.performSegueWithIdentifier("showSuggestUsersSegue", sender: nil)
        }
    }
}
