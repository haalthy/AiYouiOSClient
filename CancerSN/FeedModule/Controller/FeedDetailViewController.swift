//
//  FeedDetailViewController.swift
//  CancerSN
//
//  Created by lay on 16/1/7.
//  Copyright © 2016年 lily. All rights reserved.
//

import UIKit

let kFeedDetailKeyBoardHeight: CGFloat = 50

class FeedDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, KeyBoardDelegate {

    // 控件关联
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        
        
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.initContentView()
    }

    override func viewDidAppear(animated: Bool) {
        self.initContentView()

    }
    
    // MARK: - init ContentView
    
    func initContentView() {
    
        // 评论
        let keyBoardView: KeyBoardView = KeyBoardView(frame: CGRECT(0, SCREEN_HEIGHT - kFeedDetailKeyBoardHeight, SCREEN_WIDTH, kFeedDetailKeyBoardHeight))
        keyBoardView.delegate = self
        keyBoardView.setPlaceHolderTextColor(RGB(204, 204, 204))
        keyBoardView.setPlaceHolderText("在此输入您要发送的评论")

        self.view.addSubview(keyBoardView)
        self.view.bringSubviewToFront(keyBoardView)
    }
    // MARK: - 网络请求
    
    func getFeedDetailContentFromServer() {
    
        
    }
    
    func commentToFeedDetail() {
    
        
    }
    
    // MARK: - Table view data source
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 0
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
       // let feedFrame: PostFeedFrame = dataArr[indexPath.row] as! PostFeedFrame
        
       // return feedFrame.cellHeight
        return 10
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        //let cell = tableView.dequeueReusableCellWithIdentifier(cellFeedIdentifier)! as! FeedCell
        
        
      //  let feedFrame: PostFeedFrame = dataArr[indexPath.row] as! PostFeedFrame
        
       // cell.feedOriginFrame = feedFrame.feedOriginalFrame
      
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: nil)
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
    }

    // MARK: - 发送评论代理
    
    func sendCommentAction() {
        
        print("send")
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
