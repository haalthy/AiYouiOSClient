//
//  FeedTagsViewController.swift
//  CancerSN
//
//  Created by lay on 16/1/18.
//  Copyright © 2016年 lily. All rights reserved.
//

import UIKit
import CoreData

// 重用cell identifier
let cellTagIdentifier = "TagCell"

protocol PostTagDelegate {
    func updatePostTagList(_ tagList: NSArray)
}

class FeedTagsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, SelectedTagVCDelegate{

    @IBOutlet weak var tableView: UITableView!
    
    var isNavigationPop = false
    var isSelectedByPost = false
    
    var selectedTagNameList = NSMutableArray()
    var defaultSelectTagNameList = NSArray()
    
    var dataTagsArr: NSMutableArray!
    var tagCell: TagCell!
    var dict = NSArray()
    
    var islookAround = false
    
    let headerHeight: CGFloat = 44
    let cancelBtnLeftSpace: CGFloat = 15
    let cancelBtnWidth: CGFloat = 40
    let cancelBtnFont:UIFont = UIFont.systemFont(ofSize: 15)
    let cancelBtnColor: UIColor = headerColor
    
    let confirmBtnRightSpace: CGFloat = 15
    let confirmBtnWidth: CGFloat = 40

    var heightForHeaderInSection: CGFloat = 37
    
    var postDelegate: PostTagDelegate?
    
