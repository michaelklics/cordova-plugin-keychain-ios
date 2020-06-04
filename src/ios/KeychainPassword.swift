//
//  CordovaKeychainPlugin.swift
//  KeyChainPlugin
//
//  Created by Michael Klics on 6/1/20.
//  Copyright © 2020 Michael Klics. All rights reserved.
//

import Foundation

private struct KeychainConfiguration {
    let serviceName: String
    let accessGroup: String?

    init(_ serviceName: String,_ accessGroup: String? = nil) {
        self.serviceName = serviceName
        self.accessGroup = accessGroup
    }
}

@objc(KeychainPassword)
public class CordovaPluginTemplate: CDVPlugin {

    // MARK: Properties

    private var keychainConfiguration: KeychainConfiguration = {
        return KeychainConfiguration("KeychainPasswordPlugin")
    }()

    // MARK: Types

    private enum KeychainInterfaceError: Error {
        case invalidInput
        case unknownError
        // TODO: Capitalize and split
        var message: String {
            return String(describing: KeychainInterfaceError.self) + ": " + String(describing: self)
        }
    }

    // MARK: Cordova Exposed Methods

    @objc func savePassword(_ command: CDVInvokedUrlCommand) {
        DispatchQueue.global(qos: .userInteractive).sync {
            if let credentials = command.arguments[0] as? [String] {
                guard credentials.count == 2 else {
                    let error = KeychainInterfaceError.invalidInput
                    let data = ["Error": error.message]
                    self.failureCallback(callbackId: command.callbackId, data: data)
                    return
                }
                let accountName = credentials[0]
                let password = credentials[1]
                let keychainPasswordItem = self.createKeychainItem(accountName)
                do {
                    try keychainPasswordItem.savePassword(password)
                    self.successCallback(callbackId: command.callbackId, data: ["password": password])
                }
                catch let error {
                    self.handleKeychainError(error, command)
                }
            }
        }
    }

    @objc func renameAccount(_ command: CDVInvokedUrlCommand) {
        DispatchQueue.global(qos: .userInteractive).sync {
            if let credentials = command.arguments[0] as? [String] {
                guard credentials.count == 2 else {
                    let error = KeychainInterfaceError.invalidInput
                    let data = ["Error": error.message]
                    self.failureCallback(callbackId: command.callbackId, data: data)
                    return
                }
                let oldAccountName = credentials[0]
                let newAccountName = credentials[1]
                var keychainPasswordItem = self.createKeychainItem(oldAccountName)
                do {
                    try keychainPasswordItem.renameAccount(newAccountName)
                    self.successCallback(callbackId: command.callbackId, data: [:])
                }
                catch let error {
                    self.handleKeychainError(error, command)
                }
            }
        }
    }

    @objc func getPassword(_ command: CDVInvokedUrlCommand) {
        DispatchQueue.global(qos: .userInteractive).sync {
            if let accountName = command.arguments[0] as? [String], accountName.count == 1 {
                do {
                    let passwordItem = self.createKeychainItem(accountName[0])
                    let password = try passwordItem.readPassword()
                    self.successCallback(callbackId: command.callbackId, data: ["password": password])
                }
                catch let error {
                    self.handleKeychainError(error, command)
                }
            } else {
                self.handleKeychainError(KeychainInterfaceError.invalidInput, command)
            }
        }
    }

    @objc func updateKeychainConfiguration(_ command: CDVInvokedUrlCommand) {
        DispatchQueue.global(qos: .userInteractive).sync {
            if let settings = command.arguments[0] as? [String] {
                guard settings.count >= 1, settings.count < 3 else {
                    let error = KeychainInterfaceError.invalidInput
                    let data = ["error": error.message]
                    self.failureCallback(callbackId: command.callbackId, data: data)
                    return
                }
                let service = settings[0]
                let accessGroup = settings.count == 2 ? settings[1] : nil
                self.keychainConfiguration = KeychainConfiguration(service, accessGroup)
                self.successCallback(callbackId: command.callbackId, data: [:])
            }
        }
    }

    @objc func delete(_ command: CDVInvokedUrlCommand) {
        DispatchQueue.global(qos: .userInteractive).sync {
            if let accountNames = command.arguments[0] as? [String], accountNames.count == 1 {
                do {
                    let passwordItem = self.createKeychainItem(accountNames[0])
                    try passwordItem.deleteItem()
                    self.successCallback(callbackId: command.callbackId, data: [:])
                }
                catch let error {
                    self.handleKeychainError(error, command)
                }
            } else {
                self.handleKeychainError(KeychainInterfaceError.invalidInput, command)
            }
        }
    }

    // MARK: Convenience

    private func handleKeychainError(_ error: Error,_ command: CDVInvokedUrlCommand) {
        var data = [String: String]()
        if let error = error as? KeychainPasswordItem.KeychainError {
            data["error"] = error.message
        } else if let error = error as? KeychainInterfaceError {
            data["error"] = error.message
        } else {
            //TODO: Possibly Trap Here
            let error = KeychainInterfaceError.unknownError
            data["error"] = error.message
        }
        failureCallback(callbackId: command.callbackId, data: data)
    }

    private func createKeychainItem(_ accountName: String) -> KeychainPasswordItem {
        return KeychainPasswordItem(service: keychainConfiguration.serviceName,
                                    account: accountName,
                                    accessGroup: keychainConfiguration.accessGroup)
    }

    // MARK: Delegate back to javascript

    private func successCallback(callbackId: String, data: [String: Any]) {
        if let commandResult = CDVPluginResult.init(status: CDVCommandStatus_OK, messageAs: data) {
            commandResult.keepCallback = true
            DispatchQueue.main.async {
                self.commandDelegate.send(commandResult, callbackId: callbackId)
            }
        }
    }

    private func failureCallback(callbackId: String, data: [String: Any]) {
        if let commandResult = CDVPluginResult.init(status: CDVCommandStatus_ERROR, messageAs: data) {
            commandResult.keepCallback = true
            DispatchQueue.main.async {
                self.commandDelegate.send(commandResult, callbackId: callbackId)
            }
        }
    }
}
