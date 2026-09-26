//
//  HMAAppDelegate.swift
//  HomeMaintenanceAssistant
//
//  Application entry point. Programmatic UI, no main storyboard.
//

import UIKit

@main
final class HMAAppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Open the database and seed bundled maintenance content on first run.
        HMADatabaseManager.shared.HMAprepareStore()
        HMATheme.HMAapplyGlobalAppearance()
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication,
                     configurationForConnecting connectingSceneSession: UISceneSession,
                     options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
}
