//
//  UserBasicInfoTableViewController.swift
//  CancerSN
//
//  Created by lily on 2/8/16.
//  Copyright © 2016 lily. All rights reserved.
//

import UIKit

class UserBasicInfoTableViewController: UITableViewController, SettingNickVCDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, GenderSettingVCDelegate, AgeSettingVCDelegate, CancerTypeSettingVCDelegate, PathologicalSettingVCDelegate, GeneticMutationVCDelegate, StageSettingVCDelegate, MetastasisSettingVCDelegate {

    let heightForSction: CGFloat = CGFloat(35)
    let headerTitleLeftSpace: CGFloat = CGFloat(15)
    let sectionTitleFont = UIFont.systemFontOfSize(14)
    let sectionTitleLeftSpace = CGFloat(15)
    let subTitleRightSpace: CGFloat = 15
    let portraitViewLength: CGFloat = 40
    let heightForRow = CGFloat(49)
    let sectionTitleColor = UIColor.init(red: 102 / 255, green: 102 / 255, blue: 102 / 255, alpha: 1)
    let sectionBackgroundColor = UIColor.init(red: 242 / 255, green: 248 / 255, blue: 248 / 255, alpha: 1)
    let cellTextColor = UIColor.init(red: 51 / 255, green: 51 / 255, blue: 51 / 255, alpha: 1)
    let subTitleTextColor = UIColor.init(red: 153 / 255, green: 153 / 255, blue: 153 / 255, alpha: 1)
    
    let getAccessToken = GetAccessToken()
    let keychainAccess = KeychainAccess()
    
    var userProfile: UserProfile?
    
