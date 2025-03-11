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
            Text("NotificationMainView")
            
        }
        .refreshable {
            await viewModel.getNotifications()
        }
        .task {
            await viewModel.getNotifications()
        }
        .navigationTitle("Notifications")
    }
    
}
