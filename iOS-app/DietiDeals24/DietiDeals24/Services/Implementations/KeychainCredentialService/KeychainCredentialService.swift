//
//  KeychainCredentialService.swift
//  DietiDeals24
//
//  Created by Oreste Leone on 05/02/25.
//

actor KeychainCredentialService: CredentialService {
    
    private enum KeychainKeys: String, CaseIterable {
        case accessToken
        case idToken
        case refreshToken
    }
    
    func store(credentials: TokenCredentials) {
        self._accessToken = credentials.accessToken
        self._idToken = credentials.idToken
        if let accessToken = credentials.accessToken {
            self.setTokenInKeychain(.accessToken, value: accessToken)
        }
        if let idToken = credentials.idToken {
            self.setTokenInKeychain(.idToken, value: idToken)
        }
        if let refreshToken = credentials.refreshToken {
            self.setTokenInKeychain(.refreshToken, value: refreshToken)
        }
    }
    
    func getAccessToken() -> String? {
        guard let accessToken = self._accessToken, !accessToken.isEmpty else {
            self._accessToken = getTokenInKeychain(.accessToken)
            return self._accessToken
        }
        return accessToken
    }
    
    func getRefreshToken() -> String? {
        return self.getTokenInKeychain(.refreshToken)
    }
    
    func getIdToken() -> String? {
        guard let idToken = self._idToken, !idToken.isEmpty else {
            self._idToken = getTokenInKeychain(.idToken)
            return self._idToken
        }
        return idToken
    }
    
    func clearCredentials() {
        KeychainKeys.allCases.forEach { key in
            KeychainWrapper.removeData(key: key.rawValue)
        }
    }
    
    private var _accessToken: String?
    private var _idToken: String?

    
    private func getTokenInKeychain(_ key: KeychainKeys) -> String? {
        return KeychainWrapper.getData(key: key.rawValue)
    }
    
    private func setTokenInKeychain(_ key: KeychainKeys, value: String) {
        KeychainWrapper.saveData(key: key.rawValue, value: value)
    }
}
