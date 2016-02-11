//
//  FeedPhotosView.swift
//  CancerSN
//
//  Created by lay on 15/12/30.
//  Copyright © 2015年 lily. All rights reserved.
//

import UIKit

// MARK: - 相关配置常量

// 数量最大图片数量
let kPhotosMaxCount: Int = 9

// 图片列数
func getPhotosMaxCols(photoCount: Int) -> Int {

    return photoCount == 4 ? 2 : 3
}

let kPhotosWidth = SCREEN_WIDTH * 0.22
let kPhotosHeight = kPhotosWidth
// 图片间距
let kPhotosMargin = 7

class FeedPhotosView: UIView {

    // 网络图片数组
    var picsUrl: [String] {

        didSet {
        
            // 初始化图片imageView
            self.addFeedPhotos()
            
            // 图片布局
            self.layoutForPic()
            
            let picsCount = self.picsUrl.count
        
            
            for var i = 0; i < kPhotosMaxCount; i++ {
            
                let photoView: UIImageView = self.subviews[i] as! UIImageView                
                if i < picsCount {
                
                    photoView.addImageCache(self.picsUrl[i], placeHolder: "icon_profile")
                    photoView.hidden = false
                }
                else {
                
                    photoView.hidden = true
                }
            }
            
        }
        
    }
    
    init(feedModel: PostFeedStatus, frame: CGRect) {
        

        let picArr: Array<String> = ((feedModel.imageURL).componentsSeparatedByString(","))

        self.picsUrl = picArr
        
        

        super.init(frame: frame)
        
        self.userInteractionEnabled = true


    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 添加photos
    
    func addFeedPhotos() {
    
        for var i = 0; i < kPhotosMaxCount; i++ {
            
            let photoImageView: UIImageView = UIImageView()
            photoImageView.tag = i;
            self.addSubview(photoImageView)
            
            // 添加手势
            
            let gesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "addPhotoOnTap:")
            photoImageView.addGestureRecognizer(gesture)
            
        }
    }
    
    // MARK: 点击图片查看
    
    func addPhotoOnTap(gesture: UITapGestureRecognizer) {
    
        
    }
    
    // MARK: - 单张图片布局
    
    func layoutForPic() {
    
        let count = self.picsUrl.count
        let maxCols = getPhotosMaxCols(count)
        
        for var i = 0; i < count; i++ {
        
            let imageView: UIImageView = self.subviews[i] as! UIImageView
            
            let photoW: CGFloat = kPhotosWidth
            let photoH: CGFloat = kPhotosWidth
            let photoX: CGFloat = CGFloat(i % maxCols) * (kPhotosWidth + CGFloat(kPhotosMargin))
            let photoY: CGFloat = CGFloat(i / maxCols) * (kPhotosWidth + CGFloat(kPhotosMargin))

            imageView.frame = CGRECT(photoX, photoY, photoW, photoH)
        }
    }
    
    // MARK: - 图片布局
    
        class func layoutForPhotos(photoCount: Int) -> CGSize {
    
        let maxCols = getPhotosMaxCols(photoCount)
        
        // 总列数
        let totalCols = photoCount > maxCols ? maxCols : photoCount
        
        // 总行数
        let totalRows: Int = (photoCount + maxCols - 1) / maxCols
        
        // 总宽度
        let width: CGFloat = CGFloat(totalCols * Int(kPhotosWidth) + (totalCols - 1) * kPhotosMargin)
        let height = CGFloat(totalRows * Int(kPhotosHeight) + (totalRows - 1) * kPhotosMargin)

        return CGSizeMake(width, height)
    }
}
