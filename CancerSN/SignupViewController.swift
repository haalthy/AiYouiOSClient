//
//  SignupViewController.swift
//  CancerSN
//
//  Created by lily on 7/26/15.
//  Copyright (c) 2015 lily. All rights reserved.
//

import UIKit

class SignupViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate, UIGestureRecognizerDelegate, UITextFieldDelegate  {
    
    @IBOutlet weak var submitBtn: UIButton!
    func cropToSquare(image originalImage: UIImage) -> UIImage {
        // Create a copy of the image without the imageOrientation property so it is in its native orientation (landscape)
        let contextImage: UIImage = UIImage(CGImage: originalImage.CGImage)!
        
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
        let imageRef: CGImageRef = CGImageCreateWithImageInRect(contextImage.CGImage, rect)
        
        // Create a new image based on the imageRef and rotate back to the original orientation
        let image: UIImage = UIImage(CGImage: imageRef, scale: originalImage.scale, orientation: originalImage.imageOrientation)!
        
        return image
    }
    
    @IBOutlet weak var portrait: UIImageView!
    
    @IBOutlet weak var emailInput: UITextField!
    @IBOutlet weak var usernameInput: UITextField!
    @IBOutlet weak var passwordInput: UITextField!
    
    var imagePicker = UIImagePickerController()
    
    var data :NSMutableData? = NSMutableData()
    @IBAction func submit(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
        //save image
        
        var selectedImage: UIImage = portrait.image!
        
        
        let fileManager = NSFileManager.defaultManager()
        
        var paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as! String
        
        var filePathToWrite = "\(paths)/" + imageFileName
        
        var imageData: NSData = UIImagePNGRepresentation(selectedImage)
        println(selectedImage.size.width, selectedImage.size.height)
        var imageDataStr = imageData.base64EncodedStringWithOptions(.allZeros)
        println(imageDataStr)
        
        fileManager.createFileAtPath(filePathToWrite, contents: imageData, attributes: nil)
        
        var getImagePath = paths.stringByAppendingPathComponent(imageFileName)
        
        //store username, password, email in NSUserData
        let profileSet = NSUserDefaults.standardUserDefaults()
        profileSet.setObject(emailInput.text, forKey: emailNSUserData)
        profileSet.setObject(imageDataStr, forKey: imageNSUserData)
        let keychainAccess = KeychainAccess()
        keychainAccess.setPasscode(usernameKeyChain, passcode: usernameInput.text)
        keychainAccess.setPasscode(passwordKeyChain, passcode: passwordInput.text)
        
        //upload UserInfo to Server
        var haalthyService = HaalthyService()
        var addUserRespData = haalthyService.addUser()
        let str: NSString = NSString(data: addUserRespData, encoding: NSUTF8StringEncoding)!
        println(str)
        var getAccessToken = GetAccessToken()
        getAccessToken.getAccessToken()
    }
    
    func connection(connection: NSURLConnection!, didReceiveData data: NSData!){
        self.data!.appendData(data)
    }
    
    func connectionDidFinishLoading(connection: NSURLConnection!)
    {
        var error: NSErrorPointer=nil
//        var jsonResult: NSArray = NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers, error: error) as! NSArray
        let str: NSString = NSString(data: data!, encoding: NSUTF8StringEncoding)!
        println(str)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        portrait.image = UIImage(named: "Mario.jpg")
        imagePicker.delegate = self
        var tapImage = UITapGestureRecognizer(target: self, action: Selector("imageTapHandler:"))
        portrait.userInteractionEnabled = true
        portrait.addGestureRecognizer(tapImage)
        
        emailInput.delegate = self
        usernameInput.delegate = self
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
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        var chosenImage = info[UIImagePickerControllerOriginalImage] as! UIImage //2
        var selectedImage = UIImage()
        selectedImage = cropToSquare(image: chosenImage)
        
        var newSize = CGSizeMake(128.0, 128.0)
        UIGraphicsBeginImageContext(newSize)
        selectedImage.drawInRect(CGRectMake(0, 0, newSize.width, newSize.height))
        portrait.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        dismissViewControllerAnimated(true, completion: nil) //5
        
    }
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func gestureRecognizer(UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWithGestureRecognizer:UIGestureRecognizer) -> Bool {
            return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        textField.resignFirstResponder()
        return true
    }
}
