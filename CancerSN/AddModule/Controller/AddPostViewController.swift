//
//  AddPostViewController.swift
//  CancerSN
//
//  Created by lily on 8/4/15.
//  Copyright (c) 2015 lily. All rights reserved.
//

import UIKit

class AddPostViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate {
    var isQuestion: Bool = true
    var isComment:Int = 0
    var postID: Int? = nil
    
    var keyboardheight:CGFloat = 0

    let viewHorizonMargin = CGFloat(15)
    let textViewVerticalMargin = CGFloat(15)
    let textViewHeight = CGFloat(115)
    let textViewFont = UIFont.systemFontOfSize(15)
    let textViewTextColor: UIColor = defaultTextColor
    
    let imageLength: CGFloat = 60
    let imageMargin: CGFloat = 6
    let imageSectionButtomSpace: CGFloat = 12
    let imageSectionTopSpace: CGFloat = 135
    let imageDeleteBtnLength: CGFloat = 13
    
    let tagSectionTopMargin: CGFloat = 12
    let tagSectionTitleFont: UIFont = UIFont.systemFontOfSize(12)
    let tagSectionTitleTextColor: UIColor = lightTextColor
    
    let tagSecitonTopSpace: CGFloat = 12
    let tagSectionBtnTextVerticalMargin: CGFloat = 8
    let tagSectionBtnTextHorizonMargin: CGFloat = 15
    let tagSectionBtnVerticalMargin: CGFloat = 11
    let tagSectionBtnHorizonMargin: CGFloat = 6
    let tagSectionHeight: CGFloat = 96
    let tagBtnFont = UIFont.systemFontOfSize(13)
    
    let buttomSectionHeight: CGFloat = 45
    let buttomSectionItemLeftSpace: CGFloat = 26
    let buttomSectionItemHorizonMargin: CGFloat = 42
    let buttomItemIconLength: CGFloat = 24
    var headerHeight = CGFloat()
    
    let textView = UITextView()
    let imageSection = UIView()
    let defaultAddImageBtn = UIButton()
    let tagSection = UIView()
    let buttomSection = UIView()
    let buttomSectionColor = UIColor.init(red: 245 / 255, green: 245 / 255, blue: 245 / 255, alpha: 1)
    
    let keychainAccess = KeychainAccess()
    let haalthyService = HaalthyService()
    let publicService = PublicService()
    
    var imagePicker = UIImagePickerController()

    var tagList:NSArray?
    
    var imageInfoList = NSMutableArray()
    var imageCountPerLine: Int = 0
    
    var selectTagLabel = NSMutableArray()
    
    var mentionUsernameList = NSMutableArray()
    
    var progressHUD: MBProgressHUD?
    
