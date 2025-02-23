//
//  UserView.swift
//  DietiDeals24
//
//  Created by Oreste Leone on 2/23/25.
//
import SwiftUI

struct UserDataModel: Equatable {
    var name: String
    var username: String
    var email: String
}

struct UserView: View {
    
    let userModel: UserDataModel?
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            HStack {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(.secondary)
                    .padding()
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("@\(userModel?.username ?? "---")")
                        .font(.title2)
                        .fontWeight(.bold)
                        .transition(.opacity)
                    
                    Text(userModel?.name ?? "---")
                        .font(.body)
                        .fontWeight(.semibold)
                        .transition(.opacity)
                    Text(userModel?.email ?? "---")
                        .font(.body)
                        .transition(.opacity)
                }
                Spacer()
            }
            .frame(height: 96)
            
            
        }
        
    }
}

#Preview {
    ScrollView {
        UserView(userModel: .init(name: "Oreste", username: "oreste_leone", email: "oreste@oreste.com"))
    }
}
