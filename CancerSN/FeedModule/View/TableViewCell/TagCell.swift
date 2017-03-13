//
//  TagCell.swift
//  CancerSN
//
//  Created by lay on 16/1/18.
//  Copyright © 2016年 lily. All rights reserved.
//

import UIKit
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}



protocol SelectedTagVCDelegate {
    func selectedTag(_ tag: String)
    func unselectedTag(_ tag: String)
}

// 相关常量

let tagFont: UIFont = UIFont.systemFont(ofSize: 15)

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
    override func setSelected(_ selected: Bool, animated: Bool) {
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
        
        for i in 0..<Int((tagArr?.count)!){
            var lastBtnMaxX: CGFloat = 0
            if self.contentView.subviews.count != 0 && i != 0 {
            
                let btn: UIButton = self.contentView.subviews.last as! UIButton
                lastBtnMaxX = btn.frame.maxX
            }
            
            let nameStr = self.tagArr![i].name
            let tagBtn: UIButton = UIButton(type: .custom)
            
            let tagW: CGFloat
               tagW = (nameStr?.sizeWithFont(tagFont, maxSize: CGSize(width: CGFloat.greatestFiniteMagnitude, height: 15)).width)! + 22

            if tagW + lastBtnMaxX + 15 >= SCREEN_WIDTH {
            
                rowStatus = 0
                row += 1
            }
            else {
                rowStatus = 1
            }
            let tagX: CGFloat = rowStatus == 0 || i == 0 ? 15 : 10 + lastBtnMaxX * CGFloat(rowStatus)
            let tagY: CGFloat = CGFloat(10 + 35 * row)
            let tagH: CGFloat = 25
            tagBtn.frame = CGRECT(tagX, tagY, tagW, tagH)
            tagBtn.titleLabel?.textAlignment = NSTextAlignment.center
            tagBtn.setTitle(nameStr, for: UIControlState())
            tagBtn.setTitleColor(tagBorderColor, for: UIControlState())
            tagBtn.backgroundColor = UIColor.clear
            tagBtn.layer.cornerRadius = 2.0
            tagBtn.layer.borderColor = tagBorderColor.cgColor
            tagBtn.layer.borderWidth = 1.0
            tagBtn.titleLabel?.font = UIFont.systemFont(ofSize: 13)
            tagBtn.addTarget(self, action: #selector(TagCell.selectedTag(_:)), for: UIControlEvents.touchUpInside)
            self.contentView.addSubview(tagBtn)
            
            // 获取cell高度
            if i == (tagArr?.count)! - 1 {
            
                self.tagCellHeight = tagY + tagH + 10
            }
            
        }
    }
    
    // MARK: - 功能方法
    
    func selectedTag(_ btn: UIButton) {
        
        btn.isSelected = !btn.isSelected
        if btn.isSelected {
        
            btn.backgroundColor = tagBorderColor
            btn.setTitleColor(UIColor.white, for: UIControlState.selected)
            selectedTagVCDelegate?.selectedTag((btn.titleLabel?.text)!)
        }
        else {
        
            btn.backgroundColor = UIColor.clear
            btn.setTitleColor(tagBorderColor, for: UIControlState())
            selectedTagVCDelegate?.unselectedTag((btn.titleLabel?.text)!)
        }
        
    }

}
