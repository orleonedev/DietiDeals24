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
    var userID: String? = nil
    var vendorId: String? = nil
    var shortBio: String? = nil
    var url: String? = nil
    var successfulAuctions: Int? = nil
    var joinedSince: Date? = nil
    var geoLocation: String? = nil
}

enum UserRole: Int {
    case buyer = 0
    case seller = 1
}

struct UserDetailView: View {
    
    let userModel: UserDataModel?
    let isPersonalAccount: Bool
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            VStack(alignment: .leading, spacing: 24){
                let role: UserRole = userModel?.role == .seller ? .seller : .buyer
                
                header(role: role)
                
                if userModel?.role == .seller {
                    if let shortBio = userModel?.shortBio, !shortBio.isEmpty {
                        Text(shortBio)
                            .font(.body)
                            .transition(.opacity)
                        
                    }
                    
                    if let url = userModel?.url, !url.isEmpty {
                        Button {
                            openWebsite(urlString: url)
                        } label: {
                            HStack {
                                Image(systemName: "link")
                                    .font(.headline)
                                Text(url)
                                    .font(.headline)
                            }
                        }
                    }
                    
                    if !isPersonalAccount {
                        HStack {
                            Button {
                                guard let email = userModel?.email else { return }
                                self.sendEmail(recipient: email)
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
}

extension UserDetailView {
    
    private func sendEmail(recipient: String) {
        let email = "mailto:\(recipient)"
        if let url = URL(string: email), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
    
    private func openWebsite(urlString: String) {
        if let url = URL(string: urlString), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
}

extension UserDetailView {
    @ViewBuilder
    func header(role: UserRole) -> some View {
        HStack(spacing: 12) {
            Image(systemName: role == .seller ? "person.badge.shield.checkmark.fill" :  "person.fill")
                .resizable()
                .padding()
                .aspectRatio(contentMode: .fit)
                .foregroundColor(.white )
                .background(Color.secondary)
                .clipShape(Circle())
                .frame(width: 80, height: 80)
            
            
            VStack(alignment: .leading, spacing: 4) {
                if let username = userModel?.username {
                    Text("@\(username)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .lineLimit(1)
                        .transition(.opacity)
                } else {
                    Text("@------------")
                        .font(.title2)
                        .fontWeight(.bold)
                        .lineLimit(1)
                        .redacted(reason: .placeholder)
                        .transition(.opacity)
                }
                
                if let name = userModel?.name {
                    Text(name)
                        .font(.title3)
                        .fontWeight(.semibold)
                        .transition(.opacity)
                    
                } else {
                    Text("------")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .redacted(reason: .placeholder)
                        .transition(.opacity)
                }
                if userModel?.role == .buyer {
                    Text(userModel?.email ?? "---")
                        .font(.body)
                        .transition(.opacity)
                } else if userModel?.role == .seller {
                    Text("Joined since \(userModel?.joinedSince?.formatted(date: .abbreviated, time: .omitted) ?? "--")")
                        .font(.callout)
                        .transition(.opacity)
                    
                    Text("Successful Auctions: \(userModel?.successfulAuctions?.formatted() ?? "--")")
                        .font(.callout)
                        .transition(.opacity)
                    
                    if let geoLocation = userModel?.geoLocation, !geoLocation.isEmpty {
                        Text("\(Image(systemName: "mappin.and.ellipse")) \(geoLocation)")
                            .font(.callout)
                            .transition(.opacity)
                    }
                }
            }
            Spacer()
        }
    }
}

#Preview {
    ScrollView {
        VStack(spacing: 32){
            UserDetailView(userModel: .init(name: "Empty", username: "empty_empty", email: "empty@empty.com", role: .seller, shortBio: "", url: "", joinedSince: .now, geoLocation: ""), isPersonalAccount: false)
            UserDetailView(userModel: .init(name: "Oreste", username: "oreste_leone", email: "oreste@oreste.com", role: .seller, shortBio: "Lorem Ipsum", url: "https://orleonedev.github.io", joinedSince: .now, geoLocation: "Napoli"), isPersonalAccount: false)
            UserDetailView(userModel: .init(name: "Buyer", username: "the_buyer", email: "buyer@buyer.com", role: .buyer), isPersonalAccount: true)
            
            UserDetailView(userModel: nil, isPersonalAccount: false)
        }
    }
    .padding()
}
