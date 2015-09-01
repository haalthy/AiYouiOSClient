//
//  MeTableViewController.swift
//  CancerSN
//
//  Created by lily on 8/5/15.
//  Copyright (c) 2015 lily. All rights reserved.
//

import UIKit

class MeTableViewController: UITableViewController {
    
    var isLogin:Bool = true
    let keyChain:KeychainAccess = KeychainAccess()
    var myProfile = NSDictionary()
    
    @IBAction func logout(sender: UIButton) {
        var keychain = KeychainAccess()
        keychain.deletePasscode(usernameKeyChain)
        keychain.deletePasscode(passwordKeyChain)
        var profileSet = NSUserDefaults.standardUserDefaults()
        profileSet.removeObjectForKey(favTagsNSUserData)
        profileSet.removeObjectForKey(genderNSUserData)
        profileSet.removeObjectForKey(ageNSUserData)
        profileSet.removeObjectForKey(cancerTypeNSUserData)
        profileSet.removeObjectForKey(pathologicalNSUserData)
        profileSet.removeObjectForKey(stageNSUserData)
        profileSet.removeObjectForKey(smokingNSUserData)
        profileSet.removeObjectForKey(metastasisNSUserData)
        profileSet.removeObjectForKey(emailNSUserData)
        profileSet.removeObjectForKey(accessNSUserData)
        profileSet.removeObjectForKey(refreshNSUserData)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        var haalthyService = HaalthyService()
        var profileData = haalthyService.getMyProfile()
        var jsonResult = NSJSONSerialization.JSONObjectWithData(profileData, options: NSJSONReadingOptions.MutableContainers, error: nil)
        if jsonResult is NSDictionary{
            myProfile = jsonResult as! NSDictionary
        }
        
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if keyChain.getPasscode(usernameKeyChain) == nil{
            isLogin = false
        }else{
            isLogin = true
        }
        self.tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if isLogin == true {
            return 3
        }else{
            return 1
        }
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var numberOfRows:Int = 0
        if isLogin == true {
            switch section{
            case 0: numberOfRows = 1
                break
            case 1: numberOfRows = 4
                break
            case 2: numberOfRows = 1
                break
            default: numberOfRows = 0
                break
            }
        }else{
            numberOfRows = 1
        }
        return numberOfRows
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var separatorLine:UIImageView = UIImageView(frame: CGRectMake(0, 0, tableView.frame.size.width-1.0, 1.0))
        separatorLine.image = UIImage(named: "grayline.png")?.stretchableImageWithLeftCapWidth(1, topCapHeight: 0)
        if isLogin == true {

            if((indexPath.section == 0)||(indexPath.section == 1)){
                let cell = tableView.dequeueReusableCellWithIdentifier("profileItem", forIndexPath: indexPath) as! UITableViewCell
                //        var separatorLine:UIImageView = UIImageView(frame: CGRectMake(0, 0, cell.frame.size.width-1.0, 1.0))
                //        separatorLine.image = UIImage(named: "grayline.png")?.stretchableImageWithLeftCapWidth(1, topCapHeight: 0)
                cell.contentView.addSubview(separatorLine)
                if indexPath.section == 0{
//                    cell.imageView?.image = UIImage(named: "Mario.jpg")
                    var paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as! String
                    
                    var imageFilePath = "\(paths)/" + imageFileName
                    cell.imageView!.image = UIImage(contentsOfFile: imageFilePath)
                    if cell.imageView?.image == nil{
                        if myProfile.objectForKey("image") != nil{
                            let dataString = myProfile.objectForKey("image") as! String
                            let imageData: NSData = NSData(base64EncodedString: dataString, options: NSDataBase64DecodingOptions(0))!
                            cell.imageView?.image = UIImage(data: imageData)
                        }
                        
                    }
                    cell.textLabel?.text = keyChain.getPasscode(usernameKeyChain) as! String
                }else{
                    switch indexPath.row{
                    case 0:
                        cell.textLabel?.text = "Following"
                        break
                    case 1:
                        cell.textLabel?.text = "Follower"
                        break
                    case 2:
                        cell.textLabel?.text = "Posts"
                        break
                    case 3:
                        cell.textLabel?.text = "Broadcasts"
                    default:
                        break
                    }
                }
                return cell
            }else{
                let cell = tableView.dequeueReusableCellWithIdentifier("logout", forIndexPath: indexPath) as! UITableViewCell
                cell.contentView.addSubview(separatorLine)
                return cell
            }
        }else{
            let cell = tableView.dequeueReusableCellWithIdentifier("login", forIndexPath: indexPath) as! UITableViewCell
            cell.contentView.addSubview(separatorLine)
            return cell
        }
    }


    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */
    override func tableView(_tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat{
        var heightForRow:CGFloat = 70
        if isLogin == true{
            switch indexPath.section {
            case 0: heightForRow = 70
                break
            default: heightForRow = 44
                break
            }
        }else{
            heightForRow = 44
        }
        return heightForRow
    }
    
    override func tableView(_tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat{
        var heightForSectionHeader:CGFloat = 20
        return heightForSectionHeader
    }

}
