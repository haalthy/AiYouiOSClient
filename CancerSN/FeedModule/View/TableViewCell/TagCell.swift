//
//  TagCell.swift
//  CancerSN
//
//  Created by lay on 16/1/18.
//  Copyright © 2016年 lily. All rights reserved.
//

import UIKit


protocol SelectedTagVCDelegate {
    func selectedTag(tag: String)
    func unselectedTag(tag: String)
}

// 相关常量

let tagFont: UIFont = UIFont.systemFontOfSize(15)

// 边框颜色
let tagBorderColor: UIColor = RGB(61, 208, 221)

class TagCell: UITableViewCell {

    // 相关变量
    var selectedTagVCDelegate: SelectedTagVCDelegate?
    
    var tagArr: Array<SubTagModel>? {
    
        didSet {
        
            // 添加标签
            self.layoutTags()
        }
    }
    
    // cell高度
    var tagCellHeight: CGFloat?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.contentView.backgroundColor = RGB(242, 248, 248)

    }
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    // MARK: - 功能方法
    
    // MARK: 获取cell高度
    
    func getCellHeight() -> CGFloat {
    
        return self.tagCellHeight!
    }
    
    // MARK: 布局cell
    
    func layoutTags() {
    
        
        // 控制换行
        var rowStatus: Int = 0
        var row: Int = 0
        
        for var i = 0; i < tagArr?.count; i++ {
        
            var lastBtnMaxX: CGFloat = 0
            if self.contentView.subviews.count != 0 && i != 0 {
            
                let btn: UIButton = self.contentView.subviews.last as! UIButton
                lastBtnMaxX = CGRectGetMaxX(btn.frame)
            }
            
            let nameStr = self.tagArr![i].name
            let tagBtn: UIButton = UIButton(type: .Custom)
            let tagW: CGFloat = nameStr.sizeWithFont(tagFont, maxSize: CGSize(width: CGFloat.max, height: 15)).width + 22

            if tagW + lastBtnMaxX + 15 >= SCREEN_WIDTH {
            
                rowStatus = 0
                row++
            }
            else {
                rowStatus = 1
            }
            let tagX: CGFloat = rowStatus == 0 || i == 0 ? 15 : 10 + lastBtnMaxX * CGFloat(rowStatus)
            let tagY: CGFloat = CGFloat(10 + 35 * row)
            let tagH: CGFloat = 25
            tagBtn.frame = CGRECT(tagX, tagY, tagW, tagH)
            tagBtn.titleLabel?.textAlignment = NSTextAlignment.Center
            tagBtn.setTitle(nameStr, forState: .Normal)
            tagBtn.setTitleColor(tagBorderColor, forState: .Normal)
            tagBtn.backgroundColor = UIColor.clearColor()
            tagBtn.layer.cornerRadius = 2.0
            tagBtn.layer.borderColor = tagBorderColor.CGColor
            tagBtn.layer.borderWidth = 1.0
            tagBtn.titleLabel?.font = UIFont.systemFontOfSize(13)
            tagBtn.addTarget(self, action: "selectedTag:", forControlEvents: UIControlEvents.TouchUpInside)
            self.contentView.addSubview(tagBtn)
            
            // 获取cell高度
            if i == (tagArr?.count)! - 1 {
            
                self.tagCellHeight = tagY + tagH + 10
            }
            
        }
    }
    
    // MARK: - 功能方法
    
    func selectedTag(btn: UIButton) {
        
        btn.selected = !btn.selected
        if btn.selected {
        
            btn.backgroundColor = tagBorderColor
            btn.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Selected)
            selectedTagVCDelegate?.selectedTag((btn.titleLabel?.text)!)
        }
        else {
        
            btn.backgroundColor = UIColor.clearColor()
            btn.setTitleColor(tagBorderColor, forState: UIControlState.Normal)
            selectedTagVCDelegate?.unselectedTag((btn.titleLabel?.text)!)
        }
        
    }

}
