//
//  CognitoAuthServiceModels.swift
//  DietiDeals24
//
//  Created by Oreste Leone on 2/2/25.
//

import Foundation

struct CognitoAuthRequestBody: Codable, BodyParameters {
    let authFlow: String
    let authParameters: [String: String]
    let clientId: String
}

enum CognitoLoginMethods {
    case usernamePassword(username: String, password: String)
    case provider(provider: String, token: String)
    case refreshToken(refreshToken: String)
}

struct CognitoAuthResponse: AuthServiceResponse {
    var authResult: AuthTokenSession
}

enum CognitoEndpoint {
    case login(method: CognitoLoginMethods)
    case signUp
    case confirmSignUp
    case forgotPassword
    case confirmForgotPassword
    case resendConfirmationCode
    
}

extension CognitoEndpoint {
    var endpoint: EndpointConvertible {
        switch self {
            case .login(let method):
                switch method {
                    case .usernamePassword(let username, let pswrd):
                        return Self.getLoginEndpoint(username: username, password: pswrd)
                    case .provider(let provider, let token):
                        return Self.getLoginEndpoint(provider: provider, token: token)
                    case .refreshToken(let refreshToken):
                        return Self.getLoginEndpoint(refreshToken: refreshToken)
                }
//            case .signUp:
//                break
//            case .confirmSignUp:
//                break
//            case .forgotPassword:
//                break
//            case .confirmForgotPassword:
//                break
//            case .resendConfirmationCode:
//                break
            @unknown default:
                return Endpoint(baseURL: URL(string: "")!, path: "")
        }
    }
    
    static func getLoginEndpoint(username: String, password: String) -> CodableEndpoint<CognitoAuthResponse> {
        
        let clientId = CognitoConfiguration.clientId
        let baseURLString = URL(string: CognitoConfiguration.url)!
        let httpMethod = HTTPMethod.post
        let encoding = Endpoint.Encoding.json
        let headers: [String: String] = [
            "X-Amz-Target": "AWSCognitoIdentityProviderService.InitiateAuth"
        ]
        let body = CognitoAuthRequestBody(
            authFlow: "USER_PASSWORD_AUTH",
            authParameters: [
                "USERNAME" : username,
                "PASSWORD" : password
            ],
            clientId: clientId
        ).jsonObject
        
        return CodableEndpoint<CognitoAuthResponse>(
            Endpoint(
                baseURL: baseURLString,
                path: "",
                parameters: body ?? [:],
                encoding: encoding,
                method: httpMethod,
                headers: headers
            )
        )
    }
    
    static func getLoginEndpoint(provider: String, token: String) -> CodableEndpoint<CognitoAuthResponse> {
        let clientId = CognitoConfiguration.clientId
        let baseURLString = URL(string: CognitoConfiguration.url)!
        let httpMethod = HTTPMethod.post
        let encoding = Endpoint.Encoding.json
        let headers: [String: String] = [
            "X-Amz-Target": "AWSCognitoIdentityProviderService.InitiateAuth"
        ]
        let body = CognitoAuthRequestBody(
            authFlow: "USER_SRP_AUTH",
            authParameters: [
                "USERNAME": provider + "_" + UUID().uuidString,  // Unique identifier for federated login
                "IDP_TOKEN": token
            ],
            clientId: clientId
        ).jsonObject
        
        return CodableEndpoint<CognitoAuthResponse>(
            Endpoint(
                baseURL: baseURLString,
                path: "",
                parameters: body ?? [:],
                encoding: encoding,
                method: httpMethod,
                headers: headers
            )
        )
    }
    
    static func getLoginEndpoint(refreshToken: String) -> CodableEndpoint<CognitoAuthResponse> {
        let clientId = CognitoConfiguration.clientId
        let baseURLString = URL(string: CognitoConfiguration.url)!
        let httpMethod = HTTPMethod.post
        let encoding = Endpoint.Encoding.json
        let headers: [String: String] = [
            "X-Amz-Target": "AWSCognitoIdentityProviderService.InitiateAuth"
        ]
        let body = CognitoAuthRequestBody(
            authFlow: "REFRESH_TOKEN_AUTH",
            authParameters: [
                "REFRESH_TOKEN": refreshToken
            ],
            clientId: clientId
        ).jsonObject
        
        return CodableEndpoint<CognitoAuthResponse>(
            Endpoint(
                baseURL: baseURLString,
                path: "",
                parameters: body ?? [:],
                encoding: encoding,
                method: httpMethod,
                headers: headers
            )
        )
    }
    
}
