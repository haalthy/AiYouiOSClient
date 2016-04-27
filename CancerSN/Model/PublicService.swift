//
//  PublicService.swift
//  CancerSN
//
//  Created by lily on 9/10/15.
//  Copyright (c) 2015 lily. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class PublicService:NSObject{

    
    func getProfileStrByDictionary(user:UserProfile)->String{
        
        var userProfileStr : String
        var gender = ""
        if (user.gender != nil) && (user.gender != ""){
            gender = user.gender!
        }
        var displayGender:String = ""
        if(gender == "M"){
            displayGender = "男"
        }else if(gender == "F"){
            displayGender = "女"
        }
        var age = String()
        var stage = String()
        var cancerType = String()
        var pathological = String()
        
        if user.age != nil{
            age = String(user.age!)
        }
        if (user.stage != nil) && (user.stage != "") {
            stage = user.stage!
        }
        
        if (user.cancerType != nil) && !(user.cancerType != "") {
            cancerType = user.cancerType!
        }
        
        if user.pathological != nil && !(user.pathological != ""){
            pathological = user.pathological!
        }
        
        userProfileStr = displayGender + " " + age + "岁 " + cancerType + " " + pathological + " " + stage + "期"
        return userProfileStr
    }
    
    
    
    func clearUserFromLocalDB() {
        let appDel:AppDelegate = (UIApplication.sharedApplication().delegate as! AppDelegate)
        let context:NSManagedObjectContext = appDel.managedObjectContext!
        let deleteUserRequet = NSFetchRequest(entityName: tableUser)
        if let results = try? context.executeFetchRequest(deleteUserRequet) {
            for param in results {
                context.deleteObject(param as! NSManagedObject);
            }
        }
        do {
            try context.save()
        } catch _ {
        }
    }
    
    func clearTreatmentFromLocalDB() {
        let appDel:AppDelegate = (UIApplication.sharedApplication().delegate as! AppDelegate)
        let context:NSManagedObjectContext = appDel.managedObjectContext!
        let deleteTreatmentRequet = NSFetchRequest(entityName: tableTreatment)
        if let results = try? context.executeFetchRequest(deleteTreatmentRequet) {
            for param in results {
                context.deleteObject(param as! NSManagedObject);
            }
        }
        do {
            try context.save()
        } catch _ {
        }
    }
    
    func clearPatientStatusFromLocalDB() {
        let appDel:AppDelegate = (UIApplication.sharedApplication().delegate as! AppDelegate)
        let context:NSManagedObjectContext = appDel.managedObjectContext!
        let deletePatientStatusRequet = NSFetchRequest(entityName: tablePatientStatus)
        if let results = try? context.executeFetchRequest(deletePatientStatusRequet) {
            for param in results {
                context.deleteObject(param as! NSManagedObject);
            }
        }
        do {
            try context.save()
        } catch _ {
        }
    }
    
    func clearClinicDataFromLocalDB() {
        let appDel:AppDelegate = (UIApplication.sharedApplication().delegate as! AppDelegate)
        let context:NSManagedObjectContext = appDel.managedObjectContext!
        let deleteClinicDataRequet = NSFetchRequest(entityName: tableClinicData)
        if let results = try? context.executeFetchRequest(deleteClinicDataRequet) {
            for param in results {
                context.deleteObject(param as! NSManagedObject);
            }
        }
        do {
            try context.save()
        } catch _ {
        }
    }
    

    
    func cleanLocalDB(){
        clearUserFromLocalDB()
        clearTreatmentFromLocalDB()
        clearPatientStatusFromLocalDB()
        clearClinicDataFromLocalDB()
    }
    
    func logOutAccount(){
        let keychain = KeychainAccess()
        keychain.deletePasscode(usernameKeyChain)
        keychain.deletePasscode(passwordKeyChain)
        let profileSet = NSUserDefaults.standardUserDefaults()
        profileSet.removeObjectForKey(favTagsNSUserData)
        profileSet.removeObjectForKey(genderNSUserData)
        profileSet.removeObjectForKey(ageNSUserData)
        profileSet.removeObjectForKey(cancerTypeNSUserData)
        profileSet.removeObjectForKey(pathologicalNSUserData)
        profileSet.removeObjectForKey(stageNSUserData)
        profileSet.removeObjectForKey(smokingNSUserData)
        profileSet.removeObjectForKey(metastasisNSUserData)
        profileSet.removeObjectForKey(emailNSUserData)
        profileSet.removeObjectForKey(accessNSUserData)
        profileSet.removeObjectForKey(refreshNSUserData)
        profileSet.removeObjectForKey(userTypeUserData)
        profileSet.removeObjectForKey(geneticMutationNSUserData)
        profileSet.removeObjectForKey(imageNSUserData)
        cleanLocalDB()
    }
    
    func cropToSquare(image originalImage: UIImage) -> UIImage {
        let contextImage: UIImage = UIImage(CGImage: originalImage.CGImage!)
        
        // Get the size of the contextImage
        let contextSize: CGSize = contextImage.size
        
        let posX: CGFloat
        let posY: CGFloat
        let width: CGFloat
        let height: CGFloat
        
        if contextSize.width > contextSize.height {
            posX = ((contextSize.width - contextSize.height) / 2)
            posY = 0
            width = contextSize.height
            height = contextSize.height
        } else {
            posX = 0
            posY = ((contextSize.height - contextSize.width) / 2)
            width = contextSize.width
            height = contextSize.width
        }
        
        let rect: CGRect = CGRectMake(posX, posY, width, height)
        
        // Create bitmap image from context using the rect
        let imageRef: CGImageRef = CGImageCreateWithImageInRect(contextImage.CGImage, rect)!
        
        // Create a new image based on the imageRef and rotate back to the original orientation
        let image: UIImage = UIImage(CGImage: imageRef, scale: originalImage.scale, orientation: originalImage.imageOrientation)
        
        return image
    }
    
    func formatButton(sender: UIButton, title: String){
        sender.backgroundColor = UIColor.whiteColor()
        sender.setTitle(title, forState: UIControlState.Normal)
        sender.setTitleColor(mainColor, forState: UIControlState.Normal)
        sender.layer.cornerRadius = 5.0
        sender.layer.borderColor = mainColor.CGColor
        sender.layer.borderWidth = 1.0
    }
    
    func unselectBtnFormat(sender: UIButton){
        sender.setTitleColor(mainColor, forState: UIControlState.Normal)
        sender.backgroundColor = UIColor.whiteColor()
        sender.layer.borderColor = mainColor.CGColor
        sender.layer.borderWidth = 1.0
        sender.layer.cornerRadius = 5
        sender.layer.masksToBounds = true
    }
    
    func selectedBtnFormat(sender: UIButton){
        sender.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        sender.backgroundColor = mainColor
    }
    
    func presentAlertController(message: String, sender: UIViewController){
        let alert = UIAlertController(title: "提示", message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "确定", style: UIAlertActionStyle.Default, handler: nil))
        sender.presentViewController(alert, animated: true, completion: nil)
    }
    
