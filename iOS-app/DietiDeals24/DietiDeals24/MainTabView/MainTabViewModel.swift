//
//  MainTabViewModel.swift
//  DietiDeals24
//
//  Created by Oreste Leone on 2/23/25.
//
import SwiftUI

@Observable
class MainTabViewModel: LoadableViewModel {
    
    var isLoading: Bool = false
    var activeTab: Int = 0 {
        willSet {
            previousTabIndex = self.activeTab
        }
    }
    var previousTabIndex: Int?
    
    let mainCoordinator: MainTabCoordinator
    
    init(mainCoordinator: MainTabCoordinator) {
        self.mainCoordinator = mainCoordinator
    }
    
    @MainActor
    func sellCheck() {
//        mainCoordinator.becomeAVendor(onDismiss: {
//            self.activeTab = self.previousTabIndex ?? 0
//            self.previousTabIndex = self.activeTab
//        })
    }
    
}
