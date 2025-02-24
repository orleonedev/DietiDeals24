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
    var role: UserRole
    var shortBio: String? = nil
    var url: String? = nil
    var auctionCreated: Int? = nil
    var joinedSince: Date? = nil
    var geoLocation: String? = nil
}

enum UserRole: Int {
    case buyer = 0
    case seller = 1
}

struct UserDetailView: View {
    
    let userModel: UserDataModel?
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            VStack(alignment: .leading, spacing: 24){
                header()
                
                if userModel?.role == .seller {
                    Text(userModel?.shortBio ?? "")
                        .font(.body)
                        .transition(.opacity)
                    
                    Button {
                        
                    } label: {
                        HStack {
                            Image(systemName: "link")
                                .font(.headline)
                            Text(userModel?.url ?? "--")
                                .font(.headline)
                        }
                    }
                    
                    HStack {
                        Button {
                            
                        } label: {
                            Text("Email")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundStyle(.white)
                                .padding(.vertical, 8)
                                .frame(maxWidth: .infinity)
                                .background(.accent)
                                .clipShape(.rect(cornerRadius: 12))
                        }
                        
                    }
                }
            }
            
            
        }
        
    }
}

extension UserDetailView {
    @ViewBuilder
    func header() -> some View {
        HStack(spacing: 12) {
            Image(systemName: "person.circle.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .foregroundColor(.secondary)
                .frame(width: 80, height: 80)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("@\(userModel?.username ?? "---")")
                    .font(.title2)
                    .fontWeight(.bold)
                    .transition(.opacity)
                
                Text(userModel?.name ?? "---")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .transition(.opacity)
                if userModel?.role == .buyer {
                    Text(userModel?.email ?? "---")
                        .font(.body)
                        .transition(.opacity)
                } else {
                    Text("Joined since \(userModel?.joinedSince?.formatted(date: .abbreviated, time: .omitted) ?? "--")")
                        .font(.callout)
                        .transition(.opacity)
                    
                    Text("Auctions Created: \(userModel?.auctionCreated?.formatted() ?? "--")")
                        .font(.callout)
                        .transition(.opacity)
                    
                    Text(userModel?.geoLocation ?? "---")
                        .font(.callout)
                        .transition(.opacity)
                }
            }
            Spacer()
        }
    }
}

#Preview {
    ScrollView {
        UserDetailView(userModel: .init(name: "Oreste", username: "oreste_leone", email: "oreste@oreste.com", role: .seller, shortBio: "Lorem Ipsum", url: "https://orleonedev.github.io", joinedSince: .now, geoLocation: "Napoli"))
    }
    .padding()
}
