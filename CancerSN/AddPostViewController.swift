//
//  AddPostViewController.swift
//  CancerSN
//
//  Created by lily on 8/4/15.
//  Copyright (c) 2015 lily. All rights reserved.
//

import UIKit

class AddPostViewController: UIViewController, PostTagVCDelegate, UITextViewDelegate {
    var isBroadcast : Int = 0
    var tagList: NSArray = NSArray()
    @IBOutlet weak var selectTagsButton: UIButton!
    @IBOutlet weak var tagListDisplay: UILabel!
    @IBOutlet weak var postContent: UITextView!
    @IBOutlet weak var sendButton: UIButton!

    @IBAction func selectTags(sender: UIButton) {
        self.performSegueWithIdentifier("selectTagSegue", sender: self)
    }
    
    @IBAction func cancel(sender: UIButton) {
        self.dismissViewControllerAnimated(false, completion: nil)
        self.performSegueWithIdentifier("selectTagSegue", sender: self)
    }
    
    @IBAction func submit(sender: UIButton) {
        if((self.isBroadcast == 0) || ((self.isBroadcast == 1)&&(self.tagList.count>0))){
            var post = NSMutableDictionary()
            post.setObject(postContent.text, forKey: "body")
            post.setObject(0, forKey: "closed")
            post.setObject(self.isBroadcast, forKey: "isBroadcast")
            post.setObject("TXT", forKey: "type")
            let haalthyService = HaalthyService()
            var respData:NSData
            if(self.isBroadcast == 0){
                respData = haalthyService.addPost(post as NSDictionary)
            }else{
                post.setObject(self.tagList, forKey: "tags")
                respData = haalthyService.addPost(post as NSDictionary)
            }
            let str: NSString = NSString(data: respData, encoding: NSUTF8StringEncoding)!
            println(str)
            self.dismissViewControllerAnimated(false, completion: nil)
        }else{
            self.performSegueWithIdentifier("selectTagSegue", sender: self)
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
//        sender.layer.borderColor = UIColor.lightGrayColor().CGColor
        sender.layer.borderWidth = 0
        sender.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        postContent.delegate = self
        if self.isBroadcast == 1 {
            postContent.text = "请在此输入广播消息"
            selectTagsButton.enabled = false
        }else{
            postContent.text = "在此分享我的心情"
        }
        postContent.textColor = UIColor.grayColor()
        sendButton.enabled = false
        sendButton.layer.cornerRadius = 5
        sendButton.layer.masksToBounds = true
        selectTagsButton.layer.cornerRadius = 5
        selectTagsButton.layer.masksToBounds = true
        disableButtonFormat(selectTagsButton)
        disableButtonFormat(sendButton)
    }
    
    override func viewWillAppear(animated: Bool) {
        if(self.isBroadcast == 1){
            selectTagsButton.hidden = false
            tagListDisplay.hidden = false
        }else{
            selectTagsButton.hidden = true
            tagListDisplay.hidden = true
        }
        var tagListStr:String = ""
        for tagItem in tagList{
            var tag = tagItem as! NSDictionary
            tagListStr += tag.objectForKey("name") as! String + ","
        }
        tagListDisplay.text = tagListStr
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "selectTagSegue" {
            var tagViewController = segue.destinationViewController as! TagViewController
            tagViewController.postBody = postContent.text
            tagViewController.isBroadcastTagSelection = 1
            tagViewController.postDelegate = self
        }
    }
    
    func getPostTagList(data: NSArray) {
        self.tagList = data
        
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        if textView.textColor != UIColor.blackColor() {
            textView.text = nil
            textView.textColor = UIColor.blackColor()
        }
        selectTagsButton.enabled = true
        sendButton.enabled = true
        enableButtonFormat(selectTagsButton)
        enableButtonFormat(sendButton)
    }
}

