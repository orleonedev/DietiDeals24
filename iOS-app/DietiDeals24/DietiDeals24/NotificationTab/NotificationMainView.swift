//
//  NotificationMainView.swift
//  DietiDeals24
//
//  Created by Oreste Leone on 3/11/25.
//

import SwiftUI

public struct NotificationMainView: View, LoadableView {
    
    @State var viewModel: NotificationMainViewModel
    
    public var body: some View {
        ScrollView{
            LazyVStack(alignment: .leading, spacing: 12) {
                ForEach(viewModel.notifications, id: \.id) { notification in
                    NotificationCard(notification: notification, onTap: viewModel.getAuctionDetail)
                }
            }
            
        }
        .refreshable {
            await viewModel.getNotifications()
        }
        .task {
            if viewModel.notifications.isEmpty {
                await viewModel.getNotifications()
            }
        }
        .overlay {
            if viewModel.notifications.isEmpty && !viewModel.isFetchingNotifications {
                ContentUnavailableView("No notifications", systemImage: "bell.fill", description: Text("If you haven't received any notifications yet, please try again later.")
                )
            } else {
                loaderView()
            }
        }
        .navigationTitle("Notifications")
    }
    
}
