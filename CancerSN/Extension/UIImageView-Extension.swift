//
//  UIImageView-Extension.swift
//  CancerSN
//
//  Created by lay on 15/12/30.
//  Copyright © 2015年 lily. All rights reserved.
//

import Foundation

extension UIImageView {

    // 添加webImage图片缓存
    
    func addImageCache(url: String, placeHolder: String) {
        // 图片加载失败显示图片
        let placeHolderImg: UIImage = UIImage(named: placeHolder)!
        let imageURL = NSURL(string: url)
        if imageURL != nil {
            self.sd_setImageWithURL(imageURL!, placeholderImage: placeHolderImg, options: SDWebImageOptions.RefreshCached)
        }
    }
}