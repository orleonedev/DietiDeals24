//
//  AuthenticationFlow.swift
//  DietiDeals24
//
//  Created by Oreste Leone on 13/02/25.
//

import RoutingKit
import SwiftUI

typealias AuthDestination = Destination

@Observable
class AuthenticationFlow {
    
    var isAuthenticated: Bool = false
    @MainActor static let authRouter = Router()
    
    @MainActor var root: some View {
        RoutableRootView(router: Self.authRouter) {
            SignInView()
        }
        
    }
}

extension AuthDestination {
    static let SignIn = Destination { SignInView() }
    static let SignUp = Destination { SignUpView() }
    static let CodeConfirmation = Destination { CodeVerificationView() }
}

