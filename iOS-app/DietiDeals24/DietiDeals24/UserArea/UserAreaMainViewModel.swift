//
//  UserAreaMainViewModel.swift
//  DietiDeals24
//
//  Created by Oreste Leone on 2/23/25.
//
import SwiftUI

@Observable
class UserAreaMainViewModel: LoadableViewModel {
    
    var isLoading: Bool = false
    var coordinator: UserAreaCoordinator
    var userDataModel: UserDataModel? = nil
    
    init(coordinator: UserAreaCoordinator) {
        self.coordinator = coordinator
    }
    
    func getUserData() async {
        isLoading = true
        let user = await coordinator.getUserData()
        self.userDataModel = user
        isLoading = false
    }
    
    func logout() {
        Task {
            isLoading = true
            await self.coordinator.logout()
            isLoading = false
        }
    }
}
