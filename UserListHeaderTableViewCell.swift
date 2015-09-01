//
//  UserListHeaderTableViewCell.swift
//  CancerSN
//
//  Created by lily on 7/22/15.
//  Copyright (c) 2015 lily. All rights reserved.
//

import UIKit

class UserListHeaderTableViewCell: UITableViewCell {
//    let searchUserBtn = UIButton()
//    let searchContentBtn = UIButton()

//    func setHighLightBtn(sender:UIButton){
//        sender.layer.cornerRadius = 5
//        sender.backgroundColor = mainColor
//        sender.layer.masksToBounds = true
//        sender.titleLabel?.textColor = UIColor.whiteColor()
//    }
//    
//    func unsetHightLightBtn(sender:UIButton){
//        sender.layer.cornerRadius = 5
//        sender.layer.borderColor = mainColor.CGColor
//        sender.layer.borderWidth = 2
//        sender.layer.masksToBounds = true
//        sender.backgroundColor = UIColor.whiteColor()
//        sender.titleLabel?.textColor = mainColor
//    }

    @IBAction func indexChanged(sender: UISegmentedControl) {
//        switch sender.selectedSegmentIndex
//        {
//        case 0:
//            textLabel!.text = "First selected";
//        case 1:
//            textLabel!.text = "Second Segment selected";
//        default:
//            break; 
//        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()

//        var btnWidth = (UIScreen.mainScreen().bounds.width-24*2)/2
        
//        searchUserBtn.frame = CGRectMake(24, 7, btnWidth, 30)
//        searchUserBtn.addTarget(self, action: "searchUser", forControlEvents: .TouchUpInside)
//        searchUserBtn.setTitle("查找用户", forState: .Normal)
//        searchUserBtn.titleLabel?.textAlignment = NSTextAlignment.Center
//        searchUserBtn.backgroundColor = mainColor
//        searchUserBtn.titleLabel?.textColor = UIColor.whiteColor()

//        setHighLightBtn(searchUserBtn)
        
//        searchContentBtn.frame = CGRectMake(24 + btnWidth, 7, btnWidth, 30)
//        searchContentBtn.addTarget(self, action: "searchContent", forControlEvents: .TouchUpInside)
//        searchContentBtn.setTitle("查找内容", forState: .Normal)
//        searchContentBtn.titleLabel?.textAlignment = NSTextAlignment.Center
//        unsetHightLightBtn(searchContentBtn)
//        searchContentBtn.backgroundColor = UIColor.greenColor()
//        searchContentBtn.titleLabel?.textColor = UIColor.redColor()
        
//        self.addSubview(searchUserBtn)
//        self.addSubview(searchContentBtn)
//        searchContentBtn.titleLabel?
//        searchContentBtn.titleLabel?.shadowColor = UIColor.blackColor()
    }

//    func searchUser(){
//        setHighLightBtn(searchUserBtn)
//        unsetHightLightBtn(searchContentBtn)
//    }
//    
//    func searchContent(){
//        setHighLightBtn(searchContentBtn)
//        unsetHightLightBtn(searchUserBtn)
//    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
