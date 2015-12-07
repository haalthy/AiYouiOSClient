//
//  AddPostViewController.swift
//  CancerSN
//
//  Created by lily on 8/4/15.
//  Copyright (c) 2015 lily. All rights reserved.
//

import UIKit

class AddPostViewController: UIViewController, PostTagVCDelegate, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, MentionVCDelegate {
    var isComment:Int = 0
    var postID: Int? = nil
    var isBroadcast: Int = 0
    var tagList = NSMutableArray()
    @IBOutlet weak var selectTagsButton: UIButton!
    @IBOutlet weak var tagListDisplay: UILabel!
    @IBOutlet weak var postContent: UITextView!
    @IBOutlet weak var sendButton: UIButton!
    var addTagBtn = UIButton()
    var addImageBtn = UIButton()
    var addMentionBtn = UIButton()
    var suggestTagView = UIView()
    var tagListLabel = UILabel()
    var imagePicker = UIImagePickerController()
    var insertImageList = NSMutableArray()
    var addNextImageLinePositionY:CGFloat = 290
    var imageHeight:CGFloat = 0
    var mentionUsernameList = NSMutableArray()
    let haalthyService = HaalthyService()
    var allTagList = NSArray()
    var keychainAccess = KeychainAccess()

//    @IBAction func testButton(sender: UIButton) {
////        self.postContent.frame.size.height = 50
//        self.addMentionBtn.center = CGPoint(x: self.addMentionBtn.center.x + 10, y: self.addMentionBtn.center.y + 10 )
//    }
    
//    @IBAction func selectTags(sender: UIButton) {
//        self.performSegueWithIdentifier("selectTagSegue", sender: self)
//    }
    
    @IBAction func cancel(sender: UIButton) {
        self.dismissViewControllerAnimated(false, completion: nil)
//        self.performSegueWithIdentifier("selectTagSegue", sender: self)
    }
    
    @IBAction func submit(sender: UIButton) {
        if self.isComment == 1{
            haalthyService.addComment(postID!, body: self.postContent.text!)
            self.dismissViewControllerAnimated(false, completion: nil)
        }else if((self.isBroadcast == 0) || ((self.isBroadcast == 1)&&(self.tagList.count>0))){
            let post = NSMutableDictionary()
            post.setObject(postContent.text, forKey: "body")
            post.setObject(0, forKey: "closed")
            post.setObject(self.isBroadcast, forKey: "isBroadcast")
            post.setObject("TXT", forKey: "type")
            post.setObject(keychainAccess.getPasscode(usernameKeyChain)!, forKey: "insertUsername")
            var respData:NSData
            if(self.isBroadcast == 0){
                respData = haalthyService.addPost(post as NSDictionary)
            }else{
                post.setObject(self.tagList, forKey: "tags")
                let postContentStr = postContent.text
                let firstRange = postContentStr.rangeOfString("@")
                if firstRange != nil {
                    let postContentArr = postContentStr.substringFromIndex((firstRange!).startIndex).componentsSeparatedByString("@")
                    for subStr in postContentArr{
                        if (subStr as NSString).length > 0{
                            var subStrArr = (subStr ).componentsSeparatedByString(" ")
                            if (subStrArr.count > 0) && (subStrArr[0] as NSString).length > 0{
                                mentionUsernameList.addObject(subStrArr[0])
                            }
                        }
                    }
                    
                    if mentionUsernameList.count > 0 {
                        post.setObject(self.mentionUsernameList, forKey: "mentionUsers")
                    }
                }
                post.setObject(self.insertImageList, forKey: "images")
                respData = haalthyService.addPost(post as NSDictionary)
            }
            let str: NSString = NSString(data: respData, encoding: NSUTF8StringEncoding)!
            print(str)
            self.dismissViewControllerAnimated(false, completion: nil)
        }else{
//            self.performSegueWithIdentifier("selectTagSegue", sender: self)
            let storyboard = UIStoryboard(name: "Registeration", bundle: nil)
            let tagViewController = storyboard.instantiateViewControllerWithIdentifier("TagEntry") as! TagTableViewController
            tagViewController.isBroadcastTagSelection = 1
            tagViewController.postDelegate = self
            self.presentViewController(tagViewController, animated: true, completion: nil)
        }
    }
    
