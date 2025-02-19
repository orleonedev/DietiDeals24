//
//  CognitoConfiguration.swift
//  DietiDeals24
//
//  Created by Oreste Leone on 2/2/25.
//

import Foundation

struct CognitoConfiguration {
    
    static var url: String {
        guard let cognitoUrl = Bundle.main.object(forInfoDictionaryKey: "COGNITO_URL") as? String else {
            return ""
        }
        return "https://"+cognitoUrl
    }
    
    static var clientId: String {
        guard let clientId = Bundle.main.object(forInfoDictionaryKey: "COGNITO_CLIENTID") as? String else {
            return ""
        }
        return clientId
    }
    
}
