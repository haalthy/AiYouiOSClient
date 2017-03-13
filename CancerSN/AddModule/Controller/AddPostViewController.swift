//
//  AddPostViewController.swift
//  CancerSN
//
//  Created by lily on 8/4/15.
//  Copyright (c) 2015 lily. All rights reserved.
//

import UIKit
//class AddPostViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate, MentionVCDelegate, PostTagDelegate, UIActionSheetDelegate, ZLPhotoPickerBrowserViewControllerDataSource, ZLPhotoPickerBrowserViewControllerDelegate, ZLPhotoPickerViewControllerDelegate {
class AddPostViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate, MentionVCDelegate, PostTagDelegate, UIActionSheetDelegate,ZLPhotoPickerBrowserViewControllerDataSource, ZLPhotoPickerBrowserViewControllerDelegate {

    var isQuestion: Bool = true
    var isComment:Int = 0
    var postID: Int? = nil
    
    var keyboardheight:CGFloat = 0

    let viewHorizonMargin = CGFloat(15)
    let textViewVerticalMargin = CGFloat(15)
    let textViewHeight = CGFloat(170)
    let textViewFont = UIFont.systemFont(ofSize: 15)
    let textViewTextColor: UIColor = defaultTextColor
    
    let imageLength: CGFloat = 60
    let imageMargin: CGFloat = 6
    let imageSectionButtomSpace: CGFloat = 12
    let imageSectionTopSpace: CGFloat = 135
    let imageDeleteBtnLength: CGFloat = 13
    
    let tagSectionTopMargin: CGFloat = 12
    let tagSectionTitleFont: UIFont = UIFont.systemFont(ofSize: 12)
    let tagSectionTitleTextColor: UIColor = lightTextColor
    
    let tagSecitonTopSpace: CGFloat = 12
    let tagSectionBtnTextVerticalMargin: CGFloat = 8
    let tagSectionBtnTextHorizonMargin: CGFloat = 15
    let tagSectionBtnVerticalMargin: CGFloat = 11
    let tagSectionBtnHorizonMargin: CGFloat = 6
    let tagSectionHeight: CGFloat = 96
    let tagBtnFont = UIFont.systemFont(ofSize: 13)
    
    let buttomSectionHeight: CGFloat = 45
    let buttomSectionItemLeftSpace: CGFloat = 26
    let buttomSectionItemHorizonMargin: CGFloat = 42
    let buttomItemIconLength: CGFloat = 24
    var headerHeight = CGFloat()
    
    let textView = UITextView()
    let imageSection = UIView()
    let defaultAddImageBtn = UIButton()
    let tagSection = UIView()
    let buttomSection = UIView()
    let buttomSectionColor = UIColor.init(red: 245 / 255, green: 245 / 255, blue: 245 / 255, alpha: 1)
    
    let keychainAccess = KeychainAccess()
    let haalthyService = HaalthyService()
    let publicService = PublicService()
    let getAccessToken = GetAccessToken()
    
    var imagePicker = UIImagePickerController()

    var tagList:NSArray?
    
    var imageInfoList = NSMutableArray()
    var imageCountPerLine: Int = 0
    
    var selectTagLabel = NSMutableArray()
    
    var selectedTagList = NSArray()
    
    var mentionUsernameList = NSMutableArray()
    var imageViewArr = NSMutableArray()
    
    var progressHUD: MBProgressHUD?
    
    @IBOutlet weak var submitBtn: UIButton!
    override func viewDidLoad() {
        
        getAccessToken.getAccessToken()
        
        let accessToken = UserDefaults.standard.object(forKey: accessNSUserData)
        
        if accessToken != nil {
            super.viewDidLoad()
            initVariables()
            initContentView()
        }else{
            let alertController = UIAlertController(title: "需要登录才能添加信息", message: nil, preferredStyle: .alert)
            
            let cancelAction = UIAlertAction(title: "取消", style: .default) { (action) in
                self.dismiss(animated: true, completion: nil)
            }
            
            alertController.addAction(cancelAction)
            let loginAction = UIAlertAction(title: "登陆", style: .cancel) { (action) in
                let storyboard = UIStoryboard(name: "Registeration", bundle: nil)
                let controller = storyboard.instantiateViewController(withIdentifier: "LoginEntry") as UIViewController
                self.present(controller, animated: true, completion: nil)
            }
            alertController.addAction(loginAction)
            
            self.present(alertController, animated: true) {
                // ...
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: view.frame.size.width - 120, height: 44))
        titleLabel.textAlignment = NSTextAlignment.center
        if self.isQuestion {
            titleLabel.text = "提出问题"
        }else{
            titleLabel.text = "发表心得"
        }
        titleLabel.textColor = UIColor.white
        self.navigationItem.titleView = titleLabel
    }
    
