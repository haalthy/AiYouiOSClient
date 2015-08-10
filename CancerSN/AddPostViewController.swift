//
//  AddPostViewController.swift
//  CancerSN
//
//  Created by lily on 8/4/15.
//  Copyright (c) 2015 lily. All rights reserved.
//

import UIKit

class AddPostViewController: UIViewController, PostTagVCDelegate {
    var isBroadcast : Int = 0
    var tagList: NSArray = NSArray()
    @IBOutlet weak var selectTagsButton: UIButton!
    @IBOutlet weak var tagListDisplay: UILabel!
    @IBOutlet weak var postContent: UITextView!

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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
}

