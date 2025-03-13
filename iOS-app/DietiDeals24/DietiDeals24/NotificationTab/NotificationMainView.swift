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
            LazyVStack(alignment: .leading, spacing: 16) {
                ForEach(viewModel.notifications, id: \.id) { notification in
                    NotificationCard(notification: notification, onTap: viewModel.getAuctionDetail)
                }
            }
            .padding(.horizontal)
            
        }
        .refreshable {
            await viewModel.getNotifications()
        }
        .padding(.top)
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

#Preview {
    @Previewable @State var vm =  NotificationMainViewModel(coordinator: NotificationCoordinator(appContainer: .init()), notificationService: DefaultNotificationService(rest: DefaultRESTDataSource()), auctionService: DefaultAuctionService(rest: DefaultRESTDataSource()))
    let not = (0...10).map { index in NotificationModel(id: UUID(), title: "Title \(index)", message: "Message \(index)", date: Date.now, auctionId: UUID(), auctionName: "Auction name \(index)", imageUrl: "")}
    vm.notifications = not
    
    return NavigationStack{NotificationMainView(viewModel: vm)}
}