    func disableButtonFormat(sender: UIButton){
        sender.backgroundColor = UIColor.whiteColor()
        sender.layer.borderColor = UIColor.lightGrayColor().CGColor
        sender.layer.borderWidth = 1
        sender.setTitleColor(UIColor.lightGrayColor(), forState: UIControlState.Highlighted)
    }
    
    func enableButtonFormat(sender: UIButton){
        sender.backgroundColor = mainColor
        sender.layer.borderWidth = 0
        sender.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        postContent.delegate = self
        if isComment == 1{
            postContent.text = "添加评论"
        }else{
            if self.isBroadcast == 1 {
                postContent.text = "请在此输入广播消息"
            }else{
                postContent.text = "在此分享心情"
            }
        }
        imageHeight = (UIScreen.mainScreen().bounds.width - 35)/4
        postContent.textColor = UIColor.grayColor()
        sendButton.enabled = false
        sendButton.layer.cornerRadius = 5
        sendButton.layer.masksToBounds = true

        disableButtonFormat(sendButton)
        self.view.addSubview(tagListLabel)
        
        self.addImageBtn = UIButton(frame: CGRectMake(10 + 55 * 0, addNextImageLinePositionY, 50, 40))
        self.addMentionBtn = UIButton(frame: CGRectMake(10 + 55 * 1, addNextImageLinePositionY, 50, 40))
        if isBroadcast == 1{
            //            self.addTagBtn = UIButton(frame: CGRectMake(10 + 55 * 2, addNextImageLinePositionY, 50, 40))
            //            initButtonItem(addTagBtn, labelTitle: "Tag", targetAction: "selectTags")
            //            initButtonItem(addTagBtn, labelTitle: "Tag", targetAction: nil)
            let getTagListRespData:NSData = haalthyService.getTagList()!
            let jsonResult = try? NSJSONSerialization.JSONObjectWithData(getTagListRespData, options: NSJSONReadingOptions.MutableContainers)
            if(jsonResult is NSArray){
                self.allTagList = jsonResult as! NSArray
            }
            if allTagList.count > 0{
                
                self.suggestTagView = UIView(frame: CGRectMake(10, addNextImageLinePositionY + 50, UIScreen.mainScreen().bounds.width - 20, 100))
                self.suggestTagView.backgroundColor = sectionHeaderColor
                self.view.addSubview(suggestTagView)
                let suggestTagLabel = UILabel(frame: CGRectMake(10, 10, 250, 20))
                suggestTagLabel.text = "请选择您的标签，更多人能看到您的问题"
                suggestTagLabel.font = UIFont(name: "Helvetica", size: 12.0)
                suggestTagView.addSubview(suggestTagLabel)
                
                let maxDisplayCount = allTagList.count > 10 ? 10: allTagList.count
                let tagHeight:CGFloat = 35
                let tagWith = ((self.suggestTagView.frame.width - 3)/5 - 3)
                var i: Int = 0
                while i < maxDisplayCount{
                    var coordinateX: CGFloat?
                    var coordinateY: CGFloat?
                    if i < 5 {
                        coordinateY = 28
                    }else{
                        coordinateY = 63
                    }
                    coordinateX = CGFloat(i%5) * tagWith + 10
                    let displayTagButton = UIButton(frame: CGRectMake(coordinateX!, coordinateY!, tagWith - 3, tagHeight-3))
//                    tagLable.text = (allTagList[i] as! NSDictionary).objectForKey("name") as! String
                    if (i == 9) && (allTagList.count>10){
                        displayTagButton.setTitle("更多...", forState: UIControlState.Normal)
                    }else{
                        displayTagButton.setTitle((allTagList[i] as! NSDictionary).objectForKey("name") as! String, forState: UIControlState.Normal)
                    }
                    displayTagButton.titleLabel!.font = UIFont(name: "Helvetica", size: 12.0)
                    displayTagButton.setTitleColor(mainColor, forState: UIControlState.Normal)
                    displayTagButton.backgroundColor = UIColor.whiteColor()
                    displayTagButton.layer.borderColor = mainColor.CGColor
                    displayTagButton.layer.borderWidth = 1.0
                    displayTagButton.layer.cornerRadius = 5.0
                    displayTagButton.layer.masksToBounds = true
                    displayTagButton.titleLabel!.textAlignment = NSTextAlignment.Center
                    if (i == 9) && (allTagList.count>10){
                        displayTagButton.addTarget(self, action: "displayMoreTags", forControlEvents: UIControlEvents.TouchUpInside)
                    }else{
                        displayTagButton.addTarget(self, action: "selectTag:", forControlEvents: UIControlEvents.TouchUpInside)
                    }
                    i++
                    self.suggestTagView.addSubview(displayTagButton)
                }
            }
        }
        if isComment == 0{
            initButtonItem(addImageBtn, labelTitle: "Image", targetAction: "selectImages")
            initButtonItem(addMentionBtn, labelTitle: "@", targetAction: "selectContacts")
        }
    }
    
