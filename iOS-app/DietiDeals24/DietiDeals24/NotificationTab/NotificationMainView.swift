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
        NotificationListView(notificationList: viewModel.notifications, additionalInfo: viewModel.notificationCount.formatted(), onTapCallBack: viewModel.getAuctionDetail, shouldFetchMore: viewModel.shouldFetchMoreNotifications, fetchCallBack: viewModel.getNotifications)
        .refreshable {
            viewModel.refreshData()
        }
        .padding(.top)
        .task {
            if viewModel.notifications.isEmpty {
                viewModel.refreshData()
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
    vm.notificationCount = not.count
    
    return NavigationStack{NotificationMainView(viewModel: vm)}
}
