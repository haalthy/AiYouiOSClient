//
//  PatientProfileTableViewController.swift
//  CancerSN
//
//  Created by lily on 10/3/15.
//  Copyright (c) 2015 lily. All rights reserved.
//

import UIKit

class PatientProfileTableViewController: UITableViewController, UIImagePickerControllerDelegate,UIGestureRecognizerDelegate, UINavigationControllerDelegate, SettingUsernameVCDelegate, GenderSettingVCDelegate, AgeSettingVCDelegate, CancerTypeSettingVCDelegate, PathologicalSettingVCDelegate, StageSettingVCDelegate, MetastasisSettingVCDelegate, GeneticMutationVCDelegate {
    var imagePicker = UIImagePickerController()

    var userProfile = NSMutableDictionary()
    let nullItemStr = "请填写"
    var portraitImage = UIImage()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self

        let backButton : UIBarButtonItem = UIBarButtonItem(title: "确定", style: UIBarButtonItemStyle.Done, target: self, action: "submit")
        self.navigationItem.rightBarButtonItem = backButton
    }
    
    func submit(){
        let haalthyService = HaalthyService()
        haalthyService.updateUser(userProfile)
        self.navigationController?.popToRootViewControllerAnimated(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 2
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var numberOfRows: Int = 0
        switch section{
        case 0: numberOfRows = 5
            break
        case 1:
            if (userProfile.objectForKey("cancerType") != nil) && (userProfile.objectForKey("cancerType") is NSNull) == false && (userProfile.objectForKey("cancerType") as! String) == "lung"{
                numberOfRows = 4
            }else{
                numberOfRows = 2
            }
            break
        default:
            break
        }
        
        return numberOfRows
    }
    
    override func viewDidAppear(animated: Bool) {
        self.tableView.reloadData()

    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("profileListIdentifier", forIndexPath: indexPath) 
        if indexPath.section == 0{
            switch indexPath.row{
            case 0:
                let imageView = UIImageView(frame: CGRectMake(cell.frame.width - 90, 10, 64, 64))
                if (self.userProfile.objectForKey("image") != nil) && (self.userProfile.objectForKey("image") is NSNull) == false{
                    let dataString = self.userProfile.objectForKey("image") as! String
                    let imageData: NSData = NSData(base64EncodedString: dataString, options: NSDataBase64DecodingOptions(rawValue: 0))!
                    imageView.image = UIImage(data: imageData)
                }else{
                    imageView.image = UIImage(named: "Mario.jpg")
                }
//                imageView.image = portraitImage
                cell.textLabel?.text = "头像"
                cell.addSubview(imageView)
                break;
            case 1:
                if (userProfile.objectForKey("username") != nil) && (userProfile.objectForKey("username") is NSNull) == false{
                    cell.detailTextLabel?.text = userProfile.objectForKey("username") as! String
                }else{
                    cell.detailTextLabel?.text = nullItemStr
                }
                cell.textLabel?.text = "用户名"
                cell.accessoryType = UITableViewCellAccessoryType.None
                break
            case 2:
                if (userProfile.objectForKey("email") != nil) && (userProfile.objectForKey("email") is NSNull) == false{
                    cell.detailTextLabel?.text = userProfile.objectForKey("email") as! String
                }else{
                    cell.detailTextLabel?.text = nullItemStr
                }
                cell.textLabel?.text = "邮件"
                cell.accessoryType = UITableViewCellAccessoryType.None
                break
            case 3:
                if (userProfile.objectForKey("displayname") != nil) && (userProfile.objectForKey("displayname") is NSNull) == false{
                    cell.detailTextLabel?.text = userProfile.objectForKey("displayname") as! String
                }else{
                    cell.detailTextLabel?.text = nullItemStr
                }
                cell.textLabel?.text = "昵称"
                break
            case 4:
                cell.textLabel?.text = "密码"
                cell.detailTextLabel?.text = ""
                break
            default:
                break
            }
        }
        if indexPath.section == 1 {
            switch indexPath.row{
            case 0:
                var genderAndAge = String()
                if (userProfile.objectForKey("gender") != nil) && (userProfile.objectForKey("gender") is NSNull) == false{
                    genderAndAge = userProfile.objectForKey("gender") as! String
                }
                if (userProfile.objectForKey("age") != nil) && (userProfile.objectForKey("age") is NSNull) == false{
                    genderAndAge += " " + (userProfile.objectForKey("age") as! NSNumber).stringValue
                }
                cell.detailTextLabel?.text = genderAndAge
                cell.textLabel?.text = "性别和年龄"
                break
            case 1:
                var cancerType = String()
                if (userProfile.objectForKey("cancerType") != nil) && (userProfile.objectForKey("cancerType") is NSNull) == false {
                    cancerType = userProfile.objectForKey("cancerType") as! String
                }else{
                    cancerType = nullItemStr
                }
                if (userProfile.objectForKey("pathological") != nil) && (userProfile.objectForKey("pathological") is NSNull) == false {
                    cancerType += " " + (userProfile.objectForKey("pathological") as! String)
                }
                cell.textLabel?.text = "癌症类型"
                cell.detailTextLabel?.text = cancerType
                break
            default:
                break
            }
            if (userProfile.objectForKey("cancerType") != nil ) && (userProfile.objectForKey("cancerType") is NSNull) == false && (userProfile.objectForKey("cancerType") as! String) == "lung"{
                switch indexPath.row{
                case 2:
                    var geneticMutation = String()
                    if (userProfile.objectForKey("geneticMutation") != nil) && (userProfile.objectForKey("geneticMutation") is NSNull) == false{
                        geneticMutation = userProfile.objectForKey("geneticMutation") as! String
                    }else{
                        geneticMutation = nullItemStr
                    }
                    cell.detailTextLabel?.text = geneticMutation
                    cell.textLabel?.text = "基因突变"
                    break
                case 3:
                    var stageAndMetastasisStr = String()
                    if (userProfile.objectForKey("stage") != nil) && (userProfile.objectForKey("stage") is NSNull) == false{
                        var stage = stageMapping.allKeysForObject(userProfile.objectForKey("stage")!) as NSArray
                        if stage.count > 0 {
                            stageAndMetastasisStr = (stageMapping.allKeysForObject(userProfile.objectForKey("stage")!) as NSArray)[0] as! String
                        }
                    }else{
                        stageAndMetastasisStr = nullItemStr
                    }
                    if (userProfile.objectForKey("metastasis") != nil) && (userProfile.objectForKey("metastasis") is NSNull) == false{
                        stageAndMetastasisStr += " " + (userProfile.objectForKey("metastasis") as! String)
                    }
                    cell.textLabel?.text = "初诊分期及转移"
                    cell.detailTextLabel?.text = stageAndMetastasisStr
                    break
                default:
                    break
                }
            }
        }

        return cell
    }
    
    override func tableView(_tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat{
        var heightForRow:CGFloat = 44.0
        if (indexPath.section == 0) && (indexPath.row == 0){
            heightForRow = 84
        }
        return heightForRow
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0{
            switch indexPath.row{
            case 0:
                imagePicker.allowsEditing = true //2
                imagePicker.sourceType = .PhotoLibrary //3
                presentViewController(imagePicker, animated: true, completion: nil)//4
                break
            case 3:
                self.performSegueWithIdentifier("setUsernameSegue", sender: self)
                break
            case 4:
                self.performSegueWithIdentifier("setPasswordSegue", sender: self)
                break
            default:
                break
            }
        }
        if indexPath.section == 1{
            switch indexPath.row{
            case 0:
                self.performSegueWithIdentifier("setGenderSegue", sender: self)
                break
            case 1:
                self.performSegueWithIdentifier("setCancerTypeSegue", sender: self)
                break
            case 2:
                self.performSegueWithIdentifier("geneticMutationSegue", sender: self)
                break
            case 3:
                self.performSegueWithIdentifier("setStageSegue", sender: self)
            default:
                break
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
        portraitImage = UIGraphicsGetImageFromCurrentImageContext()
        
        let imageData: NSData = UIImagePNGRepresentation(selectedImage)!
        let imageDataStr:String = imageData.base64EncodedStringWithOptions([])
        
        userProfile.setObject(imageDataStr, forKey: "image")
        
        UIGraphicsEndImageContext()
        dismissViewControllerAnimated(true, completion: nil) //5
        
    }
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    func gestureRecognizer(_: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWithGestureRecognizer:UIGestureRecognizer) -> Bool {
            return true
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 25.0
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var sectionTitleStr = String()
        switch section{
        case 0: sectionTitleStr = "基本信息"
            break
        case 1: sectionTitleStr = "病人信息"
            break
        default:
            break
        }
        return sectionTitleStr
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "setPasswordSegue" {
            (segue.destinationViewController as! SettingPasswordViewController).username = userProfile.objectForKey("username") as! String
        }
        if segue.identifier == "setUsernameSegue" {
            (segue.destinationViewController as! SettingUsernameViewController).settingUsernameVCDelegate = self
        }
        if segue.identifier == "setGenderSegue" {
            let destinationVC = segue.destinationViewController as! GenderSettingViewController
            destinationVC.isUpdate = true
            destinationVC.genderSettingVCDelegate = self
            destinationVC.ageSettingVCDelegate = self
        }
        if segue.identifier == "setCancerTypeSegue" {
            let destinationVC = segue.destinationViewController as! CancerTypeSettingViewController
            destinationVC.isUpdate = true
            destinationVC.cancerTypeSettingVCDelegate = self
            destinationVC.pathologicalSettingVCDelegate = self
        }
        if segue.identifier == "setStageSegue" {
            let destinationVC = segue.destinationViewController  as! StageViewController
            destinationVC.isUpdate = true
            destinationVC.stageSettingVCDelegate = self
//            destinationVC.metastasisSettingVCDelegate = self
        }
        if segue.identifier == "geneticMutationSegue" {
            let destinationVC = segue.destinationViewController as! GeneticMutationViewController
            destinationVC.isUpdate = true
            destinationVC.geneticMutationVCDelegate = self
        }
    }

    func updateDisplayname(displayname: String){
        userProfile.setObject(displayname, forKey: "displayname")
    }
    
    func updateGender(gender: String) {
        userProfile.setObject(gender, forKey: "gender")
    }
    
    func updateAge(age: Int) {
        userProfile.setObject(age, forKey: "age")
    }
    
    func updateCancerType(cancerType: String) {
        userProfile.setObject(cancerType, forKey: "cancerType")
    }
    
    func updatePathological(pathological: String) {
        userProfile.setObject(pathological, forKey: "pathological")
    }
    
    func updateStage(stage: String) {
        userProfile.setObject(stage, forKey: "stage")
    }
    
    func updateSmoking(isSmoking: Int) {
        userProfile.setObject(isSmoking, forKey: "isSmoking")
    }
    
    func updateMetastasis(metastasis: String) {
        userProfile.setObject(metastasis, forKey: "metastasis")
    }
    
    func updateGeneticMutation(geneticMutation: String) {
        userProfile.setObject(geneticMutation, forKey: "geneticMutation")
    }
}
