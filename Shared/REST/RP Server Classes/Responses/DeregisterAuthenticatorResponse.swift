//
//  DeregisterAuthenticatorResponse
//  DaonFidoSampleRpApp
//
//  Created by Neil Johnston on 5/6/16.
//  Copyright © 2018 Daon. All rights reserved.
//

internal class DeregisterAuthenticatorResponse : BaseNetworkResponse
{
    // MARK:- Properties
    
    internal var deregistrationRequest : String?
    
    
    // MARK:- Initialisation
    
    override init(error: ServerOperationError?) {
        super.init(error: error)
    }
    
    init(request: String) {
        super.init(error: nil)
        
        self.deregistrationRequest = request
    }
}
