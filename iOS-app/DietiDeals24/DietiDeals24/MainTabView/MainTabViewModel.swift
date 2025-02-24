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
            if newValue == 2 {
                self.sellerCheck()
            }
        }
    }
    
    var previousTabIndex: Int?
    
    let mainCoordinator: MainTabCoordinator
    
    init(mainCoordinator: MainTabCoordinator) {
        self.mainCoordinator = mainCoordinator
    }
    
    
    func sellerCheck() {
        Task {
            let isSeller = await mainCoordinator.sellerStatusCheck()
            if !(isSeller ?? false) {
                await mainCoordinator.becomeAVendor(onDismiss: {
                    self.activeTab = self.previousTabIndex ?? 0
                    self.previousTabIndex = self.activeTab
                })
            }
        }
    }
    
}