//    func md5(string: String) -> NSData {
//        var digest = NSMutableData(length: Int(CC_MD5_DIGEST_LENGTH))!
//        if let data :NSData = string.dataUsingEncoding(NSUTF8StringEncoding) {
//            CC_MD5(data.bytes, CC_LONG(data.length),
//                UnsafeMutablePointer<UInt8>(digest.mutableBytes))
//        }
//        return digest
//    }
    
    func md5String(string: String)->String{
        let strLen = CC_LONG(string.lengthOfBytesUsingEncoding(NSUTF8StringEncoding))
        let digestLen = Int(CC_MD5_DIGEST_LENGTH)
        let result = UnsafeMutablePointer<CUnsignedChar>.alloc(digestLen)
        CC_MD5(string.cStringUsingEncoding(NSUTF8StringEncoding)!, strLen, result)
        let hash = NSMutableString()
        for i in 0..<digestLen {
            hash.appendFormat("%02x", result[i])
        }
        result.dealloc(digestLen)
        return String(format: hash as String)
    }
    
//    func passwordEncode(var password:String)->String{
//        password = md5(password).base64EncodedStringWithOptions(NSDataBase64EncodingOptions.Encoding64CharacterLineLength)
//        print(password)
//        var passwordEndedeStr:String = ""
//        for character in password.utf16 {
//            passwordEndedeStr += "a"+(String(character))
//        }
//        return passwordEndedeStr
//    }
    
    func passwordEncode(var password:String)->String{
        password = md5String(password)
        var passwordEndedeStr:String = ""
        for character in password.utf16 {
            passwordEndedeStr += "a"+(String(character))
        }
        return passwordEndedeStr
    }
    
    func checkIsUsername(str: String) -> Bool{
        do {
            // - 1、创建规则
            let pattern = "[A-Z][A-Z][0-9]{13}.[0-9]{3}"
            // - 2、创建正则表达式对象
            let regex = try NSRegularExpression(pattern: pattern, options: NSRegularExpressionOptions.CaseInsensitive)
            // - 3、开始匹配
            let res = regex.matchesInString(str, options: NSMatchingOptions(rawValue: 0), range: NSMakeRange(0, str.characters.count))
            if res.count>0{
                return true
            }else{
                return false
            }
        }
        catch {
            return false
        }
    }
    
    func checkIsPhoneNumber(str: String) -> Bool {
        do {
            // - 1、创建规则
            let pattern = "[1-9][0-9]{8,14}"
            // - 2、创建正则表达式对象
            let regex = try NSRegularExpression(pattern: pattern, options: NSRegularExpressionOptions.CaseInsensitive)
            // - 3、开始匹配
            let res = regex.matchesInString(str, options: NSMatchingOptions(rawValue: 0), range: NSMakeRange(0, str.characters.count))
            // 输出结果
            if res.count > 0{
                return true
            }
            else{
                return false
            }
        }
        catch {
            return false
        }
    }
    
    func checkIsEmail(str: String)->Bool{
        do {
            //([a-zA-Z0-9_-])+@([a-zA-Z0-9_-])+(.[a-zA-Z0-9_-])+/
            // - 1、创建规则
            let pattern = "[a-zA-Z0-9_-]{1,20}@[a-zA-Z0-9_-]{1,20}.[a-zA-Z0-9_-]{1,20}"
            // - 2、创建正则表达式对象
            let regex = try NSRegularExpression(pattern: pattern, options: NSRegularExpressionOptions.CaseInsensitive)
            // - 3、开始匹配
            let res = regex.matchesInString(str, options: NSMatchingOptions(rawValue: 0), range: NSMakeRange(0, str.characters.count))
            // 输出结果
            if res.count > 0{
                return true
            }
            else{
                return false
            }
        }
        catch {
            return false
        }
    }
    
    func resizeImage(image: UIImage, newSize: CGSize) -> UIImage{
        let width: CGFloat = image.size.width
        let height: CGFloat = image.size.height
        
        var newSizeWidth: CGFloat = newSize.width
        var newSizeHeight: CGFloat = newSize.height
        
        if width > height {
            newSizeWidth = newSize.height
            newSizeHeight = newSize.width
        }
        
        var scaleWidth: CGFloat = 1
        var scaleHeight: CGFloat = 1
        
        if width > newSizeWidth {
            scaleWidth = newSizeWidth / width
        }
        if height > newSizeHeight {
            scaleHeight = newSizeHeight / height
        }
        let scale = (scaleWidth > scaleHeight ? scaleHeight: scaleWidth)
        newSizeWidth = width * scale
        newSizeHeight = height * scale
        
        let newSize = CGSizeMake(newSizeWidth, newSizeHeight)
        UIGraphicsBeginImageContext(newSize)
        image.drawInRect(CGRectMake(0, 0, newSize.width, newSize.height))
        let newimage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newimage
    }
    
    func savePatientStatusToLocalDB(patientStatusObjList: NSArray){
        let appDel:AppDelegate = (UIApplication.sharedApplication().delegate as! AppDelegate)
        let context:NSManagedObjectContext = appDel.managedObjectContext!
        for patientStatus in patientStatusObjList {
            let patientstatusLocalDBItem = NSEntityDescription.insertNewObjectForEntityForName(tablePatientStatus, inManagedObjectContext: context)
            let patientStatusObj = patientStatus as! PatientStatusObj
            patientstatusLocalDBItem.setValue(patientStatusObj.statusID , forKey: propertyStatusID)
            patientstatusLocalDBItem.setValue(patientStatusObj.username , forKey: propertyPatientStatusUsername)
            patientstatusLocalDBItem.setValue(patientStatusObj.statusDesc , forKey: propertyStatusDesc)
            patientstatusLocalDBItem.setValue(patientStatusObj.insertedDate , forKey: propertyInsertedDate)
            patientstatusLocalDBItem.setValue(patientStatusObj.imageURL , forKey: propertyPatientStatusImageURL)
            patientstatusLocalDBItem.setValue(patientStatusObj.scanData , forKey: propertyScanData)
            patientstatusLocalDBItem.setValue(patientStatusObj.hasImage , forKey: propertyHasImage)
        }
        do {
            try context.save()
        } catch _ {
        }
    }
    
}