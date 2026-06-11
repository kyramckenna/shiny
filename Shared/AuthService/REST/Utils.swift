//
//  Utils.swift
//  DaonFidoSampleRpApp
//
//  Created by Neil Johnston on 3/9/15.
//  Copyright (c) 2015 Daon. All rights reserved.
//

import Foundation
import UIKit

class Utils
{   
    
    class func isValidEmail(_ email : String) -> Bool
    {
        let regex       = "[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?"
        let regexTest   = NSPredicate(format:"SELF MATCHES %@", regex)
        let isValid     = regexTest.evaluate(with: email.lowercased())
        
        return isValid
    }   
    
    
    // MARK:- Validation
    
    class func isValid(url: String) -> Bool
    {
        if let nsurl = URL(string: url) {
            return UIApplication.shared.canOpenURL(nsurl)
        }
        
        return false
    }

    class func isValid(port: String) -> Bool
    {
        
        if let intVersion = Int(port) {
            return intVersion > 0
        }
        
        return false
    }
    
    // MARK:- Identifiers
        
    class func generateId() -> String
    {
        return UUID().uuidString;
    }
    
    // MARK:- Localisation
    
    class func localize(key:String) -> String
    {
        return NSLocalizedString(key, comment: "")
    }
    
}
