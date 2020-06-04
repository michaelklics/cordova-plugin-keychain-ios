//
//  KeychainPluginItem.swift
//  KeyChainPluginItem
//
//  Created by Michael Klics on 6/1/20.
//  Copyright © 2020 Michael Klics. All rights reserved.
//

import Foundation

struct KeychainPasswordItem {

    // MARK: Types

    enum KeychainError: Error {
        case noPassword
        case unexpectedPasswordData
        case unexpectedItemData
        case unhandledError(status: OSStatus)

        // TODO: Capitalize and split
        var message: String {
            switch self {
            case .unhandledError(let status):
                if #available(iOS 11.3, *), let errorMessage = SecCopyErrorMessageString(status, nil) {
                    let errorString = errorMessage as NSString as String
                    return String(describing: KeychainError.self) + ": " + errorString

                } else {
                    return String(describing: KeychainError.self)  + ": " + "unhandled error, no error message for OSStatus"
                }
            default:
                return String(describing: KeychainError.self) + ": " + String(describing: self)
            }
        }
    }

    // MARK: Properties

    private let service: String
    private var account: String
    private let accessGroup: String?

    // MARK: Intialization

    init(service: String, account: String, accessGroup: String? = nil) {
        self.service = service
        self.account = account
        self.accessGroup = accessGroup
    }

    // MARK: Keychain access

    func readPassword() throws -> String  {
        var query = KeychainPasswordItem.keychainQuery(withService: service, account: account, accessGroup: accessGroup)
        query[kSecMatchLimit as String] = kSecMatchLimitOne
        query[kSecReturnAttributes as String] = kCFBooleanTrue
        query[kSecReturnData as String] = kCFBooleanTrue

        var queryResult: AnyObject?
        let status = withUnsafeMutablePointer(to: &queryResult) {
            SecItemCopyMatching(query as CFDictionary, UnsafeMutablePointer($0))
        }

        guard status != errSecItemNotFound else { throw KeychainError.noPassword }
        guard status == noErr else { throw KeychainError.unhandledError(status: status) }

        guard let existingItem = queryResult as? [String : AnyObject],
            let passwordData = existingItem[kSecValueData as String] as? Data,
            let password = String(data: passwordData, encoding: String.Encoding.utf8)
        else {
            throw KeychainError.unexpectedPasswordData
        }
        return password
    }

    func savePassword(_ password: String) throws {
        let encodedPassword = password.data(using: String.Encoding.utf8)!

        do {
            try _ = readPassword()

            var attributesToUpdate = [String : AnyObject]()
            attributesToUpdate[kSecValueData as String] = encodedPassword as AnyObject?

            let query = KeychainPasswordItem.keychainQuery(withService: service, account: account, accessGroup: accessGroup)
            let status = SecItemUpdate(query as CFDictionary, attributesToUpdate as CFDictionary)
            guard status == noErr else { throw KeychainError.unhandledError(status: status) }
        }
        catch KeychainError.noPassword {
            var newItem = KeychainPasswordItem.keychainQuery(withService: service, account: account, accessGroup: accessGroup)
            newItem[kSecValueData as String] = encodedPassword as AnyObject?
            let status = SecItemAdd(newItem as CFDictionary, nil)
            guard status == noErr else { throw KeychainError.unhandledError(status: status) }
        }
    }

    mutating func renameAccount(_ newAccountName: String) throws {
        var attributesToUpdate = [String : AnyObject]()
        attributesToUpdate[kSecAttrAccount as String] = newAccountName as AnyObject?

        let query = KeychainPasswordItem.keychainQuery(withService: service, account: self.account, accessGroup: accessGroup)
        let status = SecItemUpdate(query as CFDictionary, attributesToUpdate as CFDictionary)
        guard status == noErr || status == errSecItemNotFound else { throw KeychainError.unhandledError(status: status) }

        self.account = newAccountName
    }

    func deleteItem() throws {
        let query = KeychainPasswordItem.keychainQuery(withService: service, account: account, accessGroup: accessGroup)
        let status = SecItemDelete(query as CFDictionary)
        guard status == noErr || status == errSecItemNotFound else { throw KeychainError.unhandledError(status: status) }
    }

    // MARK: Convenience

    private static func keychainQuery(withService service: String, account: String? = nil, accessGroup: String? = nil) -> [String : AnyObject] {
        var query = [String : AnyObject]()
        query[kSecClass as String] = kSecClassGenericPassword
        query[kSecAttrService as String] = service as AnyObject?

        if let account = account {
            query[kSecAttrAccount as String] = account as AnyObject?
        }

        if let accessGroup = accessGroup {
            query[kSecAttrAccessGroup as String] = accessGroup as AnyObject?
        }

        return query
    }
}
