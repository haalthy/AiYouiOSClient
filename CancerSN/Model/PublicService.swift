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

    
    func getProfileStrByDictionary(_ user:UserProfile)->String{
        
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
        let appDel:AppDelegate = (UIApplication.shared.delegate as! AppDelegate)
        let context:NSManagedObjectContext = appDel.managedObjectContext!
        let deleteUserRequet = NSFetchRequest<NSFetchRequestResult>(entityName: tableUser)
        if let results = try? context.fetch(deleteUserRequet) {
            for param in results {
                context.delete(param as! NSManagedObject);
            }
        }
        do {
            try context.save()
        } catch _ {
        }
    }
    
    func clearTreatmentFromLocalDB() {
        let appDel:AppDelegate = (UIApplication.shared.delegate as! AppDelegate)
        let context:NSManagedObjectContext = appDel.managedObjectContext!
        let deleteTreatmentRequet = NSFetchRequest<NSFetchRequestResult>(entityName: tableTreatment)
        if let results = try? context.fetch(deleteTreatmentRequet) {
            for param in results {
                context.delete(param as! NSManagedObject);
            }
        }
        do {
            try context.save()
        } catch _ {
        }
    }
    
    func clearPatientStatusFromLocalDB() {
        let appDel:AppDelegate = (UIApplication.shared.delegate as! AppDelegate)
        let context:NSManagedObjectContext = appDel.managedObjectContext!
        let deletePatientStatusRequet = NSFetchRequest<NSFetchRequestResult>(entityName: tablePatientStatus)
        if let results = try? context.fetch(deletePatientStatusRequet) {
            for param in results {
                context.delete(param as! NSManagedObject);
            }
        }
        do {
            try context.save()
        } catch _ {
        }
    }
    
    func clearClinicDataFromLocalDB() {
        let appDel:AppDelegate = (UIApplication.shared.delegate as! AppDelegate)
        let context:NSManagedObjectContext = appDel.managedObjectContext!
        let deleteClinicDataRequet = NSFetchRequest<NSFetchRequestResult>(entityName: tableClinicData)
        if let results = try? context.fetch(deleteClinicDataRequet) {
            for param in results {
                context.delete(param as! NSManagedObject);
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
        let profileSet = UserDefaults.standard
        profileSet.removeObject(forKey: favTagsNSUserData)
        profileSet.removeObject(forKey: genderNSUserData)
        profileSet.removeObject(forKey: ageNSUserData)
        profileSet.removeObject(forKey: cancerTypeNSUserData)
        profileSet.removeObject(forKey: pathologicalNSUserData)
        profileSet.removeObject(forKey: stageNSUserData)
        profileSet.removeObject(forKey: smokingNSUserData)
        profileSet.removeObject(forKey: metastasisNSUserData)
        profileSet.removeObject(forKey: emailNSUserData)
        profileSet.removeObject(forKey: accessNSUserData)
        profileSet.removeObject(forKey: refreshNSUserData)
        profileSet.removeObject(forKey: userTypeUserData)
        profileSet.removeObject(forKey: geneticMutationNSUserData)
        profileSet.removeObject(forKey: imageNSUserData)
        cleanLocalDB()
    }
    
    func cropToSquare(image originalImage: UIImage) -> UIImage {
        let contextImage: UIImage = UIImage(cgImage: originalImage.cgImage!)
        
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
        
        let rect: CGRect = CGRect(x: posX, y: posY, width: width, height: height)
        
        // Create bitmap image from context using the rect
        let imageRef: CGImage = contextImage.cgImage!.cropping(to: rect)!
        
        // Create a new image based on the imageRef and rotate back to the original orientation
        let image: UIImage = UIImage(cgImage: imageRef, scale: originalImage.scale, orientation: originalImage.imageOrientation)
        
        return image
    }
    
    func formatButton(_ sender: UIButton, title: String){
        sender.backgroundColor = UIColor.white
        sender.setTitle(title, for: UIControlState())
        sender.setTitleColor(mainColor, for: UIControlState())
        sender.layer.cornerRadius = 5.0
        sender.layer.borderColor = mainColor.cgColor
        sender.layer.borderWidth = 1.0
    }
    
    func unselectBtnFormat(_ sender: UIButton){
        sender.setTitleColor(mainColor, for: UIControlState())
        sender.backgroundColor = UIColor.white
        sender.layer.borderColor = mainColor.cgColor
        sender.layer.borderWidth = 1.0
        sender.layer.cornerRadius = 5
        sender.layer.masksToBounds = true
    }
    
    func selectedBtnFormat(_ sender: UIButton){
        sender.setTitleColor(UIColor.white, for: UIControlState())
        sender.backgroundColor = mainColor
    }
    
    func presentAlertController(_ message: String, sender: UIViewController){
        let alert = UIAlertController(title: "提示", message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "确定", style: UIAlertActionStyle.default, handler: nil))
        sender.present(alert, animated: true, completion: nil)
    }
    
//    func md5(string: String) -> NSData {
//        var digest = NSMutableData(length: Int(CC_MD5_DIGEST_LENGTH))!
//        if let data :NSData = string.dataUsingEncoding(NSUTF8StringEncoding) {
//            CC_MD5(data.bytes, CC_LONG(data.length),
//                UnsafeMutablePointer<UInt8>(digest.mutableBytes))
//        }
//        return digest
//    }
    
    func md5String(_ string: String)->String{
        let strLen = CC_LONG(string.lengthOfBytes(using: String.Encoding.utf8))
        let digestLen = Int(CC_MD5_DIGEST_LENGTH)
        let result = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: digestLen)
        CC_MD5(string.cString(using: String.Encoding.utf8)!, strLen, result)
        let hash = NSMutableString()
        for i in 0..<digestLen {
            hash.appendFormat("%02x", result[i])
        }
        result.deallocate(capacity: digestLen)
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
    
    func passwordEncode(_ password:String)->String{
        var password = password
        password = md5String(password)
        var passwordEndedeStr:String = ""
        for character in password.utf16 {
            passwordEndedeStr += "a"+(String(character))
        }
        return passwordEndedeStr
    }
    
    func checkIsUsername(_ str: String) -> Bool{
        do {
            // - 1、创建规则
            let pattern = "[A-Z][A-Z][0-9]{13}.[0-9]{3}"
            // - 2、创建正则表达式对象
            let regex = try NSRegularExpression(pattern: pattern, options: NSRegularExpression.Options.caseInsensitive)
            // - 3、开始匹配
            let res = regex.matches(in: str, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSMakeRange(0, str.characters.count))
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
    
    func checkIsPhoneNumber(_ str: String) -> Bool {
        do {
            // - 1、创建规则
            let pattern = "[1-9][0-9]{8,14}"
            // - 2、创建正则表达式对象
            let regex = try NSRegularExpression(pattern: pattern, options: NSRegularExpression.Options.caseInsensitive)
            // - 3、开始匹配
            let res = regex.matches(in: str, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSMakeRange(0, str.characters.count))
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
    
    func checkIsEmail(_ str: String)->Bool{
        do {
            //([a-zA-Z0-9_-])+@([a-zA-Z0-9_-])+(.[a-zA-Z0-9_-])+/
            // - 1、创建规则
            let pattern = "[a-zA-Z0-9_-]{1,20}@[a-zA-Z0-9_-]{1,20}.[a-zA-Z0-9_-]{1,20}"
            // - 2、创建正则表达式对象
            let regex = try NSRegularExpression(pattern: pattern, options: NSRegularExpression.Options.caseInsensitive)
            // - 3、开始匹配
            let res = regex.matches(in: str, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSMakeRange(0, str.characters.count))
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
    
    func resizeImage(_ image: UIImage, newSize: CGSize) -> UIImage{
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
        
        let newSize = CGSize(width: newSizeWidth, height: newSizeHeight)
        UIGraphicsBeginImageContext(newSize)
        image.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        let newimage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newimage!
    }
    
    func savePatientStatusToLocalDB(_ patientStatusObjList: NSArray){
        let appDel:AppDelegate = (UIApplication.shared.delegate as! AppDelegate)
        let context:NSManagedObjectContext = appDel.managedObjectContext!
        for patientStatus in patientStatusObjList {
            let patientstatusLocalDBItem = NSEntityDescription.insertNewObject(forEntityName: tablePatientStatus, into: context)
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
