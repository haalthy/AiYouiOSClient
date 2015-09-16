//
//  AddItemViewController.swift
//  CancerSN
//
//  Created by lily on 8/4/15.
//  Copyright (c) 2015 lily. All rights reserved.
//

import UIKit

class AddItemViewController: UIViewController {

    var isBroadcast : Int = 0
    let profileSet = NSUserDefaults.standardUserDefaults()

    var isDismiss : Bool = false
    
    
    @IBAction func addPatientStatusSegue(sender: UIButton) {
        isDismiss = true
    }
    
    @IBAction func addTreatmentSegue(sender: UIButton) {
        isDismiss = true
        self.performSegueWithIdentifier("addTreatmentSegue", sender: self)

    }
    @IBAction func addBroadcast(sender: UIButton) {
        if profileSet.objectForKey(accessNSUserData) == nil{
            self.performSegueWithIdentifier("loginSegue", sender: nil)
        }
        self.isBroadcast = 1
        isDismiss = true
        self.performSegueWithIdentifier("addPostSegue", sender: nil)
    }
    
    @IBAction func addPrivatePost(sender: UIButton) {
        if profileSet.objectForKey(accessNSUserData) == nil{
            self.performSegueWithIdentifier("loginSegue", sender: nil)
        }
        self.isBroadcast = 0
        isDismiss = true
        self.performSegueWithIdentifier("addPostSegue", sender: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.preferredContentSize = CGSizeMake(180, 180)
    }
    @IBAction func cancel(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
//        self.tabBarController?.selectedIndex = 1
    }
    
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
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "addPostSegue" {
            (segue.destinationViewController as! AddPostViewController).isBroadcast = self.isBroadcast
        }
    }
    
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
