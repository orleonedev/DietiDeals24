//
//  KeychainWrapper.swift
//  DietiDeals24
//
//  Created by Oreste Leone on 05/02/25.
//
import Foundation

class KeychainWrapper {
    
    static func getData(key: String) -> String? {
        
        var query: [String:Any] = [
            kSecClass as String: kSecClassGenericPassword as String,
            kSecAttrAccount as String: key,
            kSecReturnData as String: kCFBooleanTrue ?? false,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var dataTypeRef: AnyObject?
        let status: OSStatus = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
        if status == noErr {
            if let data = dataTypeRef as? Data {
                return String(data: data, encoding: .utf8)
            }
        }
        
        return nil
    }
    
    @discardableResult
    static func saveData(key: String, value: String) -> Bool {
        
        guard let data = value.data(using: .utf8) else { return false }
        
        var query: [String:Any] = [
            kSecClass as String: kSecClassGenericPassword as String,
            kSecAttrAccount as String: key,
            kSecValueData as String: data
        ]
        
        // Delete the query if exists
        SecItemDelete(query as CFDictionary)
        
        // Store your value
        let status: OSStatus = SecItemAdd(query as CFDictionary, nil)
        if status == noErr {
            return true
        }
        
        return false
    }
    
    @discardableResult
    static func removeData(key: String) -> Bool {
        
        var query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]
        
        let status: OSStatus = SecItemDelete(query as CFDictionary)
        if status == noErr {
            return true
        }
        
        return false
        
    }
    
}