    func selectImages(){
        imagePicker.allowsEditing = false //2
        imagePicker.sourceType = .PhotoLibrary //3
        presentViewController(imagePicker, animated: true, completion: nil)//4
    }
    
    func selectContacts(){
        self.performSegueWithIdentifier("contactSegue", sender: self)
    }
    
    func displayMoreTags(){
//        self.performSegueWithIdentifier("selectTagSegue", sender: self)
        let storyboard = UIStoryboard(name: "Registeration", bundle: nil)
        let tagViewController = storyboard.instantiateViewControllerWithIdentifier("TagEntry") as! TagTableViewController
        tagViewController.isBroadcastTagSelection = 1
        tagViewController.postDelegate = self
        self.presentViewController(tagViewController, animated: true, completion: nil)
    }
    
    func selectTag(sender:UIButton){
        var index: Int = 0
        let maxDisplayCount = allTagList.count > 10 ? 9: allTagList.count
        while index < maxDisplayCount{
            if (allTagList[index].objectForKey("name") as! String) == (sender.titleLabel!).text!{
                break
            }
            index++
        }
        sender.backgroundColor = mainColor
        sender.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        self.tagList.addObject(allTagList[index])
    }
    
    func initButtonItem(sender: UIButton, labelTitle: String, targetAction: Selector){
        sender.setTitle(labelTitle, forState: UIControlState.Normal)
        sender.addTarget(self, action: targetAction, forControlEvents: UIControlEvents.TouchUpInside)
        sender.setTitleColor(mainColor, forState: UIControlState.Normal)
        sender.titleLabel?.font = UIFont(name: "Helvetica", size: 13.0)
        sender.layer.borderWidth = 1.0
        sender.layer.borderColor = mainColor.CGColor
        sender.backgroundColor = UIColor.whiteColor()
        sender.layer.cornerRadius = 5
        sender.layer.masksToBounds = true
        self.view.addSubview(sender)
    }
    
