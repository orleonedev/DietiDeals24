//
//  NetworkConfiguration.swift
//  DietiDeals24
//
//  Created by Oreste Leone on 3/4/25.
//

import Foundation

struct NetworkConfiguration {
    
    static var backendBaseUrl: String {
        guard let backendBaseUrl = Bundle.main.object(forInfoDictionaryKey: "BACKEND_BASE_URL") as? String else {
            return ""
        }
#if DEV
        return "http://"+backendBaseUrl
#else
        return "http://"+backendBaseUrl
#endif
    }
    
    
}
