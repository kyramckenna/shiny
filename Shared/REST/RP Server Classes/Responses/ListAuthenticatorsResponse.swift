//
//  ListAuthenticatorsResponse.swift
//  DaonFidoSampleRpApp
//
//  Copyright © 2018 Daon. All rights reserved.
//

internal class ListAuthenticatorsResponse : BaseNetworkResponse
{
    // MARK:- Properties
    
    internal var authenticatorInfoList : Array<AuthenticatorInfo>?
    
    // MARK:- JSON Keys
    
    private let jsonAuthenticatorInfoListKey = "authenticatorInfoList"
    
    // MARK:- Initialisation
    
    override init(error: ServerOperationError?) {
        super.init(error: error)
    }
    
    override init(json: Any) {
        super.init(json: json)
        
        if let jsonRepresentation = json as? [String : Any] {
            self.authenticatorInfoList = Array<AuthenticatorInfo>()
            
            if let authenticatorInfos = jsonRepresentation[jsonAuthenticatorInfoListKey] as? Array<AnyObject> {
                for infoDict in authenticatorInfos {
                    let authInfo = AuthenticatorInfo(json: infoDict as? [String : Any])
                    self.authenticatorInfoList!.append(authInfo)
                }
            }
        }
    }
}
