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

struct CognitoAuthResponse: Codable {
    let authenticationResult: AuthResult?
}

struct AuthResult: Codable {
    let idToken: String?
    let accessToken: String?
    let refreshToken: String?
}

enum CognitoEndpoint: Codable {
    case login(username: String, password: String)
    case signUp
    case confirmSignUp
    case forgotPassword
    case confirmForgotPassword
    case resendConfirmationCode
    
}

extension CognitoEndpoint {
    var endpoint: EndpointConvertible {
        switch self {
            case .login(let username, let pswrd):
                return Self.getLoginEndpoint(username: username, password: pswrd)
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
    
}
