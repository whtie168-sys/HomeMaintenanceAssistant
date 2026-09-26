//
//  MainTabBarController.swift
//  Bearing Atlas Pro
//
//  Fixed five-tab structure. Each list tab is wrapped in its own
//  navigation controller for push navigation (iPhone single column).
//  Tabs: Faults, Knowledge, Maintenance, Records, Settings.
//

import UIKit

final class BAEPMainTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        configureAppearance()
        configureTabs()
    }

    private func configureTabs() {
        let faults = nav(BAEPFaultsViewController(),
                         title: "Faults", symbol: "exclamationmark.triangle.fill")
        let knowledge = nav(BAEPGatewayViewController(kind: .knowledge),
                            title: "Knowledge", symbol: "book.closed.fill")
        let maintenance = nav(BAEPGatewayViewController(kind: .maintenance),
                              title: "Maintenance", symbol: "wrench.and.screwdriver.fill")
        let records = nav(BAEPRecordsViewController(),
                          title: "Records", symbol: "tray.full.fill")
        let settings = nav(BAEPSettingsViewController(),
                           title: "Settings", symbol: "gearshape.fill")

        viewControllers = [faults, knowledge, maintenance, records, settings]
        selectedIndex = 0   // navigation always starts from Faults
    }

    private func nav(_ root: UIViewController, title: String, symbol: String) -> UINavigationController {
        let nc = UINavigationController(rootViewController: root)
        nc.tabBarItem = UITabBarItem(title: title,
                                     image: UIImage(systemName: symbol),
                                     selectedImage: UIImage(systemName: symbol))
        styleNav(nc.navigationBar)
        return nc
    }

    // MARK: - Appearance (industrial navy / orange)

    private func configureAppearance() {
        let tab = UITabBarAppearance()
        tab.configureWithOpaqueBackground()
        tab.backgroundColor = BAEPTheme.navySurface
        tab.shadowColor = BAEPTheme.steelLine

        let item = tab.stackedLayoutAppearance
        item.normal.iconColor = BAEPTheme.steel
        item.normal.titleTextAttributes = [.foregroundColor: BAEPTheme.steel,
                                            .font: BAEPTheme.mono(10, .medium)]
        item.selected.iconColor = BAEPTheme.orange
        item.selected.titleTextAttributes = [.foregroundColor: BAEPTheme.orange,
                                              .font: BAEPTheme.mono(10, .bold)]

        tabBar.standardAppearance = tab
        if #available(iOS 15.0, *) {
            tabBar.scrollEdgeAppearance = tab
        }
        tabBar.tintColor = BAEPTheme.orange
    }

    private func styleNav(_ bar: UINavigationBar) {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = BAEPTheme.navy
        appearance.shadowColor = BAEPTheme.steelLine
        appearance.titleTextAttributes = [.foregroundColor: BAEPTheme.textPrimary,
                                          .font: BAEPTheme.font(17, .bold)]
        appearance.largeTitleTextAttributes = [.foregroundColor: BAEPTheme.textPrimary,
                                              .font: BAEPTheme.font(32, .heavy)]
        bar.standardAppearance = appearance
        bar.scrollEdgeAppearance = appearance
        bar.compactAppearance = appearance
        bar.tintColor = BAEPTheme.orange
    }
}
