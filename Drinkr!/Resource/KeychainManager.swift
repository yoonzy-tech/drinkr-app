//
//  KeychainManager.swift
//  Drinkr!
//
//  Created by Ruby Chew on 2023/6/6.
//

import Foundation

class KeychainManager {
    
    enum KeychainError: Error {
        case duplicateEntry
        case unknown(OSStatus)
    }
    
    static func save(service: String, account: String, password: Data) throws {
        let query: [String: AnyObject] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service as AnyObject,
            kSecAttrAccount as String: account as AnyObject,
            kSecValueData as String: password as AnyObject
        ]
        
        let status = SecItemAdd(query as CFDictionary, nil)
        guard status != errSecDuplicateItem else {
            throw KeychainError.duplicateEntry
        }
        
        guard status == errSecSuccess else {
            throw KeychainError.unknown(status)
        }
        
        print("Saved to Keychain")
    }
    
    static func get(service: String, account: String) -> Data? {
        let query: [String: AnyObject] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service as AnyObject,
            kSecAttrAccount as String: account as AnyObject,
            kSecReturnData as String: kCFBooleanTrue,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        print("Read status: \(status)")
        
        return result as? Data
    }
    
    static func getUid(service: String, account: String) -> String {
        guard let data = KeychainManager.get(service: service, account: account) else {
            return "Fail to read UID in Keychain"
        }
        
        let uid = String(decoding: data, as: UTF8.self)
        print("Read UID: \(uid)")
        FirebaseManager.shared.fetchAccountInfo(uid: uid) { userData in
            FirebaseManager.shared.userData = userData
        }
        return uid
    }
}

/*
 
let userUid = KeychainManager.getUid(service: currentUser.providerID, account: currentUser.email ?? "Unknown user email")

let provider = user.providerID
do {
  try KeychainManager.save(
    service: provider,
    account: email,
    password: uid.data(using: .utf8) ?? Data()
 )
  print("Service: \(provider), Account: \(email), UID: \(uid)")
  completion?(user)
} catch {
    print(error)
}
 
 */
