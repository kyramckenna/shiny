//
//  CreateSessionResponse.swift
//  DaonFidoSampleRpApp
//
//  Copyright © 2018 Daon. All rights reserved.
//
import Foundation

internal enum AuthenticationMethod : String
{
    case UsernameAndPassword    = "USERNAME_PASSWORD"
    case FIDO                   = "FIDO_AUTHENTICATION"
}

internal class CreateSessionResponse : BaseNetworkResponse
{
    // MARK:- Properties
    
    internal var lastLoggedIn : Date?
    internal var loggedInWith : AuthenticationMethod?
    internal var email : String?
    internal var firstName : String?
    internal var lastName : String?
    internal var fidoAuthenticationResponse : String?
    internal var fidoResponseCode : NSNumber?
    internal var fidoResponseMsg : String?
    
    // MARK:- JSON Keys
    private let jsonSessionIdKey                    = "sessionId"
    private let jsonLastLoggedInKey                 = "lastLoggedIn"
    private let jsonLoggedInWithKey                 = "loggedInWith"
    private let jsonEmailKey                        = "email"
    private let jsonFirstNameKey                    = "firstName"
    private let jsonLastNameKey                     = "lastName"
    private let jsonFidoAuthenticationResponseKey   = "fidoAuthenticationResponse"
    private let jsonFidoResponseCodeKey             = "fidoResponseCode"
    private let jsonFidoResponseMsgKey              = "fidoResponseMsg"
        
    // MARK:- Initialisation
    
    override init(error: ServerOperationError?) {
        super.init(error: error)
    }
    
    override init(json: Any) {
        super.init(json: json)
        
        if let jsonRepresentation = json as? [String : Any] {
            self.lastLoggedIn               = ServerOperation.date(dictionary: jsonRepresentation, key:jsonLastLoggedInKey)
            self.loggedInWith               = auth(any: jsonRepresentation[jsonLoggedInWithKey])
            self.email                      = jsonRepresentation[jsonEmailKey] as? String
            self.firstName                  = jsonRepresentation[jsonFirstNameKey] as? String
            self.lastName                   = jsonRepresentation[jsonLastNameKey] as? String
            self.fidoAuthenticationResponse = jsonRepresentation[jsonFidoAuthenticationResponseKey] as? String
            self.fidoResponseCode           = jsonRepresentation[jsonFidoResponseCodeKey] as? NSNumber
            self.fidoResponseMsg            = jsonRepresentation[jsonFidoResponseMsgKey] as? String
        }
    }
    
    
    func auth(any: Any?) -> AuthenticationMethod? {
        
        if let str = any as? String {
            if (str.lowercased() == AuthenticationMethod.UsernameAndPassword.rawValue.lowercased()) {
                return AuthenticationMethod.UsernameAndPassword
            } else if (str.lowercased() == AuthenticationMethod.FIDO.rawValue.lowercased()) {
               return AuthenticationMethod.FIDO
            }
        }
        
        return nil
    }

}
