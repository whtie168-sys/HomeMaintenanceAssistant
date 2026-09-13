//
//  HMASceneDelegate.swift
//  HomeMaintenanceAssistant
//
//  Builds the root interface programmatically and adapts to iPhone / iPad.
//

import UIKit

final class HMASceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }

        let newWindow = UIWindow(windowScene: windowScene)
        newWindow.rootViewController = HMARootBuilder.HMAmakeRootController(for: windowScene.traitCollection)
        newWindow.tintColor = HMATheme.accent
        newWindow.makeKeyAndVisible()
        HMAThemePreference.HMArestore(to: newWindow)
        self.window = newWindow
    }
}
