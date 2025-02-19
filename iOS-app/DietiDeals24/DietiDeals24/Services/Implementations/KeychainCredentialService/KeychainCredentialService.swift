//
//  KeychainCredentialService.swift
//  DietiDeals24
//
//  Created by Oreste Leone on 05/02/25.
//

class KeychainCredentialService: CredentialService {
    
    private enum KeychainKeys: String, CaseIterable {
        case accessToken
        case idToken
        case refreshToken
    }
    
    func store(credentials: TokenCredentials) {
        Logger.log("Storing credentials in keychain -> \(credentials)", level: .verbose, tag: .credentialService)
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
            Logger.log("Access Token -> \(self._accessToken ?? "")", level: .verbose, tag: .credentialService)
            return self._accessToken
        }
        Logger.log("Access Token -> \(accessToken)", level: .verbose, tag: .credentialService)
        return accessToken
    }
    
    func getRefreshToken() -> String? {
        let rf = self.getTokenInKeychain(.refreshToken)
        Logger.log("refresh Token -> \(rf ?? "")", level: .verbose, tag: .credentialService)
        return rf
    }
    
    func getIdToken() -> String? {
        guard let idToken = self._idToken, !idToken.isEmpty else {
            self._idToken = getTokenInKeychain(.idToken)
            Logger.log("ID Token -> \(self._idToken ?? "")", level: .verbose, tag: .credentialService)
            return self._idToken
        }
        Logger.log("ID Token -> \(idToken)", level: .verbose, tag: .credentialService)
        return idToken
    }
    
    func clearCredentials() {
        Logger.log("clearCredentials", level: .verbose, tag: .credentialService)
        KeychainKeys.allCases.forEach { key in
            KeychainWrapper.removeData(key: key.rawValue)
            Logger.log("\(key) removed", level: .verbose, tag: .credentialService)
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
