//
//  ServerInfo.swift
//  FIDOSDKSample
//
//  Created by Kyra McKenna on 24/11/2021.
//

import Foundation

class ServerInfo: NSObject
{
    // MARK:- Properties
    
    internal var serverUrl : String
    internal var serverPort : Int
    internal var serverSecure : Bool
    
    // MARK:- Initialisation
    
    override init()
    {
        self.serverUrl      = ""
        self.serverPort     = 0
        self.serverSecure   = false
        
        super.init()
    }
    
    init(url : String, port : Int, secure : Bool)
    {
        self.serverUrl      = url
        self.serverPort     = port
        self.serverSecure   = secure
        
        super.init()
    }
    
    // MARK:- Contents
    
    func url() -> String
    {
        var server = ""
        
        if(!serverUrl.starts(with: "https")){
            let scheme = (serverSecure) ? "https" : "http"
            server = scheme + "://" + serverUrl
            
            if let url = URL(string:server) {
                let host = url.host!
                let path = url.path
                
                if serverPort == 443 {
                    return "\(scheme)://\(host)\(path)/"
                }
                
                return "\(scheme)://\(host):\(serverPort)\(path)/"
            }
        }else{
            
            if(serverUrl.hasSuffix("/")){
                return serverUrl
            }else{
                return "\(serverUrl)/"
            }
        }
        
        return server
    }
}