    var imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        initVariables()
    }
    
    func initVariables(){
        imagePicker.delegate = self
    }

    override func viewWillAppear(animated: Bool) {
        self.tableView.reloadData()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        var numberOfRows: Int = 0
        switch section {
        case 0:
            numberOfRows = 5
            break
        case 1:
            numberOfRows = 5
            break
        default:
            numberOfRows = 0
            break
        }
        return numberOfRows
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath)
        let cellWidth = cell.frame.width
        if indexPath.section == 0 {
            switch indexPath.row {
            case 0:
                cell.textLabel?.text = "头像"
                cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
                let portraitView = UIImageView(frame: CGRectMake(cellWidth - portraitViewLength - 40, headerTitleLeftSpace, portraitViewLength, portraitViewLength))
                portraitView.layer.cornerRadius = 20
                portraitView.layer.masksToBounds = true
                if self.userProfile?.portraitData != nil {
                    portraitView.image = UIImage(data: NSData(base64EncodedString: (self.userProfile?.portraitData)!, options: [])!)
                } else if self.userProfile?.portraitUrl != nil {
                    portraitView.addImageCache((self.userProfile?.portraitUrl)!, placeHolder: "icon_profile")

                }else{
                    portraitView.image = UIImage(named: "Mario.jpg")
                }
                cell.addSubview(portraitView)
                cell.detailTextLabel?.text = ""
                break
            case 1:
                cell.textLabel?.text = "用户名"
                let subTitleStr: String = (self.userProfile?.username)!
                cell.detailTextLabel?.text = subTitleStr
                break
            case 2:
                var subTitleStr: String = ""
                if self.userProfile?.email != nil {
                    cell.textLabel?.text = "邮件"
                    subTitleStr = (self.userProfile?.email)!
                }else if self.userProfile?.phone != nil {
                    cell.textLabel?.text = "电话"
                    subTitleStr = (self.userProfile?.phone)!
                }
                cell.accessoryType = UITableViewCellAccessoryType.None
                cell.detailTextLabel?.text = subTitleStr
                break
            case 3:
                cell.textLabel?.text = "昵称"
                cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
                if self.userProfile?.nick != nil {
                    let subTitleStr: String = (self.userProfile?.nick)!
                    cell.detailTextLabel?.text = subTitleStr
                }
                break
            case 4:
                cell.textLabel?.text = "重置密码"
                cell.detailTextLabel?.text = ""
                cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
            default:
                break
            }
        }
        if indexPath.section == 1 {
            var cellTitleStr: String = ""
            var subTitleStr: String = ""
            switch indexPath.row {
            case 0:
                cellTitleStr = "性别及年龄"
                if self.userProfile?.gender != nil {
                    subTitleStr = (self.userProfile?.gender)!
                }
                if self.userProfile!.age != nil {
                    subTitleStr += String((self.userProfile?.age)!)
                }
                break
            case 1:
                cellTitleStr = "癌症类型"
                if self.userProfile?.cancerType != nil {
                    subTitleStr = (self.userProfile?.cancerType)!
                }
                if self.userProfile?.pathological != nil {
                    subTitleStr += " " + String((self.userProfile?.pathological)!)
                }
                break
            case 2:
                cellTitleStr = "基因突变"
                if self.userProfile?.geneticMutation != nil {
                    subTitleStr = (self.userProfile?.geneticMutation)!
                }
                break
            case 3:
                cellTitleStr = "初诊分期"
                if (self.userProfile?.stage) != nil {
                    subTitleStr = (self.userProfile?.stage)!
                }
                break
            case 4:
                cellTitleStr = "转移情况"
                if (self.userProfile?.metastics) != nil {
                    subTitleStr = (self.userProfile?.metastics)!
                }
                break
            default:
                break
            }
            cell.textLabel?.text = cellTitleStr
            cell.detailTextLabel?.font = cellTextFont
            cell.detailTextLabel?.textColor = subTitleTextColor
            cell.detailTextLabel?.text = subTitleStr
            cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
//            cell.addSubview(subTitleLabel)
        }
        cell.textLabel?.textColor = cellTextColor
        return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        var heightForRow = self.heightForRow
        if (indexPath.section == 0) && (indexPath.row == 0) {
            heightForRow = 69
        }
        return heightForRow
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return heightForSction
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 {
            switch indexPath.row {
            case 0:
                imagePicker.allowsEditing = true //2
                imagePicker.sourceType = .PhotoLibrary //3
                presentViewController(imagePicker, animated: true, completion: nil)//4
            case 3:
                self.performSegueWithIdentifier("updateNickSegue", sender: self)
                break
            case 4:
                self.performSegueWithIdentifier("updatePasswordSegue", sender: self)
                break
            default:
                break
            }
        }
        if indexPath.section == 1 {
            switch indexPath.row {
            case 0:
                let storyboard = UIStoryboard(name: "Registeration", bundle: nil)
                let genderController = storyboard.instantiateViewControllerWithIdentifier("genderSetting") as! GenderSettingViewController
                genderController.isUpdate = true
                genderController.genderSettingVCDelegate = self
                genderController.ageSettingVCDelegate = self
                self.navigationController?.pushViewController(genderController, animated: true)
                break
            case 1:
                let storyboard = UIStoryboard(name: "Registeration", bundle: nil)
                let cancerTypeController = storyboard.instantiateViewControllerWithIdentifier("cancerTypeSetting") as! CancerTypeSettingViewController
                cancerTypeController.isUpdate = true
                cancerTypeController.cancerTypeSettingVCDelegate = self
                cancerTypeController.pathologicalSettingVCDelegate = self
                self.navigationController?.pushViewController(cancerTypeController, animated: true)
                break
            case 2:
                let storyboard = UIStoryboard(name: "Registeration", bundle: nil)
                let geneticMutationViewController = storyboard.instantiateViewControllerWithIdentifier("geneticMutationSetting") as! GeneticMutationViewController
                geneticMutationViewController.isUpdate = true
                geneticMutationViewController.geneticMutationVCDelegate = self
                self.navigationController?.pushViewController(geneticMutationViewController, animated: true)
                break
            case 3:
                let storyboard = UIStoryboard(name: "Registeration", bundle: nil)
                let stageViewController = storyboard.instantiateViewControllerWithIdentifier("stageSetting") as! StageViewController
                stageViewController.isUpdate = true
                stageViewController.stageSettingVCDelegate = self
                self.navigationController?.pushViewController(stageViewController, animated: true)
                break
            case 4:
                let storyboard = UIStoryboard(name: "Registeration", bundle: nil)
                let metasticViewController = storyboard.instantiateViewControllerWithIdentifier("MetasticsSetting") as! MetasticViewController
                metasticViewController.isUpdate = true
                metasticViewController.metastasisSettingVCDelegate = self
                self.navigationController?.pushViewController(metasticViewController, animated: true)
                break
            default:
                break
            }
        }
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRECT(0, 0, self.tableView.frame.width, heightForSction))
        var titleStr: String?
        switch section {
        case 0:
            titleStr = "用户信息"
            break
        case 1:
            titleStr = "病人信息"
            break
        default:
            break
        }
        let headerLabelW = titleStr?.sizeWithFont(sectionTitleFont, maxSize: CGSize(width: self.tableView.frame.width, height: heightForSction)).width
        let headerLabelView = UILabel(frame: CGRect(x: headerTitleLeftSpace, y: 0, width: headerLabelW!, height: heightForSction))
        headerLabelView.text = titleStr
        headerLabelView.font = sectionTitleFont
        headerLabelView.textColor = sectionTitleColor
        headerView.addSubview(headerLabelView)
        headerView.backgroundColor = sectionBackgroundColor
        return headerView
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "updateNickSegue" {
            (segue.destinationViewController as! UpdateNickTableViewController).settingNickVCDelegate = self
        }
    }
    
    func updateDisplayname(displayname: String) {
        userProfile?.nick =  displayname
        
        getAccessToken.getAccessToken()
        let accessToken = NSUserDefaults.standardUserDefaults().objectForKey(accessNSUserData)
        if accessToken != nil {
            let urlPath:String = (updateUserURL as String) + "?access_token=" + (accessToken as! String);
            let url : NSURL = NSURL(string: urlPath)!
            let request = NSMutableURLRequest(URL: url)
            request.HTTPMethod = "POST"
            let requestBody = NSMutableDictionary()
            requestBody.setValue(keychainAccess.getPasscode(usernameKeyChain), forKey: "username")
            if userProfile!.nick != nil {
                requestBody.setValue(userProfile!.nick!, forKey: "displayname")
            }
            
            request.HTTPBody = try? NSJSONSerialization.dataWithJSONObject(requestBody as NSDictionary, options: NSJSONWritingOptions())
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            
            NetRequest.sharedInstance.POST(urlPath, parameters: (requestBody as NSDictionary) as! Dictionary<String, AnyObject>,
                
                success: { (content , message) -> Void in
                    HudProgressManager.sharedInstance.showOnlyTextHudProgress(self, title: "更新成功")
                    HudProgressManager.sharedInstance.dismissHud()
                }) { (content, message) -> Void in
                    HudProgressManager.sharedInstance.showOnlyTextHudProgress(self, title: message)
                    HudProgressManager.sharedInstance.dismissHud()
            }
        }

    }
    
    func updateGender(gender: String){
        userProfile?.gender = gender
        
        getAccessToken.getAccessToken()
        let accessToken = NSUserDefaults.standardUserDefaults().objectForKey(accessNSUserData)
        if accessToken != nil {
            let urlPath:String = (updateUserURL as String) + "?access_token=" + (accessToken as! String);
            let url : NSURL = NSURL(string: urlPath)!
            let request = NSMutableURLRequest(URL: url)
            request.HTTPMethod = "POST"
            let requestBody = NSMutableDictionary()
            requestBody.setValue(keychainAccess.getPasscode(usernameKeyChain), forKey: "username")
            if userProfile!.gender != nil {
                requestBody.setValue(userProfile!.gender!, forKey: "gender")
            }
            
            request.HTTPBody = try? NSJSONSerialization.dataWithJSONObject(requestBody as NSDictionary, options: NSJSONWritingOptions())
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            
            NetRequest.sharedInstance.POST(urlPath, parameters: (requestBody as NSDictionary) as! Dictionary<String, AnyObject>,
                
                success: { (content , message) -> Void in
                    HudProgressManager.sharedInstance.showOnlyTextHudProgress(self, title: "更新成功")
                    HudProgressManager.sharedInstance.dismissHud()
                }) { (content, message) -> Void in
                    HudProgressManager.sharedInstance.showOnlyTextHudProgress(self, title: message)
                    HudProgressManager.sharedInstance.dismissHud()
            }
        }

    }
    
    func updateAge(age: Int){
        userProfile?.age = age
        
        getAccessToken.getAccessToken()
        let accessToken = NSUserDefaults.standardUserDefaults().objectForKey(accessNSUserData)
        if accessToken != nil {
            let urlPath:String = (updateUserURL as String) + "?access_token=" + (accessToken as! String);
            let url : NSURL = NSURL(string: urlPath)!
            let request = NSMutableURLRequest(URL: url)
            request.HTTPMethod = "POST"
            let requestBody = NSMutableDictionary()
            requestBody.setValue(keychainAccess.getPasscode(usernameKeyChain), forKey: "username")
            if userProfile!.age != nil {
                requestBody.setValue(userProfile!.age!, forKey: "age")
            }
            
            request.HTTPBody = try? NSJSONSerialization.dataWithJSONObject(requestBody as NSDictionary, options: NSJSONWritingOptions())
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            
            NetRequest.sharedInstance.POST(urlPath, parameters: (requestBody as NSDictionary) as! Dictionary<String, AnyObject>,
                
                success: { (content , message) -> Void in
                    HudProgressManager.sharedInstance.showOnlyTextHudProgress(self, title: "更新成功")
                    HudProgressManager.sharedInstance.dismissHud()
                }) { (content, message) -> Void in
                    HudProgressManager.sharedInstance.showOnlyTextHudProgress(self, title: message)
                    HudProgressManager.sharedInstance.dismissHud()
            }
        }

    }
    
    func updateCancerType(cancerType: String) {
        userProfile?.cancerType = cancerType
        
        getAccessToken.getAccessToken()
        let accessToken = NSUserDefaults.standardUserDefaults().objectForKey(accessNSUserData)
        if accessToken != nil {
            let urlPath:String = (updateUserURL as String) + "?access_token=" + (accessToken as! String);
            let url : NSURL = NSURL(string: urlPath)!
            let request = NSMutableURLRequest(URL: url)
            request.HTTPMethod = "POST"
            let requestBody = NSMutableDictionary()
            requestBody.setValue(keychainAccess.getPasscode(usernameKeyChain), forKey: "username")
            if userProfile!.cancerType != nil {
                requestBody.setValue(userProfile!.cancerType!, forKey: "cancerType")
            }
            
            request.HTTPBody = try? NSJSONSerialization.dataWithJSONObject(requestBody as NSDictionary, options: NSJSONWritingOptions())
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            
            NetRequest.sharedInstance.POST(urlPath, parameters: (requestBody as NSDictionary) as! Dictionary<String, AnyObject>,
                
                success: { (content , message) -> Void in
                    HudProgressManager.sharedInstance.showOnlyTextHudProgress(self, title: "更新成功")
                    HudProgressManager.sharedInstance.dismissHud()
                }) { (content, message) -> Void in
                    HudProgressManager.sharedInstance.showOnlyTextHudProgress(self, title: message)
                    HudProgressManager.sharedInstance.dismissHud()
            }
        }

    }
    
    func updatePathological(pathological: String) {
        userProfile?.pathological = pathological
        
        getAccessToken.getAccessToken()
        let accessToken = NSUserDefaults.standardUserDefaults().objectForKey(accessNSUserData)
        if accessToken != nil {
            let urlPath:String = (updateUserURL as String) + "?access_token=" + (accessToken as! String);
            let url : NSURL = NSURL(string: urlPath)!
            let request = NSMutableURLRequest(URL: url)
            request.HTTPMethod = "POST"
            let requestBody = NSMutableDictionary()
            requestBody.setValue(keychainAccess.getPasscode(usernameKeyChain), forKey: "username")

            if userProfile!.pathological != nil {
                requestBody.setValue(userProfile!.pathological!, forKey: "pathological")
            }
            
            request.HTTPBody = try? NSJSONSerialization.dataWithJSONObject(requestBody as NSDictionary, options: NSJSONWritingOptions())
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            
            NetRequest.sharedInstance.POST(urlPath, parameters: (requestBody as NSDictionary) as! Dictionary<String, AnyObject>,
                
                success: { (content , message) -> Void in
                    HudProgressManager.sharedInstance.showOnlyTextHudProgress(self, title: "更新成功")
                    HudProgressManager.sharedInstance.dismissHud()
                }) { (content, message) -> Void in
                    HudProgressManager.sharedInstance.showOnlyTextHudProgress(self, title: message)
                    HudProgressManager.sharedInstance.dismissHud()
            }
        }

    }
    
    func updateGeneticMutation(geneticMutation: String) {
        userProfile?.geneticMutation = geneticMutation
        getAccessToken.getAccessToken()
        let accessToken = NSUserDefaults.standardUserDefaults().objectForKey(accessNSUserData)
        if accessToken != nil {
            let urlPath:String = (updateUserURL as String) + "?access_token=" + (accessToken as! String);
            let url : NSURL = NSURL(string: urlPath)!
            let request = NSMutableURLRequest(URL: url)
            request.HTTPMethod = "POST"
            let requestBody = NSMutableDictionary()
            requestBody.setValue(keychainAccess.getPasscode(usernameKeyChain), forKey: "username")

            if userProfile!.geneticMutation != nil {
                requestBody.setValue(userProfile!.geneticMutation!, forKey: "geneticMutation")
            }

            request.HTTPBody = try? NSJSONSerialization.dataWithJSONObject(requestBody as NSDictionary, options: NSJSONWritingOptions())
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            
            NetRequest.sharedInstance.POST(urlPath, parameters: (requestBody as NSDictionary) as! Dictionary<String, AnyObject>,
                
                success: { (content , message) -> Void in
                    HudProgressManager.sharedInstance.showOnlyTextHudProgress(self, title: "更新成功")
                    HudProgressManager.sharedInstance.dismissHud()
                }) { (content, message) -> Void in
                    HudProgressManager.sharedInstance.showOnlyTextHudProgress(self, title: message)
                    HudProgressManager.sharedInstance.dismissHud()
            }
        }

    }
    
    func updateStage(stage: String) {
        userProfile?.stage = stage
        
        getAccessToken.getAccessToken()
        let accessToken = NSUserDefaults.standardUserDefaults().objectForKey(accessNSUserData)
        if accessToken != nil {
            let urlPath:String = (updateUserURL as String) + "?access_token=" + (accessToken as! String);
            let url : NSURL = NSURL(string: urlPath)!
            let request = NSMutableURLRequest(URL: url)
            request.HTTPMethod = "POST"
            let requestBody = NSMutableDictionary()
            requestBody.setValue(keychainAccess.getPasscode(usernameKeyChain), forKey: "username")

            if userProfile!.stage != nil {
                requestBody.setValue(userProfile!.stage!, forKey: "stage")
            }
            request.HTTPBody = try? NSJSONSerialization.dataWithJSONObject(requestBody as NSDictionary, options: NSJSONWritingOptions())
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            
            NetRequest.sharedInstance.POST(urlPath, parameters: (requestBody as NSDictionary) as! Dictionary<String, AnyObject>,
                
                success: { (content , message) -> Void in
                    HudProgressManager.sharedInstance.showOnlyTextHudProgress(self, title: "更新成功")
                    HudProgressManager.sharedInstance.dismissHud()
                }) { (content, message) -> Void in
                    HudProgressManager.sharedInstance.showOnlyTextHudProgress(self, title: message)
                    HudProgressManager.sharedInstance.dismissHud()
            }
        }

    }
    
    func updateMetastasis(metastasis: String) {
        userProfile?.metastics = metastasis
        
        getAccessToken.getAccessToken()
        let accessToken = NSUserDefaults.standardUserDefaults().objectForKey(accessNSUserData)
        if accessToken != nil {
            let urlPath:String = (updateUserURL as String) + "?access_token=" + (accessToken as! String);
            let url : NSURL = NSURL(string: urlPath)!
            let request = NSMutableURLRequest(URL: url)
            request.HTTPMethod = "POST"
            let requestBody = NSMutableDictionary()
            requestBody.setValue(keychainAccess.getPasscode(usernameKeyChain), forKey: "username")

            if userProfile!.metastics != nil {
                requestBody.setValue(userProfile!.metastics!, forKey: "metastasis")
            }

            request.HTTPBody = try? NSJSONSerialization.dataWithJSONObject(requestBody as NSDictionary, options: NSJSONWritingOptions())
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            
            NetRequest.sharedInstance.POST(urlPath, parameters: (requestBody as NSDictionary) as! Dictionary<String, AnyObject>,
                
                success: { (content , message) -> Void in
                    HudProgressManager.sharedInstance.showOnlyTextHudProgress(self, title: "更新成功")
                    HudProgressManager.sharedInstance.dismissHud()
                }) { (content, message) -> Void in
                    HudProgressManager.sharedInstance.showOnlyTextHudProgress(self, title: message)
                    HudProgressManager.sharedInstance.dismissHud()
            }
        }

    }
    
    //MARK: Delegates
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        let chosenImage = info[UIImagePickerControllerOriginalImage] as! UIImage //2
        var selectedImage = UIImage()
        let publicService = PublicService()
        selectedImage = publicService.cropToSquare(image: chosenImage)
        
        let newSize = CGSizeMake(128.0, 128.0)
        UIGraphicsBeginImageContext(newSize)
        selectedImage.drawInRect(CGRectMake(0, 0, newSize.width, newSize.height))
        let portraitImage = UIGraphicsGetImageFromCurrentImageContext()
        
        let imageData: NSData = UIImagePNGRepresentation(selectedImage)!
        let imageDataStr:String = imageData.base64EncodedStringWithOptions([])
        
        userProfile!.portraitData = imageDataStr
        
        UIGraphicsEndImageContext()
        
        getAccessToken.getAccessToken()
        let accessToken = NSUserDefaults.standardUserDefaults().objectForKey(accessNSUserData)
        if accessToken != nil {
            let urlPath:String = (updateUserURL as String) + "?access_token=" + (accessToken as! String);
            let url : NSURL = NSURL(string: urlPath)!
            let request = NSMutableURLRequest(URL: url)
            request.HTTPMethod = "POST"
            let requestBody = NSMutableDictionary()
            requestBody.setValue(keychainAccess.getPasscode(usernameKeyChain), forKey: "username")

            if userProfile!.portraitData != nil {
                let imageInfo = NSDictionary(objects: [userProfile!.portraitData!,"jpg"], forKeys: ["data", "type"])
                requestBody.setValue(imageInfo, forKey: "imageInfo")
            }
            
            request.HTTPBody = try? NSJSONSerialization.dataWithJSONObject(requestBody as NSDictionary, options: NSJSONWritingOptions())
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            
            NetRequest.sharedInstance.POST(urlPath, parameters: (requestBody as NSDictionary) as! Dictionary<String, AnyObject>,
                
                success: { (content , message) -> Void in
                    HudProgressManager.sharedInstance.showOnlyTextHudProgress(self, title: "更新成功")
                    HudProgressManager.sharedInstance.dismissHud()
                    
                }) { (content, message) -> Void in
                    HudProgressManager.sharedInstance.showOnlyTextHudProgress(self, title: message)
                    HudProgressManager.sharedInstance.dismissHud()
            }
        }
        dismissViewControllerAnimated(true, completion: nil) //5
        
    }
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
//        updateUserProfile(userProfile!)
    }
    
    func updateUserProfile(userProfile: UserProfile){

        getAccessToken.getAccessToken()
        let accessToken = NSUserDefaults.standardUserDefaults().objectForKey(accessNSUserData)
        if accessToken != nil {
            let urlPath:String = (updateUserURL as String) + "?access_token=" + (accessToken as! String);
            let url : NSURL = NSURL(string: urlPath)!
            let request = NSMutableURLRequest(URL: url)
            request.HTTPMethod = "POST"
            let requestBody = NSMutableDictionary()
            requestBody.setValue(keychainAccess.getPasscode(usernameKeyChain), forKey: "username")
            if userProfile.nick != nil {
                requestBody.setValue(userProfile.nick!, forKey: "displayname")
            }
            if userProfile.gender != nil {
                requestBody.setValue(userProfile.gender!, forKey: "gender")
            }
            if userProfile.pathological != nil {
                requestBody.setValue(userProfile.pathological!, forKey: "pathological")
            }
            if userProfile.stage != nil {
                requestBody.setValue(userProfile.stage!, forKey: "stage")
            }
            if userProfile.age != nil {
                requestBody.setValue(userProfile.age!, forKey: "age")
            }
            if userProfile.cancerType != nil {
                requestBody.setValue(userProfile.cancerType!, forKey: "cancerType")
            }
            if userProfile.metastics != nil {
                requestBody.setValue(userProfile.metastics!, forKey: "metastasis")
            }
            if userProfile.geneticMutation != nil {
                requestBody.setValue(userProfile.geneticMutation!, forKey: "geneticMutation")
            }
            if userProfile.portraitData != nil {
                let imageInfo = NSDictionary(objects: [userProfile.portraitData!,"jpg"], forKeys: ["data", "type"])
                requestBody.setValue(imageInfo, forKey: "imageInfo")
            }

            request.HTTPBody = try? NSJSONSerialization.dataWithJSONObject(requestBody as NSDictionary, options: NSJSONWritingOptions())
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            
            NetRequest.sharedInstance.POST(urlPath, parameters: (requestBody as NSDictionary) as! Dictionary<String, AnyObject>,
                
                success: { (content , message) -> Void in
                    print(content)
                    
                }) { (content, message) -> Void in
                    HudProgressManager.sharedInstance.showOnlyTextHudProgress(self, title: message)
                    HudProgressManager.sharedInstance.dismissHud()
            }
        }
    }
}
