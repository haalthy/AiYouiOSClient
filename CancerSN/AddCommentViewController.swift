//
//  AddCommentViewController.swift
//  CancerSN
//
//  Created by lily on 8/3/15.
//  Copyright (c) 2015 lily. All rights reserved.
//

import UIKit

class AddCommentViewController: UIViewController {
    var post : NSDictionary = NSDictionary()
    
    func sendSyncAddCommentRequeest(accessToken:String)->NSData{
        let urlPath:String = (addCommentsURL as String) + "?access_token=" + (accessToken as! String);
        println(urlPath)
        let url : NSURL = NSURL(string: urlPath)!
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        var response: AutoreleasingUnsafeMutablePointer<NSURLResponse?> = nil
        var requestBody = NSMutableDictionary()
        requestBody.setValue(post.objectForKey("postID"), forKey: "postID")
        requestBody.setValue(commentContent.text, forKey: "body")
        request.HTTPBody = NSJSONSerialization.dataWithJSONObject(requestBody, options: NSJSONWritingOptions.allZeros, error: nil)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        var addCommentsRespData = NSURLConnection.sendSynchronousRequest(request, returningResponse: response, error: nil)
        return addCommentsRespData!
    }
    
    @IBOutlet weak var commentContent: UITextView!
    @IBAction func cancel(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func submitComment(sender: UIButton) {
        let getAccessToken = GetAccessToken()
        var accessToken = NSUserDefaults.standardUserDefaults().objectForKey(accessNSUserData)
        if( accessToken == nil){
            getAccessToken.getAccessToken()
            accessToken = NSUserDefaults.standardUserDefaults().objectForKey(accessNSUserData)
        }
        if(accessToken != nil){
            var addCommentsRespData = self.sendSyncAddCommentRequeest(accessToken as! String)
            let str: NSString = NSString(data: addCommentsRespData, encoding: NSUTF8StringEncoding)!
            println(str)
            var jsonResult = NSJSONSerialization.JSONObjectWithData(addCommentsRespData, options: NSJSONReadingOptions.MutableContainers, error: nil)
            var jsonResultDic: NSDictionary = jsonResult as! NSDictionary
            if(jsonResultDic.objectForKey("error") != nil){
                getAccessToken.getAccessToken()
                accessToken = NSUserDefaults.standardUserDefaults().objectForKey(accessNSUserData)
                var addCommentsRespData = self.sendSyncAddCommentRequeest(accessToken as! String)
                let str: NSString = NSString(data: addCommentsRespData, encoding: NSUTF8StringEncoding)!
                println(str)
            }
        }
        if( accessToken == nil){
            performSegueWithIdentifier("loginSegue", sender: self)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
