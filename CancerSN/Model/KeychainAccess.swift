//
//  KeychainAccess.swift
//  CancerSN
//
//  Created by lily on 7/23/15.
//  Copyright (c) 2015 lily. All rights reserved.
//

import Foundation

class KeychainAccess: NSObject {
    
    func setPasscode(_ identifier: String, passcode: String) {
        let dataFromString: Data = passcode.data(using: String.Encoding.utf8)!;
        let keychainQuery = [String(kSecClass): kSecClassGenericPassword, String(kSecAttrService): identifier, String(kSecValueData): dataFromString] as [String : Any]

        SecItemDelete(keychainQuery as CFDictionary);
        
        var status: OSStatus = SecItemAdd(keychainQuery as CFDictionary, nil);
        
    }
    
    func getPasscode(_ identifier: String) -> NSString? {
        
        /*
        var keychainQuery = [
        kSecClass       : kSecClassGenericPassword,
        kSecAttrService : identifier,
        kSecReturnData  : kCFBooleanTrue,
        kSecMatchLimit  : ];
        */
        
        let keychainQuery = [String(kSecClass): kSecClassGenericPassword, String(kSecAttrService): identifier, String(kSecReturnData):kCFBooleanTrue, String(kSecMatchLimit):kSecMatchLimitOne] as [String : Any]

        var dataTypeRef: AnyObject?
        
        let status: OSStatus = withUnsafeMutablePointer(to: &dataTypeRef) { SecItemCopyMatching(keychainQuery as CFDictionary, UnsafeMutablePointer($0)) }
        var passcode: NSString?

        if status == noErr && dataTypeRef != nil{
            passcode = NSString(data: (dataTypeRef as? Data)!, encoding: String.Encoding.utf8.rawValue);
        }

        return passcode;
    }
    
    func deletePasscode(_ identifier: String){
        let keychainQuery = [String(kSecClass): kSecClassGenericPassword, String(kSecAttrService): identifier] as [String : Any]

        SecItemDelete(keychainQuery as CFDictionary);
    }
    
}
