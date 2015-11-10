//
//  TagTableViewController.swift
//  CancerSN
//
//  Created by lily on 9/24/15.
//  Copyright (c) 2015 lily. All rights reserved.
//

import UIKit

protocol UserTagVCDelegate {
    func updateUserTagList(data: NSArray)
}

protocol PostTagVCDelegate{
    func getPostTagList(data: NSArray)
}

class TagTableViewController: UITableViewController {
    var userTagDelegate: UserTagVCDelegate?
    var postDelegate: PostTagVCDelegate?

    var haalthyService = HaalthyService()
    var publicService = PublicService()
    var keychain = KeychainAccess()
    var isBroadcastTagSelection = 0
    var selectedTags = NSMutableArray()
    var selectedTagsStr = NSMutableSet()
    var tagList = NSArray()
    var tagTypeList = NSArray()
    var groupedTagList = NSMutableArray()
    var rowHightForTagContainer = NSMutableArray()
    var isFirstTagSelection = false

    @IBAction func cancel(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func submit(sender: UIButton) {
        selectedTags.removeAllObjects()
        for var index = 0; index < tagList.count; ++index{
            if selectedTagsStr.containsObject((tagList[index] as! NSDictionary).objectForKey("name") as! String){
                selectedTags.addObject(tagList[index])
            }
        }
        if isBroadcastTagSelection == 0 {
            NSUserDefaults.standardUserDefaults().setObject(selectedTags, forKey: favTagsNSUserData)
            if(keychain.getPasscode(usernameKeyChain) != nil && keychain.getPasscode(passwordKeyChain) != nil && (keychain.getPasscode(usernameKeyChain) as! String) != ""){
                var updateUserTagsRespData = haalthyService.updateUserTag(selectedTags)
            }
            userTagDelegate?.updateUserTagList(selectedTags)
            if isFirstTagSelection {
                self.performSegueWithIdentifier("homeSegue", sender: self)
            }else{
                self.dismissViewControllerAnimated(true, completion: nil)
            }
        }else{
            self.postDelegate?.getPostTagList(self.selectedTags)
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var getTagListRespData:NSData? = haalthyService.getTagList()
        if getTagListRespData != nil{
            var jsonResult = NSJSONSerialization.JSONObjectWithData(getTagListRespData!, options: NSJSONReadingOptions.MutableContainers, error: nil)
            if(jsonResult is NSArray){
                tagList = jsonResult as! NSArray
                var tagTypeSet = NSMutableSet()
                
                for tagItem in tagList{
                    var tag = tagItem as! NSDictionary
                    //                var groupedTagListItem = NSMutableArray()
                    //                var tagTypeItem = NSMutableDictionary()
                    //                tagTypeItem.setObject(tag.objectForKey("TypeRank")!, forKey: "TypeRank")
                    //                tagTypeItem.setObject(tag.objectForKey("TypeName")!, forKey: "TypeName")
                    var groupedTagsItem = NSMutableDictionary()
                    if tagTypeSet.containsObject(tag.objectForKey("typeName")!){
                        for groupedTag in groupedTagList{
                            var groupedTagItem = groupedTag as! NSMutableDictionary
                            if (groupedTagItem.objectForKey("typeName") as! String) == (tag.objectForKey("typeName") as! String){
                                var tagListsInGroup = NSMutableArray(array: groupedTagItem.objectForKey("tagsInGroup") as! NSArray)
                                tagListsInGroup.addObject(tag)
                                groupedTagItem.setObject(tagListsInGroup, forKey: "tagsInGroup")
                                break
                            }
                        }
                    }else {
                        tagTypeSet.addObject(tag.objectForKey("typeName")!)
                        var groupedTagItem = NSMutableDictionary()
                        groupedTagItem.setObject(tag.objectForKey("typeName")!, forKey: "typeName")
                        groupedTagItem.setObject(tag.objectForKey("typeRank")!, forKey: "typeRank")
                        groupedTagItem.setObject(NSArray(array: [tag]), forKey: "tagsInGroup")
                        groupedTagList.addObject(groupedTagItem)
                    }
                }
                tagTypeList = NSArray(array: tagTypeSet.allObjects)
                var descriptor: NSSortDescriptor = NSSortDescriptor(key: "typeRank", ascending: true)
                groupedTagList = NSMutableArray(array: groupedTagList.sortedArrayUsingDescriptors([descriptor]))
            }
            
            for groupedTag in groupedTagList {
                if groupedTag.objectForKey("tagsInGroup")!.count <= 5{
                    rowHightForTagContainer.addObject(40)
                }else{
                    rowHightForTagContainer.addObject(80)
                }
            }
            
            if (selectedTagsStr.count == 0) && (isBroadcastTagSelection == 0) && (isFirstTagSelection == false){
                if (keychain.getPasscode(usernameKeyChain) != nil)  {
                    var getUserFavTagsData: NSData? = haalthyService.getUserFavTags()
                    if getUserFavTagsData != nil{
                        var jsonResult = NSJSONSerialization.JSONObjectWithData(getUserFavTagsData!, options: NSJSONReadingOptions.MutableContainers, error: nil)
                        selectedTags = jsonResult as! NSMutableArray
                    }
                }else{
                    selectedTags = NSUserDefaults.standardUserDefaults().objectForKey(favTagsNSUserData) as! NSMutableArray
                }
                for favTag in selectedTags{
                    selectedTagsStr.addObject(favTag.objectForKey("name") as! String)
                }
            }
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return tagTypeList.count + 2
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var numberOfRows = 1
//        if section > 0 && section < tagTypeList.count + 1{
//            var groupIndex:Int = section - 1
//            numberOfRows = ((groupedTagList[groupIndex] as! NSDictionary).objectForKey("tagsInGroup"))!.count
//        }
        return numberOfRows
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0{
            
            let cell = tableView.dequeueReusableCellWithIdentifier("tagHeaderCell", forIndexPath: indexPath) as! TagHeaderTableViewCell
            if isBroadcastTagSelection == 1{
                cell.header.text = "请选择发布问题的标签"
                cell.cancelBtn.hidden = true
            }else{
                cell.cancelBtn.hidden = false
                cell.header.text = "请选择您关注的标签"
            }
            cell.header.textColor = textColor
            return cell
            
        } else if (indexPath.section == tagTypeList.count+1){
            let cell = tableView.dequeueReusableCellWithIdentifier("submitCell", forIndexPath: indexPath) as! UITableViewCell
            return cell
        }
        else{
            let cell = tableView.dequeueReusableCellWithIdentifier("tagContainerCell", forIndexPath: indexPath) as! UITableViewCell
            var groupedTagsInType = (groupedTagList[indexPath.section - 1] as! NSDictionary).objectForKey("tagsInGroup") as! NSArray
            var index: Int = 0
            var tagButtonHeight: CGFloat = 30
            var tagButtonWidth: CGFloat = (cell.frame.width - 20)/5 - 5
            for tag in groupedTagsInType {
                var tagItem = tag as! NSDictionary
                var coordinateX = 10 + CGFloat(index%5) * (tagButtonWidth + 5)
                var coordinateY:CGFloat = 5
                if index >= 5 {
                    coordinateY = 40
                }
                var tagButton = UIButton(frame: CGRectMake(coordinateX, coordinateY, tagButtonWidth, tagButtonHeight))
//                tagButton.setTitle(((tag as! NSDictionary).objectForKey("name") as! String), forState: UIControlState.Normal)
//                tagButton.setTitleColor(mainColor, forState: UIControlState.Normal)
                cell.addSubview(tagButton)
                publicService.formatButton(tagButton, title: tagItem.objectForKey("name") as! String)
                tagButton.titleLabel?.font = UIFont(name: fontStr, size: 12.0)
                index++
                if selectedTagsStr.containsObject(tagItem.objectForKey("name") as! String){
                    tagButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
                    tagButton.backgroundColor = mainColor
                }
                tagButton.addTarget(self, action: Selector("addSelectedTags:") , forControlEvents: UIControlEvents.TouchUpInside)
            }
        return cell
        }
    }
    
    func addSelectedTags(sender: UIButton){
        if sender.backgroundColor == UIColor.whiteColor() {
            sender.backgroundColor = mainColor
            sender.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
            selectedTagsStr.addObject((sender.titleLabel?.text)!)
        }else{
            sender.backgroundColor = UIColor.whiteColor()
            sender.setTitleColor(mainColor, forState: UIControlState.Normal)
            selectedTagsStr.removeObject((sender.titleLabel?.text)!)
        }
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        var heightForHeader:CGFloat = 0
        if section > 0 && section < tagTypeList.count + 1{
            heightForHeader = 50
        }
        return heightForHeader
    }

    override func tableView (tableView:UITableView,  viewForHeaderInSection section:Int)->UIView {
        var headerView = UIView()
        if section > 0 && section < tagTypeList.count + 1{
            headerView =  UIView(frame: CGRectMake(0, 0,self.tableView.bounds.size.width, 40))
//            headerView.backgroundColor = sectionHeaderColor
            var tagTypeLabel = UILabel(frame: CGRectMake(15, 10, self.tableView.bounds.size.width - 30, 30))
            tagTypeLabel.text = (groupedTagList[section-1] as! NSDictionary).objectForKey("typeName") as! String
            tagTypeLabel.textColor = mainColor
            tagTypeLabel.font = UIFont(name: fontStr, size: 15.0)
            headerView.addSubview(tagTypeLabel)
        }
        return headerView
    }
    
    override func tableView(_tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat{
        var heightForRow: CGFloat = 80
//        if indexPath.section == 0{
//            heightForRow = 80
//        }
        if indexPath.section > 0 && indexPath.section < tagTypeList.count + 1{
//            var groupIndex:Int = indexPath.section - 1
//            if ((groupedTagList[groupIndex] as! NSDictionary).objectForKey("tagsInGroup"))!.count <= 5 {
//                heightForRow = 40
//            }else{
//                heightForRow = 80
//            }
            heightForRow = (rowHightForTagContainer[indexPath.section - 1] as! CGFloat)
        }
        return heightForRow
    }
    

}
