//
//  Constant.swift
//  FIDOSDKSample
//
//  Created by Kyra McKenna on 24/11/2021.
//  Copyright © 2019 Daon. All rights reserved.
//

import Foundation
import UIKit

@propertyWrapper
struct UserDefault<T> {
    let key: String
    let defaultValue: T

    init(_ key: String, default defaultValue: T = "") {
        self.key = key
        self.defaultValue = defaultValue
    }

    var wrappedValue: T {
        get {
            (UserDefaults.standard.value(forKey: key) as? T) ?? defaultValue
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: key)
        }
    }
}

struct Constants {
    
    struct Face {
        static var Quality: Float = 0.50
        static var registeredImage: UIImage!
        static var isRegistered: Bool = false
    }
    
    struct User {
        @UserDefault("Name") static var Name: String
        @UserDefault("CONSENT_ID", default: "CONSENT_ID") static var CONSENT_ID: String
        @UserDefault("CREDENTIAL_REQUEST_CHALLENGE") static var CREDENTIAL_REQUEST_CHALLENGE: String
        @UserDefault("CREDENTIAL_REQUEST_ID") static var CREDENTIAL_REQUEST_ID: String
        @UserDefault("authenticationRequestId") static var authenticationRequestId: String
        @UserDefault("authenticatorData") static var authenticatorData: String
        @UserDefault("accountId") static var accountId: String
        @UserDefault("credentialID") static var credentialID: String
        @UserDefault("userID") static var userID: String
        @UserDefault("AttestationObject") static var AttestationObject: String
        @UserDefault("clientDataJSON") static var clientDataJSON: String
        @UserDefault("sessionId") static var sessionId: String
        @UserDefault("signature") static var signature: String

        /// Call this to reset all UserDefaults-stored User values
        static func clearAll() {
            let mirror = Mirror(reflecting: Self.self)
            for child in mirror.children {
                if let label = child.label {
                    UserDefaults.standard.removeObject(forKey: label)
                }
            }
        }
    }
    
    struct Server {
        static var Url: String = "emea-rp.identityx-cloud.com/ps-w3c"
    }
    
    struct Liveness {
        static var Server_Passive: Bool = true
        static var AutoFaceCapture: Bool = true
    }
    
    struct Licenses {
        static var FIDOVersion = "4.6.0.40"
        static var FIDOLicenseDate = "24/12/2030"
        static var fidoLicense = #"{"signature":"dWVBSGegPDsnVr6yN97\/FKNRunGp0eCF2b+\/UCEsbPAgKvEB34BqkZZ82MVptijn2CwCdMx2fZ0hY5eoVM13Zf8McwLr2B5pLHM0qrLCRjl8aO2BA+wXi1rILIsasJHzBmNyx8aBy62sF9yBooesYq36lDmNcZNGed1EkT1cYlCz\/nMUxUvBaoW5RIzOJBe92591XchbSW5VUwZW2DHznelWkCL7ofVKC0+U0zlI685J3D21+zabN4FovxX8ZLa6ADHnyiF\/oA97xNxaryczpev3R5g65RYvceA3v\/Z0lu0+Jco4UVBP6Z+Ongru\/FCp+ecvsUlw6Ccj+KzzO7RCEA==","organization":"DAON","signed":{"features":["ALL"],"expiry":"2030-12-24 00:00:00","applicationIdentifier":"com.daon.*"},"version":"2.1"}"#
        static var fidoLicenseDate = NSDate()
    }
}
