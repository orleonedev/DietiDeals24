//
//  AuctionListView.swift
//  DietiDeals24
//
//  Created by Oreste Leone on 3/14/25.
//

import SwiftUI

public struct NotificationListView: View {
    
    var notificationList: [NotificationModel]
    var mainHeader: String = ""
    var additionalInfo: String = ""
    var onTapCallBack: ((UUID) -> Void)?
    var shouldFetchMore: Bool = true
    var fetchCallBack: (() -> Void)?
    
    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    if !mainHeader.isEmpty {
                        Text(mainHeader)
                            .font(.title2)
                            .lineLimit(1)
                            .fontWeight(.semibold)
                    }
                    Spacer()
                    if !additionalInfo.isEmpty {
                        Text(additionalInfo)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .lineLimit(1)
                            .multilineTextAlignment(.trailing)
                    }
                }
                
                LazyVStack(alignment: .leading ,spacing: 16) {
                    ForEach(notificationList, id: \.id) { notification in
                        NotificationCard(notification: notification, onTap: onTapCallBack)
                            
                    }
                    ZStack(alignment: .center){
                        Color.clear.ignoresSafeArea(.all)
                        ProgressView()
                            .progressViewStyle(.circular)
                            .opacity(shouldFetchMore ? 1 : 0)
                            .onAppear {
                                if shouldFetchMore {
                                    fetchCallBack?()
                                }
                            }
                    }
                    .ignoresSafeArea(.all)
                }
                
            }
            .padding(.horizontal)
        }
    }
}

