//
//  HMATheme.swift
//  HomeMaintenanceAssistant
//
//  Centralised design language: Deep Navy base, Light Gray surfaces,
//  Orange accent. A "Modern Utility" look distinct from any other app.
//

import UIKit

enum HMATheme {

    // MARK: - Core palette

    /// Deep navy — primary brand colour, used for headers and the tab bar.
    static let navy = UIColor(red: 0.078, green: 0.137, blue: 0.235, alpha: 1.0)      // #14233C
    /// Slightly lighter navy for raised navy surfaces.
    static let navyRaised = UIColor(red: 0.114, green: 0.180, blue: 0.290, alpha: 1.0) // #1D2E4A
    /// Warm orange accent for actions, highlights and progress.
    static let accent = UIColor(red: 0.949, green: 0.494, blue: 0.149, alpha: 1.0)     // #F27E26
    /// Muted orange for subtle accent fills.
    static let accentSoft = UIColor(red: 0.984, green: 0.890, blue: 0.808, alpha: 1.0) // #FBE3CE

    // MARK: - Semantic, dark-mode aware

    static var screenBackground: UIColor {
        HMAdynamic(light: UIColor(red: 0.949, green: 0.957, blue: 0.969, alpha: 1.0),  // light gray
                   dark: UIColor(red: 0.063, green: 0.094, blue: 0.149, alpha: 1.0))
    }

    static var cardBackground: UIColor {
        HMAdynamic(light: .white,
                   dark: UIColor(red: 0.106, green: 0.149, blue: 0.227, alpha: 1.0))
    }

    static var primaryText: UIColor {
        HMAdynamic(light: navy, dark: UIColor(white: 0.96, alpha: 1.0))
    }

    static var secondaryText: UIColor {
        HMAdynamic(light: UIColor(red: 0.40, green: 0.44, blue: 0.51, alpha: 1.0),
                   dark: UIColor(red: 0.62, green: 0.67, blue: 0.74, alpha: 1.0))
    }

    static var hairline: UIColor {
        HMAdynamic(light: UIColor(red: 0.89, green: 0.91, blue: 0.93, alpha: 1.0),
                   dark: UIColor(red: 0.20, green: 0.25, blue: 0.33, alpha: 1.0))
    }

    // MARK: - Status colours

    static let overdue = UIColor(red: 0.847, green: 0.255, blue: 0.255, alpha: 1.0)   // red
    static let dueSoon = accent
    static let completed = UIColor(red: 0.180, green: 0.659, blue: 0.451, alpha: 1.0) // green

    // MARK: - Metrics

    static let cornerRadius: CGFloat = 16
    static let cardSpacing: CGFloat = 14
    static let screenInset: CGFloat = 18

    // MARK: - Typography

    static func titleFont(_ size: CGFloat, weight: UIFont.Weight = .bold) -> UIFont {
        UIFont.systemFont(ofSize: size, weight: weight)
    }

    static func roundedFont(_ size: CGFloat, weight: UIFont.Weight = .semibold) -> UIFont {
        if let descriptor = UIFont.systemFont(ofSize: size, weight: weight)
            .fontDescriptor.withDesign(.rounded) {
            return UIFont(descriptor: descriptor, size: size)
        }
        return UIFont.systemFont(ofSize: size, weight: weight)
    }

    // MARK: - Helpers

    static func HMAdynamic(light: UIColor, dark: UIColor) -> UIColor {
        UIColor { traits in traits.userInterfaceStyle == .dark ? dark : light }
    }

    /// Applies the navy/orange chrome to nav bars and tab bars app-wide.
    static func HMAapplyGlobalAppearance() {
        let nav = UINavigationBarAppearance()
        nav.configureWithOpaqueBackground()
        nav.backgroundColor = navy
        nav.titleTextAttributes = [
            .foregroundColor: UIColor.white,
            .font: titleFont(17, weight: .semibold)
        ]
        nav.largeTitleTextAttributes = [
            .foregroundColor: UIColor.white,
            .font: titleFont(30, weight: .heavy)
        ]
        UINavigationBar.appearance().standardAppearance = nav
        UINavigationBar.appearance().scrollEdgeAppearance = nav
        UINavigationBar.appearance().compactAppearance = nav
        UINavigationBar.appearance().tintColor = .white

        let tab = UITabBarAppearance()
        tab.configureWithOpaqueBackground()
        tab.backgroundColor = navy
        let item = tab.stackedLayoutAppearance
        item.normal.iconColor = UIColor(white: 0.62, alpha: 1.0)
        item.normal.titleTextAttributes = [.foregroundColor: UIColor(white: 0.62, alpha: 1.0)]
        item.selected.iconColor = accent
        item.selected.titleTextAttributes = [.foregroundColor: accent]
        UITabBar.appearance().standardAppearance = tab
        if #available(iOS 15.0, *) {
            UITabBar.appearance().scrollEdgeAppearance = tab
        }
    }
}