    @IBOutlet weak var submitBtn: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        initVariables()
        initContentView()
    }
    
    func initVariables(){
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillAppear:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillDisappear:", name:UIKeyboardWillHideNotification, object: nil)
        imagePicker.delegate = self
        imageCountPerLine = Int((screenWidth - viewHorizonMargin * 2) / imageLength)
        
        headerHeight = UIApplication.sharedApplication().statusBarFrame.height + (self.navigationController?.navigationBar.frame.height)!
        tagList = haalthyService.getTopTagList()
        submitBtn.enabled = false
        submitBtn.setTitleColor(lightTextColor, forState: UIControlState.Normal)
        self.isQuestion = (self.navigationController as! AddPostNavigationViewController).isQuestion
    }
    
    func initContentView(){
        //text View
        textView.frame = CGRect(x: viewHorizonMargin, y: headerHeight + textViewVerticalMargin, width: screenWidth - 2 * viewHorizonMargin, height: textViewHeight)
        textView.textColor = ultraLightTextColor
        if self.isQuestion {
            textView.text = "请输入问题"
        }else{
            textView.text = "我的心情..."
        }
        textView.font = textViewFont
        textView.delegate = self
        self.view.addSubview(textView)
        
        //imageSection
        imageSection.frame = CGRect(x: viewHorizonMargin, y: imageSectionTopSpace + headerHeight, width: screenWidth - 2 * viewHorizonMargin, height: imageLength)
        defaultAddImageBtn.frame = CGRect(x: 0, y: 0, width: imageLength, height: imageLength)
        let defaultAddImageView = UIImageView(frame: CGRECT(0, 0, imageLength, imageLength))
        defaultAddImageView.image = UIImage(named: "btn_addImage")
        defaultAddImageBtn.addSubview(defaultAddImageView)
        defaultAddImageBtn.addTarget(self, action: "selectImages", forControlEvents: UIControlEvents.TouchUpInside)
        imageSection.addSubview(defaultAddImageBtn)
        self.view.addSubview(imageSection)
        
        //tag section
        tagSection.frame = CGRect(x: viewHorizonMargin, y: imageSection.frame.origin.y + imageSection.frame.height + tagSectionTopMargin, width: screenWidth - 2 * viewHorizonMargin, height: tagSectionHeight)
        let tagTitle = UILabel(frame: CGRect(x: 0, y: 0, width: screenWidth - 2 * viewHorizonMargin, height: 13))
        tagTitle.font = tagSectionTitleFont
        tagTitle.textColor = tagSectionTitleTextColor
        tagTitle.text = "请选择相关的标签，让更多人能看到你的问题"
        tagSection.addSubview(tagTitle)
        
        var tagBtnX: CGFloat = 0
        var tagBtnY: CGFloat = 24
        var displayTagCount: Int = 0
        for tag in tagList! {
            let tagName = (tag as! NSDictionary).objectForKey("name") as! String
            let tagTextSize = tagName.sizeWithFont(tagBtnFont, maxSize: CGSize(width: CGFloat.max, height: 13))
            if ((tagTextSize.width + tagSectionBtnTextHorizonMargin*2) + tagBtnX) > (screenWidth - viewHorizonMargin){
                tagBtnX = 0
                tagBtnY += 34
            }
            print(tagBtnY)
            if tagBtnY > 70{
                break
            }
            tagBtnX += tagTextSize.width + tagSectionBtnTextVerticalMargin * 2 + tagSectionBtnHorizonMargin
            displayTagCount++
        }
        displayTagCount--
        //var tagIndex = 0
        tagBtnX = 0
        tagBtnY = 24
        for var tagIndex = 0; tagIndex < displayTagCount; tagIndex++ {
            let tag: NSDictionary = tagList?.objectAtIndex(tagIndex) as! NSDictionary
            let tagName = tag.objectForKey("name") as! String
            let tagTextSize = tagName.sizeWithFont(tagBtnFont, maxSize: CGSize(width: CGFloat.max, height: 13))
            if ((tagTextSize.width + tagSectionBtnTextHorizonMargin*2) + tagBtnX) > (screenWidth - viewHorizonMargin){
                tagBtnX = 0
                tagBtnY += 34
            }
            let tagButton = UIButton(frame: CGRect(x: tagBtnX, y: tagBtnY, width: tagTextSize.width + tagSectionBtnTextVerticalMargin * 2, height: 29))
            tagButton.setTitle(tagName, forState: UIControlState.Normal)
            tagButton.setTitleColor(headerColor, forState: UIControlState.Normal)
            tagButton.titleLabel?.font = tagBtnFont
            tagButton.layer.borderColor = headerColor.CGColor
            tagButton.layer.borderWidth = 1
            tagButton.layer.cornerRadius = 2
            tagBtnX += tagButton.frame.width + tagSectionBtnHorizonMargin
            tagButton.addTarget(self, action: "selectedTag:", forControlEvents: UIControlEvents.TouchUpInside)
            tagSection.addSubview(tagButton)
        }
        
        if (self.navigationController as! AddPostNavigationViewController).isQuestion == true {
            //更多
            let tagTextSize = String("更多>").sizeWithFont(tagBtnFont, maxSize: CGSize(width: CGFloat.max, height: 13))
            let tagButton = UIButton(frame: CGRect(x: tagBtnX, y: tagBtnY, width: tagTextSize.width + tagSectionBtnTextVerticalMargin * 2, height: 29))
            tagButton.setTitle("更多>", forState: UIControlState.Normal)
            tagButton.setTitleColor(headerColor, forState: UIControlState.Normal)
            tagButton.titleLabel?.font = tagBtnFont
            tagButton.layer.borderColor = headerColor.CGColor
            tagButton.layer.borderWidth = 1
            tagButton.layer.cornerRadius = 2
            tagBtnX += tagButton.frame.width + tagSectionBtnHorizonMargin
            tagSection.addSubview(tagButton)
            self.view.addSubview(tagSection)
        }
        
        //ButtonSection
        buttomSection.frame = CGRECT(0, screenHeight - buttomSectionHeight, screenWidth, buttomSectionHeight)
        buttomSection.backgroundColor = buttomSectionColor
        let mentionedBtn = UIButton(frame: CGRECT(buttomSectionItemLeftSpace, 11, buttomItemIconLength, buttomItemIconLength))
        let mentionedImageView = UIImageView(frame: CGRECT(0, 0, buttomItemIconLength, buttomItemIconLength))
        mentionedImageView.image = UIImage(named: "btn_mentioned")
        mentionedBtn.addSubview(mentionedImageView)
        mentionedBtn.addTarget(self, action: "selectContacts", forControlEvents: UIControlEvents.TouchUpInside)
        buttomSection.addSubview(mentionedBtn)
        self.view.addSubview(buttomSection)
    }
    
    func keyboardWillAppear(notification: NSNotification) {
        
        if self.buttomSection.center.y > UIScreen.mainScreen().bounds.height - 50{
            // 获取键盘信息
            let keyboardinfo = notification.userInfo![UIKeyboardFrameBeginUserInfoKey]
            
            keyboardheight = (keyboardinfo?.CGRectValue.size.height)!
            
            self.buttomSection.center = CGPoint(x: self.buttomSection.center.x, y: self.buttomSection.center.y - keyboardheight)
        }
    }
    
    func keyboardWillDisappear(notification:NSNotification){
        
        self.buttomSection.center = CGPoint(x: self.buttomSection.center.x, y: self.buttomSection.center.y + keyboardheight)
    }

    @IBAction func cancel(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func selectImages(){
        imagePicker.allowsEditing = false //2
        imagePicker.sourceType = .PhotoLibrary //3
        presentViewController(imagePicker, animated: true, completion: nil)//4
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        var chosenImage = info[UIImagePickerControllerOriginalImage] as! UIImage //2
        //        insertImageList.addObject(chosenImage)
        chosenImage = publicService.resizeImage(chosenImage, newSize: uploadImageSize)
        let imageData: NSData = UIImagePNGRepresentation(chosenImage)!
        //        println(selectedImage.size.width, selectedImage.size.height)
        let imageDataStr = imageData.base64EncodedStringWithOptions([])
        let imageInfo = NSDictionary(objects: [imageDataStr, "jpg"], forKeys: ["data", "type"])
        
        self.imageInfoList.addObject(imageInfo)
        let addNextImageLinePositionY: CGFloat = CGFloat(Int((imageInfoList.count)/imageCountPerLine)) * (imageLength + imageMargin)

        let coordinateX = CGFloat(imageLength+imageMargin)*CGFloat((imageInfoList.count)%imageCountPerLine)
        let imageViewContainer = UIView(frame: CGRectMake(defaultAddImageBtn.frame.origin.x, defaultAddImageBtn.frame.origin.y, imageLength, imageLength))
        let imageView = UIImageView(frame: CGRectMake(0, 0, imageLength, imageLength))
        
        let imageDeleteBtn = UIButton(frame: CGRECT(imageLength - imageDeleteBtnLength, 0, imageDeleteBtnLength, imageDeleteBtnLength))
        let imageDeleteView = UIImageView(frame: CGRECT(0, 0, imageDeleteBtnLength, imageDeleteBtnLength))
        imageDeleteView.image = UIImage(named: "btn_imageDelete")
        imageDeleteBtn.addSubview(imageDeleteView)
        imageDeleteBtn.addTarget(self, action: "deleteImage:", forControlEvents: UIControlEvents.TouchUpInside)
        
        defaultAddImageBtn.frame = CGRectMake(coordinateX, addNextImageLinePositionY, imageLength, imageLength)
        
        imageSection.frame = CGRECT(imageSection.frame.origin.x, imageSection.frame.origin.y, imageSection.frame.width, imageSection.frame.height + imageLength + imageMargin)

        
        var selectedImage = UIImage()
        selectedImage = publicService.cropToSquare(image: chosenImage)
        
        let newSize = CGSizeMake(imageLength, imageLength)
        UIGraphicsBeginImageContext(newSize)
        selectedImage.drawInRect(CGRectMake(0, 0, newSize.width, newSize.height))
        imageView.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        self.imageSection.addSubview(imageViewContainer)
        imageViewContainer.addSubview(imageView)
        imageViewContainer.addSubview(imageDeleteBtn)
        if (imageInfoList.count + 1)%imageCountPerLine == 1 {
            if isQuestion == true {
                self.tagSection.center = CGPoint(x: self.tagSection.center.x, y: self.tagSection.center.y + imageLength + imageMargin)
            }
        }
        dismissViewControllerAnimated(true, completion: nil) //5
        
    }
    

    
    func deleteImage(sender: UIButton){
        let imageIndex: Int = getImageIndexByImageCenter(sender.superview!.center)
        self.imageInfoList.removeObjectAtIndex(imageIndex - 1)
        redrawImageInfo()
    }
    
    func getImageIndexByImageCenter(centerPoint: CGPoint) -> Int{
        let indexX: Int = Int(centerPoint.x / (imageLength + imageMargin)) + 1
        let indexY: Int = Int(centerPoint.y / (imageLength + imageMargin))
        return indexY * imageCountPerLine + indexX
    }
    
    func redrawImageInfo(){
        for subView in imageSection.subviews {
            if (subView is UIButton) == false {
                subView.removeFromSuperview()
            }
        }
        var imageIndex: Int = 0
        for imageInfo in imageInfoList{
            let coordinateX: CGFloat = CGFloat(imageIndex % imageCountPerLine) * (imageLength + imageMargin)
            let coordinateY: CGFloat = CGFloat(imageIndex / imageCountPerLine) * (imageLength + imageMargin)
            
            let imageViewContainer = UIView(frame: CGRectMake(coordinateX, coordinateY, imageLength, imageLength))
            let imageView = UIImageView(frame: CGRectMake(0, 0, imageLength, imageLength))
            
            let imageDeleteBtn = UIButton(frame: CGRECT(imageLength - imageDeleteBtnLength, 0, imageDeleteBtnLength, imageDeleteBtnLength))
            let imageDeleteView = UIImageView(frame: CGRECT(0, 0, imageDeleteBtnLength, imageDeleteBtnLength))
            imageDeleteView.image = UIImage(named: "btn_imageDelete")
            imageDeleteBtn.addSubview(imageDeleteView)
            imageDeleteBtn.addTarget(self, action: "deleteImage:", forControlEvents: UIControlEvents.TouchUpInside)
            
            let publicService = PublicService()
            
            let image = UIImage(data: NSData(base64EncodedString: (imageInfo as! NSDictionary).objectForKey("data") as! String, options: NSDataBase64DecodingOptions(rawValue: 0))!)
            
            let selectedImage = publicService.cropToSquare(image: image!)
            
            let newSize = CGSizeMake(imageLength, imageLength)
            UIGraphicsBeginImageContext(newSize)
            selectedImage.drawInRect(CGRectMake(0, 0, newSize.width, newSize.height))
            imageView.image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            self.imageSection.addSubview(imageViewContainer)
            imageViewContainer.addSubview(imageView)
            imageViewContainer.addSubview(imageDeleteBtn)
            imageIndex++
        }
        
        defaultAddImageBtn.frame = CGRectMake(CGFloat((imageInfoList.count) % imageCountPerLine) * (imageLength + imageMargin), CGFloat((imageInfoList.count) / imageCountPerLine) * (imageLength + imageMargin), imageLength, imageLength)
        
        let imageSectionH: CGFloat = CGFloat(imageIndex / imageCountPerLine + 1) * (imageLength + imageMargin)
        
        imageSection.frame = CGRECT(viewHorizonMargin, imageSectionTopSpace + headerHeight, screenWidth - 2 * viewHorizonMargin, imageSectionH)
        
        if isQuestion == true {
            self.tagSection.frame = CGRECT(tagSection.frame.origin.x, imageSection.frame.origin.y + imageSection.frame.height, tagSection.frame.width, tagSection.frame.height)
        }
    }

    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func selectedTag(sender:UIButton){
        if sender.backgroundColor == headerColor {
            sender.backgroundColor = UIColor.whiteColor()
            sender.setTitleColor(headerColor, forState: UIControlState.Normal)
            selectTagLabel.removeObject((sender.titleLabel?.text!)!)
        }else {
            sender.backgroundColor = headerColor
            sender.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
            selectTagLabel.addObject((sender.titleLabel?.text!)!)
        }
    }
    
    @IBAction func submit(sender: UIButton) {
//        let testview = UIView(frame: CGRECT(100, 100, 300, 300))
//        testview.backgroundColor = UIColor.redColor()
//        self.view.addSubview(testview)
        if((self.isQuestion == false) || ((self.isQuestion == true)&&(self.selectTagLabel.count>0))){
            let post = NSMutableDictionary()
            post.setObject(textView.text, forKey: "body")
            post.setObject(0, forKey: "closed")
            if self.isQuestion {
                post.setObject(1, forKey: "isBroadcast")
            }else{
                post.setObject(0, forKey: "isBroadcast")
            }
            post.setObject("TXT", forKey: "type")
            post.setObject(keychainAccess.getPasscode(usernameKeyChain)!, forKey: "insertUsername")
            //get mentioned user List
            let postContentStr = textView.text
            let firstRange = postContentStr.rangeOfString("@")

//            if self.progressHUD == nil {
//                
//                self.progressHUD = MBProgressHUD.init(view: self.textView)
//            }
//            self.textView.addSubview(self.progressHUD!)
//            self.progressHUD?.labelText = title
//            self.progressHUD?.show(true)

            if firstRange != nil {
                let postContentArr = postContentStr.substringFromIndex((firstRange!).startIndex).componentsSeparatedByString("@")
                for subStr in postContentArr{
                    if (subStr as NSString).length > 0{
                        var subStrArr = (subStr ).componentsSeparatedByString(" ")
                        if (subStrArr.count > 0) && (subStrArr[0] as NSString).length > 0{
                            let getMentionedUsernamesRequest = NSMutableDictionary()
                            getMentionedUsernamesRequest.setObject(keychainAccess.getPasscode(usernameKeyChain)!, forKey: "username")
                            getMentionedUsernamesRequest.setObject(subStrArr[0], forKey: "mentionedDisplayname")
                            let mentionedUsers = haalthyService.getUsersByDisplayname(getMentionedUsernamesRequest)
                            for user in mentionedUsers{
                                mentionUsernameList.addObject(user.objectForKey("username")!)
                            }
                        }
                    }
                }
                
                if mentionUsernameList.count > 0 {
                    post.setObject(self.mentionUsernameList, forKey: "mentionUsers")
                }
            }
            post.setObject(self.imageInfoList, forKey: "imageInfos")
            if(self.isQuestion == true){
                post.setObject(self.getSelectedTagList(), forKey: "tags")
            }
            let result:Int = haalthyService.addPost(post as NSDictionary)
            
//            self.progressHUD?.removeFromSuperview()
            self.dismissViewControllerAnimated(false, completion: nil)
        }else{
            let storyboard = UIStoryboard(name: "Registeration", bundle: nil)
            let tagViewController = storyboard.instantiateViewControllerWithIdentifier("TagEntry") as! TagTableViewController
            tagViewController.isBroadcastTagSelection = 1
            self.presentViewController(tagViewController, animated: true, completion: nil)
        }
    }
    
    func getSelectedTagList()->NSArray{
        let selectedTagList = NSMutableArray()
        for tag in tagList! {
            if selectTagLabel.containsObject((tag as! NSDictionary).objectForKey("name") as! String){
                selectedTagList.addObject(tag)
            }
        }
        return selectedTagList
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        if textView.textColor != UIColor.blackColor() {
            textView.text = nil
            textView.textColor = UIColor.blackColor()
        }
        //        selectTagsButton.enabled = true
        submitBtn.enabled = true
        //        enableButtonFormat(selectTagsButton)
        submitBtn.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
    }
    
    func selectContacts(){
        self.performSegueWithIdentifier("contactSegue", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "selectTagSegue" {
            let tagViewController = segue.destinationViewController as! TagTableViewController
            //            tagViewController.postBody = postContent.text
            tagViewController.isBroadcastTagSelection = 1
//            tagViewController.postDelegate = self
        }
        
        if segue.identifier == "contactSegue" {
            let contactController = segue.destinationViewController as! ContactViewController
//            contactController.mentionDelegate = self
        }
    }
}