    override func viewWillAppear(animated: Bool) {
        if(self.isBroadcast == 1){
//            selectTagsButton.hidden = false
//            tagListDisplay.hidden = false
        }else{
//            selectTagsButton.hidden = true
//            tagListDisplay.hidden = true
        }
        var tagListStr:String = ""
        if tagList.count > 0 {
            for tagItem in tagList{
                let tag = tagItem as! NSDictionary
                tagListStr += tag.objectForKey("name") as! String + ","
            }
            var tagListCoordinateY:CGFloat = 0
            if insertImageList.count == 0 {
                tagListCoordinateY = addNextImageLinePositionY
            }else{
                tagListCoordinateY = CGFloat((insertImageList.count-1)/4 + 1)*imageHeight + 290
            }
            tagListLabel.frame = CGRectMake(10, tagListCoordinateY, UIScreen.mainScreen().bounds.width - 20, 40)
            tagListLabel.font = UIFont(name: "Helvetica", size: 13.0)
            tagListLabel.text = tagListStr
            self.addMentionBtn.center = CGPoint(x: self.addMentionBtn.center.x, y: tagListCoordinateY + 60 )
            self.addImageBtn.center = CGPoint(x: self.addImageBtn.center.x, y: tagListCoordinateY + 60 )
            if isBroadcast == 1 {
                self.addTagBtn.center = CGPoint(x: self.addTagBtn.center.x, y: tagListCoordinateY + 60 )
                self.suggestTagView.center = CGPoint(x: self.suggestTagView.center.x, y: self.addImageBtn.center.y + 80)
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "selectTagSegue" {
            let tagViewController = segue.destinationViewController as! TagTableViewController
//            tagViewController.postBody = postContent.text
            tagViewController.isBroadcastTagSelection = 1
            tagViewController.postDelegate = self
        }
        
        if segue.identifier == "contactSegue" {
            let contactController = segue.destinationViewController as! ContactViewController
            contactController.mentionDelegate = self
        }
    }
    
    func getPostTagList(data: NSArray) {
        self.tagList =  data.mutableCopy() as! NSMutableArray
        
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        if textView.textColor != UIColor.blackColor() {
            textView.text = nil
            textView.textColor = UIColor.blackColor()
        }
//        selectTagsButton.enabled = true
        sendButton.enabled = true
//        enableButtonFormat(selectTagsButton)
        enableButtonFormat(sendButton)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        let chosenImage = info[UIImagePickerControllerOriginalImage] as! UIImage //2
//        insertImageList.addObject(chosenImage)
        
        let imageData: NSData = UIImagePNGRepresentation(chosenImage)!
//        println(selectedImage.size.width, selectedImage.size.height)
        let imageDataStr = imageData.base64EncodedStringWithOptions([])
        insertImageList.addObject(imageDataStr)
        
        if (insertImageList.count%4 == 1) && insertImageList.count != 1 {
            self.addNextImageLinePositionY += self.imageHeight + 10
        }
        
        let coordinateX = CGFloat(imageHeight+5)*CGFloat((insertImageList.count - 1)%4)+5
        let imageView = UIImageView(frame: CGRectMake(coordinateX, addNextImageLinePositionY, imageHeight, imageHeight))
        let publicService = PublicService()
        
        var selectedImage = UIImage()
        selectedImage = publicService.cropToSquare(image: chosenImage)
        
        let newSize = CGSizeMake(imageHeight, imageHeight)
        UIGraphicsBeginImageContext(newSize)
        selectedImage.drawInRect(CGRectMake(0, 0, newSize.width, newSize.height))
        imageView.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        self.view.addSubview(imageView)
        if insertImageList.count%4 == 1 {
            self.addMentionBtn.center = CGPoint(x: self.addMentionBtn.center.x, y: self.addMentionBtn.center.y + imageHeight + 5 )
            self.addImageBtn.center = CGPoint(x: self.addImageBtn.center.x, y: self.addImageBtn.center.y + imageHeight + 5 )
            if isBroadcast == 1 {
                self.addTagBtn.center = CGPoint(x: self.addTagBtn.center.x, y: self.addTagBtn.center.y + imageHeight + 5 )
            }
        }
        self.suggestTagView.center = CGPoint(x: self.suggestTagView.center.x, y: self.addImageBtn.center.y + 80)
        dismissViewControllerAnimated(true, completion: nil) //5
        
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func updateMentionList(username: String){
//        mentionUsernameList.addObject(username)
        if postContent.textColor != UIColor.blackColor() {
            postContent.text = nil
            postContent.textColor = UIColor.blackColor()
        }
        postContent.text = postContent.text + " @" + username + " "
    }
}
