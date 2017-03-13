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
    let sectionTitleFont = UIFont.systemFont(ofSize: 14)
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

    override func viewWillAppear(_ animated: Bool) {
        self.tableView.reloadData()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
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

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
        let cellWidth = cell.frame.width
        if indexPath.section == 0 {
            switch indexPath.row {
            case 0:
                cell.textLabel?.text = "头像"
                cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
                let portraitView = UIImageView(frame: CGRect(x: cellWidth - portraitViewLength - 40, y: headerTitleLeftSpace, width: portraitViewLength, height: portraitViewLength))
                portraitView.layer.cornerRadius = 20
                portraitView.layer.masksToBounds = true
                if self.userProfile?.portraitData != nil {
                    portraitView.image = UIImage(data: Data(base64Encoded: (self.userProfile?.portraitData)!, options: [])!)
                } else if self.userProfile?.portraitUrl != nil {
                    let imageURL = (self.userProfile?.portraitUrl)! + "@80h_80w_1e"
                    portraitView.addImageCache(imageURL, placeHolder: "defaultUserImage")

                }else{
                    portraitView.image = UIImage(named: "defaultUserImage")
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
                cell.accessoryType = UITableViewCellAccessoryType.none
                cell.detailTextLabel?.text = subTitleStr
                break
            case 3:
                cell.textLabel?.text = "昵称"
                cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
                if self.userProfile?.nick != nil {
                    let subTitleStr: String = (self.userProfile?.nick)!
                    cell.detailTextLabel?.text = subTitleStr
                }
                break
            case 4:
                cell.textLabel?.text = "重置密码"
                cell.detailTextLabel?.text = ""
                cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
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
            cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
//            cell.addSubview(subTitleLabel)
        }
        cell.textLabel?.textColor = cellTextColor
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var heightForRow = self.heightForRow
        if (indexPath.section == 0) && (indexPath.row == 0) {
            heightForRow = 69
        }
        return heightForRow
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return heightForSction
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            switch indexPath.row {
            case 0:
                imagePicker.allowsEditing = true //2
                imagePicker.sourceType = .photoLibrary //3
                present(imagePicker, animated: true, completion: nil)//4
            case 3:
                self.performSegue(withIdentifier: "updateNickSegue", sender: self)
                break
            case 4:
                self.performSegue(withIdentifier: "updatePasswordSegue", sender: self)
                break
            default:
                break
            }
        }
        if indexPath.section == 1 {
            switch indexPath.row {
            case 0:
                let storyboard = UIStoryboard(name: "Registeration", bundle: nil)
                let genderController = storyboard.instantiateViewController(withIdentifier: "genderSetting") as! GenderSettingViewController
                genderController.isUpdate = true
                genderController.genderSettingVCDelegate = self
                genderController.ageSettingVCDelegate = self
                self.navigationController?.pushViewController(genderController, animated: true)
                break
            case 1:
                let storyboard = UIStoryboard(name: "Registeration", bundle: nil)
                let cancerTypeController = storyboard.instantiateViewController(withIdentifier: "cancerTypeSetting") as! CancerTypeSettingViewController
                cancerTypeController.isUpdate = true
                cancerTypeController.cancerTypeSettingVCDelegate = self
                cancerTypeController.pathologicalSettingVCDelegate = self
                self.navigationController?.pushViewController(cancerTypeController, animated: true)
                break
            case 2:
                let storyboard = UIStoryboard(name: "Registeration", bundle: nil)
                let geneticMutationViewController = storyboard.instantiateViewController(withIdentifier: "geneticMutationSetting") as! GeneticMutationViewController
                geneticMutationViewController.isUpdate = true
                geneticMutationViewController.geneticMutationVCDelegate = self
                self.navigationController?.pushViewController(geneticMutationViewController, animated: true)
                break
            case 3:
                let storyboard = UIStoryboard(name: "Registeration", bundle: nil)
                let stageViewController = storyboard.instantiateViewController(withIdentifier: "stageSetting") as! StageViewController
                stageViewController.isUpdate = true
                stageViewController.stageSettingVCDelegate = self
                self.navigationController?.pushViewController(stageViewController, animated: true)
                break
            case 4:
                let storyboard = UIStoryboard(name: "Registeration", bundle: nil)
                let metasticViewController = storyboard.instantiateViewController(withIdentifier: "MetasticsSetting") as! MetasticViewController
                metasticViewController.isUpdate = true
                metasticViewController.metastasisSettingVCDelegate = self
                self.navigationController?.pushViewController(metasticViewController, animated: true)
                break
            default:
                break
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "updateNickSegue" {
            (segue.destination as! UpdateNickTableViewController).settingNickVCDelegate = self
        }
    }
    
    func updateDisplayname(_ displayname: String) {
        userProfile?.nick =  displayname
        
        getAccessToken.getAccessToken()
        let accessToken = UserDefaults.standard.object(forKey: accessNSUserData)
        if accessToken != nil {
            let urlPath:String = (updateUserURL as String) + "?access_token=" + (accessToken as! String);
            let url : URL = URL(string: urlPath)!
            let request = NSMutableURLRequest(url: url)
            request.httpMethod = "POST"
            let requestBody = NSMutableDictionary()
            requestBody.setValue(keychainAccess.getPasscode(usernameKeyChain), forKey: "username")
            if userProfile!.nick != nil {
                requestBody.setValue(userProfile!.nick!, forKey: "displayname")
            }
            
            request.httpBody = try? JSONSerialization.data(withJSONObject: requestBody as NSDictionary, options: JSONSerialization.WritingOptions())
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
    
    func updateGender(_ gender: String){
        userProfile?.gender = gender
        
        getAccessToken.getAccessToken()
        let accessToken = UserDefaults.standard.object(forKey: accessNSUserData)
        if accessToken != nil {
            let urlPath:String = (updateUserURL as String) + "?access_token=" + (accessToken as! String);
            let url : URL = URL(string: urlPath)!
            let request = NSMutableURLRequest(url: url)
            request.httpMethod = "POST"
            let requestBody = NSMutableDictionary()
            requestBody.setValue(keychainAccess.getPasscode(usernameKeyChain), forKey: "username")
            if userProfile!.gender != nil {
                requestBody.setValue(userProfile!.gender!, forKey: "gender")
            }
            
            request.httpBody = try? JSONSerialization.data(withJSONObject: requestBody as NSDictionary, options: JSONSerialization.WritingOptions())
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
    
    func updateAge(_ age: Int){
        userProfile?.age = age
        
        getAccessToken.getAccessToken()
        let accessToken = UserDefaults.standard.object(forKey: accessNSUserData)
        if accessToken != nil {
            let urlPath:String = (updateUserURL as String) + "?access_token=" + (accessToken as! String);
            let url : URL = URL(string: urlPath)!
            let request = NSMutableURLRequest(url: url)
            request.httpMethod = "POST"
            let requestBody = NSMutableDictionary()
            requestBody.setValue(keychainAccess.getPasscode(usernameKeyChain), forKey: "username")
            if userProfile!.age != nil {
                requestBody.setValue(userProfile!.age!, forKey: "age")
            }
            
            request.httpBody = try? JSONSerialization.data(withJSONObject: requestBody as NSDictionary, options: JSONSerialization.WritingOptions())
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
    
    func updateCancerType(_ cancerType: String) {
        userProfile?.cancerType = cancerType
        
        getAccessToken.getAccessToken()
        let accessToken = UserDefaults.standard.object(forKey: accessNSUserData)
        if accessToken != nil {
            let urlPath:String = (updateUserURL as String) + "?access_token=" + (accessToken as! String);
            let url : URL = URL(string: urlPath)!
            let request = NSMutableURLRequest(url: url)
            request.httpMethod = "POST"
            let requestBody = NSMutableDictionary()
            requestBody.setValue(keychainAccess.getPasscode(usernameKeyChain), forKey: "username")
            if userProfile!.cancerType != nil {
                requestBody.setValue(userProfile!.cancerType!, forKey: "cancerType")
            }
            
            request.httpBody = try? JSONSerialization.data(withJSONObject: requestBody as NSDictionary, options: JSONSerialization.WritingOptions())
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
    
    func updatePathological(_ pathological: String) {
        userProfile?.pathological = pathological
        
        getAccessToken.getAccessToken()
        let accessToken = UserDefaults.standard.object(forKey: accessNSUserData)
        if accessToken != nil {
            let urlPath:String = (updateUserURL as String) + "?access_token=" + (accessToken as! String);
            let url : URL = URL(string: urlPath)!
            let request = NSMutableURLRequest(url: url)
            request.httpMethod = "POST"
            let requestBody = NSMutableDictionary()
            requestBody.setValue(keychainAccess.getPasscode(usernameKeyChain), forKey: "username")

            if userProfile!.pathological != nil {
                requestBody.setValue(userProfile!.pathological!, forKey: "pathological")
            }
            
            request.httpBody = try? JSONSerialization.data(withJSONObject: requestBody as NSDictionary, options: JSONSerialization.WritingOptions())
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
    
    func updateGeneticMutation(_ geneticMutation: String) {
        userProfile?.geneticMutation = geneticMutation
        getAccessToken.getAccessToken()
        let accessToken = UserDefaults.standard.object(forKey: accessNSUserData)
        if accessToken != nil {
            let urlPath:String = (updateUserURL as String) + "?access_token=" + (accessToken as! String);
            let url : URL = URL(string: urlPath)!
            let request = NSMutableURLRequest(url: url)
            request.httpMethod = "POST"
            let requestBody = NSMutableDictionary()
            requestBody.setValue(keychainAccess.getPasscode(usernameKeyChain), forKey: "username")

            if userProfile!.geneticMutation != nil {
                requestBody.setValue(userProfile!.geneticMutation!, forKey: "geneticMutation")
            }

            request.httpBody = try? JSONSerialization.data(withJSONObject: requestBody as NSDictionary, options: JSONSerialization.WritingOptions())
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
    
    func updateStage(_ stage: String) {
        userProfile?.stage = stage
        
        getAccessToken.getAccessToken()
        let accessToken = UserDefaults.standard.object(forKey: accessNSUserData)
        if accessToken != nil {
            let urlPath:String = (updateUserURL as String) + "?access_token=" + (accessToken as! String);
            let url : URL = URL(string: urlPath)!
            let request = NSMutableURLRequest(url: url)
            request.httpMethod = "POST"
            let requestBody = NSMutableDictionary()
            requestBody.setValue(keychainAccess.getPasscode(usernameKeyChain), forKey: "username")

            if userProfile!.stage != nil {
                requestBody.setValue(userProfile!.stage!, forKey: "stage")
            }
            request.httpBody = try? JSONSerialization.data(withJSONObject: requestBody as NSDictionary, options: JSONSerialization.WritingOptions())
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
    
    func updateMetastasis(_ metastasis: String) {
        userProfile?.metastics = metastasis
        
        getAccessToken.getAccessToken()
        let accessToken = UserDefaults.standard.object(forKey: accessNSUserData)
        if accessToken != nil {
            let urlPath:String = (updateUserURL as String) + "?access_token=" + (accessToken as! String);
            let url : URL = URL(string: urlPath)!
            let request = NSMutableURLRequest(url: url)
            request.httpMethod = "POST"
            let requestBody = NSMutableDictionary()
            requestBody.setValue(keychainAccess.getPasscode(usernameKeyChain), forKey: "username")

            if userProfile!.metastics != nil {
                requestBody.setValue(userProfile!.metastics!, forKey: "metastasis")
            }

            request.httpBody = try? JSONSerialization.data(withJSONObject: requestBody as NSDictionary, options: JSONSerialization.WritingOptions())
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
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let chosenImage = info[UIImagePickerControllerOriginalImage] as! UIImage //2
        var selectedImage = UIImage()
        let publicService = PublicService()
        
        let newSize = CGSize(width: 256.0, height: 256.0)
        
        selectedImage = publicService.resizeImage(chosenImage, newSize: newSize)
        let imageData: Data = UIImagePNGRepresentation(selectedImage)!
        userProfile!.portraitData = imageData.base64EncodedString(options: [])
        
        getAccessToken.getAccessToken()
        let accessToken = UserDefaults.standard.object(forKey: accessNSUserData)
        if accessToken != nil {
            let urlPath:String = (updateUserURL as String) + "?access_token=" + (accessToken as! String);
            let url : URL = URL(string: urlPath)!
            let request = NSMutableURLRequest(url: url)
            request.httpMethod = "POST"
            let requestBody = NSMutableDictionary()
            requestBody.setValue(keychainAccess.getPasscode(usernameKeyChain), forKey: "username")

            if userProfile!.portraitData != nil {
                let imageInfo = NSDictionary(objects: [userProfile!.portraitData!,"jpg"], forKeys: ["data" as NSCopying, "type" as NSCopying])
                requestBody.setValue(imageInfo, forKey: "imageInfo")
            }
            
            request.httpBody = try? JSONSerialization.data(withJSONObject: requestBody as NSDictionary, options: JSONSerialization.WritingOptions())
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
        dismiss(animated: true, completion: nil) //5
        
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
//        updateUserProfile(userProfile!)
    }
    
    func updateUserProfile(_ userProfile: UserProfile){

        getAccessToken.getAccessToken()
        let accessToken = UserDefaults.standard.object(forKey: accessNSUserData)
        if accessToken != nil {
            let urlPath:String = (updateUserURL as String) + "?access_token=" + (accessToken as! String);
            let url : URL = URL(string: urlPath)!
            let request = NSMutableURLRequest(url: url)
            request.httpMethod = "POST"
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
                let imageInfo = NSDictionary(objects: [userProfile.portraitData!,"jpg"], forKeys: ["data" as NSCopying, "type" as NSCopying])
                requestBody.setValue(imageInfo, forKey: "imageInfo")
            }

            request.httpBody = try? JSONSerialization.data(withJSONObject: requestBody as NSDictionary, options: JSONSerialization.WritingOptions())
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            
            NetRequest.sharedInstance.POST(urlPath, parameters: (requestBody as NSDictionary) as! Dictionary<String, AnyObject>,
                
                success: { (content , message) -> Void in
                    
                }) { (content, message) -> Void in
                    HudProgressManager.sharedInstance.showOnlyTextHudProgress(self, title: message)
                    HudProgressManager.sharedInstance.dismissHud()
            }
        }
    }
}
