//
//  SearchViewController.swift
//  CancerSN
//
//  Created by lay on 16/1/23.
//  Copyright © 2016年 lily. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {

    
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var userBtn: UIButton!
    
    @IBOutlet weak var methodBtn: UIButton!
    
    @IBOutlet weak var patientBtn: UIButton!
    
    var searchDataArr: NSMutableArray?
    
    var curSelectedBtn: UIButton?
    
    var searchType: Int? // 1为用户，2为治疗方案，3为临床数据
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.initVaribles()
        self.initContentView()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    // MARK: - 初始化相关变量
    
    func initVaribles() {
    
        self.searchDataArr = NSMutableArray()
    }
    
    // MARK: - 初始化相关View
    
    func initContentView() {
    
        self.userBtn.setImage(UIImage(named: "btn_user_selected"), forState: .Selected)
        self.userBtn.setImage(UIImage(named: "btn_user"), forState: .Normal)

        self.methodBtn.setImage(UIImage(named: "btn_manage"), forState: .Normal)
        self.methodBtn.setImage(UIImage(named: "btn_manage_selected"), forState: .Selected)
        
        self.patientBtn.setImage(UIImage(named: "btn_patientData"), forState: .Normal)
        self.patientBtn.setImage(UIImage(named: "btn_patientData_selected"), forState: .Selected)
        
        self.userBtn.selected = true
        
        self.curSelectedBtn = self.userBtn
        
        self.searchBar.placeholder = "用户"
    }
    
    // MARK: - 功能方法
    
    // MARK: 搜索用户
    
    @IBAction func searchUserAction(sender: UIButton) {
        
        if self.curSelectedBtn == self.userBtn {
        
            return
        }
        else
        {
            self.searchBar.placeholder = "用户"
            self.curSelectedBtn?.selected = false
            self.userBtn.selected = true
            self.curSelectedBtn = self.userBtn
        }
    }
    
    // MARK: 搜索治疗方案
    
    @IBAction func searchMethodAction(sender: UIButton) {
        
        if self.curSelectedBtn == self.methodBtn {
        
            return
        }
        else {
        
            self.searchBar.placeholder = "治疗方案"
            self.curSelectedBtn?.selected = false
            self.methodBtn.selected = true
            self.curSelectedBtn = self.methodBtn
        }
    }
    
    // MARK: 搜索临床数据
    
    @IBAction func searchPatientAction(sender: UIButton) {
        
        if self.curSelectedBtn == self.patientBtn {
        
            return
        }
        else {
        
            self.searchBar.placeholder = "临床数据"
            self.curSelectedBtn?.selected = false
            self.patientBtn.selected = true
            self.curSelectedBtn = self.patientBtn
        }
    }
    
    
    // MARK: - 网络请求
    
    // MARK: 搜索用户
    
    func getUserDataFromServer() {
        
        NetRequest.sharedInstance.POST("", parameters: ["":""], success: { (content, message) -> Void in
        
        }) { (content, message) -> Void in
            
        }
    }
    
    // MARK: 搜索治疗方案
    
    func getCureFuncDataFromServer() {
    
        NetRequest.sharedInstance.POST("", parameters: ["":""], success: { (content, message) -> Void in
            
            }) { (content, message) -> Void in
                
        }

    }
    
    // MARK: 搜索临床数据
    
    func getPatientDataFromServer() {
    
        NetRequest.sharedInstance.POST("", parameters: ["":""], success: { (content, message) -> Void in
            
            }) { (content, message) -> Void in
                
        }

    }
    
    // MARK: - searchBar Delegate
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func searchBar(searchBar: UISearchBar, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        
        return true
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        
    }
    
    // MARK: - Table view data source
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.searchDataArr!.count
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        
        return 40
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier(cellFeedIdentifier)! as! FeedCell
    
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        self.performSegueWithIdentifier("EnterDetailView", sender: self)
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
