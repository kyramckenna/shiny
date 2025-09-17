//
//  CreateAccountResponse.swift
//  DaonFidoSampleRpApp
//
//  Copyright © 2018 Daon. All rights reserved.
//

import Foundation

internal class CreateAccountResponse : BaseNetworkResponse
{
    // MARK:- Properties
    
    internal var accountId : String?
    internal var session_Id : String?
    internal var w3cMakeCredentialRequest : String?
    internal var makeCredentialRequestId : String?
    
    // MARK:- JSON Keys
    
    fileprivate let jsonAccountIdKey                      = "accountId"
    fileprivate let jsonRequestMakeCredentialResponseKey  = "requestMakeCredentialResponse"
    fileprivate let jsonw3cMakeCredentialRequestKey       = "w3cMakeCredentialRequest"
    fileprivate let jsonMakeCredentialRequestIdKey        = "makeCredentialRequestId"
    
    // MARK:- Initialisation
    
    override init(error: ServerOperationError?)
    {
        super.init(error: error)
    }
//    
//    override init(json: Any) {
//        super.init(json: json)
//        
//        if let jsonRepresentation = json as? [String: Any] {
//            self.accountId = jsonRepresentation[jsonAccountIdKey] as? String
//            self.session_Id = jsonRepresentation["sessionId"] as? String
//            
//            if let credentialResponse = jsonRepresentation[jsonRequestMakeCredentialResponseKey] as? [String: Any] {
//                //self.w3cMakeCredentialRequest = credentialResponse[jsonw3cMakeCredentialRequestKey] as? String
//                self.makeCredentialRequestId = credentialResponse[jsonMakeCredentialRequestIdKey] as? String
//                if let request =  credentialResponse[jsonw3cMakeCredentialRequestKey] as? [String: Any] {
//                    self.w3cMakeCredentialRequest = request["challenge"] as? String
//                }
//            }
//        }
//    }
//    
    override init(json: Any) {
        super.init(json: json)
        
        if let jsonRepresentation = json as? [String: Any] {
            self.accountId = jsonRepresentation[jsonAccountIdKey] as? String
            self.session_Id = jsonRepresentation["sessionId"] as? String
            
            if let credentialResponse = jsonRepresentation[jsonRequestMakeCredentialResponseKey] as? [String: Any] {
                self.makeCredentialRequestId = credentialResponse[jsonMakeCredentialRequestIdKey] as? String
                
                if let w3cMakeCredentialRequestString = credentialResponse[jsonw3cMakeCredentialRequestKey] as? String {
                    // w3cMakeCredentialRequest is a JSON string, so parse it
                    if let data = w3cMakeCredentialRequestString.data(using: .utf8),
                       let parsedRequest = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                       let makeCredentialRequestV1 = parsedRequest["makeCredentialRequestV1"] as? [String: Any],
                       let challenge = makeCredentialRequestV1["challenge"] as? String {
                        self.w3cMakeCredentialRequest = challenge
                    } else {
                        print("Failed to parse w3cMakeCredentialRequest JSON string")
                    }
                }
            }
        }
    }
}
