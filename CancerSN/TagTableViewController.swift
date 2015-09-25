//
//  TagTableViewController.swift
//  CancerSN
//
//  Created by lily on 9/24/15.
//  Copyright (c) 2015 lily. All rights reserved.
//

import UIKit

class TagTableViewController: UITableViewController {
    
    var haalthyService = HaalthyService()
    var keychain = KeychainAccess()
    var isBroadcastTagSelection = 0
    var selectedTags = NSArray()
    var tagList = NSArray()
    var tagTypeList = NSArray()
    var groupedTagList = NSMutableArray()
    var rowHightForTagContainer = NSMutableArray()

    override func viewDidLoad() {
        super.viewDidLoad()

        var getTagListRespData:NSData = haalthyService.getTagList()
        var jsonResult = NSJSONSerialization.JSONObjectWithData(getTagListRespData, options: NSJSONReadingOptions.MutableContainers, error: nil)
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
        
        if (selectedTags.count == 0) && (keychain.getPasscode(usernameKeyChain) != nil) && (isBroadcastTagSelection == 0){
            var getUserFavTagsData = haalthyService.getUserFavTags()
            var jsonResult = NSJSONSerialization.JSONObjectWithData(getUserFavTagsData!, options: NSJSONReadingOptions.MutableContainers, error: nil)
            self.selectedTags = jsonResult as! NSMutableArray
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
            let cell = tableView.dequeueReusableCellWithIdentifier("tagHeaderCell", forIndexPath: indexPath) as! UITableViewCell
            return cell
        } else if (indexPath.section == tagTypeList.count+1){
            let cell = tableView.dequeueReusableCellWithIdentifier("submitCell", forIndexPath: indexPath) as! UITableViewCell
            
            return cell
        }
        else{
        let cell = tableView.dequeueReusableCellWithIdentifier("tagContainerCell", forIndexPath: indexPath) as! UITableViewCell
        var groupedTagsInType = (groupedTagList[indexPath.section - 1] as! NSDictionary).objectForKey("tagsInGroup")
        
        return cell
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
            headerView.backgroundColor = sectionHeaderColor
            var tagTypeLabel = UILabel(frame: CGRectMake(15, 10, self.tableView.bounds.size.width - 30, 30))
            tagTypeLabel.text = (groupedTagList[section-1] as! NSDictionary).objectForKey("typeName") as! String
            tagTypeLabel.textColor = mainColor
            tagTypeLabel.font = UIFont(name: fontStr, size: 15.0)
            headerView.addSubview(tagTypeLabel)
        }
        return headerView
    }
    
    override func tableView(_tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat{
        var heightForRow: CGFloat = 40
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
