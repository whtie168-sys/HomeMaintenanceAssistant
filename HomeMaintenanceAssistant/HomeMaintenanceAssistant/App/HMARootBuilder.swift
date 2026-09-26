//
//  HMARootBuilder.swift
//  HomeMaintenanceAssistant
//
//  Assembles the root shell: a custom leading icon rail (HMARailController)
//  hosting each module. The Areas module uses a split view on iPad.
//

import UIKit

enum HMARootBuilder {

    static func HMAmakeRootController(for traits: UITraitCollection) -> UIViewController {
        let items: [HMARailItem] = [
            HMARailItem(title: "Home", icon: "square.grid.2x2.fill",
                        viewController: HMAwrap(HMADashboardViewController())),
            HMARailItem(title: "Areas", icon: "house.lodge.fill",
                        viewController: HMAmakeAreasController()),
            HMARailItem(title: "Tasks", icon: "checklist",
                        viewController: HMAwrap(HMATaskListViewController())),
            HMARailItem(title: "Records", icon: "tray.full.fill",
                        viewController: HMAwrap(HMARecordsViewController())),
            HMARailItem(title: "Settings", icon: "gearshape.fill",
                        viewController: HMAwrap(HMASettingsViewController()))
        ]
        return HMARailController(items: items)
    }

    // MARK: - Areas (split view on iPad, push nav on iPhone)

    private static func HMAmakeAreasController() -> UIViewController {
        let areasVC = HMAAreasViewController()

        if UIDevice.current.userInterfaceIdiom == .pad {
            let split = UISplitViewController(style: .doubleColumn)
            split.preferredDisplayMode = .oneBesideSecondary

            let primaryNav = UINavigationController(rootViewController: areasVC)
            let placeholder = HMAPlaceholderDetailViewController()
            let secondaryNav = UINavigationController(rootViewController: placeholder)

            areasVC.HMAonSelectArea = { [weak split] area in
                let detail = HMATaskListViewController(area: area)
                split?.setViewController(UINavigationController(rootViewController: detail), for: .secondary)
                split?.show(.secondary)
            }

            split.setViewController(primaryNav, for: .primary)
            split.setViewController(secondaryNav, for: .secondary)
            return split
        }

        return HMAwrap(areasVC)
    }

    private static func HMAwrap(_ vc: UIViewController) -> UINavigationController {
        let nav = UINavigationController(rootViewController: vc)
        nav.navigationBar.prefersLargeTitles = true
        return nav
    }
}

// MARK: - iPad placeholder detail

final class HMAPlaceholderDetailViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Select an Area"
        view.backgroundColor = HMATheme.screenBackground

        let icon = UIImageView(image: UIImage(systemName: "house.lodge"))
        icon.tintColor = HMATheme.secondaryText
        icon.contentMode = .scaleAspectFit
        let label = UILabel()
        label.text = "Choose a maintenance area to view its tasks."
        label.font = HMATheme.roundedFont(16, weight: .medium)
        label.textColor = HMATheme.secondaryText
        label.textAlignment = .center
        label.numberOfLines = 0

        let stack = UIStackView(arrangedSubviews: [icon, label])
        stack.axis = .vertical
        stack.spacing = 16
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stack.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 32),
            stack.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -32),
            icon.widthAnchor.constraint(equalToConstant: 64),
            icon.heightAnchor.constraint(equalToConstant: 64)
        ])
    }
}
