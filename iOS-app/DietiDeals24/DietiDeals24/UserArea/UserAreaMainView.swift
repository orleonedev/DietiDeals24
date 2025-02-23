//
//  UserAreaMainView.swift
//  DietiDeals24
//
//  Created by Oreste Leone on 2/23/25.
//

import SwiftUI

struct UserAreaMainView: View, LoadableView {
    
    @State var viewModel: UserAreaMainViewModel
    
    init(viewModel: UserAreaMainViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        ScrollView {
            VStack {
                UserView(userModel: viewModel.userDataModel)
            }
        }
        .padding()
        .task {
            await viewModel.getUserData()
        }
        .scrollBounceBehavior(.basedOnSize)
        .animation(.easeInOut, value: viewModel.userDataModel)
        .navigationBarTitleDisplayMode(.large)
        .navigationTitle(Text("Personal Area"))
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu("More", systemImage: "ellipsis.circle") {
                    Button(role: .destructive){
                        
                    } label: {
                        Label("Logout", systemImage: "rectangle.portrait.and.arrow.right")
                        }
                }
            }
        }
    }
}


#Preview {
    NavigationStack{
        UserAreaMainView(viewModel: .init(coordinator: .init(appContainer: .init())))
    }
}
