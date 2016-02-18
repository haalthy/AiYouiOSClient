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

class FeedTagsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    var dataTagsArr: NSMutableArray!
    var tagCell: TagCell!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.initVariables()
        self.initContentView()
        self.addItem()
        self.getAllTagsFromServer()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - 初始化变量
    
    func initVariables() {
    
        dataTagsArr = NSMutableArray()
    }
    
    // MARK: - 初始化相关view
    
    func initContentView() {
    
        self.tableView.registerClass(TagCell.self, forCellReuseIdentifier: cellTagIdentifier)
        self.tagCell = self.tableView.dequeueReusableCellWithIdentifier(cellTagIdentifier) as! TagCell
    }
    
    
    // MARK: - add Item
    
    func addItem() {
    
        let leftItem: UIBarButtonItem = UIBarButtonItem.init(title: "取消", style: UIBarButtonItemStyle.Plain, target: self, action: "dismiss")
        self.navigationItem.leftBarButtonItem = leftItem
        
        let rightItem: UIBarButtonItem = UIBarButtonItem.init(title: "确认", style: UIBarButtonItemStyle.Plain, target: self, action: "saveTagAction")
        self.navigationItem.rightBarButtonItem = rightItem
        
    }

    // MARK: - 网络请求
    
    // MARK: 获取所有标签
    
    func getAllTagsFromServer() {
    
        HudProgressManager.sharedInstance.showHudProgress(self, title: "")
        
        NetRequest.sharedInstance.GET(getTagListURL, success: { (content, message) -> Void in
            
             HudProgressManager.sharedInstance.dismissHud()
             HudProgressManager.sharedInstance.showSuccessHudProgress(self, title: "获取成功")
            let dict: NSArray = content as! NSArray
            let tagArr = TagModel.jsonToModelList(dict as Array) as! Array<TagModel>
            self.dataTagsArr = NSMutableArray(array: tagArr as NSArray)
            self.tableView.reloadData()

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
    
    
    
    // MARK: - Table view data source
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return dataTagsArr.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
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
        
        cell.backgroundColor = RGB(242, 248, 248)
        cell.tagArr = tagModel.tags
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
       // self.performSegueWithIdentifier("EnterDetailView", sender: self)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
