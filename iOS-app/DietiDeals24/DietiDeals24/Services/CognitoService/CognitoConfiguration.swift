//
//  CognitoConfiguration.swift
//  DietiDeals24
//
//  Created by Oreste Leone on 2/2/25.
//

import Foundation

struct CognitoConfiguration {
    
    static var url: String {
        guard let cognitoUrl = ProcessInfo.processInfo.environment["COGNITO_URL"] else {
            return ""
        }
        return cognitoUrl
    }
    
    static var clientId: String {
        guard let clientId = ProcessInfo.processInfo.environment["COGNITO_CLIENTID"] else {
            return ""
        }
        return clientId
    }
    
}
