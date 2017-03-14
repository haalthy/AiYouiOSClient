//
//  AddPatientStatusViewController.swift
//  CancerSN
//
//  Created by hui luo on 22/1/2016.
//  Copyright © 2016 lily. All rights reserved.
//

import UIKit
import CoreData
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


//class AddPatientStatusViewController: UIViewController, UITextViewDelegate, UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, ZLPhotoPickerBrowserViewControllerDataSource, ZLPhotoPickerBrowserViewControllerDelegate, ZLPhotoPickerViewControllerDelegate{
class AddPatientStatusViewController: UIViewController, UITextViewDelegate, UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, ZLPhotoPickerBrowserViewControllerDataSource, ZLPhotoPickerBrowserViewControllerDelegate{

    //context For LocalDB
    var context:NSManagedObjectContext?
    
    //global variable
    let getAccessToken = GetAccessToken()
    let keychainAccess = KeychainAccess()
    let profileSet = UserDefaults.standard
    let setPatientStatusFormatTimeStamp = "setPatientStatusFormatTimeStamp"


    var headerHeight: CGFloat = CGFloat()
    var screenWidth = UIScreen.main.bounds.width
    var patientStatusFormatList = NSArray()
    var clinicReportFormatList = NSArray()
    var keyboardheight:CGFloat = 0
    var patientStatusDetail: String = String()
    var clinicRowsCount:Int = 0
    var defaultClinicRowsName = NSMutableArray()
    var selfDefinedCilnicRowName = NSMutableArray()
    var clinicDataList = NSMutableArray()

    //date section
    var dateSection = UIView()
    var scrollView = UIScrollView()
    var symptomsSection = UIView()
    var symptomDesp = UITextView()
    var reportView = UIView()
    var checkedView = UIView()
    var clinicReportViewList = UIView()
    let reportTextInput = UITextField()
    let scanReportText = UITextView()
    var clinicTableView = UITableView()
    let dateBtn = UIButton()
    var isSelectedDate: Bool = false
    
    var datePickerContainerView = UIView()
    var datePicker = UIDatePicker()
    
    var dateInserted: Foundation.Date?
    var isPosted: Int = 0
    
    var scrollViewOffset: CGFloat = 0
    
    var addReportBtn = UIButton()
    
    var date:Foundation.Date = Foundation.Date()
    
    let transparentView = UIView()
    
    //image Section
    let imageSection = UIView()
    let imageLength: CGFloat = 60
    let defaultAddImageBtn = UIButton()
    var imagePicker = UIImagePickerController()
    var imageInfoList = NSMutableArray()
    var imageViewArr = NSMutableArray()
    let publicService = PublicService()
    var imageCountPerLine: Int = 0
    let imageMargin: CGFloat = 6
    let imageDeleteBtnLength: CGFloat = 13
    let viewHorizonMargin = CGFloat(15)
    
