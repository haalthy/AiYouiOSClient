//
//  UserListTableViewCell.swift
//  CancerSN
//
//  Created by lily on 7/22/15.
//  Copyright (c) 2015 lily. All rights reserved.
//

import UIKit
import CoreData

protocol UserListDelegate {
    func performLoginSegue()
}

class UserListTableViewCell: UITableViewCell {
    
    var delegate : UserListDelegate?

    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var usernameDisplay: UILabel!
    @IBOutlet weak var userProfileDisplay: UILabel!
    
    @IBOutlet weak var userFollowers: UILabel!
    
    var addFollowingResponseData : NSMutableData? = nil
    var getTokenResponseData : NSMutableData? = nil
    @IBOutlet weak var addFollowingBtn: UIButton!
    
    @IBAction func addFollowing(sender: AnyObject) {
        let profileSet = NSUserDefaults.standardUserDefaults()
        if profileSet.objectForKey(accessNSUserData) != nil{
            let accessToken : String = profileSet.objectForKey(accessNSUserData) as! String
            let urlPath: String = addFollowingURL + usernameDisplay.text! + "?access_token=" + accessToken
            addFollowingResponseData = NSMutableData()
            var url: NSURL = NSURL(string: urlPath)!
            var request: NSMutableURLRequest = NSMutableURLRequest(URL: url)
            var connection: NSURLConnection = NSURLConnection(request: request, delegate: self, startImmediately: true)!
            connection.start()
        }else{
            self.delegate?.performLoginSegue()
        }
    }
    
    func connection(connection: NSURLConnection!, didReceiveData data: NSData!){
        let connectionURLStr:NSString = (connection.currentRequest.URL)!.absoluteString!
        if( connectionURLStr.containsString(addFollowingURL)){
            addFollowingResponseData!.appendData(data)
        }else if(connectionURLStr.containsString(getOauthTokenURL)){
            getTokenResponseData!.appendData(data)
        }
    }
    
    func connectionDidFinishLoading(connection: NSURLConnection!)
    {
        var error: NSErrorPointer=nil
        let connectionURLStr:NSString = (connection.currentRequest.URL)!.absoluteString!
        if(connectionURLStr.containsString(addFollowingURL)){
            let str: NSString = NSString(data: addFollowingResponseData!, encoding:NSUTF8StringEncoding)!
            println(str)
            var jsonResult: NSDictionary = NSJSONSerialization.JSONObjectWithData(addFollowingResponseData!, options: NSJSONReadingOptions.MutableContainers, error: error) as! NSDictionary
            if(jsonResult["error"]==nil){
                addFollowingBtn.enabled = false;
                addFollowingBtn.setTitle("已关注", forState: .Normal)
                //add following to local DB
                var appDel:AppDelegate = (UIApplication.sharedApplication().delegate as! AppDelegate)
                var context:NSManagedObjectContext = appDel.managedObjectContext!
                var user = NSEntityDescription.insertNewObjectForEntityForName("Following", inManagedObjectContext: context) as! NSManagedObject
                user.setValue(usernameDisplay.text!, forKey: "username")
                user.setValue(userProfileDisplay.text!, forKey: "userProfile")
                user.setValue(UIImageJPEGRepresentation(userImage.image, 1.0), forKey: "userImage")
                context.save(nil)
            }else{
                var respError = jsonResult["error"] as! NSString
                if(respError.isEqualToString("invalid_token") ){
                    let keychainAccess = KeychainAccess()
                    let usernameStr:String = keychainAccess.getPasscode(usernameKeyChain) as! String
                    let passwordStr:String = keychainAccess.getPasscode(passwordKeyChain) as! String
                    var urlPath: String = getOauthTokenURL + "username=" + usernameStr + "&password=" + passwordStr
                    urlPath = urlPath.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
                    getTokenResponseData = NSMutableData()
                    var url: NSURL = NSURL(string: urlPath)!
                    var request: NSURLRequest = NSURLRequest(URL: url)
                    var connection: NSURLConnection = NSURLConnection(request: request, delegate: self, startImmediately: true)!
                    connection.start()
                }
            }
        }else if(connectionURLStr.containsString(getOauthTokenURL)){
            var jsonResult = NSJSONSerialization.JSONObjectWithData(getTokenResponseData!, options: NSJSONReadingOptions.MutableContainers, error: error)
            var accessToken  = jsonResult?.objectForKey("access_token")
            var refreshToken = jsonResult?.objectForKey("refresh_token")
            if(accessToken != nil && refreshToken != nil){
                let profileSet = NSUserDefaults.standardUserDefaults()
                profileSet.setObject(accessToken, forKey: accessNSUserData)
                profileSet.setObject(refreshToken, forKey: refreshNSUserData)
                let urlPath: String = addFollowingURL + usernameDisplay.text! + "?access_token=" + (accessToken as! String)
                addFollowingResponseData = NSMutableData()
                var url: NSURL = NSURL(string: urlPath)!
                var request: NSMutableURLRequest = NSMutableURLRequest(URL: url)
                var connection: NSURLConnection = NSURLConnection(request: request, delegate: self, startImmediately: true)!
                connection.start()
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
