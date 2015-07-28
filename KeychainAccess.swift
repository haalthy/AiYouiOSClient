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
        
        var keychainQuery = NSDictionary(
            objects: [kSecClassGenericPassword, identifier, dataFromString],
            forKeys: [kSecClass, kSecAttrService, kSecValueData]);
        
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
        kSecMatchLimit  : kSecMatchLimitOne];
        */
        
        var keychainQuery = NSDictionary(
            objects: [kSecClassGenericPassword, identifier, kCFBooleanTrue, kSecMatchLimitOne],
            forKeys: [kSecClass, kSecAttrService, kSecReturnData, kSecMatchLimit]);
        
        var dataTypeRef :Unmanaged<AnyObject>?;
        let status: OSStatus = SecItemCopyMatching(keychainQuery, &dataTypeRef);
        let opaque = dataTypeRef?.toOpaque();
        var passcode: NSString?;
        if let op = opaque {
            let retrievedData = Unmanaged<NSData>.fromOpaque(op).takeUnretainedValue();
            passcode = NSString(data: retrievedData, encoding: NSUTF8StringEncoding);
        } else {
            println("Username not found. Status code \(status)");
        }
        return passcode;
    }
    
    func deletePasscode(identifier: String){
        var keychainQuery = NSDictionary(
            objects: [kSecClassGenericPassword, identifier],
            forKeys: [kSecClass, kSecAttrService]);
        
        SecItemDelete(keychainQuery as CFDictionaryRef);
    }
    
}