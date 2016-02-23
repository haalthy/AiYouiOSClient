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
    
    //放大图片
    var tapedPhotoViewTag: Int = 0
    let backgroundScrollView = UIScrollView()
    
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
        

        let originPicArr: Array<String> = ((feedModel.imageURL).componentsSeparatedByString(";"))

        var picArr: Array<String> = []
        for picurl in originPicArr {
            if picurl != "" {
                picArr.append(picurl)
            }
        }
        
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
            
            let gesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "showImage:")
            
            photoImageView.addGestureRecognizer(gesture)
            photoImageView.userInteractionEnabled = true

        }
    }
    
    // MARK: 点击图片查看
    
    func addPhotoOnTap(gesture: UITapGestureRecognizer) {
        print("tap photo")
        
    }
    
    func showImage(sender: UITapGestureRecognizer){
        self.backgroundScrollView.removeAllSubviews()
        let tapLocation = sender.locationInView(self)

        let xIndex = Int((tapLocation.x)/( kPhotosWidth + CGFloat(kPhotosMargin)))
        let yIndex = Int((tapLocation.y)/( kPhotosWidth + CGFloat(kPhotosMargin)))

        tapedPhotoViewTag = yIndex * 3 + xIndex
        
        let photoView = self.subviews[tapedPhotoViewTag] as! UIImageView
        let image = photoView.image
        let window = UIApplication.sharedApplication().keyWindow
        backgroundScrollView.frame = CGRectMake(0, 0, screenWidth, screenHeight)
        //config scroll view
        backgroundScrollView.contentSize = CGSize(width: screenWidth * CGFloat(self.picsUrl.count), height: screenHeight)
        backgroundScrollView.contentOffset = CGPoint(x: screenWidth * CGFloat(tapedPhotoViewTag), y: 0)
        backgroundScrollView.pagingEnabled = true
        backgroundScrollView.userInteractionEnabled = true
        
        backgroundScrollView.backgroundColor = UIColor.blackColor()
        backgroundScrollView.alpha = 0
        let imageView = UIImageView(frame: CGRECT(photoView.frame.origin.x + screenWidth * CGFloat(tapedPhotoViewTag), (screenHeight - photoView.frame.height)/2, photoView.frame.width, photoView.frame.height))
        
        imageView.image = image
        imageView.tag = 1
        backgroundScrollView.addSubview(imageView)
        window?.addSubview(backgroundScrollView)
        let hide = UITapGestureRecognizer(target: self, action: "hideImage:")
        backgroundScrollView.addGestureRecognizer(hide)
        UIView.animateWithDuration(0.3, animations:{ () in
            let vsize = UIScreen.mainScreen().bounds.size
            imageView.frame = CGRect(x:screenWidth * CGFloat(self.tapedPhotoViewTag), y: 0.0, width: vsize.width, height: vsize.height)
            imageView.contentMode = .ScaleAspectFit
            self.backgroundScrollView.alpha = 1
            }, completion: {(finished:Bool) in
                if self.tapedPhotoViewTag > 0 {
                    for index in 0...(self.tapedPhotoViewTag - 1){
                        let imageView = UIImageView(frame: CGRECT(screenWidth * CGFloat(index), 0.0, screenWidth, screenHeight))
                        imageView.image = ((self.subviews[index]) as! UIImageView).image
                        imageView.contentMode = .ScaleAspectFit
                        self.backgroundScrollView.addSubview(imageView)
                    }
                }
                if (self.tapedPhotoViewTag + 1) < (self.subviews.count - 1) {
                    for index in (self.tapedPhotoViewTag+1)...(self.subviews.count - 1){
                        let imageView = UIImageView(frame: CGRECT(screenWidth * CGFloat(index), 0.0, screenWidth, screenHeight))
                        imageView.image = ((self.subviews[index]) as! UIImageView).image
                        imageView.contentMode = .ScaleAspectFit
                        self.backgroundScrollView.addSubview(imageView)
                    }
                }
        
        })
        
    }
    
    func hideImage(sender: UITapGestureRecognizer){
        if sender.view == backgroundScrollView {
            self.backgroundScrollView.removeFromSuperview()
        }
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
