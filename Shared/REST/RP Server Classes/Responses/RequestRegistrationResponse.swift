//
//  RequestRegistrationResponse
//  DaonFidoSampleRpApp
//
//  Created by Neil Johnston on 5/6/16.
//  Copyright © 2018 Daon. All rights reserved.
//

internal class RequestRegistrationResponse : BaseNetworkResponse
{
    // MARK:- Properties
    
    internal var fidoRegistrationRequest : String?
    internal var registrationRequestId : String?
    
    // MARK:- JSON Keys
    
    private let jsonFidoRegistrationRequestKey  = "fidoRegistrationRequest"
    private let jsonRegistrationRequestIdKey    = "registrationRequestId"
        
    // MARK:- Initialisation
    
    override init(error: ServerOperationError?) {
        super.init(error: error)
    }
    
    override init(json: Any) {
        super.init(json: json)
        
        if let jsonRepresentation = json as? [String : Any] {
            self.fidoRegistrationRequest    = jsonRepresentation[jsonFidoRegistrationRequestKey] as? String
            self.registrationRequestId      = jsonRepresentation[jsonRegistrationRequestIdKey] as? String
        }
    }
}