    var keychainAccess = KeychainAccess()
    let haalthyService = HaalthyService()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.initVariables()
        self.initContentView()
        let currentTimeStamp: Double = Foundation.Date().timeIntervalSince1970
        var previousStoreTimestamp: Double = 0
        if  UserDefaults.standard.object(forKey: setTagListTimeStamp) != nil {
            previousStoreTimestamp = UserDefaults.standard.object(forKey: setTagListTimeStamp) as! Double
            
        }
        if (currentTimeStamp - previousStoreTimestamp) > (28 * 86400) {
            clearTagListFromLacalDB()
        }else{
            getTagListFromLocalDB()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.getAllTagsFromServer()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - 初始化变量
    
    func initVariables() {
        dataTagsArr = NSMutableArray()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(TagCell.self, forCellReuseIdentifier: cellTagIdentifier)
        self.tagCell = self.tableView.dequeueReusableCell(withIdentifier: cellTagIdentifier) as! TagCell
        if screenHeight < 600 {
            heightForHeaderInSection = 20
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = false
    }
    // MARK: - 初始化相关view
    
    func initContentView() {

        if isNavigationPop {
            //previous Btn
            let btnMargin: CGFloat = 15
            let previousBtn = UIButton(frame: CGRect(x: 0, y: previousBtnTopSpace, width: previousBtnWidth + previousBtnLeftSpace + btnMargin, height: previousBtnHeight + btnMargin * 2))
            let previousImgView = UIImageView(frame: CGRECT(previousBtnLeftSpace, btnMargin, previousBtnWidth, previousBtnHeight))
            previousImgView.image = UIImage(named: "btn_previous")
            previousBtn.addTarget(self, action: #selector(FeedTagsViewController.previousView(_:)), for: UIControlEvents.touchUpInside)
            previousBtn.addSubview(previousImgView)
            self.view.addSubview(previousBtn)
            
            //sign up title
            let signUpTitle = UILabel(frame: CGRect(x: signUpTitleMargin, y: signUpTitleTopSpace, width: screenWidth - signUpTitleMargin * 2, height: signUpTitleHeight))
            signUpTitle.font = signUpTitleFont
            signUpTitle.textColor = signUpTitleTextColor
            signUpTitle.text = "请选择您关注的标签"
            signUpTitle.textAlignment = NSTextAlignment.center
            self.view.addSubview(signUpTitle)
            
            //resize tablevIEW
            self.tableView.frame = CGRECT(0, signUpTitleTopSpace + signUpTitleHeight, self.tableView.frame.width, screenHeight - signUpTitleTopSpace - signUpTitleHeight - 50)
            
            //
            let nextViewBtn = UIButton(frame: CGRect(x: 0, y: screenHeight - nextViewBtnButtomSpace - nextViewBtnHeight - 10, width: screenWidth, height: nextViewBtnHeight + 20))
            nextViewBtn.setTitle("确定", for: UIControlState())
            nextViewBtn.setTitleColor(nextViewBtnColor, for: UIControlState())
            nextViewBtn.titleLabel?.font = nextViewBtnFont
            nextViewBtn.addTarget(self, action: #selector(FeedTagsViewController.selectedNextView(_:)), for: UIControlEvents.touchUpInside)
            self.view.addSubview(nextViewBtn)
        }else {
            //modally pop view
            let headerTopSpace = UIApplication.shared.statusBarFrame.height
            let header = UIView(frame: CGRect(x: 0, y: headerTopSpace, width: screenWidth, height: headerHeight))
            
            let btnMargin: CGFloat = 9
            
            //cancel Btn
            let cancelBtn = UIButton(frame: CGRect(x: cancelBtnLeftSpace - btnMargin, y: 9 - btnMargin, width: cancelBtnWidth + btnMargin * 2, height: 15 + btnMargin * 2))
            cancelBtn.setTitle("取消", for: UIControlState())
            cancelBtn.setTitleColor(cancelBtnColor, for: UIControlState())
            cancelBtn.titleLabel?.font = cancelBtnFont
            cancelBtn.titleLabel?.textAlignment = NSTextAlignment.left
            cancelBtn.addTarget(self, action: #selector(FeedTagsViewController.cancel(_:)), for: UIControlEvents.touchUpInside)
            header.addSubview(cancelBtn)
            
            //label
            let titleLabel = UILabel(frame: CGRect(x: cancelBtnLeftSpace + cancelBtnWidth, y: 8, width: screenWidth - (cancelBtnLeftSpace + cancelBtnWidth) * 2, height: 18))
            titleLabel.text = "请选择标签"
            titleLabel.textColor = RGB(51, 51, 51)
            titleLabel.font = UIFont.systemFont(ofSize: 18)
            titleLabel.textAlignment = NSTextAlignment.center
            header.addSubview(titleLabel)
            
            //confirm
            let confirmBtn = UIButton(frame: CGRect(x: screenWidth - confirmBtnRightSpace - confirmBtnWidth, y: 0, width: confirmBtnWidth, height: 33))
            confirmBtn.setTitle("确定", for: UIControlState())
            confirmBtn.setTitleColor(cancelBtnColor, for: UIControlState())
            confirmBtn.titleLabel?.font = cancelBtnFont
            confirmBtn.titleLabel?.textAlignment = NSTextAlignment.right
            confirmBtn.addTarget(self, action: #selector(FeedTagsViewController.confirm(_:)), for: UIControlEvents.touchUpInside)
            header.addSubview(confirmBtn)
            
            //seperateLine
            let seperateLine = UIView(frame: CGRect(x: 0, y: headerHeight - 1, width: screenWidth, height: 1))
            seperateLine.backgroundColor = seperateLineColor
            header.addSubview(seperateLine)
            header.backgroundColor = UIColor.clear
            self.view.addSubview(header)
            
            self.tableView.frame = CGRECT(0, header.frame.height + headerTopSpace, screenWidth, screenHeight - header.frame.height)
        }
    }
    
    
    // MARK: - add Item
    
    func addItem() {
    
        let leftItem: UIBarButtonItem = UIBarButtonItem.init(title: "取消", style: UIBarButtonItemStyle.plain, target: self, action: #selector(FeedTagsViewController.dismiss as (FeedTagsViewController) -> () -> ()))
        self.navigationItem.leftBarButtonItem = leftItem
        
        let rightItem: UIBarButtonItem = UIBarButtonItem.init(title: "确认", style: UIBarButtonItemStyle.plain, target: self, action: #selector(FeedTagsViewController.saveTagAction))
        self.navigationItem.rightBarButtonItem = rightItem
        
    }

    func cancel(_ sender: UIButton){
        if !isSelectedByPost {
            if UserDefaults.standard.object(forKey: favTagsNSUserData) == nil {
                let selectTagList = saveTagList()
                UserDefaults.standard.set(selectTagList, forKey: favTagsNSUserData)
            }
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    func confirm(_ sender: UIButton){
        let selectTagList = saveTagList()
        if isSelectedByPost {
            postDelegate?.updatePostTagList(selectTagList)
        }else{
            UserDefaults.standard.set(selectTagList, forKey: favTagsNSUserData)
            haalthyService.updateUserTag(selectTagList )
        }
        if islookAround {
            let tabViewController : TabViewController = TabViewController()
            self.present(tabViewController, animated: true, completion: nil)
        }else{
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    //get Tag List from local DB
    func getTagListFromLocalDB() {
        let appDel:AppDelegate = (UIApplication.shared.delegate as! AppDelegate)
        let context:NSManagedObjectContext = appDel.managedObjectContext!
        let tagTypeRequest = NSFetchRequest<NSFetchRequestResult>(entityName: tableTag)
        tagTypeRequest.propertiesToFetch = [propertyTypeRank, propertyTypeName]
        tagTypeRequest.returnsDistinctResults = true
        tagTypeRequest.returnsObjectsAsFaults = false
        tagTypeRequest.sortDescriptors = [NSSortDescriptor(key: propertyTypeRank, ascending: true)]
        
        tagTypeRequest.resultType = NSFetchRequestResultType.dictionaryResultType
        let tagTypeList = try! context.fetch(tagTypeRequest)
        let tagArr = TagModel.jsonToModelList(tagTypeList as AnyObject?) as! Array<TagModel>
        
        tagTypeRequest.propertiesToFetch = [propertyTypeRank, propertyTypeName, propertyTagId, propertyTagName, propertyTagRank]

        let fullTagTypeList = try! context.fetch(tagTypeRequest)
        let fullTagArr = SubTagModel.jsonToModelList(fullTagTypeList as AnyObject?) as! Array<SubTagModel>
        for tag in tagArr {
            let tagsInType = NSMutableArray()
            for subTag in fullTagArr {
                if (tag.typeRank == subTag.typeRank){
                    tagsInType.add(subTag)
                }
            }
            tag.tags = (tagsInType as NSArray) as! Array
        }
        
        let tagDictArr = NSMutableArray()
        for tagType in tagTypeList {
            let tagDict = NSMutableDictionary()
            tagDict.setObject((tagType as! NSDictionary).object(forKey: "typeRank")!, forKey: "typeRank" as NSCopying)
            tagDict.setObject((tagType as! NSDictionary).object(forKey: "typeName")!, forKey: "typeName" as NSCopying)

            let tagsInTypeDic = NSMutableArray()
            for tag in fullTagTypeList {
                if ((tag as! NSDictionary).object(forKey: "typeRank") as! Int) == ((tagType as! NSDictionary).object(forKey: "typeRank") as! Int) {
                    tagsInTypeDic.add(tag as! NSDictionary)
                }
            }
            tagDict.setObject(tagsInTypeDic, forKey: "tags" as NSCopying)
            tagDictArr.add(tagDict)
        }
        self.dict = tagDictArr
        self.dataTagsArr = NSMutableArray(array: tagArr as NSArray)
    }
    
    //save Tag List to Local DB
    func saveTagListToLacalDB() {
        let appDel:AppDelegate = (UIApplication.shared.delegate as! AppDelegate)
        let context:NSManagedObjectContext = appDel.managedObjectContext!
        for tagType in self.dataTagsArr {
            let tagTypeItem = (tagType as! TagModel).tags
            for tag in tagTypeItem! {
                let tagItem = tag 
                let tagLocalDBItem = NSEntityDescription.insertNewObject(forEntityName: tableTag, into: context)
                tagLocalDBItem.setValue(tagItem.tagId, forKey: propertyTagId)
                tagLocalDBItem.setValue(tagItem.name, forKey: propertyTagName)
                tagLocalDBItem.setValue(tagItem.rankInType, forKey: propertyTagRank)
                tagLocalDBItem.setValue(tagItem.typeName, forKey: propertyTypeName)
                tagLocalDBItem.setValue(tagItem.typeRank, forKey: propertyTypeRank)
            }
        }
        do {
            try context.save()
        } catch _ {
        }
    }
    
    //clear Tag List From LocalDB
    func clearTagListFromLacalDB(){
        let appDel:AppDelegate = (UIApplication.shared.delegate as! AppDelegate)
        let context:NSManagedObjectContext = appDel.managedObjectContext!
        let deletePostsRequet = NSFetchRequest<NSFetchRequestResult>(entityName: tableTag)
        if let results = try? context.fetch(deletePostsRequet) {
            for param in results {
                context.delete(param as! NSManagedObject);
            }
        }
        do {
            try context.save()
        } catch _ {
        }
    }
    
    // MARK: - 网络请求

    
    // MARK: 获取所有标签
    
    func getAllTagsFromServer() {
        if (isNavigationPop == false) && (isSelectedByPost == false) {
            if (self.defaultSelectTagNameList.count == 0) && (UserDefaults.standard.object(forKey: favTagsNSUserData) != nil) {
                print(UserDefaults.standard.object(forKey: favTagsNSUserData))
                defaultSelectTagNameList = UserDefaults.standard.object(forKey: favTagsNSUserData) as! NSMutableArray
            }else if (keychainAccess.getPasscode(usernameKeyChain) != nil)  {
                self.defaultSelectTagNameList = haalthyService.getUserFavTags()
            }
        }
        
        if self.dataTagsArr.count == 0 {
            HudProgressManager.sharedInstance.showHudProgress(self, title: "加载中")
            NetRequest.sharedInstance.GET(getTagListURL, success: { (content, message) -> Void in
                self.dict = content as! NSArray
                let tagArr = TagModel.jsonToModelList(self.dict) as! Array<TagModel>
                self.dataTagsArr = NSMutableArray(array: tagArr as NSArray)
                self.tableView.reloadData()
                self.setDefaultSelectedTagBtn()
                self.saveTagListToLacalDB()
                UserDefaults.standard.set(Foundation.Date().timeIntervalSince1970, forKey: setTagListTimeStamp)
                HudProgressManager.sharedInstance.dismissHud()
                }) { (content, message) -> Void in
                    
                    HudProgressManager.sharedInstance.dismissHud()
                    HudProgressManager.sharedInstance.showOnlyTextHudProgress(self, title: message)
            }
        }
        else{
            self.setDefaultSelectedTagBtn()
        }
    }
    
    // MARK: - 功能方法
    
    // 取消
    
    func dismiss() {
    
        self.dismiss(animated: true, completion: nil)
    }
    
    func saveTagAction() {
    
    }
    
    func setDefaultSelectedTagBtn(){
        for tag in self.defaultSelectTagNameList {
            selectedTagNameList.add((tag as! NSDictionary).object(forKey: "name")!)
        }
        for indexSection in 0...(self.tableView.numberOfSections - 1){
            let indexPath = IndexPath(row: 0, section: indexSection)
            let cell = self.tableView.cellForRow(at: indexPath)
            let buttonsContainer = ((cell?.subviews)!)[0].subviews
            for subView in buttonsContainer {
                if (subView is UIButton) {
                    let btnTitle: String = ((subView as! UIButton).titleLabel?.text)!
                    if selectedTagNameList.contains(btnTitle) {
                        subView.backgroundColor = tagBorderColor
                        (subView as! UIButton).setTitleColor(UIColor.white, for: UIControlState())
                    }
                }
            }
        }
    
    }
    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return dataTagsArr.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return heightForHeaderInSection
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        let tagModel: TagModel = self.dataTagsArr[section] as! TagModel
        return tagModel.typeName
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let tagModel: TagModel = dataTagsArr[indexPath.section] as! TagModel
        
        let tagCell: TagCell = self.tagCell
        tagCell.tagArr = tagModel.tags
        return tagCell.getCellHeight()
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellTagIdentifier)! as! TagCell
        
        
        let tagModel: TagModel = dataTagsArr[indexPath.section] as! TagModel
        
        cell.backgroundColor = UIColor.clear
        cell.tagArr = tagModel.tags
        cell.selectedTagVCDelegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
       // self.performSegueWithIdentifier("EnterDetailView", sender: self)
    }
    
    func previousView(_ sender: UIButton){
        self.navigationController?.popViewController(animated: true)
    }
    
    func selectedNextView(_ sender: UIButton){
        let selectTagList = saveTagList()
//        let profileSet = NSUserDefaults.standardUserDefaults()
        //        if (profileSet.objectForKey(userTypeUserData) as! String) == aiyouUserType{
        //update user info
        
        //        }else {
        UserDefaults.standard.set(selectTagList, forKey: favTagsNSUserData)
        haalthyService.updateUserTag(selectTagList)
//        let tabViewController : TabViewController = TabViewController()
//        self.presentViewController(tabViewController, animated: true, completion: nil)
        self.performSegue(withIdentifier: "signUpSucessfulSegue", sender: self)
        
        //        }
    }
    
    func saveTagList()->NSArray{
        let selectTagList = NSMutableArray()
        for tagType in self.dict {
            for tag in (tagType as! NSDictionary).object(forKey: "tags") as! NSArray{
                if selectedTagNameList.contains((tag as! NSDictionary).object(forKey: "name") as! String) {
                    selectTagList.add(tag)
                }
            }
        }
        return selectTagList
    }
    
    func selectedTag(_ tag: String) {
        self.selectedTagNameList.add(tag)
    }
    
    func unselectedTag(_ tag: String) {
        self.selectedTagNameList.remove(tag)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let tagModel: TagModel = self.dataTagsArr[section] as! TagModel
        let title = tagModel.typeName
        var headerView = UIView()
        headerView =  UIView(frame: CGRect(x: 0, y: 0,width: self.tableView.bounds.size.width, height: heightForHeaderInSection))
        let tagTypeLabel = UILabel(frame: CGRect(x: 13, y: (heightForHeaderInSection - 15)/2, width: self.tableView.bounds.size.width - 30, height: heightForHeaderInSection))
        tagTypeLabel.text = title
        tagTypeLabel.textColor = defaultTextColor
        tagTypeLabel.font = UIFont.systemFont(ofSize: 13)
        headerView.addSubview(tagTypeLabel)
        headerView.backgroundColor = self.view.backgroundColor
        return headerView
    }
}
