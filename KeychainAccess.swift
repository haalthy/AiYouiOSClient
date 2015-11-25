//
//  KeychainAccess.swift
//  CancerSN
//
//  Created by lily on 7/23/15.
//  Copyright (c) 2015 lily. All rights reserved.
//

import Foundation

class KeychainAccess: NSObject {
    
    func setPasscode(identifier: String, passcode: String) {
        var dataFromString: NSData = passcode.dataUsingEncoding(NSUTF8StringEncoding)!;
        /*
        var keychainQuery = [
        kSecClass       : kSecClassGenericPassword,
        kSecAttrService : identifier,
        kSecValueData   : dataFromString];
        */
//        var keychainQuery = NSDictionary(
//            objects: [kSecClassGenericPassword, identifier, dataFromString],
//            forKeys: [kSecClass, kSecAttrService, kSecValueData]);
        let keychainQuery = [String(kSecClass): kSecClassGenericPassword, String(kSecAttrService): identifier, String(kSecValueData): dataFromString]

        SecItemDelete(keychainQuery as CFDictionaryRef);
        
        //            SecItemDelete(keychainQuery as CFDictionaryRef);
        var status: OSStatus = SecItemAdd(keychainQuery as CFDictionaryRef, nil);
        
    }
    
    func getPasscode(identifier: String) -> NSString? {
        
        /*
        var keychainQuery = [
        kSecClass       : kSecClassGenericPassword,
        kSecAttrService : identifier,
        kSecReturnData  : kCFBooleanTrue,
        kSecMatchLimit  : ];
        */
        
//        let values = [kSecClassGenericPassword, identifier, kCFBooleanTrue, kSecMatchLimitOne]
//        let keys = [String(kSecClass), String((kSecAttrService), String((kSecReturnData), String(kSecMatchLimit)]
//        var keychainQuery = NSDictionary(
//            objects: values,
//            forKeys: keys);
        
        let keychainQuery = [String(kSecClass): kSecClassGenericPassword, String(kSecAttrService): identifier, String(kSecReturnData):kCFBooleanTrue, String(kSecMatchLimit):kSecMatchLimitOne]
        
//        var dataTypeRef :AnyObject?
//        let status: OSStatus = withUnsafeMutablePointer(&dataTypeRef) { SecItemCopyMatching(keychainQuery as CFDictionaryRef, UnsafeMutablePointer($0)) }
//        let opaque = dataTypeRef as? NSData
//        var passcode: NSString?;
//        if let op = opaque {
//            let retrievedData = Unmanaged<NSData>.fromOpaque(op).takeUnretainedValue();
//            passcode = NSString(data: retrievedData, encoding: NSUTF8StringEncoding);
//        } else {
//            print("Username not found. Status code \(status)");
//        }
        var dataTypeRef: AnyObject?
        
        let status: OSStatus = withUnsafeMutablePointer(&dataTypeRef) { SecItemCopyMatching(keychainQuery as CFDictionaryRef, UnsafeMutablePointer($0)) }
        var passcode: NSString?

        if status == noErr && dataTypeRef != nil{
            passcode = NSString(data: (dataTypeRef as? NSData)!, encoding: NSUTF8StringEncoding);
        }

        return passcode;
    }
    
    func deletePasscode(identifier: String){
//        var keychainQuery = NSDictionary(
//            objects: [kSecClassGenericPassword, identifier],
//            forKeys: [kSecClass, kSecAttrService]);
        let keychainQuery = [String(kSecClass): kSecClassGenericPassword, String(kSecAttrService): identifier]

        SecItemDelete(keychainQuery as CFDictionaryRef);
    }
    
}