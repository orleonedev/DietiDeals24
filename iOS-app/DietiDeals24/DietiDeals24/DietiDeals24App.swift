//
//  DietiDeals24App.swift
//  DietiDeals24
//
//  Created by Oreste Leone on 26/11/24.
//
import UIKit
import UserNotifications
import SwiftUI

@main
struct DietiDeals24App: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @State var appContainer: AppContainer
    
    init() {
        self.appContainer = AppContainer()
        appDelegate.appContainer = self.appContainer
    }
    var body: some Scene {
        WindowGroup {
            AppRootView(appContainer: appContainer)
        }
    }
}

class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var appContainer: AppContainer?

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        return true
    }


    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenString = deviceToken.map { String(format: "%02x", $0) }.joined()
        print("Device Token: \(tokenString)")
        guard let appContainer = self.appContainer,
              let notificationService = appContainer.resolve(NotificationService.self),
              let credentialService = appContainer.resolve(CredentialService.self),
              let userId = UUID(uuidString: credentialService.getAccountModel()?.sub ?? "") else { return }
        Task {
            try? await notificationService.registerForRemoteNotifications(with: tokenString, forUser: userId)
        }
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register for remote notifications: \(error.localizedDescription)")
        
    }
    
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound, .badge])
    }
}