    func initVariables(){
        NotificationCenter.default.addObserver(self, selector: #selector(AddPostViewController.keyboardWillAppear(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(AddPostViewController.keyboardWillDisappear(_:)), name:NSNotification.Name.UIKeyboardWillHide, object: nil)
        imagePicker.delegate = self
        imageCountPerLine = Int((screenWidth - viewHorizonMargin * 2) / imageLength)
        
        headerHeight = UIApplication.shared.statusBarFrame.height + (self.navigationController?.navigationBar.frame.height)!
        submitBtn.isEnabled = false
        submitBtn.setTitleColor(lightTextColor, for: UIControlState())
        self.isQuestion = (self.navigationController as! AddPostNavigationViewController).isQuestion
    }
    
    func initContentView(){
        //text View
        textView.frame = CGRect(x: viewHorizonMargin, y: textViewVerticalMargin, width: screenWidth - 2 * viewHorizonMargin, height: textViewHeight)
        textView.textColor = ultraLightTextColor
        if self.isQuestion {
            textView.text = "请输入问题"
        }else{
            textView.text = "我的心情..."
        }
        textView.font = textViewFont
        textView.delegate = self
        textView.returnKeyType = UIReturnKeyType.default
        self.view.addSubview(textView)
        
        //imageSection
        imageSection.frame = CGRect(x: viewHorizonMargin, y: imageSectionTopSpace + headerHeight, width: screenWidth - 2 * viewHorizonMargin, height: imageLength)
        defaultAddImageBtn.frame = CGRect(x: 0, y: 0, width: imageLength, height: imageLength)
        let defaultAddImageView = UIImageView(frame: CGRECT(0, 0, imageLength, imageLength))
        defaultAddImageView.image = UIImage(named: "btn_addImage")
        defaultAddImageBtn.addSubview(defaultAddImageView)
        defaultAddImageBtn.addTarget(self, action: #selector(AddPostViewController.selectImages), for: UIControlEvents.touchUpInside)
        imageSection.addSubview(defaultAddImageBtn)
        self.view.addSubview(imageSection)
        
        //tag section
        if self.isQuestion == true {

            NetRequest.sharedInstance.GET(getTopTagListURL, parameters: [:], success: { (content, message) -> Void in
                if (content is NSArray){
                    self.tagList = content as? NSArray
                }
                self.tagSection.frame = CGRect(x: self.viewHorizonMargin, y: self.imageSection.frame.origin.y + self.imageSection.frame.height + self.tagSectionTopMargin, width: screenWidth - 2 * self.viewHorizonMargin, height: self.tagSectionHeight)
                let tagTitle = UILabel(frame: CGRect(x: 0, y: 0, width: screenWidth - 2 * self.viewHorizonMargin, height: 13))
                tagTitle.font = self.tagSectionTitleFont
                tagTitle.textColor = self.tagSectionTitleTextColor
                tagTitle.text = "选择标签，更多人能看到你的问题"
                self.tagSection.addSubview(tagTitle)
                
                var tagBtnX: CGFloat = 0
                var tagBtnY: CGFloat = 24
                var displayTagCount: Int = 0
                for tag in self.tagList! {
                    let tagName = (tag as! NSDictionary).object(forKey: "name") as! String
                    let tagTextSize = tagName.sizeWithFont(self.tagBtnFont, maxSize: CGSize(width: CGFloat.greatestFiniteMagnitude, height: 13))
                    if ((tagTextSize.width + self.tagSectionBtnTextHorizonMargin*2) + tagBtnX) > (screenWidth - self.viewHorizonMargin){
                        tagBtnX = 0
                        tagBtnY += 34
                    }
                    if tagBtnY > 70{
                        break
                    }
                    tagBtnX += tagTextSize.width + self.tagSectionBtnTextVerticalMargin * 2 + self.tagSectionBtnHorizonMargin
                    displayTagCount += 1
                }
                displayTagCount = displayTagCount-2
                //        var tagIndex: Int = 0
                tagBtnX = 0
                tagBtnY = 24
                for tagIndex in 0 ... displayTagCount{
                    let tag: NSDictionary = self.tagList?.object(at: tagIndex) as! NSDictionary
                    let tagName = tag.object(forKey: "name") as! String
                    let tagTextSize = tagName.sizeWithFont(self.tagBtnFont, maxSize: CGSize(width: CGFloat.greatestFiniteMagnitude, height: 13))
                    if ((tagTextSize.width + self.tagSectionBtnTextHorizonMargin*2) + tagBtnX) > (screenWidth - self.viewHorizonMargin){
                        tagBtnX = 0
                        tagBtnY += 34
                    }
                    let tagButton = UIButton(frame: CGRect(x: tagBtnX, y: tagBtnY, width: tagTextSize.width + self.tagSectionBtnTextVerticalMargin * 2, height: 29))
                    tagButton.setTitle(tagName, for: UIControlState())
                    tagButton.setTitleColor(headerColor, for: UIControlState())
                    tagButton.titleLabel?.font = self.tagBtnFont
                    tagButton.layer.borderColor = headerColor.cgColor
                    tagButton.layer.borderWidth = 1
                    tagButton.layer.cornerRadius = 2
                    tagBtnX += tagButton.frame.width + self.tagSectionBtnHorizonMargin
                    tagButton.addTarget(self, action: #selector(AddPostViewController.selectedTag(_:)), for: UIControlEvents.touchUpInside)
                    self.tagSection.addSubview(tagButton)
                }
                
                //更多
                let tagTextSize = String("更多>").sizeWithFont(self.tagBtnFont, maxSize: CGSize(width: CGFloat.greatestFiniteMagnitude, height: 13))
                let tagButton = UIButton(frame: CGRect(x: tagBtnX, y: tagBtnY, width: tagTextSize.width + self.tagSectionBtnTextVerticalMargin * 2, height: 29))
                tagButton.setTitle("更多>", for: UIControlState())
                tagButton.setTitleColor(headerColor, for: UIControlState())
                tagButton.titleLabel?.font = self.tagBtnFont
                tagButton.layer.borderColor = headerColor.cgColor
                tagButton.layer.borderWidth = 1
                tagButton.layer.cornerRadius = 2
                tagBtnX += tagButton.frame.width + self.tagSectionBtnHorizonMargin
                self.tagSection.addSubview(tagButton)
                tagButton.addTarget(self, action: "selectTags:", for: UIControlEvents.touchUpInside)
                self.view.addSubview(self.tagSection)


                HudProgressManager.sharedInstance.dismissHud()
                }) { (content, message) -> Void in

                    
            }

        }
        
        //ButtomSection
        buttomSection.frame = CGRECT(0, screenHeight - buttomSectionHeight, screenWidth, buttomSectionHeight)
        buttomSection.backgroundColor = buttomSectionColor

        let mentionedBtn = UIButton(frame: CGRECT(buttomSectionItemLeftSpace, 11, buttomItemIconLength, buttomItemIconLength))
        let mentionedImageView = UIImageView(frame: CGRECT(0, 0, buttomItemIconLength, buttomItemIconLength))
        mentionedImageView.image = UIImage(named: "btn_mentioned")
        mentionedBtn.addSubview(mentionedImageView)
        mentionedBtn.addTarget(self, action: #selector(AddPostViewController.selectContacts), for: UIControlEvents.touchUpInside)
        buttomSection.addSubview(mentionedBtn)
        self.view.addSubview(buttomSection)
        
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(AddPostViewController.tapDismiss))
        self.view.addGestureRecognizer(tapGesture)
    }
    
    func tapDismiss(){
        self.view.endEditing(true)
    }
    
    func selectTags(_ sender: UIButton){
        let storyboard = UIStoryboard(name: "Registeration", bundle: nil)
        let tagViewController = storyboard.instantiateViewController(withIdentifier: "TagEntry") as! FeedTagsViewController
        tagViewController.isSelectedByPost = true
        tagViewController.postDelegate = self
        self.present(tagViewController, animated: true, completion: nil)
    }
    
    func keyboardWillAppear(_ notification: Notification) {
        
        if self.buttomSection.center.y > UIScreen.main.bounds.height - 50{
            // 获取键盘信息
            let keyboardinfo = notification.userInfo![UIKeyboardFrameBeginUserInfoKey]
            
            keyboardheight = ((keyboardinfo as AnyObject).cgRectValue.size.height)
            
            self.buttomSection.center = CGPoint(x: self.buttomSection.center.x, y: self.buttomSection.center.y - keyboardheight)
            
            self.view.bringSubview(toFront: buttomSection)

        }
    }
    
    func keyboardWillDisappear(_ notification:Notification){
        
        self.buttomSection.center = CGPoint(x: self.buttomSection.center.x, y: self.buttomSection.center.y + keyboardheight)
    }

    @IBAction func cancel(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func selectImages() {
        
        let sysVersion: NSString = UIDevice.current.systemVersion as NSString
        if sysVersion.floatValue > 8.2 {
            
            let alertController: UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            
            let cancelAction: UIAlertAction = UIAlertAction(title: "取消", style: .cancel, handler: { (action) -> Void in
                
            })
            
            let cameraAction: UIAlertAction = UIAlertAction(title: "相机", style: .default, handler: { (action) -> Void in
                self.openCameraAction()
            })
            let photoAction: UIAlertAction = UIAlertAction(title: "照片库", style: .default, handler: { (action) -> Void in
                self.openPhotoAction()
            })
            alertController.addAction(cancelAction)
            alertController.addAction(cameraAction)
            alertController.addAction(photoAction)
            self.present(alertController, animated: true, completion: nil)
        }
        else {
        
            let actionSheet: UIActionSheet = UIActionSheet(title: nil, delegate: self, cancelButtonTitle: "取消", destructiveButtonTitle: nil, otherButtonTitles: "相机", "照片库")
            actionSheet.show(in: self.view)

        }
        
    }
    
    // MARK: 打开相机
    
    func openCameraAction() {
        
        imagePicker.allowsEditing = false //2
        imagePicker.sourceType = .camera //3
        present(imagePicker, animated: true, completion: nil)//4

    }
    
    // MARK: 打开相册
    
    func openPhotoAction() {
    
    
        let pickView: ZLPhotoPickerViewController = ZLPhotoPickerViewController()
        // 默认显示相册里面的内容SavePhotos
        pickView.status = PickerViewShowStatus.cameraRoll
        pickView.selectPickers = self.imageInfoList as [AnyObject]
        // 最多能选9张图片
        pickView.maxCount = 9
//        pickView.delegate = self
        pickView.showPickerVc(self)

        
    }
    
    // MARK: - setupCell click ZLPhotoPickerBrowserViewController
    
    func setupPhotoBrowser(_ gesture: UITapGestureRecognizer) {
    
        
        // 图片浏览
        let pickerBrowser: ZLPhotoPickerBrowserViewController = ZLPhotoPickerBrowserViewController()
        pickerBrowser.delegate = self
        pickerBrowser.dataSource = self
        // 是否可以删除照片
        pickerBrowser.isEditing = true
        // 当前选中的值
        pickerBrowser.currentIndexPath = IndexPath.init(row: (gesture.view?.tag)!, section: 0)
            // 展示控制器
        pickerBrowser.showPickerVc(self)
        
    }
    
    //MARK: - 图片浏览
    
    //MARK: ZLPhotoPickerBrowserViewControllerDataSource
    
    func numberOfSectionInPhotos(inPickerBrowser pickerBrowser: ZLPhotoPickerBrowserViewController!) -> Int {
        return 1
    }
    
    func photoBrowser(_ photoBrowser: ZLPhotoPickerBrowserViewController!, numberOfItemsInSection section: UInt) -> Int {
        return self.imageInfoList.count
    }
    
    // MARK: 每个组展示什么图片,需要包装下ZLPhotoPickerBrowserPhoto
    
    func photoBrowser(_ pickerBrowser: ZLPhotoPickerBrowserViewController!, photoAt indexPath: IndexPath!) -> ZLPhotoPickerBrowserPhoto! {
        
        let imageObj = self.imageInfoList[indexPath.row]
        // 包装下imageObj 成 ZLPhotoPickerBrowserPhoto 传给数据源
        let photo: ZLPhotoPickerBrowserPhoto = ZLPhotoPickerBrowserPhoto(anyImageObjWith: imageObj)
        
        let imageView: UIImageView = self.imageViewArr[indexPath.row] as! UIImageView
        photo.toView = imageView
        photo.thumbImage = imageView.image
        return photo

    }
    
    // MARK: 删除照片调用
    
    func photoBrowser(_ photoBrowser: ZLPhotoPickerBrowserViewController!, removePhotoAt indexPath: IndexPath!) {
        
        self.imageInfoList.removeObject(at: indexPath.row)
        self.redrawImageInfo()
    }
    
    // MARK: 获取到相册图片
    
    func pickerViewControllerDoneAsstes(_ assets: [AnyObject]!) {
        
        if self.imageInfoList.count + assets.count > 9 {
        
            HudProgressManager.sharedInstance.showOnlyTextHudProgress(self, title: "最多上传9张图片！")
            return
        }
        
        let assetImageArr: NSMutableArray = NSMutableArray(array: assets)
        
        
        self.imageInfoList.removeAllObjects()
        self.imageViewArr.removeAllObjects()
        
        redrawImageInfo()
        
        self.imageInfoList = NSMutableArray(array: assets)
        
        for i in 1...assetImageArr.count{
        
            
            if assetImageArr[i - 1] is UIImage {
                
                self.showPhotoLocation(assetImageArr[i - 1] as! UIImage, index: i)

            }
            else {
                let assetImage: ZLPhotoAssets = assetImageArr[i - 1] as! ZLPhotoAssets
                self.showPhotoLocation(assetImage.originImage(), index: i)

            }
        }
        
    }
    

    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let chosenImage = info[UIImagePickerControllerOriginalImage] as! UIImage //

        self.imageInfoList.add(chosenImage)
        
        // 展示图片
        self.showPhotoLocation(chosenImage, index: self.imageInfoList.count)
        
        dismiss(animated: true, completion: nil) //5
        
    }
    
    // MARK: 将image转化为提交格式
    
    func makeImageToCorrespondingFormat(_ array: NSMutableArray) -> NSMutableArray {
    
        let resultArr: NSMutableArray = NSMutableArray(capacity: 0)
        for item in array {
        
            var targetImage: UIImage = UIImage()
            if item is UIImage {
            
                targetImage = item as! UIImage
            }
            else {
            
                let assetImage: ZLPhotoAssets = item as! ZLPhotoAssets
                targetImage = assetImage.originImage()
            }
            
            targetImage = publicService.resizeImage(targetImage, newSize: uploadImageSize)
            let imageData: Data = UIImagePNGRepresentation(targetImage)!
            let imageDataStr = imageData.base64EncodedString(options: [])
            let imageInfo = NSDictionary(objects: [imageDataStr, "jpg"], forKeys: ["data" as NSCopying, "type" as NSCopying])
            resultArr.add(imageInfo)
        }
        
        return resultArr
    }
    
    // MARK: 展示图片位置
    
    func showPhotoLocation(_ image: UIImage, index: Int) {
    
        let addNextImageLinePositionY: CGFloat = CGFloat(Int(index/imageCountPerLine)) * (imageLength + imageMargin)
        
        let coordinateX = CGFloat(imageLength+imageMargin)*CGFloat(index%imageCountPerLine)
        let imageViewContainer = UIView(frame: CGRect(x: defaultAddImageBtn.frame.origin.x, y: defaultAddImageBtn.frame.origin.y, width: imageLength, height: imageLength))
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: imageLength, height: imageLength))
        imageView.tag = index - 1
        self.imageViewArr.add(imageView)
        let gesgure: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(AddPostViewController.setupPhotoBrowser(_:)))
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(gesgure)
        let imageDeleteBtn = UIButton(frame: CGRECT(imageLength - imageDeleteBtnLength, 0, imageDeleteBtnLength, imageDeleteBtnLength))
        let imageDeleteView = UIImageView(frame: CGRECT(0, 0, imageDeleteBtnLength, imageDeleteBtnLength))
        imageDeleteView.image = UIImage(named: "btn_imageDelete")
        imageDeleteBtn.addSubview(imageDeleteView)
        imageDeleteBtn.addTarget(self, action: #selector(AddPostViewController.deleteImage(_:)), for: UIControlEvents.touchUpInside)
        
        defaultAddImageBtn.frame = CGRect(x: coordinateX, y: addNextImageLinePositionY, width: imageLength, height: imageLength)
        
        imageSection.frame = CGRECT(imageSection.frame.origin.x, imageSection.frame.origin.y, imageSection.frame.width, imageSection.frame.height + imageLength + imageMargin)
        
        
        var selectedImage = UIImage()

        selectedImage = publicService.cropToSquare(image: image)
        
        let newSize = CGSize(width: imageLength, height: imageLength)
        UIGraphicsBeginImageContext(newSize)
//        UIGraphicsBeginImageContext(selectedImage.size)
        selectedImage.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        imageView.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        imageViewContainer.isUserInteractionEnabled = true
        self.imageSection.addSubview(imageViewContainer)
        imageViewContainer.addSubview(imageView)
        imageViewContainer.addSubview(imageDeleteBtn)
        if (index + 1)%imageCountPerLine == 1 {
            if isQuestion == true {
                self.tagSection.center = CGPoint(x: self.tagSection.center.x, y: self.tagSection.center.y + imageLength + imageMargin)
            }
        }
    }
    
    func deleteImage(_ sender: UIButton){
        let imageIndex: Int = getImageIndexByImageCenter(sender.superview!.center)
        self.imageInfoList.removeObject(at: imageIndex - 1)
        redrawImageInfo()
    }
    
    func getImageIndexByImageCenter(_ centerPoint: CGPoint) -> Int{
        let indexX: Int = Int(centerPoint.x / (imageLength + imageMargin)) + 1
        let indexY: Int = Int(centerPoint.y / (imageLength + imageMargin))
        return indexY * imageCountPerLine + indexX
    }
    
    func redrawImageInfo(){
        for subView in imageSection.subviews {
            if (subView is UIButton) == false {
                subView.removeFromSuperview()
            }
        }
        
        self.imageViewArr.removeAllObjects()
        
        var imageIndex: Int = 0
        for imageInfo in imageInfoList{
            let coordinateX: CGFloat = CGFloat(imageIndex % imageCountPerLine) * (imageLength + imageMargin)
            let coordinateY: CGFloat = CGFloat(imageIndex / imageCountPerLine) * (imageLength + imageMargin)
            
            let imageViewContainer = UIView(frame: CGRect(x: coordinateX, y: coordinateY, width: imageLength, height: imageLength))
            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: imageLength, height: imageLength))
            
            imageView.tag = imageIndex
            self.imageViewArr.add(imageView)
            let gesgure: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(AddPostViewController.setupPhotoBrowser(_:)))
            imageView.isUserInteractionEnabled = true
            imageView.addGestureRecognizer(gesgure)
            
