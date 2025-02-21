//
//  CognitoAuthServiceModels.swift
//  DietiDeals24
//
//  Created by Oreste Leone on 2/2/25.
//

import Foundation

// MARK: - CognitoSignUpRequest
struct CognitoSignUpRequest: Codable, BodyParameters {
    let clientID: String?
    let password: String?
    let userAttributes: [CognitoUserAttribute]?
    let username: String?

    enum CodingKeys: String, CodingKey {
        case clientID = "ClientId"
        case password = "Password"
        case userAttributes = "UserAttributes"
        case username = "Username"
    }
}

// MARK: - UserAttribute
struct CognitoUserAttribute: Codable {
    let name, value: String?

    enum CodingKeys: String, CodingKey {
        case name = "Name"
        case value = "Value"
    }
}

enum CognitoUserAttributeFields {
    case birthdate, preferredUsername, email, name, role
    
    func asCognitoUserAttribute(value: String? = nil) -> CognitoUserAttribute {
        switch self {
            case .birthdate:
                return CognitoUserAttribute(name: "birthdate", value: value)
            case .preferredUsername:
                return CognitoUserAttribute(name: "preferred_username", value: value)
            case .email:
                return CognitoUserAttribute(name: "email", value: value)
            case .name:
                return CognitoUserAttribute(name: "name", value: value)
            case .role:
                return CognitoUserAttribute(name: "custom:role", value: value)
        }
    }
}

// MARK: - CognitoSignUpResponse
struct CognitoSignUpResponse: Codable, AuthServiceSignUpResponse {
    let codeDeliveryDetails: CognitoCodeDeliveryDetails?
    let userConfirmed: Bool?
    let session, userSub: String?

    enum CodingKeys: String, CodingKey {
        case codeDeliveryDetails = "CodeDeliveryDetails"
        case session = "Session"
        case userConfirmed = "UserConfirmed"
        case userSub = "UserSub"
    }
}

// MARK: - CodeDeliveryDetails
struct CognitoCodeDeliveryDetails: Codable {
    let attributeName, deliveryMedium, destination: String?

    enum CodingKeys: String, CodingKey {
        case attributeName = "AttributeName"
        case deliveryMedium = "DeliveryMedium"
        case destination = "Destination"
    }
}

struct CognitoAuthRequestBody: Codable, BodyParameters {
    let AuthFlow: String
    let AuthParameters: [String: String]
    let ClientId: String
}

enum CognitoLoginMethods {
    case usernamePassword(username: String, password: String)
    case provider(provider: String, token: String)
    case refreshToken(refreshToken: String)
}

struct CognitoAuthResponse: AuthServiceResponse {
    var authResult: CognitoTokenResult
    
    enum CodingKeys: String, CodingKey {
        case authResult = "AuthenticationResult"
    }
}

struct CognitoTokenResult: Codable, AuthTokenSessionGenerator {
    
    let accessToken: String?
    let expiresIn: Int?
    let idToken, refreshToken, tokenType: String?
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "AccessToken"
        case expiresIn = "ExpiresIn"
        case idToken = "IdToken"
        case refreshToken = "RefreshToken"
        case tokenType = "TokenType"
    }
    
    func generateSessionToken() -> AuthTokenSession {
        return .init(accessToken: accessToken, idToken: idToken, refreshToken: refreshToken)
    }
}

enum CognitoEndpoint {
    case login(method: CognitoLoginMethods)
    case signUp(model: UserSignUpAttributes)
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
            case .signUp( let model):
                return Self.getSignUpEndpoint(model: model)
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
        let encoding = Endpoint.Encoding.customWithBody("application/x-amz-json-1.1")
        let headers: [String: String] = [
            "X-Amz-Target": "AWSCognitoIdentityProviderService.InitiateAuth"
        ]
        let body = CognitoAuthRequestBody(
            AuthFlow: "USER_PASSWORD_AUTH",
            AuthParameters: [
                "USERNAME" : username,
                "PASSWORD" : password
            ],
            ClientId: clientId
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
        let encoding = Endpoint.Encoding.customWithBody("application/x-amz-json-1.1")
        let headers: [String: String] = [
            "X-Amz-Target": "AWSCognitoIdentityProviderService.InitiateAuth"
        ]
        let body = CognitoAuthRequestBody(
            AuthFlow: "USER_SRP_AUTH",
            AuthParameters: [
                "USERNAME": provider + "_" + UUID().uuidString,  // Unique identifier for federated login
                "IDP_TOKEN": token
            ],
            ClientId: clientId
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
        let encoding = Endpoint.Encoding.customWithBody("application/x-amz-json-1.1")
        let headers: [String: String] = [
            "X-Amz-Target": "AWSCognitoIdentityProviderService.InitiateAuth"
        ]
        let body = CognitoAuthRequestBody(
            AuthFlow: "REFRESH_TOKEN_AUTH",
            AuthParameters: [
                "REFRESH_TOKEN": refreshToken
            ],
            ClientId: clientId
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
    
    static func getSignUpEndpoint(model: UserSignUpAttributes) -> CodableEndpoint<CognitoSignUpResponse> {
        let clientId = CognitoConfiguration.clientId
        let baseURLString = URL(string: CognitoConfiguration.url)!
        let httpMethod = HTTPMethod.post
        let encoding = Endpoint.Encoding.customWithBody("application/x-amz-json-1.1")
        let headers: [String: String] = [
            "X-Amz-Target": "AWSCognitoIdentityProviderService.SignUp"
        ]
        
        let body = CognitoSignUpRequest(
            clientID: clientId,
            password: model.password,
            userAttributes: [
                CognitoUserAttributeFields.email.asCognitoUserAttribute(value: model.email),
                CognitoUserAttributeFields.name.asCognitoUserAttribute(value: model.name),
                CognitoUserAttributeFields.preferredUsername.asCognitoUserAttribute(value: model.preferredUsername),
                CognitoUserAttributeFields.birthdate.asCognitoUserAttribute(value: model.birthdate.formattedString("YYYY-MM-DD")),
                CognitoUserAttributeFields.role.asCognitoUserAttribute(value: "0")
            ],
            username: model.preferredUsername
        ).jsonObject
        
        return CodableEndpoint<CognitoSignUpResponse>(
            Endpoint(
                baseURL: baseURLString,
                path: "",
                parameters: body ?? [:],
                encoding: encoding,
                method: .post,
                headers: headers
            )
        )
    }
    
}
