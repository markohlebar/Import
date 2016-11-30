//
//  Sandboxing.swift
//  Import
//
//  Created by Marko Hlebar on 30/11/2016.
//  Copyright © 2016 Marko Hlebar. All rights reserved.
//

import Foundation
import Security

public struct Sandboxing {
    //https://forums.developer.apple.com/message/135465#135465
    public static func isAppSandboxed() -> Bool {
        var err: OSStatus
        var me: SecCode?
        var dynamicInfo: CFDictionary?
        let defaultFlags = SecCSFlags(rawValue: 0)

        err = SecCodeCopySelf(defaultFlags, &me)

        guard me != nil else {
            return false
        }

        var staticMe: SecStaticCode?
        err =  SecCodeCopyStaticCode(me!, defaultFlags, &staticMe)

        guard staticMe != nil else {
            return false
        }

        err = SecCodeCopySigningInformation(staticMe!, SecCSFlags(rawValue: kSecCSDynamicInformation), &dynamicInfo)
        assert(err == errSecSuccess)

        if let info = dynamicInfo as? [String: Any],
            let entitlementsDict = info["entitlements-dict"] as? [String: Any],
            let value = entitlementsDict["com.apple.security.app-sandbox"] as? Bool {
            return value
        }

        return false
    }

    public static func userHomePath() -> String {
        let usersHomePath = getpwuid(getuid()).pointee.pw_dir
        let usersHomePathString : String = FileManager.default.string(withFileSystemRepresentation: usersHomePath!, length: Int(strlen(usersHomePath)))
        return usersHomePathString
    }
}