            let imageDeleteBtn = UIButton(frame: CGRECT(imageLength - imageDeleteBtnLength, 0, imageDeleteBtnLength, imageDeleteBtnLength))
            let imageDeleteView = UIImageView(frame: CGRECT(0, 0, imageDeleteBtnLength, imageDeleteBtnLength))
            imageDeleteView.image = UIImage(named: "btn_imageDelete")
            imageDeleteBtn.addSubview(imageDeleteView)
            imageDeleteBtn.addTarget(self, action: #selector(AddPostViewController.deleteImage(_:)), for: UIControlEvents.touchUpInside)
            
            var image = UIImage()
            let publicService = PublicService()
            
            if imageInfo is UIImage {
                image = imageInfo as! UIImage
            }
            else {
                image = (imageInfo as! ZLPhotoAssets).originImage()
            }
            
            let selectedImage = publicService.cropToSquare(image: image)
            
            let newSize = CGSize(width: imageLength, height: imageLength)
            UIGraphicsBeginImageContext(newSize)
            selectedImage.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
            imageView.image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            self.imageSection.addSubview(imageViewContainer)
            imageViewContainer.addSubview(imageView)
            imageViewContainer.addSubview(imageDeleteBtn)
            imageIndex += 1
        }
        
        defaultAddImageBtn.frame = CGRect(x: CGFloat((imageInfoList.count) % imageCountPerLine) * (imageLength + imageMargin), y: CGFloat((imageInfoList.count) / imageCountPerLine) * (imageLength + imageMargin), width: imageLength, height: imageLength)
        
