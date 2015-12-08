//
//  SignupViewController.swift
//  CancerSN
//
//  Created by lily on 7/26/15.
//  Copyright (c) 2015 lily. All rights reserved.
//

import UIKit

class SignupViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate, UIGestureRecognizerDelegate, UITextFieldDelegate  {
    
    var isFirstSignup: Bool = false
    
    @IBOutlet weak var submitBtn: UIButton!
    func cropToSquare(image originalImage: UIImage) -> UIImage {
        // Create a copy of the image without the imageOrientation property so it is in its native orientation (landscape)
        let contextImage: UIImage = UIImage(CGImage: originalImage.CGImage!)
        
        // Get the size of the contextImage
        let contextSize: CGSize = contextImage.size
        
        let posX: CGFloat
        let posY: CGFloat
        let width: CGFloat
        let height: CGFloat
        
        // Check to see which length is the longest and create the offset based on that length, then set the width and height of our rect
        if contextSize.width > contextSize.height {
            posX = ((contextSize.width - contextSize.height) / 2)
            posY = 0
            width = contextSize.height
            height = contextSize.height
        } else {
            posX = 0
            posY = ((contextSize.height - contextSize.width) / 2)
            width = contextSize.width
            height = contextSize.width
        }
        
        let rect: CGRect = CGRectMake(posX, posY, width, height)
        
        // Create bitmap image from context using the rect
        let imageRef: CGImageRef = CGImageCreateWithImageInRect(contextImage.CGImage, rect)!
        
        // Create a new image based on the imageRef and rotate back to the original orientation
        let image: UIImage = UIImage(CGImage: imageRef, scale: originalImage.scale, orientation: originalImage.imageOrientation)
        
        return image
    }
    
    @IBOutlet weak var portrait: UIImageView!
    
    @IBOutlet weak var emailInput: UITextField!
//    @IBOutlet weak var usernameInput: UITextField!
    @IBOutlet weak var passwordInput: UITextField!
    @IBOutlet weak var passwordReInput: UITextField!
    @IBOutlet weak var displayname: UITextField!
    
    var imagePicker = UIImagePickerController()
    
    var data :NSMutableData? = NSMutableData()
    @IBAction func submit(sender: UIButton) {
        //store username, password, email in NSUserData
        print(passwordInput.text)
        print(passwordReInput.text)
        if passwordInput.text != passwordReInput.text {
            let alert = UIAlertController(title: "提示", message: "密码输入不一致，请重新输入", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "确定", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }else if emailInput.text == ""{
            let alert = UIAlertController(title: "提示", message: "请输入邮箱／手机", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "确定", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }else
            if passwordInput.text == ""{
                let alert = UIAlertController(title: "提示", message: "请输入密码", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "确定", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
            }else{
                
                var usernameStr:String = String()
                let publicService = PublicService()
                print("passwordStr")
                
                let passwordStr = publicService.passwordEncode(passwordInput.text!)
                
                print(passwordStr)
                
                //save image
                let selectedImage: UIImage = portrait.image!
                
                let fileManager = NSFileManager.defaultManager()
                
                let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
                
                let filePathToWrite = "\(paths)/" + imageFileName
                
                let imageData: NSData = UIImagePNGRepresentation(selectedImage)!
                print(selectedImage.size.width, selectedImage.size.height)
                let imageDataStr = imageData.base64EncodedStringWithOptions([])
                
                fileManager.createFileAtPath(filePathToWrite, contents: imageData, attributes: nil)
                
                let profileSet = NSUserDefaults.standardUserDefaults()
                profileSet.setObject(emailInput.text, forKey: emailNSUserData)
                profileSet.setObject(imageDataStr, forKey: imageNSUserData)
                profileSet.setObject(displayname.text, forKey: displaynameUserData)
                let keychainAccess = KeychainAccess()
                let haalthyService = HaalthyService()
                keychainAccess.setPasscode(usernameKeyChain, passcode: emailInput.text!)
                keychainAccess.setPasscode(passwordKeyChain, passcode: passwordInput.text!)
                
                //upload UserInfo to Server
                let addUserRespData = haalthyService.addUser("AY")
                var returnStr = String()
                let jsonResult = try? NSJSONSerialization.JSONObjectWithData(addUserRespData, options: NSJSONReadingOptions.MutableContainers)
                if jsonResult is NSDictionary {
                    returnStr = (jsonResult as! NSDictionary).objectForKey("status") as! String
                }
                print(returnStr)
                let isReturnUsername = publicService.checkIsUsername(returnStr)

//                publicService.checkIsUsername(returnStr)
//                if returnStr != "create successful!"{
                if !isReturnUsername{
                    keychainAccess.deletePasscode(usernameKeyChain)
                    keychainAccess.deletePasscode(passwordKeyChain)
                }
                if returnStr == "this email has been registed, please use another name" {
                    let alert = UIAlertController(title: "提示", message: "此用户名已被注册，请使用其他用户名", preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "确定", style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                }
                if returnStr == "this email has been registed, please login" {
                    let alert = UIAlertController(title: "提示", message: "此邮箱/手机已被注册，请登录", preferredStyle: UIAlertControllerStyle.Alert)
                    
                    alert.addAction(UIAlertAction(title: "确定", style: UIAlertActionStyle.Default, handler: {(alert: UIAlertAction) in
                        self.dismissViewControllerAnimated(true, completion: nil)
                    }))
                    self.presentViewController(alert, animated: true, completion: nil)
                }
                if isReturnUsername {
//                    usernameStr = NSString(data: haalthyService.getUsernameByEmail(), encoding: NSUTF8StringEncoding) as! String
                    keychainAccess.setPasscode(usernameKeyChain, passcode: returnStr)
                    let getAccessToken = GetAccessToken()
                    getAccessToken.getAccessToken()
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let controller = storyboard.instantiateViewControllerWithIdentifier("MainEntry") as UIViewController
                    self.presentViewController(controller, animated: true, completion: nil)
                    
                    haalthyService.updateUserTag(NSUserDefaults.standardUserDefaults().objectForKey(favTagsNSUserData) as! NSArray)
                }
        }
    }
    
    func connection(connection: NSURLConnection!, didReceiveData data: NSData!){
        self.data!.appendData(data)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        portrait.image = UIImage(named: "Mario.jpg")
        imagePicker.delegate = self
        let tapImage = UITapGestureRecognizer(target: self, action: Selector("imageTapHandler:"))
        portrait.userInteractionEnabled = true
        portrait.addGestureRecognizer(tapImage)
        
        emailInput.delegate = self
//        usernameInput.delegate = self
        passwordInput.delegate = self
        submitBtn.layer.cornerRadius = 5
        submitBtn.layer.masksToBounds = true
    }

    func imageTapHandler(recognizer: UITapGestureRecognizer){
        imagePicker.allowsEditing = true //2
        imagePicker.sourceType = .PhotoLibrary //3
        presentViewController(imagePicker, animated: true, completion: nil)//4
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    //MARK: Delegates
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        let chosenImage = info[UIImagePickerControllerOriginalImage] as! UIImage //2
        var selectedImage = UIImage()
        selectedImage = cropToSquare(image: chosenImage)
        
        let newSize = CGSizeMake(128.0, 128.0)
        UIGraphicsBeginImageContext(newSize)
        selectedImage.drawInRect(CGRectMake(0, 0, newSize.width, newSize.height))
        portrait.image = UIGraphicsGetImageFromCurrentImageContext()
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
    
    func textFieldShouldReturn(textField: UITextField) -> Bool{
        textField.resignFirstResponder()
        return true
    }
}
