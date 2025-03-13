//
//  ContentView.swift
//  DietiDeals24
//
//  Created by Oreste Leone on 26/11/24.
//

import SwiftUI

struct ContentView: View {
    @State var appState: AppState
    var env: String {
#if DEV
        return "dev"
        #else
        return "prod"
#endif
    }
    var body: some View {
        
            ZStack(alignment: .topLeading){
                Color.clear
                Button("Revoke Cred") {
                    appState.revokeCredentials()
                }
                .buttonStyle(.bordered)
                VStack(alignment: .center) {
                    Spacer()
                    Image(systemName: "globe")
                        .imageScale(.large)
                        .foregroundStyle(.dietiYellow)
                    Text("Hello, \(env)!")
                    Text("This is the start of cognito setup")
                    Spacer()
                }
                .frame(maxWidth: .infinity)
                .padding()
            }
            .padding()
    }
}

#Preview {
    ContentView(appState: .init(credentialService: KeychainCredentialService(), authService: CognitoAuthService(rest: DefaultRESTDataSource()), notificationService: DefaultNotificationService(rest: DefaultRESTDataSource())))
}