        let imageSectionH: CGFloat = CGFloat(imageIndex / imageCountPerLine + 1) * (imageLength + imageMargin)
        
        imageSection.frame = CGRECT(viewHorizonMargin, imageSectionTopSpace + headerHeight, screenWidth - 2 * viewHorizonMargin, imageSectionH)
        
        if isQuestion == true {
            self.tagSection.frame = CGRECT(tagSection.frame.origin.x, imageSection.frame.origin.y + imageSection.frame.height, tagSection.frame.width, tagSection.frame.height)
        }
    }
    
    func updatePostTagList(_ tagList: NSArray) {
//        self.selectedTagList = tagList
        for tag in tagList {
            let tagName: String = (tag as! NSDictionary).object(forKey: "name") as! String
            if self.selectTagLabel.contains(tagName) == false {
                self.selectTagLabel.add(tagName)
            }
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func selectedTag(_ sender:UIButton){
        if sender.backgroundColor == headerColor {
            sender.backgroundColor = UIColor.white
            sender.setTitleColor(headerColor, for: UIControlState())
            selectTagLabel.remove((sender.titleLabel?.text!)!)
        }else {
            sender.backgroundColor = headerColor
            sender.setTitleColor(UIColor.white, for: UIControlState())
            selectTagLabel.add((sender.titleLabel?.text!)!)
        }
    }
    
    @IBAction func submit(_ sender: UIButton) {
        if textView.text != "" {
            if((self.isQuestion == false) || ((self.isQuestion == true)&&(self.selectTagLabel.count>0))){
                let post = NSMutableDictionary()
                post.setObject(textView.text, forKey: "body" as NSCopying)
                post.setObject(0, forKey: "closed" as NSCopying)
                if self.isQuestion {
                    post.setObject(1, forKey: "isBroadcast" as NSCopying)
                }else{
                    post.setObject(0, forKey: "isBroadcast" as NSCopying)
                }
                post.setObject("TXT", forKey: "type" as NSCopying)
                post.setObject(keychainAccess.getPasscode(usernameKeyChain)!, forKey: "insertUsername" as NSCopying)
                //get mentioned user List
                let postContentStr = textView.text
                let firstRange = postContentStr?.range(of: "@")
                
                if firstRange != nil {
                    let postContentArr = postContentStr?.substring(from: (firstRange!).lowerBound).components(separatedBy: "@")
                    for subStr in postContentArr!{
                        if (subStr as NSString).length > 0{
                            var subStrArr = (subStr ).components(separatedBy: " ")
                            if (subStrArr.count > 0) && (subStrArr[0] as NSString).length > 0{
                                let getMentionedUsernamesRequest = NSMutableDictionary()
                                getMentionedUsernamesRequest.setObject(keychainAccess.getPasscode(usernameKeyChain)!, forKey: "username" as NSCopying)
                                getMentionedUsernamesRequest.setObject(subStrArr[0], forKey: "mentionedDisplayname" as NSCopying)
                                let mentionedUsers = haalthyService.getUsersByDisplayname(getMentionedUsernamesRequest)
                                for user in mentionedUsers{
                                    mentionUsernameList.add((user as AnyObject).object(forKey: "username")!)
                                }
                            }
                        }
                    }
                    
                    if mentionUsernameList.count > 0 {
                        post.setObject(self.mentionUsernameList, forKey: "mentionUsers" as NSCopying)
                    }
                }
                //            post.setObject(self.makeImageToCorrespondingFormat(self.imageInfoList), forKey: "imageInfos")
                post.setObject(self.imageInfoList.count, forKey: "hasImage" as NSCopying)
                
                if(self.isQuestion == true){
                    post.setObject(self.getSelectedTagList(), forKey: "tags" as NSCopying)
                }
                
                let result:Int = haalthyService.addPost(post as NSDictionary)
                //            dispatch_async(dispatch_get_main_queue()) {
                //                self.submitImages(result)
                //            }
                
                DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async(execute: {
                    self.submitImages(result)
                    DispatchQueue.main.async(execute: {
                        
                    })
                })
                HudProgressManager.sharedInstance.dismissHud()
                if result > 0 {
                    HudProgressManager.sharedInstance.showSuccessHudProgress(self, title: "提交成功")
                }else {
                    HudProgressManager.sharedInstance.showOnlyTextHudProgress(self, title: "提交失败")
                }
                self.dismiss(animated: false, completion: nil)
                
            }else{
                let storyboard = UIStoryboard(name: "Registeration", bundle: nil)
                let tagViewController = storyboard.instantiateViewController(withIdentifier: "TagEntry") as! FeedTagsViewController
                tagViewController.isSelectedByPost = true
                tagViewController.postDelegate = self
                self.present(tagViewController, animated: true, completion: nil)
            }
        }else{
            let alertController = UIAlertController(title: "内容不能为空", message: nil, preferredStyle: .alert)
            
            let cancelAction = UIAlertAction(title: "取消", style: .default) { (action) in
            }
            
            alertController.addAction(cancelAction)
            
            self.present(alertController, animated: true) {
            }
        }
    }

    func submitImages(_ id: Int){
        let imageInfosParameter = self.makeImageToCorrespondingFormat(self.imageInfoList)
        var index: Int = 0
        for imgeInfo in imageInfosParameter{
            
            getAccessToken.getAccessToken()
            let accessToken = UserDefaults.standard.object(forKey: accessNSUserData)
            
            let urlPath:String = (addPostImageURL as String) + "?access_token=" + (accessToken as! String)
            
            let requestBody = NSMutableDictionary()
            requestBody.setValue(id, forKey: "id")
            requestBody.setValue(index, forKey: "imageIndex")
            requestBody.setValue(imgeInfo, forKey: "imageInfo")
            NetRequest.sharedInstance.POST_A(urlPath, parameters: (requestBody as NSDictionary) as! Dictionary<String, AnyObject>)
            index += 1
        }
    }
    
    func getSelectedTagList()->NSArray{
        let selectedTagList = NSMutableArray()
        for tag in tagList! {
            if selectTagLabel.contains((tag as! NSDictionary).object(forKey: "name") as! String){
                selectedTagList.add(tag)
            }
        }
        return selectedTagList
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor != defaultTextColor {
            textView.text = nil
            textView.textColor = defaultTextColor
        }
        //        selectTagsButton.enabled = true
        submitBtn.isEnabled = true
        //        enableButtonFormat(selectTagsButton)
        submitBtn.setTitleColor(UIColor.white, for: UIControlState())
    }
    
    func selectContacts(){
        self.performSegue(withIdentifier: "contactSegue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "selectTagSegue" {
//            let tagViewController = segue.destinationViewController as! TagTableViewController
//            //            tagViewController.postBody = postContent.text
//            tagViewController.isBroadcastTagSelection = 1
////            tagViewController.postDelegate = self
//        }
        
        if segue.identifier == "contactSegue" {
            let contactController = segue.destination as! ContactTableViewController
            contactController.mentionVCDelegate = self
        }
    }
    
    func updateMentionList(_ userListStr: String) {
        if textView.textColor == defaultTextColor {
            textView.text = textView.text + userListStr
        }else {
            textView.text = userListStr
            textView.textColor = defaultTextColor
        }
    }
}

