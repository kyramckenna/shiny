//
//  SettingsManager.swift
//  DaonFidoSampleRpApp
//
//  Copyright (c) 2015 Daon. All rights reserved.
//

import Foundation

class SettingsManager: NSObject
{
    static let shared: SettingsManager = SettingsManager()
    
    // MARK:- Settings Keys
    private let KAccountIdKey                       = "accountId"
    private let KSignedInKey                        = "signedIn"
    private let KFidoAppIdKey                       = "fidoAppId"
    private let KServerInfoUrl                      = "serverInfoUrl"
    private let KOtherTabbedVerification            = "tabbedVerification"
    private let KOtherMultipleChoiceAuthentication  = "multipleChoiceAuthentication"
    private let KOtherSingleShot                    = "singleShot"
    // Stronger key protection for Touch/Face ID
    private let KOtherLocalAuthenticationAccessBiometry = "localAuthenticationAccessBiometry"
    private let KUICaptureMechanism                 = "uiCaptureMechanism"
    
    
    enum UICaptureMechanism : Int
    {
        case defaultMechanism               = 0
        case customViewControllersMechanism = 1
        case captureControllersMechanism    = 2
        case swiftUI                        = 3
    }
    
    // Push notification
    internal var notification : [AnyHashable: Any]?
        
    let defaults = UserDefaults(suiteName: "group.daon")
    
    // No group
    // let defaults = UserDefaults(suiteName: nil)
    
    // MARK:- Initialisation
    
    override init()
    {
        super.init()
        
        setDefaults()
    }

    // MARK:- Settings - UserDefaults Access
    
    private func setDefaults()
    {
        let initialDefaultsPath = Bundle.main.path(forResource: "defaultPrefs", ofType: "plist")
        //let keyedValues         = NSDictionary(contentsOfFile: initialDefaultsPath!)
        
        //defaults?.register(defaults: keyedValues as! Dictionary)
    }
    
    private func update(key: String, newValue: Any)
    {
        defaults?.set(newValue, forKey: key)
        defaults?.synchronize()
    }
    
    private func stringForPref(key: String) -> String
    {
        let storedString : String? = defaults?.object(forKey: key) as? String
        
        if let loadedString = storedString
        {
            return loadedString as String
        }
        else
        {
            return ""
        }
    }
    
    private func boolForPref(key: String) -> Bool
    {
        if let b = defaults?.bool(forKey: key) {
            return b
        }
        
        return false
    }
    
    private func integerForPref(key: String) -> NSInteger
    {
        if let i = defaults?.integer(forKey: key) {
            return i
        }
        
        return 0
    }
    
    func allKeys() -> [String : Any]?
    {
        return defaults?.dictionaryRepresentation()
    }
    
    
    // MARK:- Settings - Account
    
    func setAccount(withName: String?)
    {
        if let name = withName {
            update(key: KAccountIdKey, newValue: name)
        } else {
            defaults?.removeObject(forKey: KAccountIdKey)
            defaults?.synchronize()
        }
    }
    
    func account() -> String?
    {
        return stringForPref(key: KAccountIdKey)
    }
    

    // MARK:- Settings - Server
    
    func setServer(url: String)
    {
        update(key: KServerInfoUrl, newValue: url)
    }
        
    func url() -> String
    {
        print("url: ", stringForPref(key: KServerInfoUrl))
        return stringForPref(key: KServerInfoUrl)
    }
    
    // MARK:- Settings - UI
    
    func setTabbedVerification(on: Bool)
    {
        update(key: KOtherTabbedVerification, newValue: on)
    }
    
    func tabbedVerification() -> Bool
    {
        return boolForPref(key: KOtherTabbedVerification)
    }
    
    func setMultipleChoiceAuthentication(on: Bool)
    {
        update(key: KOtherMultipleChoiceAuthentication, newValue: on)
    }
    
    func multipleChoiceAuthentication() -> Bool
    {
        return boolForPref(key: KOtherMultipleChoiceAuthentication)
    }
    
    func setUICaptureMechanism(_ mechanism: UICaptureMechanism)
    {
        update(key: KUICaptureMechanism, newValue: mechanism.rawValue)
    }
    
    func uiCaptureMechanism() -> UICaptureMechanism
    {
        if let mechanism = UICaptureMechanism(rawValue: integerForPref(key: KUICaptureMechanism))
        {
            return mechanism
        }
        else
        {
            return .defaultMechanism
        }
    }

    // MARK:- Settings - Other Features
    
    func setSingleShot(enabled: Bool)
    {
        update(key: KOtherSingleShot, newValue: enabled)
    }
    
    func isSingleShotEnabled() -> Bool
    {
        return boolForPref(key: KOtherSingleShot)
    }
    
    func setLocalAuthenticationAccessBiometry(enabled: Bool)
    {
        update(key: KOtherLocalAuthenticationAccessBiometry, newValue: enabled)
    }
    
    func isLocalAuthenticationAccessBiometryEnabled() -> Bool
    {
        return boolForPref(key: KOtherLocalAuthenticationAccessBiometry)
    }
    
    // MARK:- Reset
    
    func reset()
    {
        if let existingSettings = defaults?.dictionaryRepresentation() {
            
            for settingKey in existingSettings.keys
            {
                defaults?.removeObject(forKey: settingKey)
            }
            
            defaults?.synchronize()
        }
        setDefaults()
    }
    
    func logout()
    {
//        Fido.shared.revokeServiceAccess(parameters: nil) { (error) in
//            (UIApplication.shared.delegate as! AppDelegate).logout()
//        }
    }
}
