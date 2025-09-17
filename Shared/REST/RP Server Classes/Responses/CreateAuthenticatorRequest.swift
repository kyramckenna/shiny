//
//  CreateAuthenticator.swift
//  DaonFidoSampleRpApp
//
//  Created by Neil Johnston on 5/6/16.
//  Copyright © 2016 Daon. All rights reserved.
//

import Foundation

internal class CreateAuthenticatorRequest : NSObject
{
    // MARK:- Properties
    
    internal var fidoReqistrationResponse : String
    internal var registrationChallengeId : String
    
    // MARK:- JSON Keys
    
    fileprivate let jsonFidoReqistrationResponseKey = "fidoReqistrationResponse"
    fileprivate let jsonRegistrationChallengeIdKey  = "registrationChallengeId"
    
    // MARK:- Initialisation
    
    init(response: String, challengeId: String)
    {
        self.fidoReqistrationResponse   = response
        self.registrationChallengeId    = challengeId
    }
    
    // MARK:- JSON
    
    internal func dictionary() -> Dictionary<String, String>
    {
        var dict = Dictionary<String, String>()
        
        dict[jsonFidoReqistrationResponseKey]   = fidoReqistrationResponse
        dict[jsonRegistrationChallengeIdKey]    = registrationChallengeId
        
        return dict
    }
}
