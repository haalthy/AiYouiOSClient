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
    
    var searchDataArr: NSMutableArray?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.initVaribles()
        self.initContentView()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.searchBar.becomeFirstResponder()
    }
    
    override func viewDidAppear(animated: Bool) {
        
        super.viewDidAppear(animated)
        self.searchBar.becomeFirstResponder()
        
    }
    
    // MARK: - 初始化相关变量
    
    func initVaribles() {
    
        self.searchDataArr = NSMutableArray()
    }
    
    // MARK: - 初始化相关View
    
    func initContentView() {
    
        //self.searchBar.becomeFirstResponder()
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
    
    }
    
    // MARK: 搜索临床数据
    
    func getPatientDataFromServer() {
    
        
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
