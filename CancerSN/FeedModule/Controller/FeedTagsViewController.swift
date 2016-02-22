//
//  FeedTagsViewController.swift
//  CancerSN
//
//  Created by lay on 16/1/18.
//  Copyright © 2016年 lily. All rights reserved.
//

import UIKit

// 重用cell identifier
let cellTagIdentifier = "TagCell"

protocol PostTagDelegate {
    func updatePostTagList(tagList: NSArray)
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
    
    let headerHeight: CGFloat = 44
    let cancelBtnLeftSpace: CGFloat = 15
    let cancelBtnWidth: CGFloat = 40
    let cancelBtnFont:UIFont = UIFont.systemFontOfSize(15)
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
//        self.addItem()
        self.getAllTagsFromServer()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - 初始化变量
    
    func initVariables() {
        self.tableView.delegate = self
        self.tableView.dataSource = self
        dataTagsArr = NSMutableArray()
        if screenHeight < 600 {
            heightForHeaderInSection = 20
        }
        
        if (isNavigationPop == false) && (isSelectedByPost == false) {
            if (keychainAccess.getPasscode(usernameKeyChain) != nil)  {
                   self.defaultSelectTagNameList = haalthyService.getUserFavTags()
            }
            if (self.defaultSelectTagNameList.count == 0) && (NSUserDefaults.standardUserDefaults().objectForKey(favTagsNSUserData) != nil) {
                defaultSelectTagNameList = NSUserDefaults.standardUserDefaults().objectForKey(favTagsNSUserData) as! NSMutableArray
            }
        }
    }
    
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.navigationBar.hidden = true
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.navigationController?.navigationBar.hidden = false
    }
    // MARK: - 初始化相关view
    
    func initContentView() {
        self.tableView.registerClass(TagCell.self, forCellReuseIdentifier: cellTagIdentifier)
        self.tagCell = self.tableView.dequeueReusableCellWithIdentifier(cellTagIdentifier) as! TagCell
        if isNavigationPop {
            //previous Btn
            let previousBtn = UIButton(frame: CGRect(x: previousBtnLeftSpace, y: previousBtnTopSpace, width: previousBtnWidth, height: previousBtnHeight))
            let previousImgView = UIImageView(frame: CGRECT(0, 0, previousBtn.frame.width, previousBtn.frame.height))
            previousImgView.image = UIImage(named: "btn_previous")
            previousBtn.addTarget(self, action: "previousView:", forControlEvents: UIControlEvents.TouchUpInside)
            previousBtn.addSubview(previousImgView)
            self.view.addSubview(previousBtn)
            
            //sign up title
            let signUpTitle = UILabel(frame: CGRect(x: signUpTitleMargin, y: signUpTitleTopSpace, width: screenWidth - signUpTitleMargin * 2, height: signUpTitleHeight))
            signUpTitle.font = signUpTitleFont
            signUpTitle.textColor = signUpTitleTextColor
            signUpTitle.text = "请选择您关注的标签"
            signUpTitle.textAlignment = NSTextAlignment.Center
            self.view.addSubview(signUpTitle)
            
            //resize tablevIEW
            self.tableView.frame = CGRECT(0, signUpTitleTopSpace + signUpTitleHeight, self.tableView.frame.width, screenHeight - signUpTitleTopSpace - signUpTitleHeight - 50)
            
            //
            let nextViewBtn = UIButton(frame: CGRect(x: 0, y: screenHeight - nextViewBtnButtomSpace - nextViewBtnHeight, width: screenWidth, height: nextViewBtnHeight + 10))
            nextViewBtn.setTitle("确定", forState: UIControlState.Normal)
            nextViewBtn.setTitleColor(nextViewBtnColor, forState: UIControlState.Normal)
            nextViewBtn.titleLabel?.font = nextViewBtnFont
            nextViewBtn.addTarget(self, action: "selectedNextView:", forControlEvents: UIControlEvents.TouchUpInside)
            self.view.addSubview(nextViewBtn)
        }else {
            //modally pop view
            let headerTopSpace = UIApplication.sharedApplication().statusBarFrame.height
            let header = UIView(frame: CGRect(x: 0, y: headerTopSpace, width: screenWidth, height: headerHeight))
            
            //cancel Btn
            let cancelBtn = UIButton(frame: CGRect(x: cancelBtnLeftSpace, y: 9, width: cancelBtnWidth, height: 15))
            cancelBtn.setTitle("取消", forState: UIControlState.Normal)
            cancelBtn.setTitleColor(cancelBtnColor, forState: UIControlState.Normal)
            cancelBtn.titleLabel?.font = cancelBtnFont
            cancelBtn.titleLabel?.textAlignment = NSTextAlignment.Left
            cancelBtn.addTarget(self, action: "cancel:", forControlEvents: UIControlEvents.TouchUpInside)
            header.addSubview(cancelBtn)
            
            //label
            let titleLabel = UILabel(frame: CGRect(x: cancelBtnLeftSpace + cancelBtnWidth, y: 8, width: screenWidth - (cancelBtnLeftSpace + cancelBtnWidth) * 2, height: 18))
            titleLabel.text = "请选择标签"
            titleLabel.textColor = RGB(51, 51, 51)
            titleLabel.font = UIFont.systemFontOfSize(18)
            titleLabel.textAlignment = NSTextAlignment.Center
            header.addSubview(titleLabel)
            
            //confirm
            let confirmBtn = UIButton(frame: CGRect(x: screenWidth - confirmBtnRightSpace - confirmBtnWidth, y: 9, width: confirmBtnWidth, height: 15))
            confirmBtn.setTitle("确定", forState: UIControlState.Normal)
            confirmBtn.setTitleColor(cancelBtnColor, forState: UIControlState.Normal)
            confirmBtn.titleLabel?.font = cancelBtnFont
            confirmBtn.titleLabel?.textAlignment = NSTextAlignment.Right
            confirmBtn.addTarget(self, action: "confirm:", forControlEvents: UIControlEvents.TouchUpInside)
            header.addSubview(confirmBtn)
            
            //seperateLine
            let seperateLine = UIView(frame: CGRect(x: 0, y: headerHeight - 1, width: screenWidth, height: 1))
            seperateLine.backgroundColor = seperateLineColor
            header.addSubview(seperateLine)
            header.backgroundColor = UIColor.clearColor()
            self.view.addSubview(header)
            
            self.tableView.frame = CGRECT(0, header.frame.height + headerTopSpace, screenWidth, screenHeight - header.frame.height)
        }
    }
    
    
    // MARK: - add Item
    
    func addItem() {
    
        let leftItem: UIBarButtonItem = UIBarButtonItem.init(title: "取消", style: UIBarButtonItemStyle.Plain, target: self, action: "dismiss")
        self.navigationItem.leftBarButtonItem = leftItem
        
        let rightItem: UIBarButtonItem = UIBarButtonItem.init(title: "确认", style: UIBarButtonItemStyle.Plain, target: self, action: "saveTagAction")
        self.navigationItem.rightBarButtonItem = rightItem
        
    }

    func cancel(sender: UIButton){
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func confirm(sender: UIButton){
        let selectTagList = saveTagList()
        if isSelectedByPost {
            postDelegate?.updatePostTagList(selectTagList)
        }else{
            NSUserDefaults.standardUserDefaults().setObject(selectTagList, forKey: favTagsNSUserData)
            haalthyService.updateUserTag(selectTagList )
        }
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    // MARK: - 网络请求
    
    // MARK: 获取所有标签
    
    func getAllTagsFromServer() {
    
        HudProgressManager.sharedInstance.showHudProgress(self, title: "加载中")
        NetRequest.sharedInstance.GET(getTagListURL, success: { (content, message) -> Void in
            
            self.dict = content as! NSArray
            let tagArr = TagModel.jsonToModelList(self.dict as Array) as! Array<TagModel>
            self.dataTagsArr = NSMutableArray(array: tagArr as NSArray)
            self.tableView.reloadData()
            self.setDefaultSelectedTagBtn()
            HudProgressManager.sharedInstance.dismissHud()
            }) { (content, message) -> Void in
               
                HudProgressManager.sharedInstance.dismissHud()
                HudProgressManager.sharedInstance.showOnlyTextHudProgress(self, title: message)
            
        }
    }
    
    // MARK: - 功能方法
    
    // 取消
    
    func dismiss() {
    
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func saveTagAction() {
    
    }
    
    func setDefaultSelectedTagBtn(){
        for tag in self.defaultSelectTagNameList {
            selectedTagNameList.addObject((tag as! NSDictionary).objectForKey("name")!)
        }
        for indexSection in 0...(self.tableView.numberOfSections - 1){
            let indexPath = NSIndexPath(forRow: 0, inSection: indexSection)
            let cell = self.tableView.cellForRowAtIndexPath(indexPath)
            print(cell?.subviews.count)
            let buttonsContainer = ((cell?.subviews)!)[0].subviews
            for subView in buttonsContainer {
                if (subView is UIButton) {
                    let btnTitle: String = ((subView as! UIButton).titleLabel?.text)!
                    if selectedTagNameList.containsObject(btnTitle) {
                        subView.backgroundColor = tagBorderColor
                        (subView as! UIButton).setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
                    }
                }
            }
        }
    
    }
    
    // MARK: - Table view data source
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return dataTagsArr.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return heightForHeaderInSection
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        let tagModel: TagModel = self.dataTagsArr[section] as! TagModel
        return tagModel.typeName
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        let tagModel: TagModel = dataTagsArr[indexPath.section] as! TagModel
        
        let tagCell: TagCell = self.tagCell
        tagCell.tagArr = tagModel.tags
        return tagCell.getCellHeight()
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier(cellTagIdentifier)! as! TagCell
        
        
        let tagModel: TagModel = dataTagsArr[indexPath.section] as! TagModel
        
        cell.backgroundColor = UIColor.clearColor()
        cell.tagArr = tagModel.tags
        cell.selectedTagVCDelegate = self
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
       // self.performSegueWithIdentifier("EnterDetailView", sender: self)
    }
    
    func previousView(sender: UIButton){
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func selectedNextView(sender: UIButton){
        saveTagList()
        self.performSegueWithIdentifier("signupSegue", sender: self)
    }
    
    func saveTagList()->NSArray{
        let selectTagList = NSMutableArray()
        for tagType in dict {
            for tag in (tagType as! NSDictionary).objectForKey("tags") as! NSArray{
                if selectedTagNameList.containsObject((tag as! NSDictionary).objectForKey("name") as! String) {
                    selectTagList.addObject(tag)
                }
            }
        }
        return selectTagList
    }
    
    func selectedTag(tag: String) {
        self.selectedTagNameList.addObject(tag)
    }
    
    func unselectedTag(tag: String) {
        self.selectedTagNameList.removeObject(tag)
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let tagModel: TagModel = self.dataTagsArr[section] as! TagModel
        let title = tagModel.typeName
        var headerView = UIView()
        headerView =  UIView(frame: CGRectMake(0, 0,self.tableView.bounds.size.width, heightForHeaderInSection))
        let tagTypeLabel = UILabel(frame: CGRectMake(13, (heightForHeaderInSection - 15)/2, self.tableView.bounds.size.width - 30, heightForHeaderInSection))
        tagTypeLabel.text = title
        tagTypeLabel.textColor = defaultTextColor
        tagTypeLabel.font = UIFont.systemFontOfSize(13)
        headerView.addSubview(tagTypeLabel)
        headerView.backgroundColor = self.view.backgroundColor
        return headerView
    }
}