    @IBOutlet weak var submitBtn: UIButton!
    override func viewDidLoad() {
        let appDel:AppDelegate = (UIApplication.shared.delegate as! AppDelegate)
        context = appDel.managedObjectContext!
        getAccessToken.getAccessToken()
        let accessToken = UserDefaults.standard.object(forKey: accessNSUserData)
        
        if accessToken != nil {
            initVariables()
            initContentView()
            NotificationCenter.default.addObserver(self, selector: #selector(AddPatientStatusViewController.keyboardWillAppear(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(AddPatientStatusViewController.keyboardWillDisappear(_:)), name:NSNotification.Name.UIKeyboardWillHide, object: nil)
            clinicTableView.delegate = self
            clinicTableView.dataSource = self
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
    
    func initVariables(){
        scrollView.delegate = self
        headerHeight = UIApplication.shared.statusBarFrame.height + (self.navigationController?.navigationBar.frame.height)!
        dateInserted = Foundation.Date()
        getPatientStatusFormat()
        imageCountPerLine = Int((screenWidth - viewHorizonMargin * 2) / imageLength)
    }
    
    func initContentView(){
        //设置透明层
        transparentView.frame = CGRECT(0, 0, UIScreen.main.bounds.width, UIScreen.main.bounds.height)
        transparentView.backgroundColor = UIColor.lightGray
        transparentView.alpha = 0.6
        //
        dateSection = UIView(frame: CGRect(x: 0, y: headerHeight, width: screenWidth, height: patientStatusDateSectionHeight))
        let dateLabel = UILabel(frame: CGRect(x: patientStatusDateLabelLeftSpace, y: 0, width: 39, height: patientStatusDateSectionHeight))
        dateLabel.text = "日期："
        dateLabel.textColor = patientStatusDataLabelColor
        dateLabel.font = patientStatusDateLabelFont
        dateSection.addSubview(dateLabel)
        
        // add date button
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY/MM/dd" // superset of OP's format
        let dateStr = dateFormatter.string(from: dateInserted!)
        let dateBtnTextSize = dateStr.sizeWithFont(patientStatusDateBtnFont, maxSize: CGSize(width: screenWidth, height: CGFloat.greatestFiniteMagnitude))
        dateBtn.frame = CGRect(x: patientStatusDateLabelLeftSpace + 39, y: 0, width: dateBtnTextSize.width + patientStatusDropdownLeftSpace + patientStatusDropdownW, height: patientStatusDateSectionHeight)
        dateBtn.setTitle(dateStr, for: UIControlState())
        dateBtn.setTitleColor(headerColor, for: UIControlState())
        dateBtn.titleLabel?.font = patientStatusDateBtnFont
        dateBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignment.left
        dateBtn.addTarget(self, action: #selector(AddPatientStatusViewController.selectDate(_:)), for: UIControlEvents.touchUpInside)
        let dropdownImageView: UIImageView = UIImageView(frame: CGRECT(dateBtnTextSize.width + patientStatusDropdownLeftSpace, 0, patientStatusDropdownW, patientStatusDateSectionHeight))
        dropdownImageView.image = UIImage(named: "btn_datedropdown")
        dropdownImageView.contentMode = UIViewContentMode.scaleAspectFit
        dateBtn.addSubview(dropdownImageView)
        dateSection.addSubview(dateBtn)
        let dateSeperateLine = UIView(frame: CGRECT(0, patientStatusDateSectionHeight - 0.5, screenWidth, 0.5))
        dateSeperateLine.backgroundColor = seperateLineColor
        dateSection.addSubview(dateSeperateLine)
        self.view.addSubview(dateSection)
        
        //symptoms section
        let symptomsSectionW: CGFloat = screenWidth - 2 * symptomsSectionLeftSpace
        //symptons title
        let symptomsTitleSize = symptomsTitleStr.sizeWithFont(symptomsFont, maxSize: CGSize(width: symptomsSectionW, height: CGFloat.greatestFiniteMagnitude))
        let symptomsTitleLbl = UILabel(frame: CGRECT(0, symptomsTitleTopSpace, symptomsTitleSize.width, symptomsTitleSize.height))
        symptomsTitleLbl.text = symptomsTitleStr
        symptomsTitleLbl.textColor = symptomsTitleColor
        symptomsTitleLbl.font = symptomsFont
        symptomsSection.addSubview(symptomsTitleLbl)
        
        //symptons buttons
        var symptomBtnsX: CGFloat = 0
        var symptomBtnsY: CGFloat = symptomsBtnsTopSpace + symptomsTitleLbl.frame.height + symptomsTitleTopSpace
        for patientStatus in patientStatusFormatList {
            let symptomBtnText = (patientStatus as! NSDictionary).object(forKey: "statusName") as! String
            let symptomBtnTextSize = symptomBtnText.sizeWithFont(symptomsFont, maxSize: CGSize(width: symptomsSectionW - symptomBtnsX, height: symptomsBtnHeight))
            if symptomBtnsX + symptomBtnTextSize.width > symptomsSectionW {
                symptomBtnsX = 0
                symptomBtnsY += symptomsBtnHeight + 11
            }
            let symptomBtn = UIButton(frame: CGRECT(symptomBtnsX, symptomBtnsY, symptomBtnTextSize.width + 20, symptomsBtnHeight))
            symptomBtn.setTitle(symptomBtnText, for: UIControlState())
            symptomBtn.setTitleColor(headerColor, for: UIControlState())
            symptomBtn.titleLabel?.font = symptomsFont
            symptomBtn.layer.borderColor = headerColor.cgColor
            symptomBtn.layer.borderWidth = 1
            symptomBtn.layer.cornerRadius = 2
            symptomBtn.layer.masksToBounds = true
            symptomBtn.addTarget(self, action: #selector(AddPatientStatusViewController.selectSymptom(_:)), for: UIControlEvents.touchUpInside)
            symptomsSection.addSubview(symptomBtn)
            symptomBtnsX += symptomBtn.frame.width + 11
        }
        
        symptomsSection.frame = CGRECT(symptomsSectionLeftSpace, 0, symptomsSectionW, symptomBtnsY + symptomsBtnHeight + 13.0)
        let symptomSeperateLine = UIView(frame: CGRECT(0, symptomsSection.frame.height - 0.5, screenWidth, 0.5))
        symptomSeperateLine.backgroundColor = seperateLineColor
        symptomsSection.addSubview(symptomSeperateLine)
        self.scrollView.addSubview(symptomsSection)
        //add text view input
        symptomDesp.frame = CGRECT(symptomDespTextHorizonSpace, symptomDespTextTopSpace + symptomsSection.frame.height, screenWidth - 2 * symptomDespTextHorizonSpace, symptomDespTextHeight)
        symptomDesp.text = symptomDespText
        symptomDesp.textColor = textInputViewPlaceholderColor
        symptomDesp.font = symptomDespFont
        symptomDesp.delegate = self
        symptomDesp.returnKeyType = UIReturnKeyType.done
        self.scrollView.addSubview(symptomDesp)
    
        //add "more" button
        let addReportBtnW = screenWidth - 2 * addReportButtonLeftSpace
        let addReportBtnH = addReportBtnW * 90 / 690 + 40
        addReportBtn = UIButton(frame: CGRect(x: addReportButtonLeftSpace, y: symptomDespTextTopSpace + symptomsSection.frame.height + symptomDesp.frame.height + 50, width: addReportBtnW, height: addReportBtnH))
        let addReportImgView = UIImageView(frame: CGRECT(addReportBtnW / 2 - 15, 0, 31, 23))
        addReportImgView.image = UIImage(named: "addReportDragUp")
        addReportBtn.addSubview(addReportImgView)
        addReportBtn.setTitle(addReportButtonText, for: UIControlState())
        addReportBtn.setTitleColor(addReportButtonTextColor, for: UIControlState())
        addReportBtn.titleLabel?.font = addReportButtonFont
        addReportBtn.addTarget(self, action: #selector(AddPatientStatusViewController.addReport(_:)), for: UIControlEvents.touchUpInside)
        addReportBtn.titleLabel?.textAlignment = .center
        self.scrollView.addSubview(addReportBtn)
        
        scrollView.frame = CGRECT(0, headerHeight + dateSection.frame.height, screenWidth, UIScreen.main.bounds.height)
        self.view.addSubview(self.scrollView)
        scrollView.contentSize = CGSize(width: screenWidth, height: UIScreen.main.bounds.height + 10)
        scrollView.isPagingEnabled = false

        //add footer
        let privateCheckUIView = PrivateCheckUIView()
        checkedView = privateCheckUIView.createCheckedSection()
        self.view.addSubview(checkedView)
        privateCheckUIView.checkbox.addTarget(self, action: #selector(AddPatientStatusViewController.checkedPrivate(_:)), for: UIControlEvents.touchUpInside)
        
        self.scrollView.isUserInteractionEnabled = true
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(AddPatientStatusViewController.tapDismiss))
        self.scrollView.addGestureRecognizer(tapGesture)
        
        self.transparentView.isUserInteractionEnabled = true
        let tapTransparentView = UITapGestureRecognizer(target: self, action: #selector(AddPatientStatusViewController.dateCancel))
        self.transparentView.addGestureRecognizer(tapTransparentView)
    }
    
    func selectSymptom(_ sender: UIButton){
        if (sender.backgroundColor == nil) || (sender.backgroundColor == UIColor.white){
            sender.backgroundColor = headerColor
            sender.setTitleColor(UIColor.white, for: UIControlState())
        }else{
            sender.backgroundColor = UIColor.white
            sender.setTitleColor(headerColor, for: UIControlState())
        }
    }
    
    func selectDate(_ sender: UIButton) {
        if isSelectedDate == false {
            self.view.endEditing(true)
            self.view.addSubview(transparentView)
            isSelectedDate = true
            let datePickerHeight:CGFloat = 200
            let confirmButtonWidth:CGFloat = 100
            let confirmButtonHeight:CGFloat = 30
            datePickerContainerView = UIView(frame: CGRect(x: 0, y: screenHeight - datePickerHeight - 30, width: screenWidth, height: datePickerHeight + 30))
            datePickerContainerView.backgroundColor = UIColor.white
            self.datePicker.frame = CGRect(x: 0 , y: 30, width: UIScreen.main.bounds.width, height: datePickerHeight)
            self.datePicker.datePickerMode = UIDatePickerMode.date
            let confirmButton = UIButton(frame: CGRect(x: screenWidth - confirmButtonWidth, y: 0, width: confirmButtonWidth, height: confirmButtonHeight))
            confirmButton.setTitle("确定", for: UIControlState())
            confirmButton.setTitleColor(headerColor, for: UIControlState())
            confirmButton.addTarget(self, action: #selector(AddPatientStatusViewController.dateChanged), for: UIControlEvents.touchUpInside)
            let cancelButton = UIButton(frame: CGRect(x: 0, y: 0, width: confirmButtonWidth, height: confirmButtonHeight))
            cancelButton.setTitle("取消", for: UIControlState())
            cancelButton.setTitleColor(headerColor, for: UIControlState())
            cancelButton.addTarget(self, action: #selector(AddPatientStatusViewController.dateCancel), for: UIControlEvents.touchUpInside)
            datePickerContainerView.addSubview(self.datePicker)
            datePickerContainerView.addSubview(confirmButton)
            datePickerContainerView.addSubview(cancelButton)
            self.view.addSubview(datePickerContainerView)
        }else {
            isSelectedDate = false
            dateCancel()
        }
    }
    
    func dateCancel(){
        isSelectedDate = false
        transparentView.removeFromSuperview()
        self.datePickerContainerView.removeFromSuperview()
    }
    
    func dateChanged(){
        isSelectedDate = false
        transparentView.removeFromSuperview()

        dateInserted = datePicker.date
        self.datePickerContainerView.removeFromSuperview()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY/MM/dd" // superset of OP's format
        let dateStr = dateFormatter.string(from: dateInserted!)
        dateBtn.setTitle(dateStr, for: UIControlState())
    }
    
    func addReport(_ sender: UIButton){
        sender.removeFromSuperview()
        getClinicReportFormat()
        //seperate Line View
        let seperateTitleLine = UIView(frame: CGRect(x: 0, y: clinicReportTitleListHeight - 0.5, width: screenWidth - clinicReportListLeftSpace, height: 0.5))
        seperateTitleLine.backgroundColor = seperateLineColor
        
        //report table view
        let reportListViewY: CGFloat = symptomDespTextTopSpace + symptomsSection.frame.height + symptomDesp.frame.height + 10
        let reportListViewW: CGFloat = screenWidth - clinicReportListLeftSpace * 2
        let reportListViewH: CGFloat = clinicReportTitleListHeight * CGFloat(clinicReportFormatList.count + 2)
        let reportListView: UIView = UIView(frame: CGRect(x: clinicReportListLeftSpace, y: reportListViewY, width: reportListViewW, height: reportListViewH))
        
        //add report list title
        let reportListTitle: UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: reportListViewW, height: clinicReportTitleListHeight))
        reportListTitle.text = reportListTitleStr
        reportListTitle.textColor = reportListTitleColor
        reportListTitle.font = reportListTitleFont
        reportListView.addSubview(seperateTitleLine)
        reportListView.addSubview(reportListTitle)
        
        //add report list
        clinicTableView.isScrollEnabled = false
        clinicTableView.frame = CGRECT(0, clinicReportTitleListHeight, screenWidth - 30, CGFloat(clinicReportFormatList.count + 1)*clinicReportTitleListHeight)
        for clinicReportFormat in clinicReportFormatList {
            defaultClinicRowsName.add((clinicReportFormat as! NSDictionary).object(forKey: "clinicItem") as! String)
        }
        clinicRowsCount = defaultClinicRowsName.count
//        clinicTableView.setEditing(true, animated: true)
        reportListView.addSubview(clinicTableView)
        //add report text
        self.scrollView.addSubview(reportListView)
        
        scanReportText.frame = CGRECT(10, reportListViewY + reportListView.frame.height, reportListViewW, scanReportHeight)
        scanReportText.text = scanReportDespStr
        scanReportText.textColor = textInputViewPlaceholderColor
        scanReportText.delegate = self
        scanReportText.font = scanReportDespFont
        scanReportText.returnKeyType = UIReturnKeyType.done
        scrollView.addSubview(scanReportText)
        
        //add image section
        imageSection.frame = CGRect(x: 10, y: scanReportText.frame.origin.y + scanReportText.frame.height + 10, width: reportListViewW, height: imageLength)
        defaultAddImageBtn.frame = CGRect(x: 0, y: 0, width: imageLength, height: imageLength)
        let defaultAddImageView = UIImageView(frame: CGRECT(0, 0, imageLength, imageLength))
        defaultAddImageView.image = UIImage(named: "btn_addImage")
        defaultAddImageBtn.addSubview(defaultAddImageView)
        defaultAddImageBtn.addTarget(self, action: #selector(AddPatientStatusViewController.selectImages), for: UIControlEvents.touchUpInside)
        imageSection.addSubview(defaultAddImageBtn)
        self.scrollView.addSubview(imageSection)
        
        scrollView.frame = CGRECT(0, headerHeight + dateSection.frame.height, screenWidth, UIScreen.main.bounds.height - headerHeight - dateSection.frame.height - patientstatusFooterH)
        scrollView.contentSize = CGSize(width: screenWidth, height: scrollView.frame.height + reportListViewY + imageLength)
        self.scrollView.contentOffset = CGPoint(x: 0, y: symptomDespTextTopSpace + symptomsSection.frame.height + symptomDesp.frame.height)
        self.scrollView.isScrollEnabled = true
        

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
        
        for i in 1...assetImageArr.count {
            
            
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
        
        imageSection.frame = CGRECT(imageSection.frame.origin.x, imageSection.frame.origin.y, imageSection.frame.width, imageSectionH)
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func tapDismiss(){
        self.view.endEditing(true)
    }
    
    func addClinicData(_ sender: UIButton){
        self.clinicTableView.beginUpdates()
        let indexPath = IndexPath(row: clinicRowsCount, section: 0)
        clinicRowsCount += 1
        self.clinicTableView.insertRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
        self.clinicTableView.endUpdates()
        
        self.clinicTableView.frame = CGRECT(clinicTableView.frame.origin.x, clinicTableView.frame.origin.y, clinicTableView.frame.width, clinicTableView.frame.height + clinicReportTitleListHeight)
        let reportListView = clinicTableView.superview!
        reportListView.frame = CGRECT(reportListView.frame.origin.x, reportListView.frame.origin.y, reportListView.frame.width, reportListView.frame.height + clinicReportTitleListHeight)
        scanReportText.center = CGPoint(x: scanReportText.center.x, y: scanReportText.center.y + clinicReportTitleListHeight)
        sender.center = CGPoint(x: sender.center.x, y: sender.center.y + clinicReportTitleListHeight)
        scrollView.contentSize = CGSize(width: scrollView.contentSize.width, height: scrollView.contentSize.height + clinicReportTitleListHeight)
    }
    
    func deleteClinicData(_ sender: UIButton){
        let indexPath = self.clinicTableView.indexPath(for: sender.superview as! UITableViewCell)
        clinicRowsCount -= 1
        if indexPath?.row < defaultClinicRowsName.count {
            defaultClinicRowsName.removeObject(at: (indexPath?.row)!)
        }
        self.clinicTableView.deleteRows(at: [indexPath!], with: UITableViewRowAnimation.automatic)
        self.clinicTableView.frame = CGRECT(clinicTableView.frame.origin.x, clinicTableView.frame.origin.y, clinicTableView.frame.width, clinicTableView.frame.height - clinicReportTitleListHeight)
        let reportListView = clinicTableView.superview!
        reportListView.frame = CGRECT(reportListView.frame.origin.x, reportListView.frame.origin.y, reportListView.frame.width, reportListView.frame.height - clinicReportTitleListHeight)
        scanReportText.center = CGPoint(x: scanReportText.center.x, y: scanReportText.center.y - clinicReportTitleListHeight)
        scrollView.contentSize = CGSize(width: scrollView.contentSize.width, height: scrollView.contentSize.height - clinicReportTitleListHeight)
    }
    
    func checkedPrivate(_ sender: UIButton){
        if isPosted == 0 {
            isPosted = 1
            sender.backgroundColor = headerColor
            let checkImgView = UIImageView(image: UIImage(named: "btn_check"))
            checkImgView.frame = CGRECT(0, 0, sender.frame.width, sender.frame.height)
            checkImgView.contentMode = UIViewContentMode.scaleAspectFit
            sender.layer.borderColor = headerColor.cgColor
            sender.addSubview(checkImgView)
        }else{
            isPosted = 0
            sender.backgroundColor = UIColor.white
            sender.layer.borderColor = privateLabelColor.cgColor
            sender.removeAllSubviews()
        }
    }
    
    func getClinicReportFormat(){
        let currentTimeStamp: Double = Foundation.Date().timeIntervalSince1970
        var previousStoreTimestamp: Double = 0
        if  UserDefaults.standard.object(forKey: setPatientStatusFormatTimeStamp) != nil {
            previousStoreTimestamp = profileSet.object(forKey: setPatientStatusFormatTimeStamp) as! Double
        }
        if (profileSet.object(forKey: "clinicReportFormatList") == nil) || ((currentTimeStamp - previousStoreTimestamp) > 86400 * 15) {
            let parameters = NSDictionary(object: keychainAccess.getPasscode(usernameKeyChain)!, forKey: "username" as NSCopying)
            let jsonResult = NetRequest.sharedInstance.POST_A(getClinicReportFormatURL, parameters: parameters as! Dictionary<String, AnyObject>)
            if (jsonResult.object(forKey: "content") != nil) && ((jsonResult ).object(forKey: "content") is NSArray){
                self.clinicReportFormatList = (jsonResult ).object(forKey: "content") as! NSArray
                profileSet.set(clinicReportFormatList, forKey: "clinicReportFormatList")
            }
        }else{
            clinicReportFormatList = profileSet.object(forKey: "clinicReportFormatList") as! NSArray
        }
    }
    
    func getPatientStatusFormat(){

        let currentTimeStamp: Double = Foundation.Date().timeIntervalSince1970
        var previousStoreTimestamp: Double = 0
        if  UserDefaults.standard.object(forKey: setPatientStatusFormatTimeStamp) != nil {
            previousStoreTimestamp = profileSet.object(forKey: setPatientStatusFormatTimeStamp) as! Double
            
        }
        if (profileSet.object(forKey: "patientStatusFormat") == nil) || ((currentTimeStamp - previousStoreTimestamp) > 86400 * 15) {
            let parameters = NSDictionary()
            let jsonResult = NetRequest.sharedInstance.GET_A(getPatientStatusFormatURL, parameters: parameters as! Dictionary<String, AnyObject>)
            if (jsonResult.object(forKey: "content") != nil){
                patientStatusFormatList = jsonResult.object(forKey: "content") as! NSArray
                profileSet.set(patientStatusFormatList, forKey: "patientStatusFormat")
                profileSet.set(currentTimeStamp, forKey: setPatientStatusFormatTimeStamp)
            }else{
            }
        }else{
            patientStatusFormatList = profileSet.object(forKey: "patientStatusFormat") as! NSArray
        }
    }
    
    @IBAction func loadPreviousView(){
//        self.navigationController?.popToRootViewControllerAnimated(true)
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func submitStatus(_ sender: UIButton){
        
        for symptonButton in symptomsSection.subviews {
            if symptonButton is UIButton && symptonButton.backgroundColor == headerColor{
                patientStatusDetail += ((symptonButton as! UIButton).titleLabel!).text! + " "
            }
        }
        patientStatusDetail += "::"
        if symptomDesp.textColor != textInputViewPlaceholderColor{
            patientStatusDetail += symptomDesp.text
        }
        if patientStatusDetail == "::" {
            patientStatusDetail = ""
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd"
        date = dateFormatter.date(from: (dateBtn.titleLabel?.text)!)!
        
        var scanReportStr: String = ""
        if self.scanReportText.textColor != textInputViewPlaceholderColor {
            scanReportStr = self.scanReportText.text
        }
        let pateintStatusDic  = NSMutableDictionary(objects: [date.timeIntervalSince1970 * 1000, self.isPosted, patientStatusDetail, scanReportStr], forKeys: [ "insertedDate" as NSCopying, "isPosted" as NSCopying, "statusDesc" as NSCopying, "scanData" as NSCopying])

        getClinicDataStr()
        var clinicReportStr: String = ""
        var isClinicDataFloat: Bool = true
        for clinicData in clinicDataList {
            let clinicDataDic = clinicData as! NSDictionary
            let clinicDataValueStr = (clinicDataDic.allValues as NSArray).object(at: 0)as! NSString
            let clinicValue:Float = clinicDataValueStr.floatValue
            if (clinicDataValueStr != "0") && (clinicDataValueStr != "0.0") && (clinicValue == 0.0) {
                isClinicDataFloat = false
            }else{
                isClinicDataFloat = true
                clinicReportStr += "[" + ((clinicDataDic.allKeys as NSArray).object(at: 0)as! String) + ":" + ((clinicDataDic.allValues as NSArray).object(at: 0)as! String) + "]"
            }
        }
        if isClinicDataFloat {
            let clinicReportDic = NSDictionary(objects: [clinicReportStr, self.isPosted], forKeys: [ "clinicReport" as NSCopying, "isPosted" as NSCopying])
            
            var accessToken = UserDefaults.standard.object(forKey: accessNSUserData)
            if accessToken == nil {
                getAccessToken.getAccessToken()
                accessToken = UserDefaults.standard.object(forKey: accessNSUserData)
            }
            
            let urlPath:String = (addPatientStatusURL as String) + "?access_token=" + (accessToken as! String);
            
            let requestBody = NSMutableDictionary()
            requestBody.setValue(pateintStatusDic, forKey: "patientStatus")
            requestBody.setValue(clinicReportDic, forKey: "clinicReport")
            requestBody.setValue(keychainAccess.getPasscode(usernameKeyChain), forKey: "insertUsername")
            requestBody.setValue(self.imageInfoList.count, forKey: "hasImage")
            saveClinicDataToLocalDB(clinicDataList)
            NetRequest.sharedInstance.POST(urlPath, parameters: (requestBody as NSDictionary) as! Dictionary<String, AnyObject>,
                success: { (content , message) -> Void in
                    let statusID = (content as! NSDictionary).object(forKey: "count") as! Int
                    pateintStatusDic.setObject(statusID, forKey: "statusID" as NSCopying)
                    self.savePatientStatusToLocalDB(pateintStatusDic)
                    DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async(execute: {
                        self.submitImages(statusID)
                        DispatchQueue.main.async(execute: {
                            
                        })
                    })
                }) { (content, message) -> Void in
                    HudProgressManager.sharedInstance.showOnlyTextHudProgress(self, title: message)
            }
            self.dismiss(animated: true, completion: nil)
        }else {
            let alertController = UIAlertController(title: "检测数据必须为数值", message: nil, preferredStyle: .alert)
            
            let cancelAction = UIAlertAction(title: "取消", style: .default) { (action) in
            }
            
            alertController.addAction(cancelAction)
            
            self.present(alertController, animated: true) {
                // ...
            }
        }
    }
    
    func submitImages(_ id: Int){
        let imageInfosParameter = self.makeImageToCorrespondingFormat(self.imageInfoList)
        var index: Int = 0
        getAccessToken.getAccessToken()
        let accessToken = UserDefaults.standard.object(forKey: accessNSUserData)
        for imgeInfo in imageInfosParameter{
            
            let urlPath:String = (addPatientImageURL as String) + "?access_token=" + (accessToken as! String)
            
            let requestBody = NSMutableDictionary()
            requestBody.setValue(id, forKey: "id")
            requestBody.setValue(index, forKey: "imageIndex")
            requestBody.setValue(imgeInfo, forKey: "imageInfo")
            NetRequest.sharedInstance.POST_A(urlPath, parameters: (requestBody as NSDictionary) as! Dictionary<String, AnyObject>)
            index += 1
        }
        //update patient status localDB imageURL
        let urlPath:String = (getPatientStatusByID as String) + "?access_token=" + (accessToken as! String)
        let requestBody = NSDictionary(object: id, forKey: "id" as NSCopying)
        let result = NetRequest.sharedInstance.POST_A(urlPath, parameters: (requestBody as NSDictionary) as! Dictionary<String, AnyObject>)
        if (result.object(forKey: "result") != nil) && ((result.object(forKey: "result") as! Int) == 1) && (result.object(forKey: "content") != nil){
            let insertedPatientStatus = result.object(forKey: "content") as! NSDictionary
            updatePatientStatusToLocalDB(insertedPatientStatus)
        }
    }
    
    func updatePatientStatusToLocalDB(_ patientStatus: NSDictionary){
        let predicate = NSPredicate(format: "statusID == %d", patientStatus.object(forKey: "statusID") as! Int)
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: tablePatientStatus)
        fetchRequest.predicate = predicate
        
        do {
            let fetchedEntities: NSArray = try self.context!.fetch(fetchRequest) as NSArray
            if fetchedEntities.count > 0{
                let entityToUpdated = fetchedEntities[0]
                let imageURLStr: String = patientStatus.object(forKey: "imageURL") as! String
                var newImageURLStr: String = ""
                let imageURLArr = imageURLStr.components(separatedBy: ",")
                for imageURL in imageURLArr{
                    let imageURLAndIndex = imageURL.components(separatedBy: ";")
                    if imageURLAndIndex.count > 0 {
                        newImageURLStr += imageURLAndIndex[0] + ";"
                    }
                }
                (entityToUpdated as AnyObject).setValue(newImageURLStr, forKey: propertyPatientStatusImageURL)
            }
        } catch {
            // Do something in response to error condition
        }
        
        do {
            try self.context!.save()
        } catch {
            // Do something in response to error condition
        }
    }
    
    func savePatientStatusToLocalDB(_ patientStatus: NSDictionary){
        let patientstatusLocalDBItem = NSEntityDescription.insertNewObject(forEntityName: tablePatientStatus, into: context!)
        //        let patientStatusObj = PatientStatusObj.jsonToModel(PatientStatus) as PatientStatusObj
        //        patientstatusLocalDBItem.setValue(patientStatusObj.statusID , forKey: propertyStatusID)
        let keychainAccess = KeychainAccess()
        patientstatusLocalDBItem.setValue(keychainAccess.getPasscode(usernameKeyChain)! , forKey: propertyPatientStatusUsername)
        patientstatusLocalDBItem.setValue(patientStatus.object(forKey: "statusDesc") , forKey: propertyStatusDesc)
        patientstatusLocalDBItem.setValue(patientStatus.object(forKey: "insertedDate") , forKey: propertyInsertedDate)
        patientstatusLocalDBItem.setValue(patientStatus.object(forKey: "imageURL") , forKey: propertyPatientStatusImageURL)
        patientstatusLocalDBItem.setValue(patientStatus.object(forKey: "scanData") , forKey: propertyScanData)
        patientstatusLocalDBItem.setValue(patientStatus.object(forKey: "hasImage") , forKey: propertyHasImage)
        patientstatusLocalDBItem.setValue(patientStatus.object(forKey: "statusID") , forKey: propertyStatusID)
        
        do {
            try context!.save()
        } catch _ {
        }
    }
    
    func saveClinicDataToLocalDB(_ clinicDataList: NSArray){
        let keychainAccess = KeychainAccess()
        for clinicData in clinicDataList {
            let clinicDataLocalDBItem = NSEntityDescription.insertNewObject(forEntityName: tableClinicData, into: context!)
            let keys = (clinicData as! NSDictionary).allKeys
            if (keys.count > 0) {
                let key:String = (keys as NSArray).object(at: 0) as! String
                clinicDataLocalDBItem.setValue( key, forKey: propertyClinicItemName)
                clinicDataLocalDBItem.setValue(Int((clinicData as AnyObject).object(forKey: key) as! String), forKey: propertyClinicItemValue)
                clinicDataLocalDBItem.setValue(date.timeIntervalSince1970 * 1000, forKey: propertyClinicDataInsertDate)
                clinicDataLocalDBItem.setValue(keychainAccess.getPasscode(usernameKeyChain)!, forKey: propertyClinicDataUsername)
            }
        }
        do {
            try context!.save()
        } catch _ {
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n"{
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor != UIColor.black {
            textView.text = nil
            textView.textColor = UIColor.black
        }
        self.scrollViewOffset = textView.frame.origin.y
        self.scrollView.contentOffset = CGPoint(x: 0, y: scrollViewOffset)
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func loadPreviousView(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func keyboardWillAppear(_ notification: Notification) {
        
        if self.checkedView.center.y > UIScreen.main.bounds.height - 50{
            // 获取键盘信息
            let keyboardinfo = notification.userInfo![UIKeyboardFrameBeginUserInfoKey]
            
            keyboardheight = ((keyboardinfo as AnyObject).cgRectValue.size.height)
            
            self.checkedView.center = CGPoint(x: self.checkedView.center.x, y: self.checkedView.center.y - keyboardheight)
        }
    }
    
    func keyboardWillDisappear(_ notification:Notification){
        
        self.checkedView.center = CGPoint(x: self.checkedView.center.x, y: self.checkedView.center.y + keyboardheight)
        self.scrollView.contentOffset = CGPoint(x: 0, y: 0)
    }
    //UITextField
//    func textFieldDidEndEditing(textField: UITextField) {
//        if textField.superview  is UITableViewCell{
//            let clinicData = NSMutableDictionary()
//            var clinicDataName: String = ""
//            let cell = textField.superview as! UITableViewCell
//            if textField.placeholder == reportListItemPlaceholder {
//                if (cell.textLabel != nil) && (cell.textLabel?.text != nil) && (cell.textLabel?.text != ""){
//                    clinicDataName = (cell.textLabel?.text)!
//                }else{
//                    for subView in cell.subviews {
//                        if (subView is UITextField) && (subView as! UITextField).frame.origin.x < clinicReportLblW {
//                            clinicDataName = (subView as! UITextField).text!
//                        }
//                    }
//                }
//                if (textField.text != "")&&(clinicDataName != "") {
//                    clinicData.setObject(textField.text!, forKey: clinicDataName)
//                    self.clinicDataList.addObject(clinicData)
//                }
//            }else{
//                if (textField.text != "") {
//                    for subView in cell.subviews {
//                        if (subView is UITextField) && (subView as! UITextField).placeholder == reportListItemPlaceholder {
//                            let clinicDataValue = (subView as! UITextField).text!
//                            if clinicDataValue != "" {
//                                clinicData.setObject(clinicDataValue, forKey: textField.text!)
//                                self.clinicDataList.addObject(clinicData)
//                            }
//                        }
//                    }
//                }
//            }
//        }
//    }
    
    func getClinicDataStr(){
        if self.clinicTableView.numberOfRows(inSection: 0) > 0{
            for index in 0...(self.clinicTableView.numberOfRows(inSection: 0) - 1) {
                var clinicDataName: String = ""
                var clinicDataValue: String = ""
                let indexPath = IndexPath(row: index, section: 0)
                let cell = self.clinicTableView.cellForRow(at: indexPath)
                if (cell!.textLabel != nil) && (cell!.textLabel?.text != nil) && (cell!.textLabel?.text != ""){
                    clinicDataName = (cell!.textLabel?.text)!
                }
                
                for subView in cell!.subviews {
                    if (subView is UITextField) && (subView as! UITextField).frame.origin.x < clinicReportLblW {
                        clinicDataName = (subView as! UITextField).text!
                    }else if (subView is UITextField) && (subView as! UITextField).frame.origin.x > (clinicReportLblW - 10){
                        clinicDataValue = (subView as! UITextField).text!
                    }
                }
                
                if (clinicDataName != "") && (clinicDataValue != "") {
                    let clinicData = NSDictionary(object: clinicDataValue, forKey: clinicDataName as NSCopying)
                    self.clinicDataList.add(clinicData)
                }
            }
        }
    }
    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            return clinicRowsCount
        }else{
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var heightForRow: CGFloat = 0
        switch indexPath.section {
        case 0:
            heightForRow = clinicReportTitleListHeight
            break
        case 1:
            heightForRow = 90
            break
        default:
            break
        }
        return heightForRow
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier:String = "cell"
        let cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: cellIdentifier)
        if indexPath.section == 0{
            if indexPath.row < defaultClinicRowsName.count {
                cell.textLabel?.text =  defaultClinicRowsName.object(at: indexPath.row) as? String
                cell.textLabel?.font = reportListTitleFont
                cell.textLabel?.textColor = reportListItemColor

            }else{
                let clinicItemNameTextField = UITextField(frame: CGRect(x: 15, y: 0, width: clinicReportLblW - 10, height: clinicReportTitleListHeight))
                clinicItemNameTextField.placeholder = "其他指标:"
                clinicItemNameTextField.font = reportListTitleFont
                clinicItemNameTextField.delegate = self
                clinicItemNameTextField.returnKeyType = UIReturnKeyType.done
                cell.addSubview(clinicItemNameTextField)
            }
            //textField
            let clinicItemValueTextField = UITextField(frame: CGRect(x: clinicReportLblW, y: 0, width: cell.frame.width - clinicReportLblW - clinicReportDelBtnRightSpace - clinicReportDelBtnWidth, height: clinicReportTitleListHeight))
            clinicItemValueTextField.placeholder = reportListItemPlaceholder
            clinicItemValueTextField.font = reportListTitleFont
            clinicItemValueTextField.delegate = self
            clinicItemValueTextField.returnKeyType = UIReturnKeyType.done
            cell.addSubview(clinicItemValueTextField)
            //delete button
            let clinicReportDelBtnWidthMargin: CGFloat = 15
            let deleteBtn = UIButton(frame: CGRect(x: cell.frame.width - clinicReportDelBtnWidth - 30 - clinicReportDelBtnWidthMargin * 2, y: 16 - clinicReportDelBtnWidthMargin, width: clinicReportDelBtnWidth + clinicReportDelBtnWidthMargin * 2, height: clinicReportDelBtnWidth + clinicReportDelBtnWidthMargin * 2))
            deleteBtn.backgroundColor = UIColor.clear
            let btnImageView = UIImageView(frame: CGRECT(clinicReportDelBtnWidth, clinicReportDelBtnWidth, clinicReportDelBtnWidth, clinicReportDelBtnWidth))
            btnImageView.image = UIImage(named: "btn_deleteClinicData")
            deleteBtn.addSubview(btnImageView)
            deleteBtn.layer.cornerRadius = clinicReportDelBtnWidth/2
            deleteBtn.layer.masksToBounds = true
            deleteBtn.addTarget(self, action: #selector(AddPatientStatusViewController.deleteClinicData(_:)), for: UIControlEvents.touchUpInside)
            cell.addSubview(deleteBtn)
        }else{
            let addMoreClinicDataBtnW:CGFloat = cell.frame.size.width - 12
            let addMoreClinicDataBtnH:CGFloat = 30
            let addMoreClinicDataBtn = UIButton(frame: CGRect(x: 12, y: 12, width: cell.frame.width - 36, height: addMoreClinicDataBtnH))
            let addReportImgView = UIImageView(frame: CGRECT(0, 0, addMoreClinicDataBtnW, addMoreClinicDataBtnH))
            addReportImgView.image = UIImage(named: "btn_addReport")
            addMoreClinicDataBtn.addSubview(addReportImgView)
            addMoreClinicDataBtn.setTitle("添加更多指标", for: UIControlState())
            addMoreClinicDataBtn.setTitleColor(addReportButtonTextColor, for: UIControlState())
            addMoreClinicDataBtn.titleLabel?.font = addReportButtonFont
            addMoreClinicDataBtn.addTarget(self, action: #selector(AddPatientStatusViewController.addClinicData(_:)), for: UIControlEvents.touchUpInside)

            cell.addSubview(addMoreClinicDataBtn)
        }
        return cell
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        print("begin dragging")
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if scrollView.contentSize.height < UIScreen.main.bounds.height + 15 {
            addReport(addReportBtn)
        }
    }
    
}

