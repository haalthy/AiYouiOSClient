//
//  LoginViewController.swift
//  CancerSN
//
//  Created by lily on 7/28/15.
//  Copyright (c) 2015 lily. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var portrait: UIImageView!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var username: UITextField!
    var data:NSMutableData?  = nil
    
    @IBAction func login(sender: UIButton) {
        let usernameStr = username.text
        let passwordStr = password.text
        
        var urlPath: String = getOauthTokenURL + "username=" + usernameStr + "&password=" + passwordStr
        urlPath = urlPath.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        data = NSMutableData()
        var url: NSURL = NSURL(string: urlPath)!
        var request: NSURLRequest = NSURLRequest(URL: url)
        var connection: NSURLConnection = NSURLConnection(request: request, delegate: self, startImmediately: true)!
        connection.start()
    }
    func connection(connection: NSURLConnection!, didReceiveData data: NSData!){
        self.data!.appendData(data)
    }
    
    func connectionDidFinishLoading(connection: NSURLConnection!)
    {
        var error: NSErrorPointer=nil
        var jsonResult = NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers, error: error)
        var accessToken  = jsonResult?.objectForKey("access_token")
        var refreshToken = jsonResult?.objectForKey("refresh_token")
        if(accessToken != nil && refreshToken != nil){
            let profileSet = NSUserDefaults.standardUserDefaults()
            profileSet.setObject(accessToken, forKey: accessNSUserData)
            profileSet.setObject(refreshToken, forKey: refreshNSUserData)
            let keychainAccess = KeychainAccess()
            keychainAccess.setPasscode(usernameKeyChain, passcode: username.text)
            keychainAccess.setPasscode(passwordKeyChain, passcode: password.text)
        }
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func forgetPassword(sender: UIButton) {
        
    }
    
    @IBAction func cancel(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as! String
        
        var imageFilePath = "\(paths)/" + imageFileName
        portrait.image = UIImage(contentsOfFile: imageFilePath)
        password.delegate = self
        username.delegate = self
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
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        textField.resignFirstResponder()
        return true
    }
}
