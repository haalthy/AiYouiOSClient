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
        let keychainQuery = [String(kSecClass): kSecClassGenericPassword, String(kSecAttrService): identifier, String(kSecValueData): dataFromString]

        SecItemDelete(keychainQuery as CFDictionaryRef);
        
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
        
        let keychainQuery = [String(kSecClass): kSecClassGenericPassword, String(kSecAttrService): identifier, String(kSecReturnData):kCFBooleanTrue, String(kSecMatchLimit):kSecMatchLimitOne]

        var dataTypeRef: AnyObject?
        
        let status: OSStatus = withUnsafeMutablePointer(&dataTypeRef) { SecItemCopyMatching(keychainQuery as CFDictionaryRef, UnsafeMutablePointer($0)) }
        var passcode: NSString?

        if status == noErr && dataTypeRef != nil{
            passcode = NSString(data: (dataTypeRef as? NSData)!, encoding: NSUTF8StringEncoding);
        }

        return passcode;
    }
    
    func deletePasscode(identifier: String){
        let keychainQuery = [String(kSecClass): kSecClassGenericPassword, String(kSecAttrService): identifier]

        SecItemDelete(keychainQuery as CFDictionaryRef);
    }
    
}