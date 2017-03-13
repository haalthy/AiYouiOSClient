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
func getPhotosMaxCols(_ photoCount: Int) -> Int {

    return photoCount == 4 ? 2 : 3
}

let kPhotosWidth = SCREEN_WIDTH * 0.22
let kPhotosHeight = kPhotosWidth
// 图片间距
let kPhotosMargin = 7

class FeedPhotosView: UIView {
    var progressHUD: MBProgressHUD = MBProgressHUD()
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
        
            
            for i in 0 ..< ((kPhotosMaxCount < self.picsUrl.count) ? kPhotosMaxCount : self.picsUrl.count) {
            
                let photoView: UIImageView = self.subviews[i] as! UIImageView                
                if i < picsCount {
                    if (self.picsUrl[i] != "<null>"){
                        let imageURL = self.picsUrl[i] + "@100h_100w_1e_1c"
                        photoView.addImageCache(imageURL, placeHolder: placeHolderStr)
                    }
                    photoView.isHidden = false
                }
                else {
                
                    photoView.isHidden = true
                }
            }
            
        }
        
    }
    
    init(feedModel: PostFeedStatus, frame: CGRect) {
        

        let originPicArr: Array<String> = ((feedModel.imageURL).components(separatedBy: ";"))

        var picArr: Array<String> = []
        for picurl in originPicArr {
            if picurl != "" {
                picArr.append(picurl)
            }
        }
        
        self.picsUrl = picArr
        
        

        super.init(frame: frame)
        
        self.isUserInteractionEnabled = true


    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 添加photos
    
    func addFeedPhotos() {
    
        for i in 0 ..< ((kPhotosMaxCount < self.picsUrl.count) ? kPhotosMaxCount : self.picsUrl.count) {
            
            let photoImageView: UIImageView = UIImageView()
            photoImageView.backgroundColor = seperateLineColor
            photoImageView.tag = i;
            self.addSubview(photoImageView)
            
            // 添加手势
            
            let gesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(FeedPhotosView.showImage(_:)))
            
            photoImageView.addGestureRecognizer(gesture)
            photoImageView.isUserInteractionEnabled = true

        }
    }
    
    // MARK: 点击图片查看
    
    func showImage(_ sender: UITapGestureRecognizer){
        self.backgroundScrollView.removeAllSubviews()
        let tapLocation = sender.location(in: self)
        
        let xIndex = Int((tapLocation.x)/( kPhotosWidth + CGFloat(kPhotosMargin)))
        let yIndex = Int((tapLocation.y)/( kPhotosWidth + CGFloat(kPhotosMargin)))
        
        tapedPhotoViewTag = yIndex * 3 + xIndex
        
        let photoView = self.subviews[tapedPhotoViewTag] as! UIImageView
        if photoView.sd_imageURL() != nil {
            if photoView.sd_imageURL().absoluteString != self.picsUrl[tapedPhotoViewTag] {
                self.superview?.addSubview(progressHUD)
                progressHUD.labelText = "加载图片"
                progressHUD.show(true)
                photoView.sd_setImage(with: URL(string: self.picsUrl[tapedPhotoViewTag] + "@800h"), placeholderImage: photoView.image, options: SDWebImageOptions.cacheMemoryOnly) { (imageTest, err, type , urltest) -> Void in
                    //
                    self.progressHUD.removeFromSuperview()
                    if err == nil{
                        self.showSlideImage()
                    }else{
                        print("加载失败")
                    }
                }
            }
            else{
                showSlideImage()
            }
        }
    }
    
    func showSlideImage(){
        let photoView = self.subviews[self.tapedPhotoViewTag] as! UIImageView
        let image = (self.subviews[self.tapedPhotoViewTag] as! UIImageView).image
        
        let window = UIApplication.shared.keyWindow
        self.backgroundScrollView.frame = CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight)
        //config scroll view
        self.backgroundScrollView.contentSize = CGSize(width: screenWidth * CGFloat(self.picsUrl.count), height: screenHeight)
        self.backgroundScrollView.contentOffset = CGPoint(x: screenWidth * CGFloat(self.tapedPhotoViewTag), y: 0)
        self.backgroundScrollView.isPagingEnabled = true
        self.backgroundScrollView.isUserInteractionEnabled = true
        
        self.backgroundScrollView.backgroundColor = UIColor.black
        self.backgroundScrollView.alpha = 0
        let imageView = UIImageView(frame: CGRECT(photoView.frame.origin.x + screenWidth * CGFloat(self.tapedPhotoViewTag), (screenHeight - photoView.frame.height)/2, photoView.frame.width, photoView.frame.height))
        
        imageView.image = image
        imageView.tag = 1
        self.backgroundScrollView.addSubview(imageView)
        window?.addSubview(self.backgroundScrollView)
        let hide = UITapGestureRecognizer(target: self, action: #selector(FeedPhotosView.hideImage(_:)))
        self.backgroundScrollView.addGestureRecognizer(hide)
        UIView.animate(withDuration: 0.3, animations:{ () in
            let vsize = UIScreen.main.bounds.size
            imageView.frame = CGRect(x:screenWidth * CGFloat(self.tapedPhotoViewTag), y: 0.0, width: vsize.width, height: vsize.height)
            imageView.contentMode = .scaleAspectFit
            self.backgroundScrollView.alpha = 1
            }, completion: {(finished:Bool) in
                if self.tapedPhotoViewTag > 0 {
                    for index in 0...(self.tapedPhotoViewTag - 1){
                        let imageView = UIImageView(frame: CGRECT(screenWidth * CGFloat(index), 0.0, screenWidth, screenHeight))
                        imageView.sd_setImage(with: URL(string: self.picsUrl[index] + "@800h"), placeholderImage: UIImage(contentsOfFile: placeHolderStr), options: SDWebImageOptions.cacheMemoryOnly)
                        imageView.contentMode = .scaleAspectFit
                        self.backgroundScrollView.addSubview(imageView)
                    }
                }
                if (self.tapedPhotoViewTag + 1) < (self.subviews.count ) {
                    for index in (self.tapedPhotoViewTag+1)...(self.subviews.count - 1){
                        let imageView = UIImageView(frame: CGRECT(screenWidth * CGFloat(index), 0.0, screenWidth, screenHeight))
                        imageView.sd_setImage(with: URL(string: self.picsUrl[index] + "@800h"), placeholderImage: UIImage(contentsOfFile: placeHolderStr), options: SDWebImageOptions.cacheMemoryOnly)
                        imageView.contentMode = .scaleAspectFit
                        self.backgroundScrollView.addSubview(imageView)
                    }
                }
        })
    }
    
    func hideImage(_ sender: UITapGestureRecognizer){
        if sender.view == backgroundScrollView {
            self.backgroundScrollView.removeFromSuperview()
        }
    }
    // MARK: - 单张图片布局
    
    func layoutForPic() {
    
        let count = self.picsUrl.count
        let maxCols = getPhotosMaxCols(count)
        
        for i in 0 ..< count {
        
            let imageView: UIImageView = self.subviews[i] as! UIImageView
            
            let photoW: CGFloat = kPhotosWidth
            let photoH: CGFloat = kPhotosWidth
            let photoX: CGFloat = CGFloat(i % maxCols) * (kPhotosWidth + CGFloat(kPhotosMargin))
            let photoY: CGFloat = CGFloat(i / maxCols) * (kPhotosWidth + CGFloat(kPhotosMargin))

            imageView.frame = CGRECT(photoX, photoY, photoW, photoH)
        }
    }
    
    // MARK: - 图片布局
    
        class func layoutForPhotos(_ photoCount: Int) -> CGSize {
    
        let maxCols = getPhotosMaxCols(photoCount)
        
        // 总列数
        let totalCols = photoCount > maxCols ? maxCols : photoCount
        
        // 总行数
        let totalRows: Int = (photoCount + maxCols - 1) / maxCols
        
        // 总宽度
        let width: CGFloat = CGFloat(totalCols * Int(kPhotosWidth) + (totalCols - 1) * kPhotosMargin)
        let height = CGFloat(totalRows * Int(kPhotosHeight) + (totalRows - 1) * kPhotosMargin)

        return CGSize(width: width, height: height)
    }
}
